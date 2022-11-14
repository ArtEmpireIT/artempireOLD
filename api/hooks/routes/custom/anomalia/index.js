'use strict';

const express = require('express');
const router = express.Router();
const db = require('../../../../config/db');
const sequelize = require('sequelize');

router.get('/completion', (req, res) => {
  const searchTerm = req.query.q;
  const query = `
    WITH RECURSIVE recursive_data(nombre, id_anomalia, nombre_completo, traduccion_completa) AS (
      SELECT a0.nombre, 
        a0.id_anomalia,
        a0.nombre,
        COALESCE(a0.traduccion::text, ''::text)
      FROM anomalia AS a0
      WHERE a0.fk_anomalia_id IS NULL
      UNION ALL
      SELECT an.nombre,
        an.id_anomalia,
        rd.nombre_completo || ' - ' || 
          an.nombre 
          AS nombre_completo,
        rd.traduccion_completa || ' - ' ||
          COALESCE(an.traduccion::text, ''::text)
          AS traduccion_completa
      FROM recursive_data rd, anomalia AS an
      WHERE an.fk_anomalia_id = rd.id_anomalia
    )
    SELECT id_anomalia, 
      trim(rd.nombre_completo) || ': ' ||
      cr.nombre || ' / ' ||
      rd.traduccion_completa || ': ' ||
      COALESCE(cr.traduccion::text, ''::text) as nombre_completo
    FROM recursive_data rd,
      categoria_resto_rel_anomalia ca,
      categoria_resto cr
    WHERE ca.fk_anomalia_id = id_anomalia
    AND cr.nombre = ca.fk_categoria_resto
    AND rd.nombre_completo ILIKE ?
    ORDER BY nombre_completo;  
  `;
  db.query(query, {replacements: [`%${searchTerm}%`], type: sequelize.QueryTypes.SELECT})
  .then(data => {
    res.status(200).send(data);
  }).catch(error => {
    res.status(500).send({error: error.message});
  });
});

router.get('/search_by_category/:cat/:search?', (req, res, next) => {

  let searchCondition = '';
  if (req.params.search) {
    searchCondition = ` AND lower(path_text) LIKE lower('%${req.params.search}%')`;
  }

  const categoryQuery = `
    (SELECT array_agg(DISTINCT(fk_categoria_resto_nombre)) as categories FROM (
      WITH RECURSIVE nodes_cte(id_categoria_resto_indice, fk_categoria_resto_nombre, fk_categoria_resto_indice_id, path) AS (

              SELECT tn.id_categoria_resto_indice, tn.fk_categoria_resto_nombre, tn.fk_categoria_resto_indice_id,
              ARRAY[tn.id_categoria_resto_indice]
              FROM categoria_resto_indice AS tn
              WHERE tn.fk_categoria_resto_indice_id IS NOT NULL

            UNION ALL

              SELECT c.id_categoria_resto_indice, c.fk_categoria_resto_nombre, c.fk_categoria_resto_indice_id,
              array_append(p.path, c.id_categoria_resto_indice)
              FROM nodes_cte AS p, categoria_resto_indice AS c
              WHERE c.id_categoria_resto_indice = p.fk_categoria_resto_indice_id

            )
            SELECT id_categoria_resto_indice, fk_categoria_resto_nombre, path  FROM nodes_cte
            WHERE (SELECT ARRAY_AGG(id_categoria_resto_indice) FROM categoria_resto_indice WHERE fk_categoria_resto_nombre = '${req.params.cat}') && path
    ) as categories)
  `;

  const query = `
    WITH RECURSIVE nodes_cte(id_anomalia, nombre, fk_anomalia_id, path_text, categories) AS (

      SELECT tn.id_anomalia, tn.nombre, tn.fk_anomalia_id, tn.nombre, (SELECT ARRAY_AGG(fk_categoria_resto) FROM (SELECT fk_categoria_resto FROM categoria_resto_rel_anomalia WHERE fk_anomalia_id = tn.id_anomalia) as categories)
      FROM anomalia AS tn
      WHERE tn.fk_anomalia_id IS NULL

    UNION ALL

      SELECT c.id_anomalia, c.nombre, c.fk_anomalia_id,
      p.nombre || ' ' || c.nombre,
      (
        p.categories ||
        (SELECT ARRAY_AGG(fk_categoria_resto) FROM (SELECT fk_categoria_resto FROM categoria_resto_rel_anomalia WHERE fk_anomalia_id = p.id_anomalia) as categories)
      )
      FROM nodes_cte AS p, anomalia AS c
      WHERE c.fk_anomalia_id = p.id_anomalia

    )
    SELECT id_anomalia, path_text FROM nodes_cte
    WHERE (
      ${categoryQuery} && categories
    ) ${searchCondition}
    ORDER BY path_text

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

router.post('/anomalies_for_remains/:id_individuo_resto', (req, res) => {
  const id_individuo_resto = req.params.id_individuo_resto;
  const anomalies = [...req.body];
  
  if (!anomalies.length) {
    res.status(204).send();
    return;
  }

  const sql = `SELECT ae_add_anomalia_rel_resto_individuo(
    ${id_individuo_resto},
    '{${anomalies}}'::numeric[]
  )`;

  db.query(sql)
  .then(data => {
    res.status(200).json(data[0]);
  })
  .catch(error => {
    console.error(error);
    res.status(500).json(error);
  });
})

module.exports = router;
