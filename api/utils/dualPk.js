'use strict';

var express = require('express'),
    db = require('../config/db'),
    resProcessor = require('./resProcessor');


var _get = (slug, pk1, pk2) =>  {

  return (req, res, next) => {

      const pPk1 = req.params.pk1;
      const pPk2 = req.params.pk2;

      let sql =
        `SELECT *
          FROM ${slug}
          WHERE ${pk1}='${pPk1}'`;


      if(pPk2){
        sql = `${sql} AND ${pk2} = '${pPk2}'`;
      }


      resProcessor(sql, res);

  }

}

var _post = (slug, pk1, pk2) =>  {

  return (req, res, next) => {

      const pPk1 = req.body.pk1;
      const pPk2 = req.body.pk2;

      const sql =
        `INSERT INTO ${slug}
          (${pk1}, ${pk2})
          VALUES ('${pPk1}', '${pPk2}')`;

      resProcessor(sql, res);

  }

}


var _put = (slug, pk1, pk2) =>  {

  return (req, res, next) => {

      const oldPk1 = req.params.pk1;
      const oldPk2 = req.params.pk2;

      const pPk1 = req.body[pk1];
      const pPk2 = req.body[pk2];

      const sql =
        `UPDATE ${slug}
          SET ${pk1}='${pPk1}', ${pk2}='${pPk2}'
        WHERE ${pk1}='${oldPk1}' AND ${pk2}='${oldPk2}'`;

      resProcessor(sql, res);

  }

}




var _delete = (slug, pk1, pk2) =>  {

  return (req, res, next) => {

      const pPk1 = req.params.pk1;
      const pPk2 = req.params.pk2;

      let sql =
        `DELETE
          FROM ${slug}
          WHERE ${pk1}='${pPk1}'`;

      if(pPk2){
        sql = `${sql} AND ${pk2} = '${pPk2}'`;
      }

      resProcessor(sql, res);

  }

}





module.exports = (slug, pk1, pk2) => {

  var router = express.Router();

  router.get('/:pk1/:pk2?', _get(slug, pk1, pk2))
  router.post('/:pk1/:pk2', _post(slug, pk1, pk2));
  router.put('/:pk1/:pk2', _put(slug, pk1, pk2));
  router.delete('/:pk1/:pk2?', _delete(slug, pk1, pk2))

  return router;
}
