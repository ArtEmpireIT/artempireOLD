'use strict';

var express = require('express'),
  router = express.Router(),
  db = require('../../../../config/db'),
  responseValidator = require('../../../../utils/middlewares').responseValidator,
  bodyParse = require('../../../../utils/middlewares').bodyParse,
  resProcessor = require('../../../../utils/resProcessor');

router.post('/', bodyParse, (req, res) => {
  const query = `
    SELECT ae_add_persona(
      ${req.body.id_persona_historica},
      ${req.body.nombre_persona_historica || null},
      ${req.body.genero || null }
    )`;
  resProcessor(query, res);
});

router.get('/search/:search?', (req, res, next) => {

  if (req.params.search) {
    const query = `
      SELECT data.*,
      (
        SELECT json_build_object(
          'id_persona_rol_pertenencia', prp.id_persona_rol_pertenencia,
          'descripcion', prp.descripcion,
          'tipo_doc', d.tipo,
          'campo', p.tipo_atr_doc,
          'fecha_inicio', p.fecha_inicio,
          'roles', (SELECT ARRAY(SELECT fk_rol_nombre FROM persona_rol_pertenencia_rel_rol prpr WHERE prpr.fk_persona_rol_pertenencia = prp.id_persona_rol_pertenencia)),
          'ocupaciones', (SELECT ARRAY(SELECT fk_ocupacion_nombre FROM persona_rol_pertenencia_rel_ocupacion prpo WHERE prpo.fk_persona_rol_pertenencia_id = prp.id_persona_rol_pertenencia)),
          'cargos', (SELECT ARRAY(SELECT fk_cargo_nombre FROM persona_rol_pertenencia_rel_cargo prpc WHERE prpc.fk_persona_rol_pertenencia_id = prp.id_persona_rol_pertenencia))
        ) as page
        FROM  persona_rol_pertenencia prp
        INNER JOIN pertenencia p on p.id_pertenencia = prp.fk_pertenencia_id
        INNER JOIN documento d on d.id_documento = p.fk_documento_id
        WHERE prp.id_persona_rol_pertenencia = data.ids_persona_rol_pertenencia[1]
      )
      FROM (
        SELECT ph.id_persona_historica, ph.nombre, ph.genero,
          (
            SELECT ARRAY (
              SELECT prp.id_persona_rol_pertenencia 
              FROM persona_rol_pertenencia prp 
              INNER JOIN pertenencia p ON p.id_pertenencia = prp.fk_pertenencia_id
              WHERE p.fk_documento_id IS NOT NULL 
              AND COALESCE(prp.is_relation, FALSE) = FALSE
              AND prp.fk_pertenencia_id IS NOT NULL 
              AND (p.motivo is null or p.motivo != 'Creación de relación') 
              AND prp.fk_persona_historica_id = ph.id_persona_historica 
              ORDER BY prp.id_persona_rol_pertenencia
            )
          ) as ids_persona_rol_pertenencia
        FROM persona_historica ph
        WHERE lower(ph.nombre) LIKE lower('%${req.params.search}%') 
        AND ph.nombre != 'Anónimo'
        ORDER BY ph.nombre
      ) as data
      ORDER BY data.nombre, coalesce(array_length(data.ids_persona_rol_pertenencia, 1),0) DESC
    `

    db.query(query)
    .then(data => {
      res.status(200).send(data[0]);
    })
    .catch(error => {
      res.status(200).send([]);
    });

  }else {
    res.status(200).send([]);
  }

})

