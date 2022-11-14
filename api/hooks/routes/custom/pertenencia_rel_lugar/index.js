'use strict';

var express = require('express'),
  router = express.Router(),
  db = require('../../../../config/db');


router.get('/:tipo_atr_doc/:fk_documento_id', function(req, res, next){

  var query = `
    SELECT
      p.*,
      l.id_lugar,
      l.nombre as lugar,
      prl.precision_pert_lugar as precision_lugar,
      prl.tipo_lugar as tipo
    FROM pertenencia p
    LEFT JOIN pertenencia_rel_lugar prl ON p.id_pertenencia=prl.fk_pertenencia_id
    LEFT JOIN lugar l ON prl.fk_lugar_id=l.id_lugar
    WHERE p.fk_documento_id=${req.params.fk_documento_id}
    AND p.tipo_atr_doc = '${req.params.tipo_atr_doc}'
    `;

  db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    res.status(200).send([]);
  });

})

module.exports = router;
