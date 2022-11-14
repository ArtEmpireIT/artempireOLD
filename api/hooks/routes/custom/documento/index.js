'use strict';

const express = require('express');
const router = express.Router();
const db = require('../../../../config/db');
const {bodyParse, parseJWT} = require('../../../../utils/middlewares');

router.get('/list', parseJWT, function(req, res, next) {

  let filter = '';
  if (req.query.q) {
    filter=` AND (
        tipo ILIKE '%${req.query.q}%'
        OR titulo ILIKE '%${req.query.q}%'
        OR nombre ILIKE '%${req.query.q}%'
        OR sigla ILIKE '%${req.query.q}%'
        OR signatura ILIKE '%${req.query.q}%'
      )`;
  }
  if (req.query.s) {
    filter += ` AND ( resumen ILIKE '%${req.query.s}%' )`;
  }
  if (req.query.t) {
    filter += ` AND ( transcripcion ILIKE '%${req.query.t}%' )`;
  }

  // const { access_history } = (req.user || {});
  const secretQuery = req.user ? '' : 'AND COALESCE(confidencial_datos, FALSE) = FALSE ';

  var query = `
    SELECT
    id_documento,
    tipo,
    subtipo,
    titulo,
    fecha_inicio,
    nombre,
    sigla,
    signatura,
    insertdatetime,
    css
    FROM (
      SELECT DISTINCT
        d.id_documento,
        d.tipo,
        d.subtipo,
        d.titulo,
        p.fecha_inicio,
        s.nombre,
        c.sigla,
        d.signatura,
        d.insertdatetime,
        d.resumen,
        d.transcripcion,
        CONCAT(c.sigla, CONCAT(', ', s.nombre, CONCAT(', ', d.signatura))) AS css
      FROM documento d
        LEFT JOIN pertenencia p ON (p.fk_documento_id=d.id_documento AND (p.tipo_atr_doc='Emisión' OR p.tipo_atr_doc='Creación Documento'))
        LEFT JOIN seccion s ON d.fk_seccion_id=s.id_seccion
        LEFT JOIN coleccion c ON c.nombre=s.fk_coleccion
        LEFT JOIN usuario u ON u.id_usuario=d.fk_usuario_id
      WHERE TRUE ${secretQuery}
      ORDER BY p.fecha_inicio ASC, titulo ASC
    ) q
    WHERE TRUE ${filter}
  `;


    db.query(query)
    .then(data => {
      res.status(200).send(data[0]);
    })
    .catch(error => {
      res.status(200).send([]);
    });

})


router.get('/basic/:id_documento', function(req, res, next){

  var query = `
  SELECT
    d.id_documento,
    d.tipo,
    d.subtipo,
    d.titulo,
    array_agg(kw.fk_keyword_palabra) as keywords,
    d.signatura,
    d.foliado,
    d.des_foliado,
    p.fecha_inicio as fecha_emision,
    p.precision_inicio as precision_fecha_emision,
    s.nombre as seccion,
    c.sigla,
    d.signatura,
    json_build_object(
      'nombre', marginalia.nombre,
      'descripcion', marginalia.descripcion) AS marginalia,
      json_build_object(
        'nombre', manode.nombre,
        'descripcion', manode.descripcion) AS manode
  FROM documento d
    LEFT JOIN pertenencia p ON (p.fk_documento_id=d.id_documento AND (p.tipo_atr_doc='Emisión' OR p.tipo_atr_doc='Creación Documento'))
    LEFT JOIN seccion s ON d.fk_seccion_id=s.id_seccion
    LEFT JOIN coleccion c ON c.nombre=s.fk_coleccion
    LEFT JOIN usuario u ON u.id_usuario=d.fk_usuario_id
    LEFT JOIN keyword_rel_documento kw ON kw.fk_documento_id=d.id_documento
    LEFT JOIN (
      SELECT
        ph.nombre,
        p.tipo_atr_doc,
        p.motivo,
        p.fk_documento_id
      FROM persona_rol_pertenencia prp JOIN pertenencia p ON prp.fk_pertenencia_id=p.id_pertenencia
      JOIN persona_historica ph ON prp.fk_persona_historica_id=ph.id_persona_historica)
      prh ON prh.fk_documento_id=d.id_documento

    LEFT JOIN (
      SELECT
        ph.nombre,
        p.tipo_atr_doc as descripcion,
        p.motivo,
        p.fk_documento_id
      FROM persona_rol_pertenencia prp
      JOIN persona_historica ph ON prp.fk_persona_historica_id=ph.id_persona_historica
      JOIN pertenencia p ON prp.fk_pertenencia_id=p.id_pertenencia
      WHERE p.tipo_atr_doc='Marginalia' LIMIT 1)
      marginalia ON marginalia.fk_documento_id=d.id_documento

      LEFT JOIN (
        SELECT
          ph.nombre,
          p.tipo_atr_doc as descripcion,
          p.motivo,
          p.fk_documento_id
        FROM persona_rol_pertenencia prp
        JOIN persona_historica ph ON prp.fk_persona_historica_id=ph.id_persona_historica
        JOIN pertenencia p ON prp.fk_pertenencia_id=p.id_pertenencia
        WHERE p.tipo_atr_doc='Mano_secretario' LIMIT 1)
        manode ON manode.fk_documento_id=d.id_documento

  WHERE d.id_documento=${req.params.id_documento}
  GROUP by id_documento, d.tipo, subtipo, titulo, signatura,
    foliado, des_foliado, fecha_emision, precision_fecha_emision,
    seccion, sigla, signatura, marginalia.nombre, marginalia.descripcion,
    manode.nombre, manode.descripcion
  `;

    db.query(query)
    .then(data => {
      res.status(200).send(data[0]);
    })
    .catch(error => {
      res.status(200).send([]);
    });

})

router.get('/dates/:id_documento', function(req, res, next){
  const query = `
    SELECT pem.fecha_inicio, pem.precision_inicio, prec.fecha_inicio as fecha_fin, prec.precision_inicio as precision_fin
    FROM documento d
    LEFT JOIN pertenencia pem ON (pem.fk_documento_id=d.id_documento AND (pem.tipo_atr_doc='Emisión' OR pem.tipo_atr_doc='Creación Documento'))
    LEFT JOIN pertenencia prec ON prec.fk_documento_id=d.id_documento AND prec.tipo_atr_doc='Recepción'
    WHERE d.id_documento=${req.params.id_documento}
  `;

  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(500).send([error]);
  });

});

router.get('/carta/:id_documento', function(req, res) {
  const query = `
    SELECT d.id_documento as id_document,
    
    ${selectHistoricPersonWithRole('Emisor', 'emitters')},
    ${selectHistoricPersonWithRole('Destinatario', 'recipients')}

    FROM documento d
    WHERE d.id_documento=${req.params.id_documento}
  `;

  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(500).send([error]);
  });

})

router.post('/save_carta', bodyParse, function(req, res, next){

  const query = `
    SELECT ae_add_carta(
      ${req.body.id_document},
      ${req.body.emitters!== 'ARRAY[]::text[]' ? req.body.emitters : 'ARRAY[]::json[]'},
      ${req.body.recipients!== 'ARRAY[]::text[]' ? req.body.recipients : 'ARRAY[]::json[]'}
    )
  `
  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(500).send([error]);
  });

});

router.get('/testamento/:id_documento', function(req, res) {
  const query = `
    SELECT d.id_documento as id_document, d.preambulo_testamento as preamble, d.disp_ente_testamento as burial_arrangement,

    ${selectHistoricPersonWithRole('Testamentario', 'testamentary')},
    ${selectHistoricPersonWithRole('Albacea', 'executor')},
    ${selectHistoricPersonWithRole('Heredero', 'heir')},
    ${selectHistoricPersonWithRole('Escribano', 'notary')},
    ${selectHistoricPersonWithRole('Testigo de emisión', 'witnesses_issue')},
    ${selectHistoricPersonWithRole('Testigo de apertura', 'witnesses_opening')},

    (SELECT coalesce(json_agg(mandas.jsonb_build_object), '[]'::json) as mandas FROM
      (
        SELECT jsonb_build_object('order', orden, 'description', motivo)
        FROM pertenencia
        WHERE fk_documento_id = d.id_documento AND tipo_atr_doc = 'Manda' ORDER BY orden
      ) as mandas)

    FROM documento d
    WHERE d.id_documento=${req.params.id_documento}
  `;

  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(500).send([error]);
  });

})

