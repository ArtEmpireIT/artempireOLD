'use strict';

var Sequelize = require('sequelize'),
    config = require('../config/config'),
    db = require('../config/db'),
    models = require('../models'),
    hooks = require('../hooks'),
    process = require('process');


var type2TS = function(type) {

  if(type==='BOOLEAN')
    return 'boolean';

  else if(type==='DOUBLE PRECISION')
    return 'number';

  else if(type==='INTEGER')
    return 'number';

  else if(type==='TIME')
    return 'string';

  else if(type==='TIMESTAMP WITH TIME ZONE')
    return 'string';

  else if(type==='VARCHAR(255)')
    return 'string';
  else {
    console.log("UNKNON TYPE: " + type);
    return 'string';
  }

}

console.log("// AUTO-GENERATED MODELS\n\n");



  // Models composition
  for(var model in models){

    try {

      // First finds out Primery Key for each model

      var m = models[model];
      var primaryKey = m.primaryKeyField;

      // Then setup API resource
      var endpoint = '/' + m.name;
      var toStr = `export class ${m.name} {\n\n`;

      // toStr += `  attrs: Object = {\n\n`
      let appended = [];
      for(var attr in m.attributes){

        var attribute = m.attributes[attr];
        var attrName = attribute.field;
        var attrType = type2TS(attribute.type.toString());
        var attrDef = "    " + attrName + ": " + attrType + ";\n";

        if(appended.indexOf(attrName)===-1) {
          toStr += attrDef;
          appended.push(attrName);
        }
      }
      appended = [];

      toStr += "\n";
      toStr += `    public static endpoint: string = '${endpoint}';\n`;
      toStr += `    pk: string = '${primaryKey}';\n`;

      const pkeyField = m.attributes[primaryKey];
      if(pkeyField.autoIncrement) {
        toStr += `    auto_pk: boolean = true;\n`;
      }
      else {
        toStr += `    auto_pk: boolean = false;\n`;
      }

      // Constructor
      toStr += `
    constructor(modelData: any){
`;

      let attrs = {};

      // console.log(m.attributes);
      for(var attr in m.attributes){
        var attribute = m.attributes[attr];
        var attrName = attribute.field;
        if(attrName!=='INTEGER'){
          const pkeyField = m.attributes[primaryKey];
          if(attrName !== primaryKey || (attrName===primaryKey && !m.attributes[primaryKey].autoIncrement)) {
            toStr += `      this.${attrName} = modelData.${attrName};\n`;
            attrs[attrName] = null;
          }
        }
      }

      toStr += '\n';
      toStr += "    }\n\n";
      toStr += `    public static attrs () { return JSON.parse(JSON.stringify(` + JSON.stringify(attrs) + `)); }\n`;

      toStr += "}\n\n";

      console.log(toStr);

    } catch(e) {
      console.error(e);
      console.error(toStr);
    }

    // console.log("Endpoint appended: " + endpoint);
  }
  process.exit(0);
