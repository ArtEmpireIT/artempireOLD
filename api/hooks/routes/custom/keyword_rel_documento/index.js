'use strict';

var dualPk = require('../../../../utils/dualPk');
module.exports = dualPk('keyword_rel_documento', 'fk_documento_id', 'fk_keyword_palabra');
