'use strict';

var express = require('express'),
  router = express.Router(),
  db = require('../../../../config/db'),
  keyword = require('../../../../models').keyword;

router.get('/completion', function(req, res, next){

  var filter = '';
  if(req.query.fk_keyword){
    if(typeof req.query.fk_keyword!=='object'){
      req.query.fk_keyword = [req.query.fk_keyword];
    }
    var a = req.query.fk_keyword.join("', '");
    filter = `OR fk_keyword IN ('${a}')`;
  }

  var query = `
    SELECT * FROM keyword
    WHERE (palabra LIKE '%${req.query.q}%' OR fk_keyword LIKE '%${req.query.q}%')
    AND (fk_keyword IS NULL
    ${filter})
    ORDER BY fk_keyword, palabra`;

  db.query(query, {model: keyword})
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(200).send([]);
  });

})


module.exports = router;