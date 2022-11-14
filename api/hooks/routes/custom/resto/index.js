'use strict';
const express = require('express');
const router = express.Router();
const db = require('../../../../config/db');
const bodyParse = require('../../../../utils/middlewares').bodyParse;
const sequelize = require('sequelize');

router.get('/remains_by_cat/:cat', (req, res) => {
  const query = `
    SELECT r.traduccion as nombre, r.variable
    FROM resto r
    INNER JOIN resto_rel_categoria_resto_indice rrcri on rrcri.fk_resto_variable = r.variable
    WHERE rrcri.fk_categoria_resto_indice_id = ANY (
      (
        SELECT array_agg(id_categoria_resto_indice) as categories FROM (
          WITH RECURSIVE nodes_cte(id_categoria_resto_indice, fk_categoria_resto_nombre, fk_categoria_resto_indice_id, path) 
          AS (
            SELECT tn.id_categoria_resto_indice, tn.fk_categoria_resto_nombre, tn.fk_categoria_resto_indice_id, ARRAY[tn.id_categoria_resto_indice]
            FROM categoria_resto_indice AS tn
            WHERE tn.fk_categoria_resto_indice_id IS NULL

            UNION ALL

            SELECT c.id_categoria_resto_indice, c.fk_categoria_resto_nombre, c.fk_categoria_resto_indice_id, array_append(p.path, c.id_categoria_resto_indice)
            FROM nodes_cte AS p, categoria_resto_indice AS c
            WHERE c.fk_categoria_resto_indice_id = p.id_categoria_resto_indice
          )
          SELECT id_categoria_resto_indice, fk_categoria_resto_nombre, path
          FROM nodes_cte
          WHERE (
            SELECT ARRAY_AGG(id_categoria_resto_indice) 
            FROM categoria_resto_indice 
            WHERE fk_categoria_resto_nombre = '${req.params.cat}'
          ) && path
        ) as categories
      ) ::integer[]
    ) ORDER BY r.traduccion
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

router.get('/category_children/:cat', (req, res) => {
  const query = `
  SELECT array_agg(to_json(categories)) as categories FROM (
    WITH RECURSIVE nodes_cte(
        id_categoria_resto_indice,
        fk_categoria_resto_nombre,
        fk_categoria_resto_indice_id,
        path
    ) AS (
      SELECT tn.id_categoria_resto_indice, tn.fk_categoria_resto_nombre, tn.fk_categoria_resto_indice_id, ARRAY[tn.id_categoria_resto_indice]
      FROM categoria_resto_indice AS tn
      WHERE tn.fk_categoria_resto_indice_id IS NULL
      UNION ALL
      SELECT c.id_categoria_resto_indice, c.fk_categoria_resto_nombre, c.fk_categoria_resto_indice_id, array_append(p.path, c.id_categoria_resto_indice)
      FROM nodes_cte AS p, categoria_resto_indice AS c
      WHERE c.fk_categoria_resto_indice_id = p.id_categoria_resto_indice      
    )
    SELECT id_categoria_resto_indice, fk_categoria_resto_nombre, path
    FROM nodes_cte
    WHERE (
      SELECT ARRAY_AGG(id_categoria_resto_indice) 
      FROM categoria_resto_indice 
      WHERE fk_categoria_resto_nombre = '${req.params.cat}'
    ) && path
  ) as categories`;
  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    console.error(error);
    res.status(500).send([error]);
  });
})

router.get('/by_individuo/:id_individuo', (req, res) => {
  const id_individuo = req.params.id_individuo;

  const individuo_search = id_individuo ?
    `AND ir.fk_individuo_arqueologico_id = ${id_individuo}` : '';

  const query = `
    SELECT r.nombre as nombre_resto,
      r.traduccion as traduccion_resto,
      ir.fk_individuo_arqueologico_id,
      ir.fk_resto_variable,
      ir.id_individuo_resto,
      ir.numero,
      ir.fk_especie_nombre,
      json_agg(a) as anomalias,
      json_agg(cri) as categorias
    FROM individuo_resto ir
    JOIN resto r ON r.variable = ir.fk_resto_variable
    LEFT JOIN anomalia_rel_individuo_resto arir ON arir.fk_individuo_resto_id = ir.id_individuo_resto
    LEFT JOIN anomalia a ON a.id_anomalia = arir.fk_anomalia_id
    JOIN resto_rel_categoria_resto_indice rrcri ON rrcri.fk_resto_variable = r.variable
    JOIN categoria_resto_indice cri ON cri.id_categoria_resto_indice = rrcri.fk_categoria_resto_indice_id
    WHERE ir.fk_resto_variable IS NOT NULL
    ${individuo_search} 
    GROUP BY ir.fk_resto_variable, traduccion_resto, nombre_resto, id_individuo_resto, numero
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

router.get('/completion', (req, res) => {
  const searchTerm = req.query.q;
  const useTranslated = !!req.query.useTranslated;
  const nameField = useTranslated ? 'traduccion' : 'nombre';
  const query = `
    SELECT * FROM (
      SELECT variable, (${nameField} || ' (' || fk_categoria_resto_nombre || ')') as nombre_completo
      FROM resto r
      JOIN resto_rel_categoria_resto_indice rrcri ON rrcri.fk_resto_variable = r.variable
      JOIN categoria_resto_indice cri ON cri.id_categoria_resto_indice = rrcri.fk_categoria_resto_indice_id
    ) as data
    WHERE nombre_completo ILIKE ?`;
  db.query(query, {replacements: [`%${searchTerm}%`], type: sequelize.QueryTypes.SELECT})
  .then(data => {
    res.status(200).send(data);
  }).catch(error => {
    res.status(500).send({error: error.message});
  });
});

router.post('/', bodyParse, (req, res) => {
  const query = `SELECT ae_add_individuo_resto(
    ${req.body.id_individuo_resto},
    ${req.body.fk_resto_variable},
    ${req.body.fk_especie_nombre},
    ${req.body.fk_individuo_arqueologico_id},
    ${req.body.numero},
    ${req.body.anomalias}
  )`;
  db.query(query)
  .then(data => {
    res.status(200).send(data[0] && data[0][0]);
  })
  .catch(error => {
    res.status(500).send([error]);
  });
});

router.delete('/:id_individuo_resto', (req, res) => {
  const id_individuo_resto = req.params.id_individuo_resto;
  if(isNaN(parseInt(id_individuo_resto, 10))) {
    res.status(400).json({
      ok: false, 
      error: true, 
      message: 'Invalid parameter id_individuo_resto'
    });
    return;
  }
  const query = `
    DELETE FROM individuo_resto
    WHERE id_individuo_resto=${id_individuo_resto}
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

module.exports = router;
