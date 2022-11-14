'use strict';

var express = require('express'),
  router = express.Router(),
  db = require('../../../../config/db');

router.get('/:fk_documento_id', function(req, res, next){


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
    FROM documento_rel_unidad dru JOIN unidad u
    ON dru.fk_unidad_nombre=u.nombre
    WHERE dru.fk_documento_id=${req.params.fk_documento_id}
    ORDER BY u.nombre`;

  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(200).send([]);
  });

})


module.exports = router;