'use strict';

const express = require('express')
const router = express.Router()
const db = require('../../../../config/db')
const { bodyParse } = require('../../../../utils/middlewares');

router.get('/objects_by_document/:id_documento/:search?', function(req, res, next){

  const id_documento = req.params.id_documento,
    search = req.params.search;

  let query = `
    SELECT DISTINCT
      o.nombre,
      o.id_objeto,
      o.tipo,
      l.descripcion,
      p.tipo_atr_doc,
      l.id_linea
    FROM pertenencia p
    INNER JOIN pertenencia_rel_agrupacion_bienes pab on pab.fk_pertenencia_id = p.id_pertenencia
    INNER JOIN agrupacion_bienes ab on ab.id_agrupacion_bienes = pab.fk_agrupacion_bienes_id
    INNER JOIN linea l on l.fk_agrupacion_bienes_id = ab.id_agrupacion_bienes
    INNER JOIN objeto o on o.id_objeto = l.fk_objeto_id
    where p.fk_documento_id=${id_documento}
    ORDER BY o.nombre`;

  if (search) {
    query += ` AND lower(o.nombre) LIKE lower('%${search}%')`;
  }

  db.query(query,[req.params.id_documento])
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(200).send([]);
  });

})

router.get('/completion/:key', (req, res) => {
  const q = req.query.q.toLowerCase();
  const key = req.params.key;
  const noLower = !!req.query.noLower;
  const lowerFn = noLower ? '' : 'lower';
  const query = `
    SELECT distinct(${lowerFn}("${key}")) as "${key}" 
    FROM objeto
    WHERE "${key}" ILIKE '%${q}%'
    ORDER BY ${lowerFn}("${key}")
  `;
  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(500).send([error]);
  });
})

router.get('/get_objects_for_document/:id_linea/:id_document', function(req, res, next){
  var query = `
    SELECT
      DISTINCT
      o.nombre as object_name,
      l.id_linea,
      l.fk_objeto_id,
      l.fk_agrupacion_bienes_id,
      l.descripcion,
      l.cantidad,
      l.color,
      l.calidad,
      l.estado,
      l.fk_material_id,
      m.nombre as material,
      l.fk_lugar_nombre,
      p.tipo_atr_doc,
      (select ARRAY_TO_JSON(ARRAY_AGG(ROW_TO_JSON(t))) FROM (SELECT lu.valor as value, lu.fk_unidad_nombre as name, u.tipo as type FROM public.linea_rel_unidad lu INNER JOIN public.unidad u on u.nombre =  lu.fk_unidad_nombre WHERE fk_linea_id=${req.params.id_linea} ORDER BY lu.fk_unidad_nombre) as t) as units
    FROM pertenencia p
    INNER JOIN pertenencia_rel_agrupacion_bienes pab on pab.fk_pertenencia_id = p.id_pertenencia
    INNER JOIN agrupacion_bienes ab on ab.id_agrupacion_bienes = pab.fk_agrupacion_bienes_id
    INNER JOIN linea l on l.fk_agrupacion_bienes_id = ab.id_agrupacion_bienes
    INNER JOIN objeto o on o.id_objeto = l.fk_objeto_id
    INNER JOIN public.material m on m.id_material = l.fk_material_id
    where p.fk_documento_id=${req.params.id_document} AND l.id_linea =${req.params.id_linea}
  `
  db.query(query,[req.params.id_documento])
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(200).send([]);
  });
})

