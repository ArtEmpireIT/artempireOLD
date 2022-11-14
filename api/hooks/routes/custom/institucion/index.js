'use strict';

var express = require('express'),
  router = express.Router(),
  db = require('../../../../config/db'),
  responseValidator = require('../../../../utils/middlewares').responseValidator,
  bodyParse = require('../../../../utils/middlewares').bodyParse,
  resProcessor = require('../../../../utils/resProcessor');


var insValidator = function (req, res, next) {

    req.checkBody('id_documento', 'id_documento requerido').notEmpty();
    req.checkBody('nombre', 'nombre requerido').notEmpty();
    return next();

};


router.post('/',
  insValidator,
  responseValidator,
  bodyParse,
  (req, res, next) => {

    console.log(req.body);


    const query = `
      SELECT ae_add_institucion(
        ${req.body.id_documento},
        ${req.body.id_pertenencia},
        ${req.body.id_persona_rol_pertenencia},
        ${req.body.nombre},
        ${req.body.rol},
        ${req.body.motivo},
        ${req.body.tipo_atr_doc},
        ${req.body.descripcion}
      )`;

      resProcessor(query, res);

})


module.exports = router;
