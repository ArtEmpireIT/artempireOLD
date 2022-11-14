'use strict';

var express = require('express'),
  router = express.Router(),
  db = require('../../../../config/db'),
  responseValidator = require('../../../../utils/middlewares').responseValidator,
  resProcessor = require('../../../../utils/resProcessor');

// Just for Mandas
router.get('/mandas/:fk_documento_id', function(req, res, next){

  var query = `
    SELECT
      id_pertenencia,
      orden AS manda_order,
      motivo
    FROM pertenencia p
    WHERE p.fk_documento_id=${req.params.fk_documento_id}
    AND p.tipo_atr_doc = 'Manda'`;

  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(200).send([]);
  });

})

router.get('/mandas/max/:fk_documento_id', function(req, res, next){

  var query = `
    SELECT MAX(orden) FROM pertenencia p
    WHERE p.fk_documento_id=${req.params.fk_documento_id}
    AND p.tipo_atr_doc ='Manda'`;

  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(200).send([]);
  });

})


module.exports = router;