router.post('/save_objects_for_document', function(req, res, next){

  // const catalogElements = [
  //   {schema:'public', table:'objeto', returning_key:'id_objeto', columns:['nombre'], values:['Prueba'], searchValue:1},
  //   {schema:'public', table:'material', returning_key:'id_material', columns:['nombre'], values:['Prueba'], searchValue:78},
  //   {schema:'public', table:'lugar', returning_key:'nombre', columns:['nombre'], values:['Sevilla'], searchValue:'Sevilla'}
  // ]

  // console.log(iwcow(catalogElements));

  var query = `
  WITH
  objeto_select as (
     SELECT id_objeto
     FROM public.objeto
     WHERE id_objeto = ${req.body.object.id_objeto}
  ), objeto_insert as (
     INSERT INTO public.objeto (nombre)
     SELECT '${req.body.object.nombre}'
     WHERE NOT EXISTS (select id_objeto from objeto_select)
     RETURNING id_objeto
  ),
   material_select as (
       SELECT id_material
       FROM public.material
       WHERE id_material = ${req.body.material.id_material}
   ), material_insert as (
       INSERT INTO public.material (nombre)
       SELECT '${req.body.material.nombre}'
       WHERE NOT EXISTS (select id_material from material_select)
       RETURNING id_material
   ),
   lugar_select as (
       SELECT nombre
       FROM public.lugar
       WHERE nombre = '${req.body.origen.nombre}'
   ), lugar_insert as (
       INSERT INTO public.lugar (nombre)
       SELECT '${req.body.origen.nombre}'
       WHERE NOT EXISTS (select nombre from lugar_select)
       RETURNING nombre
   ),
   ${_getUnitsSubQuerys(req.body.units)},
   _agrupacion_bienes as (
     INSERT INTO agrupacion_bienes(nombre) VALUES(null) RETURNING id_agrupacion_bienes
   ),
   _pertenencia as (
     INSERT INTO public.pertenencia(fk_documento_id, tipo_atr_doc) VALUES(${req.body.id_documento}, '${req.body.campo}') RETURNING id_pertenencia
   ),
   _pertenencia_rel_agrupacion_bienes as (
     INSERT INTO public.pertenencia_rel_agrupacion_bienes(fk_pertenencia_id,fk_agrupacion_bienes_id) VALUES((SELECT id_pertenencia FROM _pertenencia),(SELECT id_agrupacion_bienes FROM _agrupacion_bienes))
   ),
   _linea as(
     INSERT INTO
      linea(fk_objeto_id, fk_agrupacion_bienes_id, descripcion, cantidad, color, calidad, estado, fk_material_id, fk_lugar_nombre)
       SELECT objeto.id_objeto, (SELECT id_agrupacion_bienes FROM _agrupacion_bienes), '${req.body.descripcion}', ${req.body.cantidad}, '${req.body.color.color}', '${req.body.calidad.calidad}', '${req.body.estado.estado}', material.id_material,lugar.nombre
       FROM
       (SELECT id_objeto
       FROM objeto_insert
       UNION ALL
       SELECT id_objeto
       FROM objeto_select) as objeto,
       (SELECT id_material
       FROM material_insert
       UNION ALL
       SELECT id_material
       FROM material_select) as material,
       (SELECT nombre
       FROM lugar_insert
       UNION ALL
       SELECT nombre
       FROM lugar_select) as lugar

       RETURNING id_linea
   )
   INSERT INTO public.linea_rel_unidad(fk_linea_id,fk_unidad_nombre,valor) VALUES ${_getUnitValues(req.body.units,'(SELECT id_linea FROM _linea)')}
  `

  db.query(query)
  .then(data => {
    res.status(200).send([]);
  })
  .catch(error => {
    console.log(error);
    res.status(200).send([]);
  });


})

const checkEmptyJsonArray = item => (
  item === 'ARRAY[]::text[]' ? 'ARRAY[]::json[]' : item
)

router.post('/objetos_for_document', bodyParse, function(req, res) {

  const query = `
    SELECT ae_add_objeto(
      ${req.body.id_documento},
      ${req.body.id_pertenencia},
      ${req.body.id_agrupacion},
      ${req.body.id_linea},

      ${req.body.descripcion},
      ${req.body.calidad},
      ${req.body.estado},
      ${checkEmptyJsonArray(req.body.units)},

      ${req.body.tipo_atr_doc},

      ${req.body.cantidad},
      ${req.body.color},

      ${req.body.material.id_material},
      ${req.body.material.nombre},
      ${req.body.material.fk_material_id},

      ${req.body.object.id_objeto || null},
      ${req.body.object.nombre},

      ${req.body.origen.id_lugar},

      ${req.body.tipo_impuesto},      

      ${req.body.doPertenencia},

      ${checkEmptyJsonArray(req.body.relations.person)},
      ${checkEmptyJsonArray(req.body.relations.place)}
    )
  `
  
  db.query(query)
  .then(() => {
    res.status(200).json({message: `saved object ${req.body.object.nombre}`});
  })
  .catch(error => {
    res.status(500).send(error);
  });

});

var formatRelation = function(relation) {

  let result = [];
  if (relation.length === 0) {
    result = `ARRAY[]::json[]`;
  } else {
    for (const p of relation) {
      result.push(JSON.stringify(p));
    }
    result = `ARRAY['${result.join("','")}']::json[]`
  }
  return result;
}

