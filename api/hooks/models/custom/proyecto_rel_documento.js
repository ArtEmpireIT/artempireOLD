'use strict';
var exchangePk = require('../../../utils/exchange_pk');

module.exports = function(model) {
  exchangePk(model, 'fk_proyecto_nombre', 'fk_documento_id');
}
