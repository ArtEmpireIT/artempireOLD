'use strict';

const express = require('express');
const router  = express.Router();
const db = require('../../config/db');
const sequelize = require('sequelize');
const jwt = require('jsonwebtoken');
const {secret} = require('../../config/config');

router.post('/login', (req, res) => {
  const {username, password} = req.body;
  const query = `
    SELECT id, username, access_history, access_archeology, access_isotopes, access_dna, access_maps
    FROM users WHERE username = ? and password = crypt(?, password)
  `;

  db.query(query, {replacements: [username, password], type: sequelize.QueryTypes.SELECT})
  .then(data => {
    const payload = data[0];
    if (!payload) {
      res.status(401).json({error: 'Wrong credentials'});
      return;
    }
    const token = jwt.sign({data: payload}, secret, { expiresIn: '5d' });
    res.json({token});
  }).catch(error => {
    res.status(500).json({error: error.message});
  });
});

module.exports = router;