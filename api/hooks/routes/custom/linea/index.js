'use strict';

var express = require('express'),
  router = express.Router(),
  db = require('../../../../config/db');

router.get('/for_contabilidad/:id_agrupacion_bienes', function(req, res, next){

  const query =`
    SELECT
      l.id_linea as id,
      l.descripcion as ingreso,
      l.fk_agrupacion_bienes_id AS id_agrupacion_bienes,
      json_agg(
        json_build_object(
          'unidad', lru.fk_unidad_nombre,
          'valor', lru.valor
        )
      ) as unidades
    FROM linea l join linea_rel_unidad lru
    on l.id_linea=lru.fk_linea_id
    WHERE l.fk_agrupacion_bienes_id=${req.params.id_agrupacion_bienes}
    GROUP BY l.id_linea, l.descripcion, l.fk_agrupacion_bienes_id
    ORDER BY id_linea

  `;
  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(200).send([]);
  });

})

router.get('/relations_for_linea/:id_documento/:id_linea', (req, res, next) => {
  const query = `
  SELECT json_build_object(
    'person',
    (SELECT coalesce(json_agg(people.person), '[]'::json) FROM (
      (
        SELECT json_build_object ('id', ph.id_persona_historica, 'name', ph.nombre, 'type', 'person', 'descripcion', prp.descripcion, 'role', prpr.fk_rol_nombre) as person
        FROM persona_rol_pertenencia_rel_linea prpl
        LEFT JOIN persona_rol_pertenencia prp on prp.id_persona_rol_pertenencia = prpl.fk_persona_rol_pertenencia_id
        LEFT JOIN pertenencia p on p.id_pertenencia = prp.fk_pertenencia_id
        LEFT JOIN persona_historica ph on ph.id_persona_historica = prp.fk_persona_historica_id
        LEFT JOIN persona_rol_pertenencia_rel_rol prpr ON prpr.fk_persona_rol_pertenencia = prp.id_persona_rol_pertenencia
        WHERE p.fk_documento_id = ${req.params.id_documento} AND prpl.fk_linea = ${req.params.id_linea}
      )
    ) as people)
    ,
    'object', ARRAY[]::text[]
    ,
    'place',
      (SELECT coalesce(json_agg(places.place), '[]'::json) FROM (
        (
          SELECT json_build_object ('id', l.id_lugar, 'name', l.nombre, 'type', 'place', 'descripcion', prl.descripcion_lugar) as place
          FROM linea_rel_lugar prl
          LEFT JOIN lugar l on l.id_lugar = prl.fk_lugar_id
          WHERE prl.fk_linea_id = ${req.params.id_linea}
        )
      ) as places)
  ) as relations
  `;

  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(500).send([error]);
  });

})

router.get('/completion/:key', (req, res) => {
  const q = req.query.q.toLowerCase();
  const key = req.params.key;
  const query = `
    SELECT distinct(lower("${key}")) as "${key}" 
    FROM linea
    WHERE "${key}" ILIKE '%${q}%'
    ORDER BY lower("${key}")
  `;
  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(500).send([error]);
  });
})

module.exports = router;
