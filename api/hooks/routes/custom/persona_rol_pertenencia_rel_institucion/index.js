'use strict';

var dualPk = require('../../../../utils/dualPk');
module.exports = dualPk('persona_rol_pertenencia_rel_institucion', 'fk_persona_rol_pertenencia_id', 'fk_institucion_nombre');
