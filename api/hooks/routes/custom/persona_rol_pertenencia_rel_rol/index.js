'use strict';

var dualPk = require('../../../../utils/dualPk');
module.exports = dualPk('persona_rol_pertenencia_rel_rol', 'fk_persona_rol_pertenencia', 'fk_rol_nombre');
