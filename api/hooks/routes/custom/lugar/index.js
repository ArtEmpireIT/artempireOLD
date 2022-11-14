'use strict';

var express = require('express'),
  router = express.Router(),
  db = require('../../../../config/db'),
  bodyParse = require('../../../../utils/middlewares').bodyParse;


router.get('/_/doc/:id_documento/:search?', function(req, res, next){

  const id_documento = req.params.id_documento,
    search = req.params.search;

  let query = `
    SELECT l.id_lugar, l.nombre, l.fk_tipo_lugar_nombre as tipo_lugar, p.id_pertenencia
    FROM public.lugar l
    LEFT JOIN pertenencia_rel_lugar prl on prl.fk_lugar_id = l.id_lugar
    LEFT JOIN pertenencia p on p.id_pertenencia = prl.fk_pertenencia_id
    WHERE p.fk_documento_id = ${id_documento}
    ORDER BY l.nombre
  `;

  if (search) {
    query += ` AND lower(l.nombre) LIKE lower('%${search}%')`;
  }

  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(500).send([error]);
  });
});

router.get('/place_by_name/:place?', function(req, res, next){
  let query = `
    SELECT l.*, l.fk_tipo_lugar_nombre as tipo_lugar,
    coalesce(ST_AsGeoJSON(point.geom_wgs84)::text, '') || coalesce(ST_AsGeoJSON(line.geom_wgs84)::text, '') || coalesce(ST_AsGeoJSON(polygon.geom_wgs84)::text, '') as geom
    FROM public.lugar l
    LEFT JOIN point on point.id_point = l.fk_point_id
    LEFT JOIN line on line.id_line = l.fk_line_id
    LEFT JOIN polygon on polygon.id_polygon = l.fk_polygon_id
  `;

  if (req.params.place) {
    query += ` WHERE lower(l.nombre) LIKE lower('%${req.params.place}%')`
  }

  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    console.log(error);
    res.status(500).send([error]);
  });
});

router.get('/place_by_id/:id_lugar', function(req, res, next){
  let query = `
    SELECT l.*, l.fk_tipo_lugar_nombre as tipo_lugar,
    coalesce(ST_AsGeoJSON(point.geom_wgs84)::text, '') || coalesce(ST_AsGeoJSON(line.geom_wgs84)::text, '') || coalesce(ST_AsGeoJSON(polygon.geom_wgs84)::text, '') as geom
    FROM public.lugar l
    LEFT JOIN point on point.id_point = l.fk_point_id
    LEFT JOIN line on line.id_line = l.fk_line_id
    LEFT JOIN polygon on polygon.id_polygon = l.fk_polygon_id
    WHERE l.id_lugar = ${req.params.id_lugar}
  `;

  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    console.log(error);
    res.status(500).send([error]);
  });
});

