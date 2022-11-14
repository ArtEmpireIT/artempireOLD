'use strict';

var dualPk = require('../../../../utils/dualPk');
module.exports = dualPk('pertenencia_rel_agrupacion_bienes', 'fk_pertenencia_id', 'fk_agrupacion_bienes_id');
