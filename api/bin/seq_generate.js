'use strict';

var SequelizeAuto = require('sequelize-auto')
var config = require('../config/config');
var appDir = require('app-root-path').path;
var ospath = require('path');
var process = require('process');
var c = config;

console.log(ospath.join(appDir, 'models'));

var auto = new SequelizeAuto(
  c.pgname,
  c.pguser,
  c.pgpass, {
    host: c.pghost,
    dialect: 'postgres',
    directory: ospath.join(appDir, 'models'),
    port: c.pgport,
    additional: {
      timestamps: false
    }
  });

var a = auto.run(function (err) {
  if (err) throw err;

  // console.log(auto.tables); // table list
  console.log(auto.foreignKeys); // foreign key list
  process.exit(0);
});
