'use strict';
var exchangePk = require('../../../utils/exchange_pk');

module.exports = function(model) {
  exchangePk(model, 'fk_institucion_nombre', 'fk_persona_rol_pertenencia_id');
}
