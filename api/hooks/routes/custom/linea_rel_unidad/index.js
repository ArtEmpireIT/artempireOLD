'use strict';

var express = require('express'),
  router = express.Router(),
  db = require('../../../../config/db');

router.get('/:fk_linea_id', function(req, res, next){


  var filter = '';
  if(req.query.tipo){
    if(typeof req.query.tipo!=='object'){
      req.query.tipo = [req.query.tipo];
    }
    var a = req.query.tipo.join("', '");
    filter = `AND tipo IN ('${a}')`;
  }


  var query = `
    SELECT
      *
    FROM linea_rel_unidad lru JOIN unidad u
    ON lru.fk_unidad_nombre=u.nombre
    WHERE lru.fk_linea_id=${req.params.fk_linea_id}
    ${filter}
    ORDER BY u.nombre`;

  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(200).send([]);
  });

})

router.delete('/:id_linea', (req, res, next) => {
  const query = `DELETE from linea_rel_unidad WHERE fk_linea_id=${req.params.id_linea}`;
  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(200).send([]);
  });
})


module.exports = router;