router.get('/place_for_document/:id_documento/:id_lugar', (req, res, next) => {
  const query = `
    SELECT l.id_lugar, l.nombre, l.fk_tipo_lugar_nombre as tipo_lugar, p.tipo_atr_doc as campo, l.localizacion, l.region_cont,
    p.id_pertenencia, p.fk_documento_id as id_documento,
    coalesce(ST_AsGeoJSON(point.geom_wgs84)::text, '') || coalesce(ST_AsGeoJSON(line.geom_wgs84)::text, '') || coalesce(ST_AsGeoJSON(polygon.geom_wgs84)::text, '') as geom,

    (SELECT json_build_object(
      'person',
      (SELECT coalesce(json_agg(people.person), '[]'::json) FROM (
        (
          SELECT json_build_object ('id', ph.id_persona_historica, 'name', ph.nombre, 'type', 'place', 'descripcion', prp.descripcion) as person
          FROM persona_rol_pertenencia_rel_lugar prpl
          LEFT JOIN persona_rol_pertenencia prp on prp.id_persona_rol_pertenencia = prpl.fk_persona_rol_pertenencia_id
          LEFT JOIN pertenencia p on p.id_pertenencia = prp.fk_pertenencia_id
          LEFT JOIN persona_historica ph on ph.id_persona_historica = prp.fk_persona_historica_id
          WHERE p.fk_documento_id = ${req.params.id_documento} AND prpl.fk_lugar_id = ${req.params.id_lugar}
        )
      ) as people)
      ,
      'object',
        (SELECT coalesce(json_agg(objects.object), '[]'::json) FROM (
          (
            SELECT json_build_object ('id', l.id_linea, 'name', o.nombre, 'type', 'object', 'descripcion', prl.descripcion_lugar) as object
            FROM linea_rel_lugar prl
            LEFT JOIN linea l on l.id_linea = prl.fk_linea_id
            LEFT JOIN objeto o on o.id_objeto = l.fk_objeto_id
            WHERE prl.fk_lugar_id  = ${req.params.id_lugar}
          )
        ) as objects)
      ,
      'place', ARRAY[]::text[]
    )) as relations

    FROM public.lugar l
    LEFT JOIN pertenencia_rel_lugar prl on prl.fk_lugar_id = l.id_lugar
    LEFT JOIN pertenencia p on p.id_pertenencia = prl.fk_pertenencia_id
    LEFT JOIN point on point.id_point = l.fk_point_id
    LEFT JOIN line on line.id_line = l.fk_line_id
    LEFT JOIN polygon on polygon.id_polygon = l.fk_polygon_id
    WHERE p.fk_documento_id = ${req.params.id_documento} AND l.id_lugar = ${req.params.id_lugar}
  `;

  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    console.log(error);
    res.status(500).send([error]);
  });

});

router.post('/clear_place_for_document', bodyParse, (req, res) => {
  const id_pertenencia = parseInt(req.body.id_pertenencia) || null;
  const id_documento = parseInt(req.body.id_documento) || null;
  const id_lugar = parseInt(req.body.id_lugar) || null;
  const deletePertenencia = `
    DELETE FROM pertenencia WHERE id_pertenencia in (
      ${id_pertenencia},
      (
        SELECT p.id_pertenencia
        FROM persona_rol_pertenencia_rel_lugar prpl
        LEFT JOIN persona_rol_pertenencia prp on prp.id_persona_rol_pertenencia = prpl.fk_persona_rol_pertenencia_id
        LEFT JOIN pertenencia p on p.id_pertenencia = prp.fk_pertenencia_id
        WHERE p.fk_documento_id = ${id_documento} AND prpl.fk_lugar_id = ${id_lugar}
      )
    ) 
  `
  const deleteObjeto = `DELETE FROM linea_rel_lugar WHERE fk_lugar_id=${id_lugar}`;

  Promise.all([
    db.query(deleteObjeto),
    db.query(deletePertenencia)
  ])
  .then(() => {
    res.status(200).send([]);
  })
  .catch(error => {
    console.log(error);
    res.status(500).send(error);
  });
})

router.post('/save_place_for_document', bodyParse, (req, res, next) => {

  const query = `
    SELECT ae_add_pertenencia_rel_lugar(
      ${req.body.id_lugar},
      ${req.body.nombre},
      ${req.body.tipo_lugar},
      ${req.body.campo},
      ${req.body.localizacion},
      ${req.body.region_cont},
      ${req.body.geom},
      ${req.body.tipo_geom},
      ${req.body.id_pertenencia},
      ${req.body.id_documento},
      ${req.body.relations.person !== 'ARRAY[]::text[]' ? req.body.relations.person : 'ARRAY[]::json[]'},
      ${req.body.relations.object !== 'ARRAY[]::text[]' ? req.body.relations.object : 'ARRAY[]::json[]'}
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

router.post('/save_place_complete', bodyParse, (req, res, next) => {

  const query = `
    SELECT ae_add_lugar_complete(
      ${req.body.id_lugar},
      ${req.body.nombre},
      ${req.body.tipo_lugar},
      ${req.body.localizacion},
      ${req.body.region_cont},
      ${req.body.geom},
      ${req.body.tipo_geom}
    )
  `

  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    console.log(error);
    res.status(500).send([error]);
  });
});

module.exports = router;