router.post('/save_testamento', bodyParse, function(req, res) {

  const query = `
    SELECT ae_add_testamento(
      ${req.body.id_document},
      ${req.body.testamentary!== 'ARRAY[]::text[]' ? req.body.testamentary : 'ARRAY[]::json[]'},
      ${req.body.executor!== 'ARRAY[]::text[]' ? req.body.executor : 'ARRAY[]::json[]'},
      ${req.body.heir!== 'ARRAY[]::text[]' ? req.body.heir : 'ARRAY[]::json[]'},
      ${req.body.notary!== 'ARRAY[]::text[]' ? req.body.notary : 'ARRAY[]::json[]'},
      ${req.body.witnesses_issue!== 'ARRAY[]::text[]' ? req.body.witnesses_issue : 'ARRAY[]::json[]'},
      ${req.body.witnesses_opening!== 'ARRAY[]::text[]' ? req.body.witnesses_opening : 'ARRAY[]::json[]'},
      ${req.body.preamble},
      ${req.body.mandas!== 'ARRAY[]::text[]' ? req.body.mandas : 'ARRAY[]::json[]'},
      ${req.body.burial_arrangement}
    )
  `
  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(500).send([error]);
  });

});

router.get('/almoneda/:id_documento', function(req, res) {
  const query = `
    SELECT d.id_documento as id_document, d.motivo_almoneda as reason,

    ${selectHistoricPersonWithRole('Propietario', 'owner')},
    ${selectHistoricPersonWithRole('Albacea', 'executor')},
    ${selectHistoricPersonWithRole('Pregonero', 'crier')},
    ${selectHistoricPersonWithRole('Escribano', 'notary')},
    ${selectHistoricPersonWithRole('Testigo', 'witness')}

    FROM documento d
    WHERE d.id_documento=${req.params.id_documento}
  `;

  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(500).send([error]);
  });

})

router.post('/save_almoneda', bodyParse, function(req, res) {

  const query = `
    SELECT ae_add_almoneda(
      ${req.body.id_document},
      ${req.body.owner!== 'ARRAY[]::text[]' ? req.body.owner : 'ARRAY[]::json[]'},
      ${req.body.executor!== 'ARRAY[]::text[]' ? req.body.executor : 'ARRAY[]::json[]'},
      ${req.body.crier!== 'ARRAY[]::text[]' ? req.body.crier : 'ARRAY[]::json[]'},
      ${req.body.notary!== 'ARRAY[]::text[]' ? req.body.notary : 'ARRAY[]::json[]'},
      ${req.body.witness!== 'ARRAY[]::text[]' ? req.body.witness : 'ARRAY[]::json[]'},
      ${req.body.reason}
    )
  `
  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(500).send([error]);
  });

});

router.get('/inventario_bienes/:id_documento', function(req, res) {
  const query = `
    SELECT d.id_documento as id_document,
    
    ${selectHistoricPersonWithRole('Propietario', 'owner')},
    ${selectHistoricPersonWithRole('Escribano', 'notary')}

    FROM documento d
    WHERE d.id_documento=${req.params.id_documento}
  `;

  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(500).send([error]);
  });

})

router.post('/save_inventario_bienes', bodyParse, function(req, res) {

  const query = `
    SELECT ae_add_inventario_bienes(
      ${req.body.id_document},
      ${req.body.owner!== 'ARRAY[]::text[]' ? req.body.owner : 'ARRAY[]::json[]'},
      ${req.body.notary!== 'ARRAY[]::text[]' ? req.body.notary : 'ARRAY[]::json[]'}
    )
  `
  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(500).send([error]);
  });

});

router.get('/vista/:id_documento', function(req, res) {
  const query = `
    SELECT d.id_documento as id_document,

    ${selectHistoricPersonWithRole('Demandante', 'applicant')},
    ${selectHistoricPersonWithRole('Demandado', 'defendant')},
    ${selectHistoricPersonWithRole('Testigo', 'witness')},
    ${selectHistoricPersonWithRole('Escribano', 'notary')},

    (SELECT motivo as diligence FROM pertenencia WHERE fk_documento_id = d.id_documento AND tipo_atr_doc='Deligencia_preliminar'),

    (SELECT coalesce(json_agg(accusations.jsonb_build_object), '[]'::json) as accusations FROM
      (
        SELECT jsonb_build_object('order', orden, 'description', motivo)
        FROM pertenencia
        WHERE fk_documento_id = d.id_documento AND tipo_atr_doc = 'Acusacion' ORDER BY orden
      ) as accusations),

    (SELECT coalesce(json_agg(appeals.jsonb_build_object), '[]'::json) as appeals FROM
      (
        SELECT jsonb_build_object('order', orden, 'description', motivo)
        FROM pertenencia
        WHERE fk_documento_id = d.id_documento AND tipo_atr_doc = 'Apelacion' ORDER BY orden
      ) as appeals)

    FROM documento d
    WHERE d.id_documento=${req.params.id_documento}
  `;

  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(500).send([error]);
  });

})

router.post('/save_vista', bodyParse, function(req, res) {

  const query = `
    SELECT ae_add_visita(
      ${req.body.id_document},
      ${req.body.applicant!== 'ARRAY[]::text[]' ? req.body.applicant : 'ARRAY[]::json[]'},
      ${req.body.defendant!== 'ARRAY[]::text[]' ? req.body.defendant : 'ARRAY[]::json[]'},
      ${req.body.witness!== 'ARRAY[]::text[]' ? req.body.witness : 'ARRAY[]::json[]'},
      ${req.body.notary!== 'ARRAY[]::text[]' ? req.body.notary : 'ARRAY[]::json[]'},
      ${req.body.diligence},
      ${req.body.accusations!== 'ARRAY[]::text[]' ? req.body.accusations : 'ARRAY[]::json[]'},
      ${req.body.appeals!== 'ARRAY[]::text[]' ? req.body.appeals : 'ARRAY[]::json[]'}
    )
  `
  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(500).send([error]);
  });

});

router.get('/juicio_residencia/:id_documento', function(req, res) {
  const query = `
    SELECT d.id_documento as id_document,

    ${selectHistoricPersonWithRole('Demandante', 'applicant')},
    ${selectHistoricPersonWithRole('Demandado', 'defendant')},
    ${selectHistoricPersonWithRole('Testigo', 'witness')},
    ${selectHistoricPersonWithRole('Escribano', 'notary')},

    (SELECT motivo as diligence FROM pertenencia WHERE fk_documento_id = d.id_documento AND tipo_atr_doc='Deligencia_preliminar'),

    (SELECT coalesce(json_agg(charges.jsonb_build_object), '[]'::json) as charges FROM
      (
        SELECT jsonb_build_object('order', orden, 'description', motivo)
        FROM pertenencia
        WHERE fk_documento_id = d.id_documento AND tipo_atr_doc = 'Cargo' ORDER BY orden
      ) as charges),

    (SELECT coalesce(json_agg(appeals.jsonb_build_object), '[]'::json) as appeals FROM
      (
        SELECT jsonb_build_object('order', orden, 'description', motivo)
        FROM pertenencia
        WHERE fk_documento_id = d.id_documento AND tipo_atr_doc = 'Apelacion' ORDER BY orden
      ) as appeals)

    FROM documento d
    WHERE d.id_documento=${req.params.id_documento}
  `;

  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(500).send([error]);
  });

})

