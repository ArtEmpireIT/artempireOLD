'use strict';

var express = require('express'),
  db = require('../../config/db'),
  ospath = require('path'),
  uploader = require('../../utils/uploader'),
  relatedQuery = require('../../utils/relatedQuery'),
  resProcessor = require('../../utils/resProcessor'),
  config = require('../../config/config'),
  readUploads = require('../../utils/readUploads'),
  fs = require('fs');



var getStatic = function(req, res, next){
  var c = config;
  var target = ospath.join(c.uploads, req.slug, req.params.id);
  console.log(target);
  return express.static(target);
}


var uploadFile = function(slug){

  return function(req, res, next){

    uploader(ospath.join(slug, req.params.id), req.files.upload)
    .then(function(d){
      res.status(201).send();
    })
    .catch(function(err){
      res.status(400);
    })

  }
}

var deleteFile = function(req, res, next){

  var c = config;
  var fullpath = ospath.join(c.uploads, req.slug, req.params.id, req.params.filename);
  var thumbspath = ospath.join(c.uploads, req.slug, req.params.id, 'thumbs', req.params.filename + '_thumb.png');

  console.log(fullpath);
  console.log(thumbspath);

  fs.unlinkSync(fullpath);
  fs.unlinkSync(thumbspath);

  res.status(200).send({message: `deleted file ${req.params.filename}`});
}

// Completion simple
var completionKeywords = function(slug){

  return function(req, res, next){

    const columns = req.params.columns.split('&');
    let filter = columns.map( column => {
      return `(${column}::text ILIKE '%${req.query.q}%' AND ${column} IS NOT NULL)`
    });
    filter = filter.join(' OR ');

    var query;
    if(req.params.columns){
      query = `
        SELECT DISTINCT ${columns.join(',')} FROM ${slug}
        WHERE true
        AND (
          ${filter}
        )
        ORDER BY ${columns[0]}`;
    }
    else {
      query = `SELECT DISTINCT * FROM ${slug}`;
    }

    db.query(query)
    .then(data => {
      res.status(200).send(data[0]);
    })
    .catch(error => {
      res.status(200).send([]);
    });
  }
}

module.exports = function(slug){

  var router = express.Router();

  // To upload files
  router.get('/:id/uploads/', readUploads);
  router.post('/:id/upload', uploadFile(slug));
  router.delete('/:id/upload/:filename', deleteFile)

  // Auto-completion
  router.get('/completion/:columns', completionKeywords(slug));

  return router;
}
