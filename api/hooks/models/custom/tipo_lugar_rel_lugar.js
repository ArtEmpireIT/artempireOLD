'use strict';
var exchangePk = require('../../../utils/exchange_pk');

module.exports = function(model) {
  exchangePk(model, 'fk_tipo_lugar_nombre', 'fk_lugar_id');
}