router.put('/save_objects_for_document', function(req, res, next){
  var query = `
    DELETE FROM public.linea_rel_unidad WHERE fk_linea_id=${req.body.id_linea}
  `;

  db.query(query)
  .then(data => {
    query = `
    WITH
    objeto_select as (
       SELECT id_objeto
       FROM public.objeto
       WHERE id_objeto = ${req.body.object.id_objeto}
    ), objeto_insert as (
       INSERT INTO public.objeto (nombre)
       SELECT '${req.body.object.nombre}'
       WHERE NOT EXISTS (select id_objeto from objeto_select)
       RETURNING id_objeto
    ),
     material_select as (
         SELECT id_material
         FROM public.material
         WHERE id_material = ${req.body.material.id_material}
     ), material_insert as (
         INSERT INTO public.material (nombre)
         SELECT '${req.body.material.nombre}'
         WHERE NOT EXISTS (select id_material from material_select)
         RETURNING id_material
     ),
     lugar_select as (
         SELECT nombre
         FROM public.lugar
         WHERE nombre = '${req.body.origen.nombre}'
     ), lugar_insert as (
         INSERT INTO public.lugar (nombre)
         SELECT '${req.body.origen.nombre}'
         WHERE NOT EXISTS (select nombre from lugar_select)
         RETURNING nombre
     ),
     ${_getUnitsSubQuerys(req.body.units)},
     _pertenencia as (
       UPDATE public.pertenencia SET tipo_atr_doc = '${req.body.campo}' WHERE id_pertenencia = (SELECT pab.fk_pertenencia_id FROM public.linea l INNER JOIN agrupacion_bienes ab on ab.id_agrupacion_bienes = l.fk_agrupacion_bienes_id INNER JOIN public.pertenencia_rel_agrupacion_bienes pab on pab.fk_agrupacion_bienes_id = ab.id_agrupacion_bienes WHERE l.id_linea=${req.body.id_linea})
     ),
     _linea as(
       UPDATE
        linea SET fk_objeto_id=subquery.id_objeto, descripcion='${req.body.descripcion}', cantidad=${req.body.cantidad}, color='${req.body.color.color}', calidad='${req.body.calidad.calidad}', estado='${req.body.estado.estado}', fk_material_id=subquery.id_material, fk_lugar_nombre=subquery.lugar_nombre
         FROM(
           SELECT objeto.id_objeto as id_objeto, material.id_material as id_material, lugar.nombre as lugar_nombre
           FROM
           (SELECT id_objeto
           FROM objeto_insert
           UNION ALL
           SELECT id_objeto
           FROM objeto_select) as objeto,
           (SELECT id_material
           FROM material_insert
           UNION ALL
           SELECT id_material
           FROM material_select) as material,
           (SELECT nombre
           FROM lugar_insert
           UNION ALL
           SELECT nombre
           FROM lugar_select) as lugar
         ) as subquery
        WHERE id_linea=${req.body.id_linea}
     )
     INSERT INTO public.linea_rel_unidad(fk_linea_id,fk_unidad_nombre,valor) VALUES ${_getUnitValues(req.body.units,req.body.id_linea)}
    `
    db.query(query)
    .then(data => {
      res.status(200).send([]);
    })
    .catch(error => {
      console.log(error);
      res.status(200).send([]);
    });

  })
  .catch(error => {
    console.log(error);
    res.status(200).send([]);
  });

})

router.delete('/delete_object_for_document/:id_linea', function(req, res, next){
  var query = `
    WITH
    _linea_rel_unidad as (
      DELETE FROM public.linea_rel_unidad WHERE fk_linea_id=${req.params.id_linea}
    ),
    _pertenencia as (
      DELETE FROM public.pertenencia WHERE id_pertenencia = (SELECT pab.fk_pertenencia_id FROM public.linea l INNER JOIN agrupacion_bienes ab on ab.id_agrupacion_bienes = l.fk_agrupacion_bienes_id INNER JOIN public.pertenencia_rel_agrupacion_bienes pab on pab.fk_agrupacion_bienes_id = ab.id_agrupacion_bienes WHERE l.id_linea=${req.params.id_linea})
    ),
    _agrupacion_bienes as (
      DELETE FROM public.agrupacion_bienes WHERE id_agrupacion_bienes = (SELECT ab.id_agrupacion_bienes FROM public.linea l INNER JOIN agrupacion_bienes ab on ab.id_agrupacion_bienes = l.fk_agrupacion_bienes_id WHERE l.id_linea=${req.params.id_linea})
    )
    DELETE FROM public.linea WHERE id_linea = ${req.params.id_linea}
  `;
  db.query(query)
  .then(() => {
    res.status(200).json({message: `deleted object for line ${req.params.id_linea}`});
  }).catch(error => {
    res.status(500).send(error);
  });
})

var _getUnitsSubQuerys = function(units){
  let query = '';
  let i = 0;
  for (let u of units) {
    query += `unit_select_${i} as (
              SELECT nombre, tipo
              FROM public.unidad
              WHERE nombre = '${u.name}' AND tipo = '${u.type}'
          ), unit_insert_${i} as (
              INSERT INTO public.unidad (nombre, tipo)
              SELECT '${u.name}', '${u.type}'
              WHERE NOT EXISTS (select nombre, tipo from unit_select_${i})
          ),`
    ;
    i++;
  }
  return query.slice(0,-1);
}

var _getUnitValues = function(units,fk_linea_id){
  let result = '';
  for (let u of units) {
    result += `(${fk_linea_id},'${u.name}', ${u.value}),`
  }
  return result.slice(0,-1);
}


module.exports = router;
