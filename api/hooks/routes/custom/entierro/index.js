'use strict';
const express = require('express');
const router = express.Router();
const db = require('../../../../config/db');
const {bodyParse, parseJWT} = require('../../../../utils/middlewares');

router.get('/', parseJWT, (req, res) => {
  const search = req.query.q && req.query.q.replace(/['";]/g, '');
  const searchQuery = search ? `AND e.nomenclatura_sitio ILIKE '%${search}%'` : '';
  const query = `
    SELECT e.id_entierro, e.nomenclatura_sitio, e.lugar, e.anio_fecha, count(ia) as units
    FROM entierro e
    LEFT JOIN individuo_arqueologico ia ON ia.fk_entierro = e.id_entierro
    WHERE TRUE ${searchQuery}
    GROUP BY e.id_entierro, e.nomenclatura_sitio, e.lugar, e.anio_fecha
    ORDER BY e.nomenclatura_sitio
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

router.get('/espacios', (req, res) => {
  const query = `
  WITH RECURSIVE space_group(nombre, fk_espacio_entierro, hijos) AS (
    SELECT e0.nombre, e0.fk_espacio_entierro,
    ARRAY[e0.nombre::text] as hijos
    FROM espacio_entierro AS e0
  UNION ALL
    SELECT ei.nombre, ei.fk_espacio_entierro,
    array_append(en.hijos, ei.nombre::text)
    FROM space_group as en JOIN espacio_entierro as ei
    ON en.fk_espacio_entierro = ei.nombre
  ) SELECT nombre as palabra, json_agg(hijos) as hijos FROM space_group GROUP BY palabra;
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

router.post('/transform_geometry', (req, res) => {
  const x = (req.body.x);
  const y = (req.body.y);
  const to_ref = (req.body.to_ref);
  const from_ref = (req.body.from_ref);

  if (!Number.isFinite(Number(x)) || 
      !Number.isFinite(Number(y)) || 
      !Number.isFinite(Number(from_ref)) || 
      !Number.isFinite(Number(to_ref))) {
    res.status(400).json({
      ok: false, 
      error: true, 
      message: 'Invalid parameters. x, y and ref must be numbers'
    });
    return;
  }

  const query = `SELECT json_build_object(
    'x', ST_X(_geom), 
    'y', ST_Y(_geom)
  ) as geom
  FROM (
    SELECT ST_Transform(
      ST_GeomFromText(
        'POINT(${x} ${y})',
        ${from_ref}
      ),
      ${to_ref}
    ) AS _geom
  ) AS data`;

  db.query(query)
  .then(data => {
    const geom = data[0] && data[0][0] && data[0][0]['geom'];
    res.status(200).json(geom);
  })
  .catch(error => {
    console.error(error);
    res.status(500).json(error);
  });
})

router.get('/:id_entierro', (req, res) => {
  const id_entierro = parseInt(req.params.id_entierro);
  if (isNaN(id_entierro)) {
    res.status(400).json({
      ok: false, 
      error: true, 
      message: 'Invalid parameter id_entierro'
    });
    return;
  }
  const query = `
    SELECT *, ST_AsGeoJSON(place_geometry) as place_geometry 
    FROM entierro 
    WHERE id_entierro = ${id_entierro}
  `;
  db.query(query)
  .then(data => {
    res.status(200).send(data[0] && data[0][0]);
  })
  .catch(error => {
    console.log(error);
    res.status(500).send([error]);
  });
})

router.post('/:id_entierro', bodyParse, (req, res) => {
  const id_entierro = req.params.id_entierro;
  const query = `SELECT ae_add_entierro(
    ${id_entierro},
    ${req.body.nomenclatura_sitio},
    ${req.body.lugar},
    ${req.body.anio_fecha},
    ${req.body.fk_espacio_nombre},
    ${req.body.estructura},
    ${req.body.forma},
    ${req.body.largo},
    ${req.body.ancho},
    ${req.body.profundidad},
    ${req.body.observaciones},
    ${req.body.place_geometry}
  )`;
  db.query(query)
  .then(data => {
    res.status(200).send(data[0] && data[0][0]);
  })
  .catch(error => {
    res.status(500).send([error]);
  });
})

router.delete('/:id_entierro', (req, res) => {
  const id_entierro = req.params.id_entierro;
  if(isNaN(parseInt(id_entierro, 10))) {
    res.status(400).json({
      ok: false, 
      error: true, 
      message: 'Invalid parameter id_entierro'
    });
    return;
  }

  const query = `
    DELETE FROM entierro
    WHERE id_entierro=${id_entierro}
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

router.get('/:id_entierro/lotes', (req, res) => {
  const id_entierro = req.params.id_entierro;
  const query = `
    SELECT id_lote, nmi, unid_estratigrafica FROM lote l
    JOIN entierro_rel_lote erl ON erl.fk_lote_id = l.id_lote
    WHERE erl.fk_entierro_id = ${id_entierro}
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

router.post('/delete_lge', (req, res) => {
  const lge = req.body;
  const query = `
    DELETE FROM lote_genero_edad
    WHERE fk_lote_id=${lge.fk_lote_id}
    AND fk_genero_lote_nombre='${lge.fk_genero_lote_nombre}'
    AND fk_edad_lote_nombre='${lge.fk_edad_lote_nombre}'
    AND cantidad=${lge.cantidad}
  `;
  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    console.error(error);
    res.status(500).send([error]);
  });
})

router.post('/ae_add_lote', bodyParse, (req, res) => {

  const query = `SELECT ae_add_lote_entierro(
    ${req.body.id_entierro},
    ${req.body.unid_estratigrafica},
    ${req.body.fk_genero_lote_nombre},
    ${req.body.fk_edad_lote_nombre},
    ${req.body.cantidad}
  )`;

  db.query(query)
  .then(() => {
    res.status(200).send([]);
  })
  .catch(error => {
    console.log(error);
    res.status(500).send([error]);
  });
})

router.post('/estados_individuo_arqueo/:id_individuo', (req, res) => {
  const id_individuo = parseInt(req.params.id_individuo, 10);
  const estados = req.body;
  if (isNaN(id_individuo)) {
    res.status(400).json({error: 'id_individuo must be a integer'});
    return;
  }
  if (!Array.isArray(estados)) {
    res.status(400).json({error: 'POST body must be an array in json format'})
  }

  let estados_json = estados.map(e => `'${JSON.stringify(e)}'`).join(',');
  const query = `SELECT ae_add_estado_rel_individuo(
    ${id_individuo},
    ARRAY[${estados_json}]::json[]
  )`;

  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    console.error(error);
    res.status(500).send([error]);
  });
})

router.get('/:id_entierro/geometry', (req, res) => {
  const id_entierro = req.params.id_entierro;
  const query = `
    SELECT ST_X(place_geometry) as x, ST_Y(place_geometry) as y
    FROM entierro
    WHERE id_entierro=${id_entierro}
  `;
  db.query(query)
  .then(data => {
    res.status(200).send(data[0] && data[0][0]);
  })
  .catch(error => {
    console.log(error);
    res.status(500).send([error]);
  });
})

router.post('/:id_entierro/geometry', (req, res) => {
  const x = (req.body.x);
  const y = (req.body.y);
  const ref = (req.body.ref);
  const id_entierro = req.params.id_entierro;

  if (!Number.isFinite(Number(x)) || !Number.isFinite(Number(y)) || !Number.isFinite(Number(ref))) {
    res.status(400).json({
      ok: false, 
      error: true, 
      message: 'Invalid parameters. x, y and ref must be numbers'
    });
    return;
  }
  const query = `
    UPDATE entierro SET place_geometry=(ST_Transform(ST_GeomFromText('POINT(${x} ${y})', ${ref}), 4326))
    WHERE id_entierro=${id_entierro}
    RETURNING *
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

router.get('/:id_entierro/ajuar', (req, res) => {
  const id = req.params.id_entierro;
  const query = `
    SELECT *, o.nombre as nombre_objeto FROM linea l 
    JOIN objeto o ON l.fk_objeto_id=o.id_objeto
    WHERE l.fk_entierro_id=${id} AND descripcion='Ajuar'
  `;
  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    console.error(error);
    res.status(500).send([error]);
  });
});

module.exports = router;
