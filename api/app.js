'use strict';

require('sequelize');
const epilogue = require('epilogue');
const config = require('./config/config');
const db = require('./config/db');
const models = require('./models');
const http = require('http');
const hooks = require('./hooks');
const middlewares = require('./utils/middlewares');
const search = require('./hooks/routes/search');
const users = require('./hooks/routes/users');
const jwtMiddleware = require('express-jwt');
const cors = require('cors');
const helmet = require('helmet');

// Initialize server
const express = require('express');
const bodyParser = require('body-parser');
const fileUpload = require('express-fileupload');

const app = express();

app.set('json spaces', 2);

app.use(cors());
app.use(helmet());

app.use(fileUpload({
  limits: {fileSize: 50 * 1024 * 1024},
  abortOnLimit: true
}));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(middlewares.validator); 

// auth middleware
const jwtWhitelist = [/^\/search\//, '/users/login'];
app.use(
  jwtMiddleware({ secret: config.secret }).unless({
    method: ['GET', 'OPTIONS'],
    path: jwtWhitelist
  })
);

// Custom middlewares
app.use(middlewares.slugger);
app.use(middlewares.bodyQuoter);


const server = http.createServer(app);

// Initialize epilogue
epilogue.initialize({
  app: app,
  sequelize: db
});

// Models setup
for (const model in models) {
  // First finds out Primary Key for each model
  const m = models[model];
  const primaryKey = m.primaryKeyField;

  const endpoint = '/' + m.name;
  const endpoints = [endpoint, endpoint + '/:' + primaryKey];
  
  // Then setup API resource
  const r = epilogue.resource({model: m, endpoints: endpoints});

  // Apply custom hooks, if needed
  hooks.epilogue.apply(r);

  // Custom routes
  hooks.routes.apply(app, r);
}

// // Serve static Uploads
// TODO: Add to enviroment var, commet in production mode
// app.use('/uploads', express.static(config.uploads));
// 
// // Apply static routes
// hooks.static.apply(app);

// Other routes
app.use('/search', search);
app.use('/users', users);

// 404 handler
app.use((req, res, next) => {
  if (req.method === 'OPTIONS') {
    next();
    return;
  }
  res.status(404).json({error: `${req.url} not found`});
});

// error handler
app.use((err, req, res, next) => {
  console.error('ERROR caught: ', err);
  if (res.headersSent) {
    return next(err);
  }
  err.status = err.status || 500;
  res.status(err.status).json(Object.assign({}, err));
});

// Listen
server.listen(config.port, function() {
  const host = server.address().address;
  const port = server.address().port;

  console.log('Listening at http://%s:%s', host, port);
});