router.post('/save_juicio_residencia', bodyParse, function(req, res) {

  const query = `
    SELECT ae_add_juicio_residencia(
      ${req.body.id_document},
      ${req.body.applicant!== 'ARRAY[]::text[]' ? req.body.applicant : 'ARRAY[]::json[]'},
      ${req.body.defendant!== 'ARRAY[]::text[]' ? req.body.defendant : 'ARRAY[]::json[]'},
      ${req.body.witness!== 'ARRAY[]::text[]' ? req.body.witness : 'ARRAY[]::json[]'},
      ${req.body.notary!== 'ARRAY[]::text[]' ? req.body.notary : 'ARRAY[]::json[]'},
      ${req.body.diligence},
      ${req.body.charges!== 'ARRAY[]::text[]' ? req.body.charges : 'ARRAY[]::json[]'},
      ${req.body.appeals!== 'ARRAY[]::text[]' ? req.body.appeals : 'ARRAY[]::json[]'}
    )
  `
  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(500).send([error]);
  });

});

router.get('/pleito_entre_partes/:id_documento', function(req, res) {
  const query = `
    SELECT d.id_documento as id_document,
    
    ${selectHistoricPersonWithRole('Demandante', 'applicant')},
    ${selectHistoricPersonWithRole('Demandado', 'defendant')},
    ${selectHistoricPersonWithRole('Testigo', 'witness')},
    ${selectHistoricPersonWithRole('Escribano', 'notary')},

    (SELECT coalesce(json_agg(accusations.jsonb_build_object), '[]'::json) as accusations FROM
      (
        SELECT jsonb_build_object('order', orden, 'description', motivo)
        FROM pertenencia
        WHERE fk_documento_id = d.id_documento AND tipo_atr_doc = 'Acusacion' ORDER BY orden
      ) as accusations),

    (SELECT coalesce(json_agg(allegations.jsonb_build_object), '[]'::json) as allegations FROM
      (
        SELECT jsonb_build_object('order', orden, 'description', motivo)
        FROM pertenencia
        WHERE fk_documento_id = d.id_documento AND tipo_atr_doc = 'Alegato' ORDER BY orden
      ) as allegations),

    (SELECT coalesce(json_agg(appeals.jsonb_build_object), '[]'::json) as appeals FROM
      (
        SELECT jsonb_build_object('order', orden, 'description', motivo)
        FROM pertenencia
        WHERE fk_documento_id = d.id_documento AND tipo_atr_doc = 'Apelacion' ORDER BY orden
      ) as appeals)

    FROM documento d
    WHERE d.id_documento=${req.params.id_documento}
  `;

  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(500).send([error]);
  });

})

router.post('/save_pleito_entre_partes', bodyParse, function(req, res) {

  const query = `
    SELECT ae_add_pleito_entre_partes(
      ${req.body.id_document},
      ${req.body.applicant!== 'ARRAY[]::text[]' ? req.body.applicant : 'ARRAY[]::json[]'},
      ${req.body.defendant!== 'ARRAY[]::text[]' ? req.body.defendant : 'ARRAY[]::json[]'},
      ${req.body.witness!== 'ARRAY[]::text[]' ? req.body.witness : 'ARRAY[]::json[]'},
      ${req.body.notary!== 'ARRAY[]::text[]' ? req.body.notary : 'ARRAY[]::json[]'},
      ${req.body.accusations!== 'ARRAY[]::text[]' ? req.body.accusations : 'ARRAY[]::json[]'},
      ${req.body.allegations!== 'ARRAY[]::text[]' ? req.body.allegations : 'ARRAY[]::json[]'},
      ${req.body.appeals!== 'ARRAY[]::text[]' ? req.body.appeals : 'ARRAY[]::json[]'}
    )
  `
  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(500).send([error]);
  });

});

router.get('/relacion_meritos/:id_documento', function(req, res) {
  const query = `
    SELECT d.id_documento as id_document,
    ${selectHistoricPersonWithRole('Demandante', 'applicant')},
    ${selectHistoricPersonWithRole('Protagonista', 'protagonist')},
    ${selectHistoricPersonWithRole('Testigo', 'witness')},
    ${selectHistoricPersonWithRole('Escribano', 'notary')},

    (SELECT coalesce(json_agg(allegations.jsonb_build_object), '[]'::json) as allegations FROM
      (
        SELECT jsonb_build_object('order', orden, 'description', motivo)
        FROM pertenencia
        WHERE fk_documento_id = d.id_documento AND tipo_atr_doc = 'Alegato' ORDER BY orden
      ) as allegations),

    (SELECT coalesce(json_agg(requests.jsonb_build_object), '[]'::json) as requests FROM
      (
        SELECT jsonb_build_object('order', orden, 'description', motivo)
        FROM pertenencia
        WHERE fk_documento_id = d.id_documento AND tipo_atr_doc = 'Solicitud' ORDER BY orden
      ) as requests)

    FROM documento d
    WHERE d.id_documento=${req.params.id_documento}
  `;

  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(500).send([error]);
  });

})

router.post('/save_relacion_meritos', bodyParse, function(req, res) {

  const query = `
    SELECT ae_add_relacion_meritos(
      ${req.body.id_document},
      ${req.body.applicant!== 'ARRAY[]::text[]' ? req.body.applicant : 'ARRAY[]::json[]'},
      ${req.body.protagonist!== 'ARRAY[]::text[]' ? req.body.protagonist : 'ARRAY[]::json[]'},
      ${req.body.witness!== 'ARRAY[]::text[]' ? req.body.witness : 'ARRAY[]::json[]'},
      ${req.body.notary!== 'ARRAY[]::text[]' ? req.body.notary : 'ARRAY[]::json[]'},
      ${req.body.allegations!== 'ARRAY[]::text[]' ? req.body.allegations : 'ARRAY[]::json[]'},
      ${req.body.requests!== 'ARRAY[]::text[]' ? req.body.requests : 'ARRAY[]::json[]'}
    )
  `
  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(500).send([error]);
  });

});

function selectHistoricPersonWithRole(role, property_name) {
  return `
    (
      SELECT coalesce(
        json_agg(${property_name}.jsonb_build_object),
        '[]'::json
      )
      as ${property_name} FROM
      (
        SELECT jsonb_build_object(
          'id_persona_historica', ph.id_persona_historica,
          'nombre', ph.nombre,
          'genero', ph.genero,
          'descripcion', prp.descripcion,
          'id_prp', prp.id_persona_rol_pertenencia
        )
        FROM persona_rol_pertenencia prp
        INNER JOIN pertenencia p on p.id_pertenencia = prp.fk_pertenencia_id
        INNER JOIN persona_historica ph on ph.id_persona_historica = prp.fk_persona_historica_id
        INNER JOIN persona_rol_pertenencia_rel_rol prpr on prpr.fk_persona_rol_pertenencia = prp.id_persona_rol_pertenencia
        WHERE p.fk_documento_id = d.id_documento AND prpr.fk_rol_nombre = '${role}'
      )
      as ${property_name}
    )
  `
}
function selectInstitution(role, property_name) {
  return `
    (
      SELECT coalesce(
        json_agg(${property_name}.jsonb_build_object),
        '[]'::json
      )
      as ${property_name} FROM
      (
        SELECT jsonb_build_object('descripcion', prp.descripcion, 'nombre', prpi.fk_institucion_nombre)
        FROM persona_rol_pertenencia prp
        INNER JOIN persona_rol_pertenencia_rel_institucion prpi ON prpi.fk_persona_rol_pertenencia_id = prp.id_persona_rol_pertenencia
        INNER JOIN pertenencia p on p.id_pertenencia = prp.fk_pertenencia_id
        INNER JOIN persona_historica ph on ph.id_persona_historica = prp.fk_persona_historica_id
        INNER JOIN persona_rol_pertenencia_rel_rol prpr on prpr.fk_persona_rol_pertenencia = prp.id_persona_rol_pertenencia
        WHERE p.fk_documento_id = d.id_documento AND prpr.fk_rol_nombre = '${role}' AND ph.nombre='Anónimo'
      )
      as ${property_name}
    )
  `
}


