'use strict';

var sequelize = require('./config/db');
var Sequelize = require('sequelize');
var walk = require('walk');
var appDir = require('app-root-path').path;
var ospath = require('path');
var modelsDir = ospath.join(appDir, 'models');
var hooks = require('./hooks');

var importer = function(slug){
  var model = require(modelsDir + '/'+ slug)(sequelize, Sequelize);
  // Model hooks
  try { hooks.models.apply(model); }
  catch(e) { console.error(e); }
  return model;
}

var exports = {};

walk.walkSync(modelsDir, {
  followLinks: false,
  listeners: {
    file: function(root, fileStats, next){
      var slug = ospath.basename(fileStats.name, '.js');
      exports[slug] = importer(slug);
      next();
    }
  }
});


module.exports = exports;
