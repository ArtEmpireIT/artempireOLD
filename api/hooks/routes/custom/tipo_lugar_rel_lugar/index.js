'use strict';

var dualPk = require('../../../../utils/dualPk');
module.exports = dualPk('tipo_lugar_rel_lugar', 'fk_lugar_id', 'fk_tipo_lugar_nombre');
