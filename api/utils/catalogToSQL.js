'use strict';

const catalogElements = [
  {schema:'public', table:'objeto', returning_key:'id_objeto', columns:['nombre'], values:['Prueba'], searchValue:1, searchValues:[1]},
  {schema:'public', table:'material', returning_key:'id_material', columns:['nombre'], values:['Prueba'], searchValue: 78, searchValues:[78]},
  {schema:'public', table:'lugar', returning_key:'nombre', columns:['nombre'], values:['Sevilla'], searchValue: 'Sevilla', searchValues:['Sevilla']}
]

module.exports = function(catalogElements){

  console.log(catalogElements);



  // console.log(iwcow(catalogElements));

  let withString = 'WITH ';
  let selects = '';
  let columnIds = '';

  for(let c of catalogElements){

    const escapeValues = [];
    for (let v of c.values) {
      if (typeof v === 'string'){
        escapeValues.push(`\'${v}\'`);
      }else{
        escapeValues.push(v);
      }
    }
    let searchValues = c.searchValues.map( searchValue => {
      if (typeof searchValue === 'string'){
        return `\'${searchValue}\'`;
      }
      else {
        return searchValue;
      }
    });


    withString += `
      ${c.table}_select as (
          SELECT ${c.returning_key}
          FROM ${c.schema}.${c.table}
          WHERE ${c.returning_key} = ${c.searchValue}
      ), ${c.table}_insert as (
          INSERT INTO ${c.schema}.${c.table} (${c.columns.toString()})
          SELECT ${escapeValues.toString()}
          WHERE NOT EXISTS (select ${c.returning_key} from ${c.table}_select)
          RETURNING ${c.returning_key}
      ),`;

    selects += `
      (SELECT ${c.returning_key}
      FROM ${c.table}_insert
      UNION ALL
      SELECT ${c.returning_key}
      FROM ${c.table}_select) as ${c.table},`;

    columnIds += `${c.table}.${c.returning_key},`;

  }
  withString = withString.slice(0,-1);
  columnIds = columnIds.slice(0,-1);
  selects = `SELECT ${columnIds} FROM ${selects.slice(0,-1)}`;
  return `${withString} ${selects}`;
}
