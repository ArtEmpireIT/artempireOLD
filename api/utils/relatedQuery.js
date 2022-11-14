'use strict';

var Sequelize = require('sequelize'),
  _ = Sequelize.Utils._;
var sequelize = require('../config/db');
var express = require('express');
var resProcessor = require('./resProcessor');

var walk = require('walk');
var appDir = require('app-root-path').path;
var ospath = require('path');
var modelsDir = ospath.join(appDir, 'models');

var allModels = {};
walk.walkSync(modelsDir, {
  followLinks: false,
  listeners: {
    file: function(root, fileStats, next){
      var slug = ospath.basename(fileStats.name, '.js');
      allModels[slug] = require(modelsDir+'/'+slug)(sequelize, Sequelize);
      next();
    }
  }
});


var reverseFind = function(slug) {

  let reRelated = [];
  for(var m in allModels) {
    var model = allModels[m];
    for(var att in model.attributes) {
      var at = model.attributes[att];
      if(at.references && at.references.model === slug){
        at.tableName = model.tableName;
        reRelated.push(at);
      }

    }
  }

  return reRelated;
}


var _relatedSQL = function(model, sqls) {


  const related = _.filter(model.attributes, attr => { return attr.references });
  const reverseRelated = reverseFind(model.name);

  const own = _.map(model.attributes, attr => { return model.tableName+'.'+attr.fieldName }).join(', ');

  let sql;
  if(related || reverseRelated ){
      const plain_related = _.map(related, attr => {

        const relModel = allModels[attr.references.model];

        if(relModel){

          let joinname = relModel.tableName;
          if(relModel.tableName===model.tableName) {
            joinname = '_' + model.tableName
          }


          return {
            attrs: _.map(relModel.attributes, attr => { return `${joinname}.${attr.fieldName} AS ${relModel.tableName}__${attr.fieldName}` }).join(', '),
            join: ` LEFT OUTER JOIN ${attr.references.model} ${joinname} ON ${model.tableName}.${attr.fieldName}=${joinname}.${attr.references.key}`
          }

        } else {
          return {
            attrs: '1',
            join: ''
          }
        }

      });

      const reverse_related = _.map(reverseRelated, attr => {
        const relModel = attr.Model;
        let joinname = relModel.tableName;
        if(relModel.tableName===model.tableName) {
          joinname = '__' + model.tableName
        }
        return {
          attrs: _.map(relModel.attributes, attr => {return `${joinname}.${attr.fieldName} AS ${relModel.tableName}__${attr.fieldName}` }).join(', '),
          join: ` LEFT OUTER JOIN ${attr.tableName} ${joinname} ON ${joinname}.${attr.fieldName}=${model.tableName}.${attr.references.key}`
        }
      })


      let fds, rfds = '1';
      let joins, rjoins = '';

      if(plain_related){
        fds = _.map(plain_related, a => { return a.attrs }).join(', ');
        joins = _.map(plain_related, a => { return a.join }).join('\n');
      }

      if(reverse_related) {
        rfds = _.map(reverse_related, a => { return a.attrs }).join(', ');
        rjoins = _.map(reverse_related, a => { return a.join }).join('\n');
      }

      sql = `
        SELECT
          ${own},
          ${fds || 1},
          ${rfds || 1}
        FROM
          ${model.tableName}
          ${joins}
          ${rjoins}
        `;

        sqls.push(sql);


    }

    else {
        let sql = `
          SELECT
            ${own}
          FROM
            ${model.tableName}
          `;
          sqls.push(sql);
    }



    return sql;


}

var relatedSQL = function(slug, req) {


    reverseFind(slug);

    let filter = '';

    if(req.query){
      console.log(req.query);
      for(var k in req.query) {
        filter = `${filter} AND ${k} = '${req.query[k]}'`
      }
    }
    const model = allModels[slug];
    let sqls = [];
    let sql = _relatedSQL(model, sqls)

    sql = `
      SELECT
        query.*
      FROM (${sql}) query
      WHERE true
      ${filter}`

      return sql;

}

var related = function(slug){
  return function(req, res, next) {
    const sql = relatedSQL(slug, req);
    resProcessor(sql, res);
  }
}



var insertedOrSelected = function(slug, req) {
  return "SELECT 1";
}


var upserted = function(slug){
  return function(req, res, next) {
    const sql = insertedOrSelected(slug, req);
    resProcessor(sql, res);
  }
}

module.exports = (slug) => {

  var router = express.Router();
  router.get('/:filter?', related(slug))
  router.post('/', upserted(slug))

  return router;
}
