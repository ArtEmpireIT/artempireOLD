'use strict';
var exchangePk = require('../../../utils/exchange_pk');

module.exports = function(model) {
  exchangePk(model, 'fk_agrupacion_bienes_id', 'fk_pertenencia_id');
}
