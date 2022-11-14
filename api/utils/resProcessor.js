'use strict';
var db = require('../config/db');

module.exports = (query, res) => {
  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(500).send(error);
  });
}