router.get('/search/page/:id?', (req, res, next) => {

  const query = `
    SELECT json_build_object(
      'id_persona_rol_pertenencia', prp.id_persona_rol_pertenencia,
      'descripcion', prp.descripcion,
      'tipo_doc', d.tipo,
      'fecha_inicio', p.fecha_inicio,
      'campo', p.tipo_atr_doc,
      'roles', (SELECT ARRAY(SELECT fk_rol_nombre FROM persona_rol_pertenencia_rel_rol prpr WHERE prpr.fk_persona_rol_pertenencia = prp.id_persona_rol_pertenencia)),
      'ocupaciones', (SELECT ARRAY(SELECT fk_ocupacion_nombre FROM persona_rol_pertenencia_rel_ocupacion prpo WHERE prpo.fk_persona_rol_pertenencia_id = prp.id_persona_rol_pertenencia)),
      'cargos', (SELECT ARRAY(SELECT fk_cargo_nombre FROM persona_rol_pertenencia_rel_cargo prpc WHERE prpc.fk_persona_rol_pertenencia_id = prp.id_persona_rol_pertenencia))
    ) as page
    FROM  persona_rol_pertenencia prp
    INNER JOIN pertenencia p on p.id_pertenencia = prp.fk_pertenencia_id
    INNER JOIN documento d on d.id_documento = p.fk_documento_id
    WHERE prp.id_persona_rol_pertenencia = ${req.params.id}
  `;

  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(200).send([]);
  });

})

router.get('/completion/:keyword?', (req, res, next) => {

  const filter = (req.params.keyword) ? `AND nombre ILIKE '%${req.params.keyword}%'` : '';
  const kind = (req.query.kind && req.query.kind !== 'both') ? ` AND tipo='${req.query.kind}'` : `AND (tipo ='person' OR tipo='institution')`;

  var query = `
    SELECT
      *
    FROM (
      (SELECT
        id_persona_historica,
        'person' as tipo,
        nombre
      FROM persona_historica
      WHERE nombre!='Anónimo'
      ${filter})
      UNION ALL
      (SELECT
        DISTINCT
        ROW_NUMBER() OVER() as id_persona_historica,
        'institution' as tipo,
        nombre
      FROM institucion
      WHERE nombre !=''
      ${filter})

    ) u
    WHERE nombre !=''
    ${filter}
    ${kind}
    ORDER BY nombre`;

  resProcessor(query, res);

});

