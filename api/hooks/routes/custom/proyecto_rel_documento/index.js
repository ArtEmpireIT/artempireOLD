'use strict';

var dualPk = require('../../../../utils/dualPk');
module.exports = dualPk('proyecto_rel_documento', 'fk_documento_id', 'fk_proyecto_nombre');
