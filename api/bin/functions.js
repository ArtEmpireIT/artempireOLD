#!/usr/bin/env node

'use strict';

const db = require('../config/db'),
    process = require('process');
const walk = require('walk');
const fs = require('fs');
const appDir = require('app-root-path').path;
const ospath = require('path');
const log = console;
/*
 * Showing a little bit of courtesy
 */
log.info('FUNCTIONS LOADER');
log.info('======================\n');

process.on('exit', function(code, t) {
  if(!code){
    log.info('GOODBYE!!!');
    log.info('==========');
  }
   else {
    log.error("There was an error. Aborting execution.")
   }

});

/*
 * Constants definition
 */
var BASE = './db/plpgsql/';
var FBASE = ospath.join(appDir, BASE);

var SEPARTAROR = '_';
var VERBOSE = true;

let promises = [];
walk.walkSync(FBASE, {
  followLinks: false,
  listeners: {
    file: function(root, fileStats, next){
      try {
        const target = ospath.join(root, fileStats.name);
        let functionSql = fs.readFileSync(target).toString();

        promises.push(
          db.query(functionSql)
            .then( data => {
              log.info(data[1]['command'], target);
              next();
            })
            .catch( error => { throw error })
          );

        } catch(e) {
          log.error(e);
          process.exit(1);
        }


    }
  }
});

Promise.all(promises).then( values => {
  process.exit(0);
})
.catch( error => {
  log.error(error);
  process.exit(2);
});