router.get('/person_for_document/:id_documento/:id_pertenencia', (req, res, next) => {

  const query = `
    SELECT json_build_object(
      'id_persona_historica', ph.id_persona_historica,
      'nombre',ph.nombre,
      'genero', ph.genero
    ) as persona_historica,
    pt.id_pertenencia,
    prp.id_persona_rol_pertenencia,
    prp.descripcion,
    pt.tipo_atr_doc as campo,
    pt.fk_documento_id as documento_id,
    ARRAY(
      SELECT c.nombre FROM persona_rol_pertenencia_rel_cargo prpc
      INNER JOIN cargo c on prpc.fk_cargo_nombre = c.nombre
      WHERE prpc.fk_persona_rol_pertenencia_id = prp.id_persona_rol_pertenencia
    ) as cargos,
    ARRAY(
      SELECT o.nombre FROM persona_rol_pertenencia_rel_ocupacion prpo
      INNER JOIN ocupacion o on prpo.fk_ocupacion_nombre = o.nombre
      WHERE prpo.fk_persona_rol_pertenencia_id = prp.id_persona_rol_pertenencia
    ) as ocupaciones,
    ARRAY(
      SELECT r.nombre FROM persona_rol_pertenencia_rel_rol prpr
      INNER JOIN rol r on prpr.fk_rol_nombre = r.nombre
      WHERE prpr.fk_persona_rol_pertenencia = prp.id_persona_rol_pertenencia
    ) as roles,
    prp.edad_min as _edad_min,
    prp.edad_max as _edad_max,
    prp.edad_recodificada,
    pt.fecha_inicio,
    pt.fecha_fin,
    pt.precision_inicio as precision_fecha_inicio,
    pt.precision_fin as precision_fecha_fin,
    json_build_object(
      'id_lugar', l.id_lugar, 'nombre', l.nombre
    ) as origen,
    json_build_object(
      'nombre', i.nombre, 'fecha_creacion', i.fecha_creacion, 'descripcion', i.descripcion, 'id_lugar_institucion', linst.id_lugar, 'lugar_institucion', linst.nombre
    ) as institucion,
    json_build_object(
      'id_lugar', linst.id_lugar, 'nombre', linst.nombre
    ) as institucion_lugar
    
    FROM public.persona_historica ph
    LEFT JOIN persona_rol_pertenencia prp on prp.fk_persona_historica_id = ph.id_persona_historica
    LEFT JOIN public.pertenencia pt on pt.id_pertenencia = prp.fk_pertenencia_id
    LEFT JOIN persona_rol_pertenencia_rel_institucion prpi on prpi.fk_persona_rol_pertenencia_id = prp.id_persona_rol_pertenencia
    LEFT JOIN institucion i on i.nombre = prpi.fk_institucion_nombre

    LEFT JOIN persona_rol_pertenencia_rel_lugar prpl on prpl.fk_persona_rol_pertenencia_id = prp.id_persona_rol_pertenencia
    LEFT JOIN lugar l on l.id_lugar = prpl.fk_lugar_id

    LEFT JOIN persona_rol_pertenencia_rel_lugar prplinst on prplinst.fk_persona_rol_pertenencia_id = (SELECT id_persona_rol_pertenencia FROM persona_rol_pertenencia where fk_persona_historica_id = (SELECT id_persona_historica FROM persona_historica WHERE nombre='Anónimo' ORDER BY id_persona_historica  LIMIT 1) AND fk_persona_rol_pertenencia_id = prp.id_persona_rol_pertenencia)
    LEFT JOIN lugar linst on linst.id_lugar = prplinst.fk_lugar_id
    WHERE pt.fk_documento_id = ${req.params.id_documento}
    AND pt.id_pertenencia = ${req.params.id_pertenencia}
    AND prp.is_relation = FALSE
  `;

  db.query(query)
  .then(data => {
    const person = data[0][0]
    const queryForRelations = `
      SELECT json_build_object(
        'person',
        (
          SELECT COALESCE(
            array_agg(people.person),
            ARRAY[]::jsonb[]
          ) FROM (
            SELECT jsonb_build_object(
              'id_persona_historica', ph_relation.id_persona_historica,
              'nombre', ph_relation.nombre,
              'genero', ph_relation.genero,
              'descripcion', prp_relation.descripcion,
              'id_prp', prp_relation.id_persona_rol_pertenencia,
              'id_pertenencia', prp_relation.fk_pertenencia_id,
              'changedRelationOrder', FALSE
            ) as person
            FROM persona_rol_pertenencia prp
            JOIN persona_rol_pertenencia prp_relation
              ON prp_relation.fk_persona_rol_pertenencia_id = prp.id_persona_rol_pertenencia
            JOIN persona_historica ph_relation
              ON prp_relation.fk_persona_historica_id = ph_relation.id_persona_historica
            WHERE prp.is_relation = TRUE
            AND prp_relation.is_relation = TRUE
            AND prp.fk_pertenencia_id = ${person.id_pertenencia}

            UNION ALL 

            SELECT jsonb_build_object(
              'id_persona_historica', ph_relation.id_persona_historica,
              'nombre', ph_relation.nombre,
              'genero', ph_relation.genero,
              'descripcion', prp_relation.descripcion,
              'id_prp', prp_relation.id_persona_rol_pertenencia,
              'id_pertenencia', prp_relation.fk_pertenencia_id,
              'changedRelationOrder', TRUE
            ) as person
            FROM persona_rol_pertenencia prp
            JOIN persona_rol_pertenencia prp_relation
              ON prp.fk_persona_rol_pertenencia_id = prp_relation.id_persona_rol_pertenencia
            JOIN persona_historica ph_relation
              ON prp_relation.fk_persona_historica_id = ph_relation.id_persona_historica
            WHERE prp.is_relation = TRUE
            AND prp_relation.is_relation = TRUE
            AND prp.fk_pertenencia_id = ${person.id_pertenencia}
          ) as people
        ),
        'object',
        (SELECT coalesce(json_agg(objects.object), '[]'::json) FROM (
          (
            SELECT json_build_object (
              'id', prpl.fk_linea,
              'nombre', o.nombre,
              'descripcion', prp.descripcion
            ) as object
            FROM persona_rol_pertenencia_rel_linea prpl
            LEFT JOIN persona_rol_pertenencia prp on prp.id_persona_rol_pertenencia = prpl.fk_persona_rol_pertenencia_id
            LEFT JOIN pertenencia p on p.id_pertenencia = prp.fk_pertenencia_id
            LEFT JOIN linea l on l.id_linea = prpl.fk_linea
            LEFT JOIN objeto o on o.id_objeto = l.fk_objeto_id
            WHERE p.fk_documento_id = ${req.params.id_documento}
            AND prp.fk_persona_historica_id = ${person.persona_historica.id_persona_historica}
          )
        ) as objects),
        'place',
        (SELECT coalesce(json_agg(places.place), '[]'::json) FROM (
          (
            SELECT json_build_object (
              'id', prpl.fk_lugar_id,
              'nombre', l.nombre,
              'descripcion', prp.descripcion
            ) as place
            FROM persona_rol_pertenencia_rel_lugar prpl
            LEFT JOIN persona_rol_pertenencia prp on prp.id_persona_rol_pertenencia = prpl.fk_persona_rol_pertenencia_id
            LEFT JOIN pertenencia p on p.id_pertenencia = prp.fk_pertenencia_id
            LEFT JOIN lugar l on l.id_lugar = prpl.fk_lugar_id
            WHERE p.fk_documento_id = ${req.params.id_documento}
            AND prp.fk_persona_historica_id = ${person.persona_historica.id_persona_historica}
            AND prp.fk_pertenencia_id != ${person.id_pertenencia}
          )
        ) as places)
      ) as relations
    `;

    return db.query(queryForRelations)
    .then(relations => {
      person.relations = relations[0][0].relations;
      return person
    })
  })
  .then(data => {
    res.status(200).send([data]);
  })
  .catch(error => {
    console.error(error);
    res.status(500).send([error]);
  });

});