const checkEmptyJsonArray = item => (
  item === 'ARRAY[]::text[]' ? 'ARRAY[]::json[]' : item
)

router.get('/poder/:id_documento', (req, res) => {
  const query = `
    SELECT d.id_documento as id_document,
    ${selectHistoricPersonWithRole('Emisor', 'senders')},
    ${selectHistoricPersonWithRole('Testigo de emisión', 'sender_witnesees')},
    ${selectHistoricPersonWithRole('Destinatario', 'recipients')},
    ${selectHistoricPersonWithRole('Testigo de presentación', 'presentation_witnesses')},
    ${selectHistoricPersonWithRole('Notario', 'notaries')},
    (
      SELECT coalesce(
        json_agg(motivo)::json,
        '[]'::json
      )
      FROM pertenencia
      WHERE fk_documento_id = d.id_documento AND tipo_atr_doc = 'Poder'
    ) as powers,
    (
      SELECT to_json(l)
      FROM lugar l
      INNER JOIN pertenencia_rel_lugar prl on prl.fk_lugar_id = l.id_lugar
      INNER JOIN pertenencia p on p.id_pertenencia = prl.fk_pertenencia_id
      WHERE p.fk_documento_id = d.id_documento AND p.tipo_atr_doc = 'Ámbito de aplicación'
    ) as area_of_application,
    (
      SELECT precision_pert_lugar
      from pertenencia_rel_lugar prl
      INNER JOIN pertenencia p on p.id_pertenencia = prl.fk_pertenencia_id
      WHERE p.fk_documento_id = d.id_documento AND p.tipo_atr_doc = 'Ámbito de aplicación'
    ) as area_precision,
    (
      SELECT coalesce(
        json_agg(resignations.jsonb_build_object),
        '[]'::json
      )
      as resignations FROM
      (
        SELECT jsonb_build_object('type', substring(p.tipo_atr_doc, 10), 'description', p.motivo)
        FROM pertenencia p
        WHERE p.fk_documento_id = d.id_documento AND p.tipo_atr_doc LIKE 'renuncia#%'
      )
      as resignations
    ),
    (
      SELECT fecha_inicio
      FROM pertenencia p
      WHERE p.fk_documento_id = d.id_documento AND p.tipo_atr_doc='Plazo de vigencia'
    ) as start_date,
    (
      SELECT fecha_fin
      FROM pertenencia p
      WHERE p.fk_documento_id = d.id_documento AND p.tipo_atr_doc='Plazo de vigencia'
    ) as end_date,
    (
      SELECT precision_inicio
      FROM pertenencia p
      WHERE p.fk_documento_id = d.id_documento AND p.tipo_atr_doc='Plazo de vigencia'
    ) as start_date_precision,
    (
      SELECT precision_fin
      FROM pertenencia p
      WHERE p.fk_documento_id = d.id_documento AND p.tipo_atr_doc='Plazo de vigencia'
    ) as end_date_precision

    FROM documento d
    WHERE d.id_documento=${req.params.id_documento}
  `

  db.query(query)
  .then(data => {
    res.status(200).json(data[0]);
  })
  .catch(error => {
    res.status(500).json([error]);
  });
})

router.post('/save_poder', bodyParse, (req, res) => {
  const query = `SELECT ae_add_poder(
    ${req.body.id_document},
    ${checkEmptyJsonArray(req.body.senders)},
    ${checkEmptyJsonArray(req.body.sender_witnesees)},
    ${checkEmptyJsonArray(req.body.recipients)},
    ${checkEmptyJsonArray(req.body.presentation_witnesses)},
    ${checkEmptyJsonArray(req.body.notaries)},
    ${req.body.powers},
    ${req.body.area_of_application.id_lugar},
    ${req.body.area_precision},
    ${checkEmptyJsonArray(req.body.resignations)},
    ${req.body.start_date},
    ${req.body.start_date_precision},
    ${req.body.end_date},
    ${req.body.end_date_precision}
  )`

  db.query(query)
  .then(data => res.status(200).json(data[0]))
  .catch(error => res.status(500).json([error]))
})

router.get('/acta/:id_documento', (req, res) => {
  const query = `
    SELECT d.id_documento as id_document,
    ${selectHistoricPersonWithRole('Emisor', 'senders')},
    ${selectHistoricPersonWithRole('Participante', 'recipients')},
    ${selectHistoricPersonWithRole('Notario', 'notaries')},
    ${selectHistoricPersonWithRole('Pregonero', 'criers')},
    ${selectHistoricPersonWithRole('Testigo', 'witnesses')}

    FROM documento d
    WHERE d.id_documento=${req.params.id_documento}
  `;

  db.query(query)
  .then(data => {
    res.status(200).json(data[0]);
  })
  .catch(error => {
    res.status(500).json([error]);
  });
})

router.post('/save_acta', bodyParse, (req, res) => {
  const query = `SELECT ae_add_acta(
    ${req.body.id_document},
    ${checkEmptyJsonArray(req.body.senders)},
    ${checkEmptyJsonArray(req.body.recipients)},
    ${checkEmptyJsonArray(req.body.notaries)},
    ${checkEmptyJsonArray(req.body.criers)},
    ${checkEmptyJsonArray(req.body.witnesses)}
  )`;

  db.query(query)
  .then(data => {
    res.status(200).json(data[0]);
  })
  .catch(error => {
    res.status(500).json([error]);
  });
})

router.get('/acta_sentencia/:id_documento', (req, res) => {
  const query = `
    SELECT d.id_documento as id_document,
    ${selectHistoricPersonWithRole('Emisor', 'senders')},
    ${selectHistoricPersonWithRole('Destinatario', 'recipients')},
    ${selectHistoricPersonWithRole('Notario', 'notaries')},
    ${selectHistoricPersonWithRole('Pregonero', 'criers')},
    ${selectHistoricPersonWithRole('Testigo', 'witnesses')},
    (
      SELECT to_json(p) AS pena
      FROM pena p JOIN documento d ON d.fk_pena_id = p.id_pena
      WHERE d.id_documento=${req.params.id_documento}
    ),
    (
      SELECT coalesce(json_agg(fk_miembro_texto)::json, '[]'::json) AS miembros
      FROM pena_rel_miembro prm
      JOIN pena p ON prm.fk_pena_id = p.id_pena
      JOIN documento d ON p.id_pena = d.fk_pena_id
      WHERE d.id_documento=${req.params.id_documento}
    ),
    (
      SELECT coalesce(json_agg(monedas.jsonb_build_object), '[]'::json) AS monedas
      FROM (
        SELECT jsonb_build_object('value', pru.valor, 'unit', pru.fk_unidad_nombre)
          FROM pena_rel_unidad pru
          JOIN pena p ON pru.fk_pena_id = p.id_pena
          JOIN documento d ON p.id_pena = d.fk_pena_id
          WHERE d.id_documento=${req.params.id_documento}
      ) AS monedas
    )

    FROM documento d
    WHERE d.id_documento=${req.params.id_documento}
  `;

  db.query(query)
  .then(data => {
    res.status(200).json(data[0]);
  })
  .catch(error => {
    res.status(500).json([error]);
  });
})

router.post('/save_acta_sentencia', bodyParse, (req, res) => {
  const query = `SELECT ae_add_acta_sentencia(
    ${req.body.id_document},
    ${checkEmptyJsonArray(req.body.senders)},
    ${checkEmptyJsonArray(req.body.recipients)},
    ${checkEmptyJsonArray(req.body.notaries)},
    ${checkEmptyJsonArray(req.body.criers)},
    ${checkEmptyJsonArray(req.body.witnesses)},
    ${req.body.pena.miembros},
    ${checkEmptyJsonArray(req.body.pena.monedas)},
    '${JSON.stringify(req.body.pena).replace(/\$string\$/g, '').replace(/'/g, '')}'
  )`;

  db.query(query)
  .then(data => {
    res.status(200).json(data[0]);
  })
  .catch(error => {
    res.status(500).json([error]);
  });
})

