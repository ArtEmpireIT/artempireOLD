'use strict';

var dualPk = require('../../../../utils/dualPk');

var express = require('express'),
  router = express.Router(),
  db = require('../../../../config/db');

router.delete('/:texto/:id_persona_rol_pertenencia', function(req, res, next){

  var texto = req.params.texto;
  var fk_persona_rol_pertenencia_id = req.params.id_persona_rol_pertenencia;

  var query = `
    DELETE FROM persona_rol_pertenencia_rel_tortura
    WHERE
      fk_tortura_texto = '${texto}'
      AND fk_persona_rol_pertenencia_id = ${fk_persona_rol_pertenencia_id}`;


  console.log(query);

  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(200).send([]);
  });

})


module.exports = router;
