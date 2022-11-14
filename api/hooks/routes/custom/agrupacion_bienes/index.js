'use strict';

var express = require('express'),
  router = express.Router(),
  db = require('../../../../config/db'),
  responseValidator = require('../../../../utils/middlewares').responseValidator,
  bodyParse = require('../../../../utils/middlewares').bodyParse,
  resProcessor = require('../../../../utils/resProcessor');



// Just for Mandas
router.get('/:id', function(req, res, next){

  var query = `
    SELECT
      p.id_pertenencia,
      ab.id_agrupacion_bienes,
      ab.nombre,
      ab.descripcion_cont as descripcion,

      (
        SELECT array_agg(json_build_object(
          'nombre', o.nombre,
          'numero', l.cantidad,
          'descripcion', l.descripcion,
          'id_linea', l.id_linea
        ) ORDER BY l.id_linea ) as json FROM objeto o
        JOIN linea l ON l.fk_objeto_id = o.id_objeto
        WHERE l.fk_agrupacion_bienes_id = ab.id_agrupacion_bienes
      ) as objetos,

      (
        SELECT array_agg(json_build_object(
          'nombre', au.fk_unidad_nombre,
          'value', au.valor,
          'is_tax', TRUE
        )) FROM agrupacion_bienes_rel_unidad au
        WHERE au.fk_agrupacion_bienes_id = ab.id_agrupacion_bienes
      ) as units

    FROM pertenencia p
    JOIN pertenencia_rel_agrupacion_bienes prab ON p.id_pertenencia = prab.fk_pertenencia_id
    JOIN agrupacion_bienes ab ON ab.id_agrupacion_bienes = prab.fk_agrupacion_bienes_id
    WHERE p.fk_documento_id=${req.params.id}
    AND p.tipo_atr_doc = 'Transacción_bienes'
    GROUP BY p.id_pertenencia, ab.id_agrupacion_bienes`;

  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(500).send(error);
  });

})


router.delete('/:id_agrupacion_bienes/:id_pertenencia', function(req, res, next){

  var query = `
    DELETE FROM pertenencia_rel_agrupacion_bienes where fk_agrupacion_bienes_id=${req.params.id_agrupacion_bienes}
      AND fk_pertenencia_id=${req.params.id_pertenencia};
    DELETE FROM pertenencia where id_pertenencia=${req.params.id_pertenencia};
    DELETE FROM linea where fk_agrupacion_bienes_id = ${req.params.id_agrupacion_bienes};
    DELETE FROM agrupacion_bienes WHERE id_agrupacion_bienes=${req.params.id_agrupacion_bienes};
  `;



  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(200).send([]);
  });

})


