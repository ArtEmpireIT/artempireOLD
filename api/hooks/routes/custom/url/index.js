'use strict';

var express = require('express'),
  router = express.Router(),
  db = require('../../../../config/db');


router.get('/', function(req, res, next){

  var url = req.query.q;
  var query = `
    SELECT
      fk_documento_id,
      id_url,
      url
    FROM url u JOIN documento_rel_url d ON u.id_url=d.fk_url_id
    WHERE (u.url LIKE '%${url}%' OR u.descripcion LIKE '%${url}%')`;

  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(200).send([]);
  });

})




router.get('/:fk_documento_id', function(req, res, next){

  var query = `
    SELECT
      fk_documento_id,
      id_url,
      url
    FROM url u JOIN documento_rel_url d ON u.id_url=d.fk_url_id
    WHERE d.fk_documento_id=${req.params.fk_documento_id}`;

  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(200).send([]);
  });

})


router.delete('/:fk_documento_id/:fk_url_id', function(req, res, next){


  var id_url = req.params.fk_url_id;
  var id_documento = req.params.fk_documento_id;


  var query = `
    DELETE FROM documento_rel_url
    WHERE
      fk_url_id = ${id_url}
      AND fk_documento_id = ${id_documento};
    DELETE FROM url
    WHERE
      id_url=${id_url}`;

  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(200).send([]);
  });

})



module.exports = router;