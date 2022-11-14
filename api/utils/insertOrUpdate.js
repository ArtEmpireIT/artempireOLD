'use strict';


var express = require('express');
var resProcessor = require('./resProcessor');
var catalogToSQL = require('./catalogToSQL');

module.exports = () => {

  var router = express.Router();

  router.get('/', function(req, res, next){
    // resProcessor("SELECT 'Hello Generic' as hello", res);
    console.log("INSERT");
    res.sendStatus(200);
  })

  router.post('/', function(req, res, next){
    resProcessor(catalogToSQL(req.body), res);
  });

  return router;
}