router.get('/incautacion/:id_documento', (req, res) => {
  const query = `
    SELECT d.id_documento as id_document,
    ${selectHistoricPersonWithRole('Incautado', 'seized_from')},
    ${selectHistoricPersonWithRole('Comandante', 'ordered_by')},
    ${selectHistoricPersonWithRole('Ejecutor', 'executioners')},
    ${selectHistoricPersonWithRole('Notario', 'notaries')},
    ${selectHistoricPersonWithRole('Propietario', 'propietaries')},
    ${selectHistoricPersonWithRole('Testigo', 'witnesses')},
    (
      SELECT coalesce(
        json_agg(motivo)::json,
        '[]'::json
      )
      FROM pertenencia
      WHERE fk_documento_id = d.id_documento AND tipo_atr_doc = 'Motivo'
    ) as motives,
    (
      SELECT fecha_inicio
      FROM pertenencia p
      WHERE p.fk_documento_id = d.id_documento AND p.tipo_atr_doc='Fecha de incautacion'
    ) as date,
    (
      SELECT precision_inicio
      FROM pertenencia p
      WHERE p.fk_documento_id = d.id_documento AND p.tipo_atr_doc='Fecha de incautacion'
    ) as date_precision,
    (
      SELECT to_json(l)
      FROM lugar l
      INNER JOIN pertenencia_rel_lugar prl on prl.fk_lugar_id = l.id_lugar
      INNER JOIN pertenencia p on p.id_pertenencia = prl.fk_pertenencia_id
      WHERE p.fk_documento_id = d.id_documento AND p.tipo_atr_doc = 'Lugar de incautación'
    ) as place,
    (
      SELECT precision_pert_lugar
      from pertenencia_rel_lugar prl
      INNER JOIN pertenencia p on p.id_pertenencia = prl.fk_pertenencia_id
      WHERE p.fk_documento_id = d.id_documento AND p.tipo_atr_doc = 'Lugar de incautación'
    ) as place_precision


    FROM documento d
    WHERE d.id_documento=${req.params.id_documento}
  `;

  db.query(query)
  .then(data => {
    res.status(200).json(data[0]);
  })
  .catch(error => {
    res.status(500).json([error]);
  });
})

router.post('/save_incautacion', bodyParse, (req, res) => {
  const query = `SELECT ae_add_incautacion(
    ${req.body.id_document},
    ${checkEmptyJsonArray(req.body.seized_from)},
    ${checkEmptyJsonArray(req.body.ordered_by)},
    ${checkEmptyJsonArray(req.body.executioners)},
    ${checkEmptyJsonArray(req.body.notaries)},
    ${checkEmptyJsonArray(req.body.propietaries)},
    ${checkEmptyJsonArray(req.body.witnesses)},
    ${req.body.motives},
    ${req.body.date},
    ${req.body.date_precision},
    ${req.body.place.id_lugar},
    ${req.body.place_precision}
  )`;

  db.query(query)
  .then(data => {
    res.status(200).json(data[0]);
  })
  .catch(error => {
    res.status(500).json([error]);
  });
})

router.get('/contrato_asiento/:id_documento', (req, res) => {
  const query = `
    SELECT d.id_documento as id_document,
    ${selectHistoricPersonWithRole('Involucrado', 'parts_involved')},
    (
      SELECT coalesce(json_agg(terms.jsonb_build_object), '[]'::json)
      FROM (
        SELECT jsonb_build_object('order', orden, 'description', motivo)
        FROM pertenencia
        WHERE fk_documento_id = d.id_documento
        AND tipo_atr_doc = 'Condición'
        ORDER BY orden
      ) AS terms
    ) as terms
    FROM documento d
    WHERE d.id_documento=${req.params.id_documento}
  `;

  db.query(query)
  .then(data => {
    res.status(200).json(data[0]);
  })
  .catch(error => {
    res.status(500).json([error]);
  });
})

router.post('/save_contrato_asiento', bodyParse, (req, res) => {
  const query = `SELECT ae_add_contrato_asiento(
    ${req.body.id_document},
    ${checkEmptyJsonArray(req.body.parts_involved)},
    ${checkEmptyJsonArray(req.body.terms)}
  )`;

  db.query(query)
  .then(data => {
    res.status(200).json(data[0]);
  })
  .catch(error => {
    res.status(500).json([error]);
  });
})

router.get('/compra_venta/:id_documento', (req, res) => {
  const query = `
    SELECT d.id_documento as id_document,
    ${selectHistoricPersonWithRole('Comprador', 'buyers')},
    ${selectHistoricPersonWithRole('Vendedor', 'sellers')},
    ${selectHistoricPersonWithRole('Notario', 'notaries')},
    (
      SELECT to_json(l)
      FROM lugar l
      INNER JOIN pertenencia_rel_lugar prl on prl.fk_lugar_id = l.id_lugar
      INNER JOIN pertenencia p on p.id_pertenencia = prl.fk_pertenencia_id
      WHERE p.fk_documento_id = d.id_documento AND p.tipo_atr_doc = 'Transacción'
    ) as place,
    (
      SELECT precision_pert_lugar
      from pertenencia_rel_lugar prl
      INNER JOIN pertenencia p on p.id_pertenencia = prl.fk_pertenencia_id
      WHERE p.fk_documento_id = d.id_documento AND p.tipo_atr_doc = 'Transacción'
    ) as place_precision

    FROM documento d
    WHERE d.id_documento=${req.params.id_documento}
  `;

  db.query(query)
  .then(data => {
    res.status(200).json(data[0]);
  })
  .catch(error => {
    res.status(500).json([error]);
  });
})

router.post('/save_compra_venta', bodyParse, (req, res) => {
  const query = `SELECT ae_add_compra_venta(
    ${req.body.id_document},
    ${checkEmptyJsonArray(req.body.buyers)},
    ${checkEmptyJsonArray(req.body.sellers)},
    ${checkEmptyJsonArray(req.body.notaries)},
    ${req.body.place.id_lugar},
    ${req.body.place_precision}
  )`;

  db.query(query)
  .then(data => {
    res.status(200).json(data[0]);
  })
  .catch(error => {
    res.status(500).json([error]);
  });
})

