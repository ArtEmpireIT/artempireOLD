'use strict';

var appDir = require('app-root-path').path;
var ospath = require('path');
var walk = require('walk');
var config = require(appDir + '/config/config');
var relatedRouter = require(ospath.join(appDir, 'utils') + '/relatedQuery');

var express = require('express'),
  router = express.Router();



// Epilogue hooks
var eDir = ospath.join(appDir, 'hooks', 'epilogue');
var epilogues = {};
epilogues.common = require(ospath.join(eDir, 'common'));
eDir = ospath.join(eDir, 'custom');
walk.walkSync(eDir, {
  followLinks: false,
  listeners: {
    file: function(root, fileStats, next){
      var slug = ospath.basename(fileStats.name, '.js');
      epilogues[slug] = require(ospath.join(eDir, slug));
      next();
    }
  }
});


// Models hooks
var mDir = ospath.join(appDir, 'hooks', 'models');
var models = {};
models.common = require(ospath.join(mDir, 'common'));
mDir = ospath.join(mDir, 'custom');
walk.walkSync(mDir, {
  followLinks: false,
  listeners: {
    file: function(root, fileStats, next){
      var slug = ospath.basename(fileStats.name, '.js');
      try { models[slug] = require(ospath.join(mDir, slug)); }
      catch(e){ console.error(e); }
      next();
    }
  }
});


// Routes hooks
var rDir = ospath.join(appDir, 'hooks', 'routes', 'custom');
var routes = {};
var rCommon = ospath.join(appDir, 'hooks', 'routes', 'common');
var reqRCommon = require(rCommon);
walk.walkSync(rDir, {
  followLinks: false,
  listeners: {
    file: function(root, fileStats, next){

      var slug = ospath.basename(root, '.js');

      // Only first
      if(!(slug in routes)){
        var base = ospath.basename(root, '.js');
        var p = ospath.join(rDir, base, slug);

        try { routes[slug] = require(root); }
        catch(e){ console.error(e); }

      }
      next();
    }
  }
});


module.exports = {
  epilogue: {
    apply: function(r){
      // COMMON HOOKS FIRST
      this.hooks.common(r);
      if(r.model.name in this.hooks){
        // SPECIFIC HOOKS LATER
        console.log("");
        console.log("// EPILOGUE HOOKS FOUND FOR " + r.model.name);
        this.hooks[r.model.name](r);
      }
    },
    hooks: epilogues
  },
  models: {
    apply: function(model){

      // COMMON HOOKS FIRST
      this.hooks.common(model);
      if(model.name in this.hooks){
        // SPECIFIC HOOKS LATER
        console.log("");
        console.log("// MODEL HOOKS FOUND FOR " + model.name);
        this.hooks[model.name](model);
      }
    },
    hooks: models
  },
  routes: {
    apply: function(app, r){
      // COMMON HOOKS FIRST
      var route;
      if(r.model.name in this.hooks){
        // SPECIFIC HOOKS LATER
        route = this.hooks[r.model.name];
      }
      else {
        route = express.Router();
      }


      console.log("");
      console.log("// ROUTE HOOKS FOUND FOR " + r.model.name);
      route.stack.map(x =>{ return x.route }).forEach(ep => {
        console.log("Endpoint appended: " + '/_/' + r.model.name + ep.path );
      });
      app.use('/_/' + r.model.name, route);

      // Uploads
      var upRoute = reqRCommon(r.model.name);
      // console.log(upRoute.stack);

      upRoute.stack.map(x =>{ return x.route }).forEach(ep => {
        console.log("Endpoint appended: " + '/_/' + r.model.name + ep.path );
      });
      app.use('/_/' + r.model.name, upRoute);

      // With related
      app.use('/_related/' + r.model.name, relatedRouter(r.model.name));

    },
    hooks: routes
  },
  // static: {
  //   apply: function(app){
  //     var c = config;
  //     var dirs = new Set();

  //     walk.walkSync(c.uploads, {
  //       followLinks: false,
  //       listeners: {
  //         file: function(root, fileStats, next){
  //           dirs.add(root);
  //           next();
  //         }
  //       }
  //     });

  //     dirs.forEach(d => {
  //       var p = ospath.normalize(d);
  //       var base = p.split('/').slice(2).join('/');
  //       app.use(p, express.static(p));
  //     })

  //   }
  // }
};