router.post('/save_person_for_document', bodyParse, (req, res, next) => {

  const query = `
    SELECT ae_add_persona_rol_pertenencia(
      ${req.body.persona_historica.id_persona_historica},
      ${req.body.persona_historica.nombre},
      ${req.body.persona_historica.genero},
      ${req.body.id_pertenencia},
      ${req.body.fecha_inicio},
      ${req.body.fecha_fin},
      ${req.body.precision_fecha_inicio},
      ${req.body.precision_fecha_fin},
      ${req.body.campo},
      ${req.body.documento_id},
      ${req.body.id_persona_rol_pertenencia},
      ${req.body._edad_min},
      ${req.body._edad_max},
      ${req.body.descripcion},
      ${req.body.edad_recodificada},
      ${req.body.roles},
      ${req.body.cargos},
      ${req.body.ocupaciones},
      ${req.body.origen.id_lugar},
      ${req.body.origen.nombre},
      ${req.body.institucion.nombre},
      ${req.body.institucion.fecha_creacion},
      ${req.body.institucion.descripcion},
      ${req.body.institucion_lugar.id_lugar},
      ${req.body.institucion_lugar.nombre},
      ${req.body.relations.object !== 'ARRAY[]::text[]' ? req.body.relations.object : 'ARRAY[]::json[]'},
      ${req.body.relations.place !== 'ARRAY[]::text[]' ? req.body.relations.place : 'ARRAY[]::json[]'},
      ${req.body.relations.person !== 'ARRAY[]::text[]' ? req.body.relations.person : 'ARRAY[]::json[]'}
    )
  `
  db.query(query)
  .then(data => {
    res.status(200).send([]);
  })
  .catch(error => {
    console.log(error);
    res.status(500).send([error]);
  });

});

module.exports = router;
