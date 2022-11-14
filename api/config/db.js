'use strict';

var cacher = require('sequelize-redis-cache');
var redis = require('redis');
var config = require('./config');
var Sequelize = require('sequelize');

var rc = redis.createClient(6379, 'redis');
var db = new Sequelize(config.pgstring);

db.cacher = cacher(db, rc).ttl(150);

module.exports = db