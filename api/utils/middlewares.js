'use strict';

const config = require('../config/config')
const jwt = require('jsonwebtoken')
const expressValidator = require('express-validator');

module.exports.slugger = function(req, res, next){
  var slugs = req.originalUrl.split('/');
  var slug = slugs[1];
  req.slug = slug === '_' ? slugs[2] :  slug;

  return next();
}


module.exports.validator = expressValidator();

module.exports.responseValidator = function(req, res, next){
  return req.getValidationResult()
  .then(function(result){
    if(result.isEmpty()){
      return next();
    }
    else {
      const errors = result.array();
      return res.status(400).json(errors);
    }
  })
  .catch(function(errors){
    console.error(errors);
    return res.status(400).json(errors);

  });
}

var quoted = function(key){
  return (key) ? `'${key}'` : 'NULL';
}

var unquoted = function(key) {
  return (key) ? `${key}` : 'NULL';
}

var jsonParse = function(json) {
  for (const key in json) {
    if (json[key] === undefined) {
      json[key] = null
    }
    if (json[key] !== null) {
      if (typeof json[key] === 'string') {
        json[key] = `$string$${json[key]}$string$`;
      } else if (Object.prototype.toString.call(json[key]) === '[object Object]') {
        jsonParse(json[key]);
      } else if (Object.prototype.toString.call(json[key]) === '[object Array]') {
        if (json[key].length === 0) {
          json[key] = 'ARRAY[]::text[]';
        } else {
          let isArrayObject = false;
          for (let i=0; i<json[key].length; i++) {
            if (Object.prototype.toString.call(json[key][i]) === '[object Object]') {
              json[key][i] = JSON.stringify(json[key][i]);
              isArrayObject = true;
            }
          }
          json[key] = `ARRAY[${json[key].map(v => `$json$${v}$json$`).join()}]${isArrayObject ? '::json[]' : ''}`;
        }
      }
    }
  }
}

module.exports.bodyQuoter = (req, res, next) => {
  res.locals.quoted = {};
  res.locals.unquoted = {};
  Object.keys(req.body).map( key => {
    res.locals.quoted[key] = quoted(req.body[key]);
    res.locals.unquoted[key] = unquoted(req.body[key]);
  });

  return next();
}

module.exports.bodyParse = (req, res, next) => {
  jsonParse(req.body)
  return next();
}

module.exports.parseJWT = (req, res, next) => {
  const authHeader = req.header('Authorization') || '';
  const token = authHeader.split(' ')[1];
  if (!token) {
    next();
    return;
  }
  jwt.verify(token, config.secret, (err, decoded) => {
    if (!err) {
      req.user = decoded && decoded.data;
    }
    next();
  });
}

