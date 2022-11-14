'use strict';

var express = require('express'),
  router = express.Router(),
  db = require('../../../../config/db');

router.get('/:id_persona_historica', (req, res, next) => {
  const id_persona_historica = req.params.id_persona_historica;

  var query = `
    SELECT
       ph.id_persona_historica,
       ph.nombre,
       prp.oficio,
       prp.fk_rol_nombre as rol,
       pemision.fecha_inicio,
       pemision.fk_lugar_nombre as lugar,
       COALESCE(p.tipo_atr_doc, p.motivo) AS descripcion,
       p.tipo_atr_doc,
       p.motivo
     FROM persona_historica ph
     LEFT JOIN persona_rol_pertenencia prp ON prp.fk_persona_historica_id=ph.id_persona_historica
     LEFT JOIN pertenencia p ON p.id_pertenencia=prp.fk_pertenencia_id
     LEFT JOIN documento d ON d.id_documento=p.fk_documento_id
     LEFT JOIN (
       SELECT
         p.id_pertenencia,
         p.fecha_inicio,
         p.tipo_atr_doc,
         p.fk_documento_id,
         prl.fk_lugar_nombre
       FROM pertenencia p LEFT JOIN pertenencia_rel_lugar prl ON p.id_pertenencia=prl.fk_pertenencia_id) AS
     pemision ON (pemision.fk_documento_id=d.id_documento AND (pemision.tipo_atr_doc='Emisión' OR pemision.tipo_atr_doc='Creación Documento'))
     WHERE ph.id_persona_historica=${id_persona_historica}
     ORDER BY id_persona_historica ASC`;

    db.query(query)
    .then(data => {
      res.status(200).send(data[0]);
    })
    .catch(error => {
      res.status(200).send([]);
    });


})

router.post('/clear_person_and_relations', (req, res) => {
  const id_documento = parseInt(req.body.id_documento) || null;
  const id_persona_historica = parseInt(req.body.id_persona_historica) || null;
  const id_pertenencia_persona = parseInt(req.body.id_pertenencia_persona) || null;
  const query = `
    DELETE FROM pertenencia 
    WHERE fk_documento_id=${id_documento} 
    AND (id_pertenencia = ${id_pertenencia_persona} OR id_pertenencia in (
      (
        (
          SELECT p.id_pertenencia
          FROM persona_rol_pertenencia prpb
          LEFT JOIN pertenencia p on p.id_pertenencia = prpb.fk_pertenencia_id
          LEFT JOIN persona_rol_pertenencia prpa on prpa.id_persona_rol_pertenencia = prpb.fk_persona_rol_pertenencia_id
          WHERE p.fk_documento_id = ${id_documento} AND prpb.fk_persona_historica_id = ${id_persona_historica}
        ) UNION ALL (
          SELECT p.id_pertenencia
          FROM persona_rol_pertenencia prpb
          LEFT JOIN pertenencia p on p.id_pertenencia = prpb.fk_pertenencia_id
          INNER JOIN persona_rol_pertenencia prpa on prpa.id_persona_rol_pertenencia = prpb.fk_persona_rol_pertenencia_id
          WHERE p.fk_documento_id = ${id_documento} AND prpb.fk_persona_historica_id = ${id_persona_historica}
        )
      )
    ))
  `;
  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    console.error(error);
    res.status(500).send(error);
  });
})

router.get('/_/doc/:id_documento/:search?', function(req, res, next){

  const id_documento = req.params.id_documento;
  const search = req.params.search ? `
    AND lower(ph.nombre) LIKE lower('%${req.params.search}%')` : '';

  const query = `
    SELECT
      p.*,
      prp.*,
      ph.*
    FROM documento d
    JOIN pertenencia p ON d.id_documento = p.fk_documento_id
    JOIN persona_rol_pertenencia prp ON p.id_pertenencia=prp.fk_pertenencia_id
    JOIN persona_historica ph ON prp.fk_persona_historica_id=ph.id_persona_historica
    WHERE d.id_documento='${id_documento}'
    AND prp.fk_persona_rol_pertenencia_id is null
    -- AND prp.id_persona_rol_pertenencia not in (SELECT fk_persona_rol_pertenencia_id FROM persona_rol_pertenencia_rel_linea WHERE fk_persona_rol_pertenencia_id is not null)
    -- AND prp.id_persona_rol_pertenencia not in (SELECT fk_persona_rol_pertenencia_id FROM persona_rol_pertenencia prp LEFT JOIN persona_historica ph on ph.id_persona_historica = prp.fk_persona_historica_id WHERE ph.nombre!='Anónimo' AND prp.fk_persona_rol_pertenencia_id is not null)
    -- AND (p.motivo is null or p.motivo != 'Creación de relación')
    AND ph.nombre!='Anónimo'
    AND prp.is_relation = false
    ${search}
    ORDER BY nombre
    `;


  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(200).send([]);
  });

})

router.get('/:tipo_atr_doc/:id_documento/:id_linea?', function(req, res, next){

  var id_documento = req.params.id_documento;
  var tipo_atr_doc = req.params.tipo_atr_doc;
  var id_linea = req.params.id_linea;

  var query = `
  SELECT
     d.id_documento,
     p.id_pertenencia,
     p.motivo,
     p.tipo_atr_doc,
     prp.id_persona_rol_pertenencia,
     prp.descripcion,
     COALESCE(ins.nombre, ph.nombre) as nombre,
     (CASE WHEN ins.nombre IS NOT NULL THEN 'institution' ELSE 'person' END) AS tipo,
     ph.id_persona_historica
    FROM documento d
    JOIN pertenencia p ON d.id_documento = p.fk_documento_id
    JOIN persona_rol_pertenencia prp ON p.id_pertenencia=prp.fk_pertenencia_id
   LEFT JOIN persona_historica ph ON prp.fk_persona_historica_id=ph.id_persona_historica
   LEFT JOIN persona_rol_pertenencia_rel_institucion prpi ON prp.id_persona_rol_pertenencia=prpi.fk_persona_rol_pertenencia_id
   LEFT JOIN institucion ins ON ins.nombre=prpi.fk_institucion_nombre
   `;

  if(id_linea){
    query = `${query}
    LEFT JOIN persona_rol_pertenencia_rel_linea prprl ON prprl.fk_persona_rol_pertenencia_id=prp.id_persona_rol_pertenencia
    LEFT JOIN linea l ON l.id_linea=prprl.fk_linea`;
  }

  query = `${query}
    WHERE d.id_documento='${id_documento}'
    AND p.tipo_atr_doc='${tipo_atr_doc}'`;

  if(id_linea){
    query = `${query}
    AND l.id_linea=${id_linea}`;
  }

  console.log(query);

  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(200).send([]);
  });

})






router.get('/completion', (req, res, next) => {

  var query = `
    SELECT
      prp.*,
      ph.*,
      p.*
    FROM persona_rol_pertenencia prp
    LEFT JOIN persona_historica ph ON prp.fk_persona_historica_id=ph.id_persona_historica
    LEFT JOIN pertenencia p ON p.id_pertenencia=prl.fk_pertenencia_id
    WHERE (UPPER(ph.nombre) LIKE '%${req.query.q.toUpperCase()}%')
    ORDER BY nombre`;


  console.log(query);

  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(200).send([]);
  });

});

module.exports = router;