router.get('/desglose/:id_pertenencia', function (req, res, next){

  const query = `

       WITH _lugares AS (
         SELECT
          DISTINCT
           lugar.id_lugar,
           lugar.nombre,
           lugar.fk_tipo_lugar_nombre
         FROM lugar ORDER BY id_lugar
      ),
       _personas AS (

        SELECT
          prprl.fk_linea AS id_linea,
          json_agg(
            json_build_object(
              'id_persona_historica', _prprol.fk_persona_historica_id,
              'id_persona_rol_pertenencia', _prprol.id_persona_rol_pertenencia,
              'nombre', _prprol.nombre,
              'roles', _prprol.roles
            )
          ) as personas
        FROM persona_rol_pertenencia_rel_linea prprl LEFT JOIN
        (
          SELECT
            prp.id_persona_rol_pertenencia,
            prp.fk_persona_historica_id,
            ph.nombre,
            json_agg(
              json_build_object(
                'rol', prprol.fk_rol_nombre
              )
            ) AS roles
          FROM persona_rol_pertenencia prp JOIN persona_rol_pertenencia_rel_rol prprol
          ON prp.id_persona_rol_pertenencia=prprol.fk_persona_rol_pertenencia
          LEFT JOIN persona_historica ph ON prp.fk_persona_historica_id=ph.id_persona_historica
          GROUP BY prp.id_persona_rol_pertenencia, ph.nombre
        )
        _prprol ON
        _prprol.id_persona_rol_pertenencia=prprl.fk_persona_rol_pertenencia_id
        GROUP BY prprl.fk_linea

       ),
       _lineas AS (
         SELECT
           linea.id_linea,
           linea.fk_agrupacion_bienes_id,
           linea.descripcion,
           json_agg(
             json_build_object(
               'id_linea', lru.fk_linea_id,
               'valor', lru.valor,
               'unidad', lru.fk_unidad_nombre
             )
           ) as unidades,
           json_agg(
            json_build_object(
              'personas', personas
            )
           ) as personas
         FROM linea LEFT JOIN linea_rel_unidad lru ON linea.id_linea=lru.fk_linea_id
         LEFT JOIN _personas ON linea.id_linea=_personas.id_linea
         GROUP BY linea.id_linea, linea.fk_agrupacion_bienes_id, linea.descripcion
       ),
       _agrupaciones AS (
        SELECT
          ab.*,

          json_agg(
            json_build_object(
              'id_linea', _lineas.id_linea,
              'descripcion', _lineas.descripcion,
              'unidades', _lineas.unidades,
              'personas', _lineas.personas
            )
          ) as lineas,

          json_agg(
            json_build_object(
            'id_lugar', _lugares.id_lugar,
            'nombre', _lugares.nombre,
            'tipo_lugar', _lugares.fk_tipo_lugar_nombre
            )
          ) as lugares

          FROM agrupacion_bienes ab
          LEFT JOIN _lineas ON ab.id_agrupacion_bienes=_lineas.fk_agrupacion_bienes_id
          LEFT JOIN _lugares ON ab.fk_lugar_id=_lugares.id_lugar
          WHERE ab.nombre='Desglose'
          GROUP BY ab.id_agrupacion_bienes
      )
       SELECT
         p.*,
         json_agg(
          json_build_object(
            'id_agrupacion_bienes', ab.id_agrupacion_bienes,
            'nombre', ab.nombre,
            'fecha', ab.fecha,
            'precision_fecha', ab.precision_fecha,
            'adelanto_cont', ab.adelanto_cont,
            'descripcion_cont', ab.descripcion_cont,
            'folio_cont', ab.folio_cont,
            'fk_metodo_pago_id', ab.fk_metodo_pago_id,
            'precision_lugar', ab.precision_lugar,
            'fk_lugar_id', ab.fk_lugar_id,
            'lineas', ab.lineas,
            'lugares', ab.lugares
          )
         ) as agrupaciones
       FROM
         pertenencia p
         JOIN pertenencia_rel_agrupacion_bienes prab ON p.id_pertenencia=prab.fk_pertenencia_id
         JOIN _agrupaciones ab ON prab.fk_agrupacion_bienes_id=ab.id_agrupacion_bienes
       WHERE p.id_pertenencia=${req.params.id_pertenencia}
       GROUP BY p.id_pertenencia
  `;

  resProcessor(query, res);
});

var desgloseValidator = function (req, res, next) {
  req.checkBody('id_documento', 'requerido').notEmpty();
  req.checkBody('concepto', 'requerido').notEmpty();
  return next();
};

const checkEmptyJsonArray = item => (
  item === 'ARRAY[]::text[]' ? 'ARRAY[]::json[]' : item
)

router.post('/units', bodyParse, (req, res) => {
  const query = `SELECT ae_add_unidades_agrupacion(
    ${req.body.id_agrupacion},
    ${checkEmptyJsonArray(req.body.units)}
  )`;
  resProcessor(query, res);
})

router.post('/desglose',
  desgloseValidator,
  responseValidator,
  bodyParse,
  function (req, res) {

    const query = `SELECT ae_add_desglose(
      ${req.body.id_documento},
      ${req.body.id_pertenencia},
      ${req.body.id_agrupacion_bienes},

      ${req.body.objeto.nombre || null},
      ${req.body.objeto.id_objeto || null},

      ${req.body.concepto},
      ${req.body.masinfo},

      ${req.body.id_linea},
      ${checkEmptyJsonArray(req.body.lineas)},

      ${req.body.fecha_ingreso},
      ${req.body.precision_fecha},

      ${req.body.id_lugar_ingreso},
      NULL,
      ${req.body.tipo_lugar_ingreso},
      ${req.body.precision_lugar_ingreso},

      ${req.body.folio},
      ${req.body.adelanto},

      ${checkEmptyJsonArray(req.body.persons)}
    )`;
    resProcessor(query, res);
  });

module.exports = router;
