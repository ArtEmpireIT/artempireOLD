'use strict';

var express = require('express'),
  router = express.Router(),
  db = require('../../../../config/db');

router.get('/completion/:key', (req, res) => {
  const q = req.query.q.toLowerCase();
  const key = req.params.key;
  const noLower = !!req.query.noLower;
  const lowerFn = noLower ? '' : 'lower';
  const query = `
    SELECT distinct(${lowerFn}("${key}")) as "${key}" 
    FROM material
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

module.exports = router;