router.get('/nombramiento/:id_documento', (req, res) => {
  const query = `
  SELECT d.id_documento as id_document,
    ${selectHistoricPersonWithRole('Emisor', 'senders')},
    (
      SELECT coalesce(
        json_agg(recipients.jsonb_build_object),
        '[]'::json
      )
      as recipients FROM
      (
        SELECT jsonb_build_object(
          'order', p.orden,
          'recipient', jsonb_build_object(
            'id_persona_historica', ph.id_persona_historica,
            'nombre', ph.nombre,
            'genero', ph.genero,
            'descripcion', prp.descripcion,
            'id_prp', prp.id_persona_rol_pertenencia
          ),
          'roles', (
            SELECT coalesce(
              json_agg(
                jsonb_build_object(
                  'id_linea', l.id_linea,
                  'role', o.nombre,
                  'motive', l.descripcion,
                  'buy_type', l.compra_cargo,
                  'role_condition', l.condiciones_nombramiento,
                  'units', (
                    SELECT coalesce(
                      json_agg(
                        jsonb_build_object(
                          'unit', u.nombre,
                          'value', lru.valor
                        )
                      ),
                      '[]'::json
                    )
                    FROM linea_rel_unidad lru
                    JOIN unidad u ON lru.fk_unidad_nombre = u.nombre
                    WHERE lru.fk_linea_id = l.id_linea
                  ),
                  'resignant', (
                    SELECT coalesce(
                      json_agg(
                        jsonb_build_object(
                          'id_persona_historica', ph2.id_persona_historica,
                          'nombre', ph2.nombre,
                          'genero', ph2.genero,
                          'descripcion', prp2.descripcion,
                          'id_prp', prp2.id_persona_rol_pertenencia
                        )
                      ),
                      '[]'::json
                    )
                    FROM persona_rol_pertenencia prp2
                    INNER JOIN persona_rol_pertenencia_rel_linea prpl ON prpl.fk_persona_rol_pertenencia_id = prp2.id_persona_rol_pertenencia
                    INNER JOIN persona_historica ph2 on ph2.id_persona_historica = prp2.fk_persona_historica_id
                    INNER JOIN persona_rol_pertenencia_rel_rol prpr on prpr.fk_persona_rol_pertenencia = prp2.id_persona_rol_pertenencia
                    WHERE prpl.fk_linea = l.id_linea AND prpr.fk_rol_nombre = 'Renunciante'
                  )
                )
              ),
              '[]'::json
            )
            FROM pertenencia_rel_agrupacion_bienes prab
            JOIN agrupacion_bienes ab ON prab.fk_agrupacion_bienes_id = ab.id_agrupacion_bienes
            JOIN linea l ON l.fk_agrupacion_bienes_id = ab.id_agrupacion_bienes
            JOIN objeto o ON o.id_objeto = l.fk_objeto_id
            WHERE prab.fk_pertenencia_id = p.id_pertenencia
          )
        )
        FROM persona_rol_pertenencia prp
        INNER JOIN pertenencia p on p.id_pertenencia = prp.fk_pertenencia_id
        INNER JOIN persona_historica ph on ph.id_persona_historica = prp.fk_persona_historica_id
        INNER JOIN persona_rol_pertenencia_rel_rol prpr on prpr.fk_persona_rol_pertenencia = prp.id_persona_rol_pertenencia
        WHERE p.fk_documento_id = d.id_documento AND prpr.fk_rol_nombre = 'Transacción'
      )
      as recipients
    )
    as recipients
    FROM documento d
    WHERE d.id_documento=${Number(req.params.id_documento) || 'NULL'}
  `;

  db.query(query)
  .then(data => {
    res.status(200).json(data[0]);
  })
  .catch(error => {
    res.status(500).json([error]);
  });
})

router.post('/save_nombramiento', bodyParse, (req, res) => {
  const query = `SELECT ae_add_nombramiento(
    ${req.body.id_document},
    ${checkEmptyJsonArray(req.body.senders)},
    ${checkEmptyJsonArray(req.body.recipients)}
  )`;

  db.query(query)
  .then(data => {
    res.status(200).json(data[0]);
  })
  .catch(error => {
    res.status(500).json([error]);
  });
})

router.get('/acta_repartimiento/:id_documento', (req, res) => {
  const query = `
    SELECT jsonb_build_object(
      'persona', jsonb_build_object(
        'id_persona_historica', ph.id_persona_historica,
        'nombre', ph.nombre,
        'genero', ph.genero,
        'descripcion', prp.descripcion,
        'id_prp', prp.id_persona_rol_pertenencia,
        'id_pertenencia', prp.fk_pertenencia_id
      ),
      'personas_relacionadas', (
        SELECT COALESCE(
          array_agg(
            jsonb_build_object(
              'id_persona_historica', related_ph.id_persona_historica,
              'nombre', related_ph.nombre,
              'genero', related_ph.genero,
              'descripcion', related_prp.descripcion,
              'id_prp', related_prp.id_persona_rol_pertenencia,
              'id_pertenencia', related_prp.fk_pertenencia_id
            )
          ),
          ARRAY[]::jsonb[]
        )

        FROM persona_rol_pertenencia related_prp
        INNER JOIN pertenencia related_p on related_p.id_pertenencia = related_prp.fk_pertenencia_id
        INNER JOIN persona_historica related_ph on related_ph.id_persona_historica = related_prp.fk_persona_historica_id
        INNER JOIN persona_rol_pertenencia_rel_rol related_prpr 
          ON related_prpr.fk_persona_rol_pertenencia = related_prp.id_persona_rol_pertenencia

        INNER JOIN persona_rol_pertenencia related_prp_relation
          ON related_prp_relation.fk_pertenencia_id = related_p.id_pertenencia
          AND related_prp_relation.fk_persona_historica_id = related_ph.id_persona_historica
          AND related_prp_relation.is_relation = true

        INNER JOIN persona_rol_pertenencia prp_relation
          ON prp_relation.id_persona_rol_pertenencia = related_prp_relation.fk_persona_rol_pertenencia_id
          AND prp_relation.is_relation = true
          AND prp_relation.fk_pertenencia_id = p.id_pertenencia

        WHERE related_p.fk_documento_id = p.fk_documento_id
        AND related_prpr.fk_rol_nombre = 'Persona relacionada'
      ),
      'agrupacion', (
        SELECT jsonb_build_object(
          'id', ab.id_agrupacion_bienes,
          'objetos', (
            SELECT COALESCE(
              array_agg(
                jsonb_build_object(
                  'nombre', o.nombre,
                  'numero', l.cantidad,
                  'descripcion', l.descripcion,
                  'id_linea', l.id_linea
                )
              ),
              ARRAY[]::jsonb[]
            )
            FROM objeto o
            JOIN linea l ON l.fk_objeto_id = o.id_objeto
            WHERE l.fk_agrupacion_bienes_id = ab.id_agrupacion_bienes
          )
        )
        FROM pertenencia_rel_agrupacion_bienes prab
        INNER JOIN agrupacion_bienes ab 
          ON prab.fk_agrupacion_bienes_id = ab.id_agrupacion_bienes
        WHERE prab.fk_pertenencia_id = p.id_pertenencia
      )
    ) as data
    
    FROM persona_rol_pertenencia prp
    INNER JOIN pertenencia p on p.id_pertenencia = prp.fk_pertenencia_id
    INNER JOIN persona_historica ph on ph.id_persona_historica = prp.fk_persona_historica_id
    INNER JOIN persona_rol_pertenencia_rel_rol prpr 
      ON prpr.fk_persona_rol_pertenencia = prp.id_persona_rol_pertenencia
    
    WHERE p.fk_documento_id = ${req.params.id_documento}
    AND prpr.fk_rol_nombre = 'Persona principal'
  `;

  db.query(query)
  .then(data => {
    res.status(200).json(data[0]);
  })
  .catch(error => {
    res.status(500).json([error]);
  });
})

router.post('/save_acta_repartimiento', bodyParse, (req, res) => {
  const query = `SELECT ae_add_acta_repartimiento(
    ${req.body.id_documento},
    ${checkEmptyJsonArray(req.body.personas)},
    ${checkEmptyJsonArray(req.body.personas_relacionadas)}
  )`;

  db.query(query)
  .then(data => {
    res.status(200).json(data[0]);
  })
  .catch(error => {
    res.status(500).json([error]);
  });
})

router.get('/basic_info/keywords', (req, res) => {
  const query = `
  WITH RECURSIVE keyword_group(palabra, fk_keyword, hijos) AS (
    SELECT k0.palabra, k0.fk_keyword,
    ARRAY[k0.palabra::text] as hijos
    FROM keyword AS k0
  UNION ALL
    SELECT ki.palabra, ki.fk_keyword,
    array_append(kn.hijos, ki.palabra::text)
    FROM keyword_group as kn JOIN keyword as ki
    ON kn.fk_keyword = ki.palabra
  ) SELECT palabra, json_agg(hijos) as hijos FROM keyword_group GROUP BY palabra;
  `;
  db.query(query)
  .then(data => {
    const mapped = data[0].map(d => {
      d.hijos = d.hijos.reduce((prev, next) => prev.concat(next), [])
      .filter(key => key !== d.palabra)
      .reduce((keys, next) => {
        if(keys.indexOf(next) === -1) {
          keys.push(next);
        }
        return keys;
      }, [])
      return d
    })
    res.status(200).json(mapped);
  })
  .catch(error => {
    res.status(500).json(error.message);
  });
})

