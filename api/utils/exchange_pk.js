'use strict';

module.exports = (model, oldPk, newPk) => {

  // HACK for dual primary key
  for(var att in model.attributes) {
    var attr = model.attributes[att];
    if(att===newPk){
      attr.primaryKey = true;
    }

    if(att===oldPk){
      delete attr.primaryKey;
    }
  }

  model.primaryKeyField = newPk;
  model.refreshAttributes();
}
