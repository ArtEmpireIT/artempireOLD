'use strict';

module.exports = function(model){

  // HACK for autoIncrement
  for(var att in model.attributes) {
    var attr = model.attributes[att];
    if('defaultValue' in attr && 'primaryKey' in attr) {
      if(attr.primaryKey) {
        delete attr.defaultValue;
        attr.autoIncrement = true;
        // console.log("AUTO INCREMENT SET FOR " + model.name);
        model.refreshAttributes();
      }
    }
  }

};