router.get('/basic_info/:id_documento', (req, res) => {
  const query = `
    SELECT d.id_documento as id_document,
    tipo,
    subtipo,
    signatura,
    foliado,
    des_foliado,
    titulo,
    firmada,
    holografa,
    (
      SELECT to_json(c) as coleccion
      FROM coleccion c
      INNER JOIN seccion s ON c.nombre = s.fk_coleccion
      INNER JOIN documento d ON d.fk_seccion_id = s.id_seccion
      WHERE d.id_documento = ${req.params.id_documento}
    ),
    (
      SELECT to_json(s) as seccion
      FROM seccion s
      INNER JOIN documento d ON d.fk_seccion_id = s.id_seccion
      WHERE d.id_documento = ${req.params.id_documento}
    ),
    (
      SELECT array_agg(palabra)
      FROM keyword k
      JOIN keyword_rel_documento krl ON krl.fk_keyword_palabra=k.palabra
      WHERE krl.fk_documento_id=d.id_documento
    ) as keywords,
    (
      SELECT coalesce(
        json_agg(relaciones_documentos.jsonb_build_object),
        '[]'::json
      ) as relaciones_documentos FROM (
        SELECT jsonb_build_object('id_documento', d2.id_documento, 'titulo', d2.titulo)
        FROM documento d2
        INNER JOIN documento_rel_documento drd ON drd.fk_documento2=d2.id_documento
        WHERE drd.fk_documento1=d.id_documento
      ) as relaciones_documentos
    ),
    (
      SELECT fecha_inicio
      FROM pertenencia p
      WHERE p.fk_documento_id = d.id_documento AND p.tipo_atr_doc='Emisión'
    ) as fecha_emision,
    (
      SELECT precision_inicio
      FROM pertenencia p
      WHERE p.fk_documento_id = d.id_documento AND p.tipo_atr_doc='Emisión'
    ) as precision_fecha_emision,
    (
      SELECT to_json(l)
      FROM lugar l
      INNER JOIN pertenencia_rel_lugar prl on prl.fk_lugar_id = l.id_lugar
      INNER JOIN pertenencia p on p.id_pertenencia = prl.fk_pertenencia_id
      WHERE p.fk_documento_id = d.id_documento AND p.tipo_atr_doc = 'Emisión'
    ) as lugar_emision,
    (
      SELECT precision_pert_lugar
      from pertenencia_rel_lugar prl
      INNER JOIN pertenencia p on p.id_pertenencia = prl.fk_pertenencia_id
      WHERE p.fk_documento_id = d.id_documento AND p.tipo_atr_doc = 'Emisión'
    ) as precision_lugar_emision,
    (
      SELECT fecha_inicio
      FROM pertenencia p
      WHERE p.fk_documento_id = d.id_documento AND p.tipo_atr_doc='Recepción'
    ) as fecha_recepcion,
    (
      SELECT precision_inicio
      FROM pertenencia p
      WHERE p.fk_documento_id = d.id_documento AND p.tipo_atr_doc='Recepción'
    ) as precision_fecha_recepcion,
    (
      SELECT to_json(l)
      FROM lugar l
      INNER JOIN pertenencia_rel_lugar prl on prl.fk_lugar_id = l.id_lugar
      INNER JOIN pertenencia p on p.id_pertenencia = prl.fk_pertenencia_id
      WHERE p.fk_documento_id = d.id_documento AND p.tipo_atr_doc = 'Recepción'
    ) as lugar_recepcion,
    (
      SELECT precision_pert_lugar
      from pertenencia_rel_lugar prl
      INNER JOIN pertenencia p on p.id_pertenencia = prl.fk_pertenencia_id
      WHERE p.fk_documento_id = d.id_documento AND p.tipo_atr_doc = 'Recepción'
    ) as precision_lugar_recepcion,
    ${selectHistoricPersonWithRole('Mano_secretario', 'secretario')},
    ${selectHistoricPersonWithRole('Persona_marginalia', 'marginalia_personas')},
    ${selectInstitution('Institucion_marginalia', 'marginalia_instituciones')}

    FROM documento d
    WHERE d.id_documento=${req.params.id_documento}
  `
  db.query(query)
  .then(data => {
    res.status(200).json(data[0]);
  })
  .catch(error => {
    res.status(500).json([error]);
  });
})

router.post('/save_basic_info', bodyParse, (req, res) => {
  const query = `SELECT ae_add_basic_info(
    ${req.body.id_document},
    ${req.body.tipo},
    ${req.body.subtipo},
    ${req.body.signatura},
    ${req.body.foliado},
    ${req.body.des_foliado},
    ${req.body.titulo},
    ${req.body.firmada},
    ${req.body.holografa},
    ${req.body.seccion.id_seccion},
    ${req.body.keywords},
    ${req.body.fecha_emision},
    ${req.body.precision_fecha_emision},
    ${req.body.lugar_emision.id_lugar},
    ${req.body.precision_lugar_emision},
    ${req.body.fecha_recepcion},
    ${req.body.precision_fecha_recepcion},
    ${req.body.lugar_recepcion.id_lugar},
    ${req.body.precision_lugar_recepcion},
    ${checkEmptyJsonArray(req.body.secretario)},
    ${checkEmptyJsonArray(req.body.marginalia_personas)},
    ${checkEmptyJsonArray(req.body.marginalia_instituciones)},
    ${req.body.relaciones_documentos}
  )`;
  db.query(query)
  .then(data => {
    res.status(200).json(data[0]);
  })
  .catch(error => {
    res.status(500).json([error]);
  });
})

router.post('/save_interrogatorio', bodyParse, (req, res) => {
  const insert_question_query = `SELECT ae_add_interrogatorio_preguntas(
    ${req.body.id_document},
    ${checkEmptyJsonArray(req.body.preguntas)},
    ${checkEmptyJsonArray(req.body.testigos)}::jsonb[]
  )`;

  db.query(insert_question_query)
  .then(data => {
    res.status(200).json(data[0]);
  })
  .catch(error => {
    res.status(500).json([error]);
  });
});

function interrogatorio_questions_query(id_documento) {
  return `
    SELECT d.id_documento as id_document,
    (
      SELECT coalesce(
        json_agg(preguntas.json_build_object),
        '[]'::json
      ) as preguntas FROM (
        SELECT json_build_object(
          'id_pertenencia', p.id_pertenencia,
          'order', p.orden,
          'description', p.motivo
        )
        FROM pertenencia p
        WHERE p.tipo_atr_doc='Pregunta' AND p.fk_documento_id=d.id_documento
        ORDER BY p.orden
      ) as preguntas
    ),
    (
      SELECT coalesce(json_agg(testigos.jsonb_build_object), '[]'::json)
      AS testigos FROM (
        SELECT jsonb_build_object(
          'person', jsonb_build_object(
            'id_persona_historica', ph.id_persona_historica,
            'nombre', ph.nombre,
            'genero', ph.genero,
            'id_prp', prp.id_persona_rol_pertenencia
          ),
          'description', prp.descripcion,
          'date', p.fecha_inicio,
          'date_precision', p.precision_inicio,
          'torturas', array_remove(array_agg(prprt.fk_tortura_texto), null),
          'respuestas', array_to_json((
            SELECT array_agg(
              json_build_object(
                'id_pertenencia_pregunta', pp.fk_pertenencia_id,
                'description', pp.motivo
              )
            ) FROM pertenencia pp
            JOIN respuesta r ON r.fk_pertenencia_id = pp.id_pertenencia
            WHERE r.fk_persona_rol_pertenencia_id = prp.id_persona_rol_pertenencia
          ))
        ) FROM persona_rol_pertenencia prp
        INNER JOIN pertenencia p on p.id_pertenencia = prp.fk_pertenencia_id
        INNER JOIN persona_historica ph on ph.id_persona_historica = prp.fk_persona_historica_id
        INNER JOIN persona_rol_pertenencia_rel_rol prpr on prpr.fk_persona_rol_pertenencia = prp.id_persona_rol_pertenencia
        LEFT JOIN persona_rol_pertenencia_rel_tortura prprt on prprt.fk_persona_rol_pertenencia_id = prp.id_persona_rol_pertenencia
        WHERE p.fk_documento_id = d.id_documento AND prpr.fk_rol_nombre = 'Testigo'
        GROUP BY prp.id_persona_rol_pertenencia, ph.id_persona_historica, prp.descripcion, ph.nombre, ph.genero, p.fecha_inicio, p.precision_inicio, p.fk_pertenencia_id, p.motivo
      ) AS testigos
    )
    FROM documento d
    WHERE d.id_documento=${id_documento}
  `;
}

