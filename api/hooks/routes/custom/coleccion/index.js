'use strict';

var express = require('express'),
  router = express.Router(),
  db = require('../../../../config/db');

router.get('/list', function(req, res, next){

  var query = `
    SELECT DISTINCT
      d.id_documento,
      d.titulo,
      p.fecha_inicio,
      s.nombre,
      c.sigla,
      d.signatura,
      CONCAT(c.sigla, CONCAT(', ', s.nombre, CONCAT(', ', d.signatura))) AS css
    FROM documento d
      LEFT JOIN pertenencia p ON (p.fk_documento_id=d.id_documento AND (p.tipo_atr_doc='Emisión' OR p.tipo_atr_doc='Creación Documento'))
      LEFT JOIN seccion s ON d.fk_seccion_id=s.id_seccion
      LEFT JOIN coleccion c ON c.nombre=s.fk_coleccion
      LEFT JOIN usuario u ON u.id_usuario=d.fk_usuario_id
    ORDER BY p.fecha_inicio DESC, titulo ASC`;

    db.query(query)
    .then(data => {
      res.status(200).send(data[0]);
    })
    .catch(error => {
      res.status(200).send([]);
    });

})


module.exports = router;
