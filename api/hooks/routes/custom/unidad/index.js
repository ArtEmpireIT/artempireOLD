'use strict';

var express = require('express'),
  router = express.Router(),
  db = require('../../../../config/db');

router.get('/completion', function(req, res, next){

  var filter = '';
  if(req.query.tipo){
    if(typeof req.query.tipo!=='object'){
      req.query.tipo = [req.query.tipo];
    }
    var a = req.query.tipo.join("', '");
    filter = `AND tipo IN ('${a}')`;
  }

  var query = `
    SELECT * FROM unidad
    WHERE (nombre ILIKE '%${req.query.q}%')
    ${filter}
    ORDER BY nombre`;

  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(200).send([]);
  });

})


module.exports = router;