router.get('/interrogatorio/:id_documento', (req, res) => {
  const query = interrogatorio_questions_query(req.params.id_documento);
  db.query(query)
  .then(data => {
    res.status(200).json(data[0]);
  })
  .catch(error => {
    res.status(500).json([error]);
  });
})

router.post('/save_contabilidad', bodyParse, (req, res) => {
  const query = `SELECT ae_add_contabilidad(
    ${req.body.id_documento},
    ${req.body.institucion ? req.body.institucion.nombre : 'NULL'},
    ${req.body.institucion ? req.body.institucion.descripcion : 'NULL'},

    ${req.body.ej_fiscal.fecha_inicio || 'NULL'},
    ${req.body.ej_fiscal.precision_inicio || 'NULL'},
    ${req.body.ej_fiscal.fecha_fin || 'NULL'},
    ${req.body.ej_fiscal.precision_fin || 'NULL'},

    ${req.body.info_lineas.fecha || 'NULL'},
    ${req.body.info_lineas.precision_fecha || 'NULL'},
    ${req.body.info_lineas.id_lugar || 'NULL'},
    ${req.body.info_lineas.tipo_lugar || 'NULL'},
    ${req.body.info_lineas.precision_lugar || 'NULL'},
    ${req.body.info_lineas.adelanto || 'NULL'},

    ${checkEmptyJsonArray(req.body.tesorero)},
    ${checkEmptyJsonArray(req.body.contador)},
    ${checkEmptyJsonArray(req.body.factor)},
    ${checkEmptyJsonArray(req.body.tomador)},
    ${checkEmptyJsonArray(req.body.veedor)},
    ${checkEmptyJsonArray(req.body.receptor)},
    ${checkEmptyJsonArray(req.body.lineas)}
  )`;

  db.query(query)
  .then(data => {
    res.status(200).json(data[0]);
  })
  .catch(error => {
    res.status(500).json([error]);
  });
});

router.get('/contabilidad/:id_documento', (req, res) => {
  const id_doc = req.params.id_documento;
  const query = `
    SELECT d.id_documento as id_document,
    ${selectHistoricPersonWithRole('Tesorero', 'tesorero')},
    ${selectHistoricPersonWithRole('Contador', 'contador')},
    ${selectHistoricPersonWithRole('Factor', 'factor')},
    ${selectHistoricPersonWithRole('Tomador', 'tomador')},
    ${selectHistoricPersonWithRole('Veedor', 'veedor')},
    ${selectHistoricPersonWithRole('Receptor', 'receptor')},
    ${selectInstitution('Institución', 'institucion')},
    (
      SELECT coalesce(
        json_agg(lineas.json_build_object),
        '[]'::json
      ) as lineas FROM (
        SELECT json_build_object(
          'id_linea', l.id_linea,
          'tipo', l.descripcion,
          'valor', lru.valor,
          'moneda', lru.fk_unidad_nombre
        )
        FROM pertenencia p
        JOIN pertenencia_rel_agrupacion_bienes prab ON prab.fk_pertenencia_id = p.id_pertenencia
        JOIN agrupacion_bienes ab ON prab.fk_agrupacion_bienes_id = ab.id_agrupacion_bienes
        LEFT JOIN linea l ON l.fk_agrupacion_bienes_id = ab.id_agrupacion_bienes
        LEFT JOIN linea_rel_unidad lru ON lru.fk_linea_id = l.id_linea
        WHERE p.tipo_atr_doc='Contabilidad' AND p.fk_documento_id=d.id_documento AND ab.nombre = 'Contabilidad'
      ) as lineas
    ),
    (
      SELECT json_build_object(
        'fecha', ab.fecha,
        'precision_fecha', ab.precision_fecha,
        'id_lugar', ab.fk_lugar_id,
        'nombre_lugar', l.nombre,
        'tipo_lugar', l.fk_tipo_lugar_nombre,
        'precision_lugar', ab.precision_lugar,
        'adelanto', ab.adelanto_cont
      ) as info_lineas
      FROM pertenencia p
      JOIN pertenencia_rel_agrupacion_bienes prab ON prab.fk_pertenencia_id = p.id_pertenencia
      JOIN agrupacion_bienes ab ON prab.fk_agrupacion_bienes_id = ab.id_agrupacion_bienes
      LEFT JOIN lugar l ON l.id_lugar = ab.fk_lugar_id
      WHERE p.tipo_atr_doc='Contabilidad' AND p.fk_documento_id=d.id_documento AND ab.nombre = 'Contabilidad'
    ),
    (
      SELECT json_build_object(
        'fecha_inicio', p.fecha_inicio,
        'fecha_fin', p.fecha_fin,
        'precision_inicio', p.precision_inicio,
        'precision_fin', p.precision_fin
      ) as ej_fiscal
      FROM pertenencia p
      WHERE p.tipo_atr_doc='Contabilidad' AND p.fk_documento_id=d.id_documento
    ),
    (
      SELECT coalesce(
        json_agg(desgloses.json_build_object),
        '[]'::json
      ) as desgloses FROM (
        SELECT json_build_object(
          'objeto', json_build_object(
            'nombre', o.nombre,
            'id_objeto', o.id_objeto
          ),
          'concepto', l.descripcion,
          'id_agrupacion_bienes', ab.id_agrupacion_bienes,
          'id_pertenencia', p.id_pertenencia,
          'id_linea', l.id_linea,
          'masinfo', ab.descripcion_cont,
          'fecha_ingreso', ab.fecha,
          'precision_fecha', ab.precision_fecha,
          'id_lugar_ingreso', ab.fk_lugar_id,
          'precision_lugar_ingreso', ab.precision_lugar,
          'nombre_lugar_ingreso', lu.nombre,
          'tipo_lugar_ingreso', lu.fk_tipo_lugar_nombre,
          'folio', ab.folio_cont,
          'adelanto', ab.adelanto_cont
        )
        FROM pertenencia p
        JOIN pertenencia_rel_agrupacion_bienes prab ON prab.fk_pertenencia_id = p.id_pertenencia
        JOIN agrupacion_bienes ab ON prab.fk_agrupacion_bienes_id = ab.id_agrupacion_bienes
        JOIN linea l ON l.fk_agrupacion_bienes_id = ab.id_agrupacion_bienes
        LEFT JOIN objeto o ON l.fk_objeto_id = o.id_objeto
        LEFT JOIN lugar lu ON lu.id_lugar = ab.fk_lugar_id
        WHERE p.tipo_atr_doc='Desglose' AND p.fk_documento_id=d.id_documento AND ab.nombre = 'Desglose'
      ) as desgloses
    )
    FROM documento d
    WHERE d.id_documento=${id_doc}
  `;

  db.query(query)
  .then(data => {
    res.status(200).json(data[0]);
  })
  .catch(error => {
    res.status(500).json([error]);
  });
})

module.exports = router;
