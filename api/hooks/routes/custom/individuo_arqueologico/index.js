'use strict';

const express = require('express');
const router = express.Router();
const db = require('../../../../config/db');
const {bodyParse, parseJWT} = require('../../../../utils/middlewares');

const checkEmptyJsonArray = item => (
  item === 'ARRAY[]::text[]' ? 'ARRAY[]::json[]' : item
)

router.get('/edades', (req, res) => {
  const query = `SELECT * FROM lote_edades`;
  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    console.log(error);
    res.status(500).send([error]);
  });
})

router.get('/edades/:id_individuo', (req, res) => {
  const id_individuo = req.params.id_individuo;
  if(isNaN(parseInt(id_individuo, 10))) {
    res.status(400).json({
      ok: false, 
      error: true, 
      message: 'Invalid parameter id_individuo'
    });
    return;
  }

  const query = `
    SELECT * 
    FROM lote_edades_rel_individuo_arqueologico
    WHERE fk_individuo_arqueologico=${parseInt(id_individuo)}
  `;
  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    console.log(error);
    res.status(500).send([error]);
  });
})

router.get('/object_search', (req, res) => {
  const search = req.query.q;
  const query = `SELECT * FROM objeto_arqueologico WHERE nombre ILIKE '%${search}%'`;
  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    console.log(error);
    res.status(500).send([error]);
  });
})

router.get('/:id_entierro', parseJWT, (req, res) => {
  const id_entierro = req.params.id_entierro;
  if(isNaN(parseInt(id_entierro, 10))) {
    res.status(400).json({
      ok: false, 
      error: true, 
      message: 'Invalid parameter id_entierro'
    });
    return;
  }
  
  const tipoMap = {
    noent: "'noent'",
    enterramiento: "'enterramiento'"
  }
  const tipo = tipoMap.hasOwnProperty(req.query.tipo) && tipoMap[req.query.tipo];
  const tipoQuery = tipo ? `AND ia.tipo=${tipo}` : '';
  
  // const { access_archeology } = (req.user || {});
  const secretQuery = req.user ? '' : 'AND COALESCE(ia.confidencial, FALSE) = FALSE ';
  const query = `
    SELECT ia.*
    FROM individuo_arqueologico ia
    WHERE ia.fk_entierro=${id_entierro} ${tipoQuery} ${secretQuery}
    ORDER BY ia.unid_estratigrafica
  `;

  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    console.log(error);
    res.status(500).send([error]);
  });
})

router.post('/:id_entierro', bodyParse, (req, res) => {
  const id_entierro = req.params.id_entierro;
  if(isNaN(parseInt(id_entierro, 10))) {
    res.status(400).json({
      ok: false, 
      error: true, 
      message: 'Invalid parameter id_entierro'
    });
    return;
  }
  const query = `SELECT ae_add_individuo_arquelogico(
    ${id_entierro},
    ${req.body.id_individuo_arqueologico},
    ${req.body.unid_estratigrafica},
    ${req.body.unid_estratigrafica_asociada},
    ${req.body.estructura},
    ${req.body.forma},
    ${req.body.largo},
    ${req.body.ancho},
    ${req.body.profundidad},
    ${req.body.tipo_enterramiento},
    ${req.body.clase_enterramiento},
    ${req.body.contenedor},
    ${req.body.descomposicion},
    ${req.body.periodo_inicio},
    ${req.body.periodo_fin},
    ${req.body.estatura},
    ${req.body.catalogo},
    ${req.body.sexo},
    ${req.body.edad},
    ${req.body.posicion_cuerpo},
    ${req.body.pos_extremidades_sup},
    ${req.body.pos_extremidades_inf},
    ${req.body.orientacion_cuerpo},
    ${req.body.orientacion_creaneo},
    ${req.body.filiacion_poblacional},
    ${req.body.observaciones},
    ${req.body.nmi_total},
    ${req.body.tipo},
    ${req.body.confidencial},
    ${checkEmptyJsonArray(req.body.edades)},
    ${checkEmptyJsonArray(req.body.estados)},
    ${checkEmptyJsonArray(req.body.restos)},
    ${checkEmptyJsonArray(req.body.lineas)}
  )`;
  db.query(query)
  .then(data => {
    res.status(200).send(data[0] && data[0][0]);
  })
  .catch(error => {
    res.status(500).send([error]);
  });
})

router.delete('/:id_individuo', (req, res) => {
  const id_individuo = req.params.id_individuo;
  if(isNaN(parseInt(id_individuo, 10))) {
    res.status(400).json({
      ok: false, 
      error: true, 
      message: 'Invalid parameter id_individuo'
    });
    return;
  }

  const query = `
    DELETE FROM individuo_arqueologico
    WHERE id_individuo_arqueologico=${id_individuo}
  `;

  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    console.log(error);
    res.status(500).send([error]);
  });
})

router.get('/:id_individuo/objetos', (req, res) => {
  const id_individuo = req.params.id_individuo;
  if(isNaN(parseInt(id_individuo, 10))) {
    res.status(400).json({
      ok: false, 
      error: true, 
      message: 'Invalid parameter id_individuo'
    });
    return;
  }
  const query = `
    SELECT
      oa.nombre as objeto_arqueologico_nombre,
      oa.id_objeto as objeto_arqueologico_id,
      l.descripcion as descripcion,
      l.cantidad as cantidad,
      l.color as color,
      m.id_material as material_id,
      m.nombre as material_nombre,
      iarl.origen as origen,
      iarl.tipo as tipo,
      l.id_linea as linea_id,
      iarl.fk_individuo_arqueologico as individuo_arqueologico_id,
      json_agg(lu) as unidades
    FROM individuo_arqueologico_rel_linea iarl
    JOIN linea l on l.id_linea = iarl.fk_linea
    JOIN objeto_arqueologico_rel_linea oarl ON oarl.fk_linea = l.id_linea
    JOIN objeto_arqueologico oa ON oa.id_objeto = oarl.fk_objeto_arqueologico
    LEFT JOIN material m ON m.id_material = l.fk_material_id
    LEFT JOIN linea_rel_unidad lu ON lu.fk_linea_id = l.id_linea
    WHERE iarl.fk_individuo_arqueologico = ${id_individuo}
    GROUP BY l.id_linea, oa.nombre, oa.id_objeto, l.descripcion, l.cantidad, l.color, m.id_material, m.nombre, iarl.origen, iarl.tipo, iarl.fk_individuo_arqueologico
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

router.post('/:id_individuo/objetos', bodyParse, (req, res) => {
  const id_individuo = req.params.id_individuo;
  if(isNaN(parseInt(id_individuo, 10))) {
    res.status(400).json({
      ok: false, 
      error: true, 
      message: 'Invalid parameter id_individuo'
    });
    return;
  }
  const query = `SELECT ae_add_linea_objeto_arqueologico(
    ${req.body.linea_id},
    ${id_individuo},
    ${req.body.objeto_arqueologico_id},
    ${req.body.objeto_arqueologico_nombre},
    ${req.body.origen},
    ${req.body.tipo},
    ${req.body.descripcion},
    ${req.body.cantidad},
    ${req.body.material_id},
    ${req.body.material_nombre},
    ${req.body.color},
    ${checkEmptyJsonArray(req.body.unidades)}
  )`;

  db.query(query)
  .then(data => {
    res.status(200).send(data[0] && data[0][0]);
  })
  .catch(error => {
    res.status(500).send([error]);
  });
})

module.exports = router;