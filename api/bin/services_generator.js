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
  else
    return 'string';
}

console.log("// AUTO-GENERATED SERVICES\n\n");
console.log('import { Injectable, Injector } from "@angular/core";');
console.log('import { RestService } from "./rest.service";');
console.log('import * as models from "../models/all";\n\n')

// Models composition
for(var model in models){

  try {
    // First finds out Primery Key for each model

    var m = models[model];
    hooks.models.apply(m);
    var primaryKey = m.primaryKeyField;

    // Then setup API resource
    var endpoint = '/' + m.name;
    var toStr = `
  @Injectable()
  export class ${m.name}Service extends RestService {
    constructor(injector: Injector){
      super(injector, models['${m.name}'].endpoint);
    }
  }
  `;

    console.log(toStr);

  } catch(e) {
    console.error(e);
    console.error(toStr);
  }

}

process.exit(0);
