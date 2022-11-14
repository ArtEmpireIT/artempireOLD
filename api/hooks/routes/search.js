'use strict';

const express = require('express');
const router  = express.Router();
const db = require('../../config/db');
const sequelize = require('sequelize');
const readFSTree = require('./readFSTree');
const { parseJWT } = require('../../utils/middlewares');

/**
 * All search endpoints receive a SearchBody as req.body
 * 
 * SearchBody
 * { viz: string[], filter: SearchFilter[] }
 * 
 * SearchFilter:
 * { id: string, type: string, value: SearchValue }
 * 
 * SearchValue:
 * string | number | boolean | string[] | number[] | SearchFilter[]   
 */

function validateSearchBody(req, res, next) {
  if (!req.body) {
    res.status(400).json({error: 'missing POST body'});
    return;
  }
  const viz = req.body.viz;
  const filter = req.body.filter;
  if (!Array.isArray(viz)) {
    res.status(400).json({error: 'body.viz must be an array'});
    return;
  }
  if (!Array.isArray(filter)) {
    res.status(400).json({error: 'body.filter must be an array'});
    return;
  }
  const aliasRegex = /^[a-zA-Z0-9_]+$/;
  const validViz = viz.every(el => aliasRegex.test(el));
  if (!validViz) {
    res.status(400).json({error: 'Invalid viz field. Only letters, numbers and _ are allowed.'});
    return;
  }
  const validFilterIds = filter.every(el => aliasRegex.test(el.id));
  if (!validFilterIds) {
    res.status(400).json({error: 'Invalid filter id. Only letters, numbers and _ are allowed.'});
    return;
  }
  const validSortKey = req.body.sortKey ? aliasRegex.test(req.body.sortKey) : true;
  if (!validSortKey) {
    res.status(400).json({error: 'Invalid sort key. Only letters, numbers and _ are allowed.'});
    return;
  }
  const page = req.body.page || 0;
  const rpp = req.body.rpp || 10;
  if (isNaN(+page) && page !== 'disable') {
    res.status(400).json({error: 'Invalid page param. It must be a number'});
    return;
  }
  if (isNaN(+rpp)) {
    res.status(400).json({error: 'Invalid rpp param. It must be a number'});
    return;
  }
  
  next();
}

function getFilterQuery(filters, join, valueJoin) {
  if (join !== 'AND' && join !== 'OR') {
    throw new Error('[search.getFilterQuery] invalid join type ', join);
  }
  if (valueJoin !== 'AND' && valueJoin !== 'OR') {
    throw new Error('[search.getFilterQuery] invalid valueJoin type ', join);
  }
  const filterMap = {
    lte: f => ({sql: `${join} ${f.id} <= ?`, params: [f.value]}),
    gte: f => ({sql: `${join} ${f.id} >= ?`, params: [f.value]}),
    exact: f => ({sql: `${join} ${f.id} = ?`, params: [f.value]}),
    text: f => ({sql: `${join} ${f.id} ILIKE ?`, params: [`%${f.value}%`]}),
    range: f => ({sql: `${join} ${f.id} BETWEEN ? AND ?`, params: f.value}),
    'date-range': f => {
      const [minKey, maxKey] = f.value.keys;
      const [minVal, maxVal] = f.value.values;
      return {
        sql: `${join} (${minKey} BETWEEN ? AND ? OR ${maxKey} BETWEEN ? AND ?)`,
        params: [minVal, maxVal, minVal, maxVal]
      }
    },
    'isotopy-range': f => {
      let sql = `${join} ${f.id} BETWEEN ? AND ?`;
      if (f.value.length === 0) {
        sql = `${join} ${f.id} IS NULL`;
      }
      if (f.value.length === 1) {
        sql = `${join} ${f.id} = ?`;
      }
      return {sql, params: f.value.map(n => Number(n.replace(',', '.')))}
    },
    'auto-complete': f => ({sql: `${join} ${f.id} = ?`, params: [f.value]}),
    'auto-complete-array': f => ({sql: `${join} ARRAY[?::varchar] <@ ${f.id} `, params: [f.value]}),
    dict: f => ({sql: `${join} ${f.id} IN (${f.value.map(() => '?').join(',')})`, params: f.value}),
    boolean: f => ({sql: `${join} ${f.id} = ?`, params: [f.value]}),
    person: f => ({sql: `${join} ${f.id} = ?`, params: [f.value]}),
    'person-array': f => ({sql: `${join} ? = ANY(${f.id})`, params: [f.value]}),
    place: f => ({sql: `${join} ${f.id} = ?`, params: [f.value]}),
    'count-subfilter': f => {
      let sql = `${join} ${f.id} = 0 `;
      let params = [];
      if (f.value) {
        const subfilter = getFilterQuery(f.value, 'AND', 'OR');
        sql = `${join} ${f.id} > 0 ${subfilter.sql}`;
        params = subfilter.params;
      }
      return {sql, params};
    },
    'groupby': f => {
      const filters = f.value
        .map(f => filterMap[f.type] && filterMap[f.type](f))
        .filter(Boolean)
      
      const sql = `${join} ( ${filters.map(f => f.sql.replace(join, '')).join(` ${valueJoin} `)} )`;
      const params = filters.reduce((acum, elem) => acum.concat(elem.params), [])
      return {sql, params}
    }
  }
  let sql = '';
  let params = [];
  filters.forEach(f => {
    if (f.value === null || 
        f.value === undefined || 
        (Array.isArray(f.value) && f.type !== 'isotopy-range' && f.value.length === 0)) {
      console.log(`\n[search.getFilterQuery] skipping filter ${f.id} with invalid value ${JSON.stringify(f.value)}\n`);
      return;
    }
    const filterPiece = filterMap[f.type] && filterMap[f.type](f);
    if (!filterPiece) {
      return;
    }
    sql += `${filterPiece.sql} `;
    params = params.concat(filterPiece.params);
  });
  sql = sql.replace(/^OR/, 'AND');
  return {sql, params};
}

function getSortAndPaging(body) {
  const sortKey = body.sortKey;
  const sortType = body.sortType === 'ASC' ? 'ASC' : 'DESC';
  let sortQuery = sortKey ? `ORDER BY ${sortKey} ${sortType}` : '';
  if (sortKey === 'ia_ue') {
    sortQuery = `ORDER BY ia_ue_only_text ${sortType},
      ia_ue_only_numbers ${sortType} NULLS FIRST,
      ia_ue ${sortType}`;
  }

  const page = body.page || 0;
  const rpp = body.rpp || 10;
  // const pagingQuery = page === 'disable' ? '' : `LIMIT ${rpp} OFFSET ${rpp * page}`;
  return {sortQuery, pagingQuery: ''};
}

function insertFiles({data, tree, idKey, fileKey, removeConfidencialImg}) {
  const imgRegex = /\.(jpeg|jpg|png|gif)$/;
  const pdfRegex = /\.pdf$/;
  const newData = data.map(row => {
    const id = row[idKey]
    fileKey = fileKey || 'files'
    const files = row[fileKey] = tree[id] || [];
    if (row.confidencial_img && removeConfidencialImg) {
      row[fileKey] = []
    }
    row[`${fileKey}_pdf`] = files.filter(n => pdfRegex.test(n));
    row[`${fileKey}_img`] = files.filter(n => imgRegex.test(n));
    row[`${fileKey}_other`] = files.filter(n => !pdfRegex.test(n) && !imgRegex.test(n));
    return row;
  });
  return newData
}

function makeResponse({res, query, filter, removeConfidencialImg, fileReads}) {
  Promise.all([
    Promise.all(fileReads.map(config => readFSTree(config.filepath))),
    db.query(query, {replacements: filter.params, type: sequelize.QueryTypes.SELECT})
  ]).then(results => {
    const [trees, rows] = results;
    let dataWithFiles = rows;
    trees.forEach((tree, index) => {
      const config = fileReads[index]
      dataWithFiles = insertFiles({
        tree,
        data: dataWithFiles,
        removeConfidencialImg,
        idKey: config.idKey,
        fileKey: config.fileKey
      })
    })
    res.status(200).send(dataWithFiles);
  }).catch(error => {
    res.status(500).send({message: 'Error in makeResponse', error});
  });
}

function geomJoins (key) {
  return `
    LEFT JOIN polygon ${key}_pg ON ${key}.fk_polygon_id = ${key}_pg.id_polygon
    LEFT JOIN point ${key}_pn ON ${key}.fk_point_id = ${key}_pn.id_point
    LEFT JOIN line ${key}_ln ON ${key}.fk_line_id = ${key}_ln.id_line
  `
}

function geomKeys (key) {
  return `${key}_pn, ${key}_pg, ${key}_ln`
}

function geomSelect (key) {
  return `
    st_astext(${key}_pn.geom_wgs84) as ${key}_pn,
    st_astext(${key}_pg.geom_wgs84) as ${key}_pg,
    st_astext(${key}_ln.geom_wgs84) as ${key}_ln`
}

router.post('/historic/document', validateSearchBody, parseJWT, (req, res) => {
  const secretQuery = req.user ? '' : 'AND COALESCE(doc.confidencial_datos, FALSE) = FALSE ';
  const {sortQuery, pagingQuery} = getSortAndPaging(req.body);
  const filter = getFilterQuery(req.body.filter, req.body.join, req.body.value_join);
  const viz = req.body.viz;

  const query = `
    SELECT DISTINCT ${viz.length > 0 ? viz : '*'},
      doc_id,
      confidencial_img,
      ${geomKeys('l_inicio')},
      count(*) OVER() AS full_count
    FROM (
      SELECT
        doc.titulo as doc_titulo,
        doc.confidencial_img as confidencial_img,
        doc.id_documento as doc_id,
        p_emision.fecha_inicio as pert_fecha_inicio,
        COALESCE(p_recepcion.fecha_inicio, p_emision.fecha_inicio) as pert_fecha_fin,
        pl.fk_lugar_id as doc_lugar_inicio_id,
        l_inicio.nombre as doc_lugar_nombre,

        ${geomSelect('l_inicio')},

        doc.signatura as doc_signatura,
        s.nombre as doc_seccion,
        s.fk_coleccion as doc_coleccion,
        ARRAY(SELECT fk_keyword_palabra FROM keyword_rel_documento kw WHERE kw.fk_documento_id = doc.id_documento)
          as doc_keyword
  
      FROM documento doc
      LEFT JOIN seccion s ON doc.fk_seccion_id = s.id_seccion
      JOIN pertenencia p_emision ON doc.id_documento = p_emision.fk_documento_id AND p_emision.tipo_atr_doc = 'Emisión'
      LEFT JOIN pertenencia p_recepcion ON doc.id_documento = p_recepcion.fk_documento_id AND p_recepcion.tipo_atr_doc = 'Recepción'
      LEFT JOIN pertenencia_rel_lugar pl ON pl.fk_pertenencia_id = p_emision.id_pertenencia
      LEFT JOIN lugar l_inicio ON pl.fk_lugar_id = l_inicio.id_lugar
      ${geomJoins('l_inicio')}
      WHERE TRUE ${secretQuery}
    ) as data
    WHERE TRUE ${filter.sql} ${sortQuery} ${pagingQuery}
  `

  makeResponse({
    res, filter, query,
    fileReads: [{
      filepath: '/uploads/documento',
      idKey: 'doc_id'
    }],
    removeConfidencialImg: !req.user
  });
})

router.post('/historic/person', validateSearchBody, parseJWT, (req, res) => {
  // const { access_history } = (req.user || {});
  const secretQuery = req.user ? '' : 'AND COALESCE(doc.confidencial_datos, FALSE) = FALSE ';
  const {sortQuery, pagingQuery} = getSortAndPaging(req.body);
  const relationsQuery = `
  (SELECT ARRAY[
    (SELECT count(people) FROM (
      (
        SELECT prpb.id_persona_rol_pertenencia
        FROM persona_rol_pertenencia prpb
        LEFT JOIN pertenencia p on p.id_pertenencia = prpb.fk_pertenencia_id
        LEFT JOIN persona_rol_pertenencia prpa on prpa.id_persona_rol_pertenencia = prpb.fk_persona_rol_pertenencia_id
        LEFT JOIN persona_historica ph on ph.id_persona_historica = prpb.fk_persona_historica_id
        WHERE p.fk_documento_id = doc.id_documento AND prpa.fk_persona_historica_id = _ph.id_persona_historica
      ) UNION ALL (
        SELECT prpb.id_persona_rol_pertenencia
        FROM persona_rol_pertenencia prpb
        LEFT JOIN pertenencia p on p.id_pertenencia = prpb.fk_pertenencia_id
        INNER JOIN persona_rol_pertenencia prpa on prpa.id_persona_rol_pertenencia = prpb.fk_persona_rol_pertenencia_id
        LEFT JOIN persona_historica ph on ph.id_persona_historica = prpa.fk_persona_historica_id
        WHERE p.fk_documento_id = doc.id_documento AND prpb.fk_persona_historica_id = _ph.id_persona_historica
      )
    ) as people), (
      SELECT count(*) FROM persona_rol_pertenencia_rel_linea prpl
      LEFT JOIN persona_rol_pertenencia prp on prp.id_persona_rol_pertenencia = prpl.fk_persona_rol_pertenencia_id
      LEFT JOIN pertenencia p on p.id_pertenencia = prp.fk_pertenencia_id
      LEFT JOIN linea l on l.id_linea = prpl.fk_linea
      LEFT JOIN objeto o on o.id_objeto = l.fk_objeto_id
      WHERE p.fk_documento_id = doc.id_documento AND prp.fk_persona_historica_id = _ph.id_persona_historica
    ), (
      SELECT count(*) FROM persona_rol_pertenencia_rel_lugar prpl
      LEFT JOIN persona_rol_pertenencia prp on prp.id_persona_rol_pertenencia = prpl.fk_persona_rol_pertenencia_id
      LEFT JOIN pertenencia p on p.id_pertenencia = prp.fk_pertenencia_id
      LEFT JOIN lugar l on l.id_lugar = prpl.fk_lugar_id
      WHERE p.fk_documento_id = doc.id_documento
      AND prp.fk_persona_historica_id = _ph.id_persona_historica
      AND prp.fk_pertenencia_id != pert.id_pertenencia
    )
  ])`;
  const filter = getFilterQuery(req.body.filter, req.body.join, req.body.value_join);
  const viz = req.body.viz;
  const query = `
    SELECT DISTINCT ${viz.length > 0 ? viz : '*'}, 
      doc_id, pert_id,
      confidencial_img,
      ${geomKeys('l_inicio')},
      ${geomKeys('l_prp')},
      count(*) OVER() AS full_count 
    FROM (
      SELECT
        doc.titulo as doc_titulo,
        doc.confidencial_img as confidencial_img,
        doc.id_documento as doc_id,
        _ph.id_persona_historica as ph_id,
        _prp.id_persona_rol_pertenencia as prp_id,
        _prp.edad_recodificada as prp_edad_recodificada,
        pert.fecha_inicio as pert_fecha_inicio,
        COALESCE(pert.fecha_fin, pert.fecha_inicio) as pert_fecha_fin,
        pert.id_pertenencia as pert_id,
        pl.fk_lugar_id as doc_lugar_inicio_id,
        l_inicio.nombre as doc_lugar_nombre,

        ${geomSelect('l_inicio')},

        _ph.nombre as ph_nombre,
        _ph.genero as ph_genero,
        _prp.descripcion as prp_descripcion,
        ARRAY[_prp.edad_min, _prp.edad_max] as prp_edad,

        doc.signatura as doc_signatura,
        s.nombre as doc_seccion,
        s.fk_coleccion as doc_coleccion,
        ARRAY(SELECT fk_keyword_palabra FROM keyword_rel_documento kw WHERE kw.fk_documento_id = doc.id_documento)
          as doc_keyword,

        l_prp.nombre as prp_origen,
        l_prp.id_lugar as prp_origen_id,
        ${geomSelect('l_prp')},

        ${relationsQuery} as prp_relaciones,
        ARRAY(SELECT fk_rol_nombre FROM persona_rol_pertenencia_rel_rol prpr WHERE prpr.fk_persona_rol_pertenencia = _prp.id_persona_rol_pertenencia)
          as prp_rol,
        ARRAY(SELECT fk_ocupacion_nombre FROM persona_rol_pertenencia_rel_ocupacion prpo WHERE prpo.fk_persona_rol_pertenencia_id = _prp.id_persona_rol_pertenencia)
          as prp_oficio,
        ARRAY(SELECT fk_cargo_nombre FROM persona_rol_pertenencia_rel_cargo prpc WHERE prpc.fk_persona_rol_pertenencia_id = _prp.id_persona_rol_pertenencia)
          as prp_cargo,
        ARRAY(SELECT fk_institucion_nombre FROM persona_rol_pertenencia_rel_institucion prpi WHERE prpi.fk_persona_rol_pertenencia_id = _prp.id_persona_rol_pertenencia)
          as prp_institucion
      FROM documento doc
      LEFT JOIN seccion s ON doc.fk_seccion_id = s.id_seccion
      JOIN pertenencia p_emision ON doc.id_documento = p_emision.fk_documento_id AND p_emision.tipo_atr_doc = 'Emisión'
      LEFT JOIN pertenencia_rel_lugar pl ON pl.fk_pertenencia_id = p_emision.id_pertenencia
      LEFT JOIN lugar l_inicio ON pl.fk_lugar_id = l_inicio.id_lugar
      ${geomJoins('l_inicio')}
      JOIN pertenencia pert ON doc.id_documento = pert.fk_documento_id
      JOIN persona_rol_pertenencia _prp ON pert.id_pertenencia = _prp.fk_pertenencia_id
      LEFT JOIN persona_rol_pertenencia_rel_lugar prpl ON prpl.fk_persona_rol_pertenencia_id = _prp.id_persona_rol_pertenencia
      LEFT JOIN lugar l_prp ON prpl.fk_lugar_id = l_prp.id_lugar
      ${geomJoins('l_prp')}
      JOIN persona_historica _ph ON _prp.fk_persona_historica_id = _ph.id_persona_historica
      WHERE TRUE ${secretQuery}
    ) as data
    WHERE TRUE ${filter.sql} ${sortQuery} ${pagingQuery}
  `;
  makeResponse({
    res, filter, query,
    fileReads: [{
      filepath: '/uploads/documento',
      idKey: 'doc_id'
    }],
    removeConfidencialImg: !req.user
  });
});

router.post('/historic/object', validateSearchBody, parseJWT, (req, res) => {
  // const { access_history } = (req.user || {});
  const secretQuery = req.user ? '' : 'AND COALESCE(d.confidencial_datos, FALSE) = FALSE ';
  const {sortQuery, pagingQuery} = getSortAndPaging(req.body);
  const personQuery = selectFields => `
    SELECT ${selectFields} FROM persona_rol_pertenencia_rel_linea prpl
    LEFT JOIN persona_rol_pertenencia prp on prp.id_persona_rol_pertenencia = prpl.fk_persona_rol_pertenencia_id
    LEFT JOIN pertenencia p on p.id_pertenencia = prp.fk_pertenencia_id
    LEFT JOIN persona_historica ph on ph.id_persona_historica = prp.fk_persona_historica_id
    WHERE p.fk_documento_id = d.id_documento
    AND prpl.fk_linea = l.id_linea
  `;
  const relationsQuery = `(SELECT ARRAY[
    (${personQuery('count(*)')}),
    0,
    (
      SELECT count(*) FROM linea_rel_lugar lrl
      LEFT JOIN lugar lg on lg.id_lugar = lrl.fk_lugar_id
      WHERE lrl.fk_linea_id = l.id_linea
    )
  ])`;

  const filter = getFilterQuery(req.body.filter, req.body.join, req.body.value_join);
  const viz = req.body.viz;
  const query = `
    SELECT DISTINCT ${viz.length > 0 ? viz : '*'}, 
      doc_id, 
      id_linea,
      confidencial_img,
      ${geomKeys('l_inicio')},
      ${geomKeys('lg')},
      count(*) OVER() AS full_count
    FROM (
      SELECT 
        d.titulo as doc_titulo,
        d.confidencial_img as confidencial_img,
        d.id_documento as doc_id,
        o.id_objeto,
        l.id_linea,
        COALESCE(p.fecha_inicio, p_emision.fecha_inicio) as pert_fecha_inicio,
        COALESCE(p.fecha_fin, p_emision.fecha_fin, p.fecha_inicio, p_emision.fecha_inicio) as pert_fecha_fin,
        pl.fk_lugar_id as doc_lugar_inicio_id,
        l_inicio.nombre as doc_lugar_nombre,

        ${geomSelect('l_inicio')},

        o.nombre as objeto_nombre,
        l.descripcion as linea_descripcion,
        l.cantidad as linea_cantidad,
        l.calidad as linea_calidad,
        l.estado as linea_estado,
        l.color as linea_color,

        lg.nombre as linea_origen,
        lg.id_lugar as linea_origen_id,
        ${geomSelect('lg')},

        d.signatura as doc_signatura,
        s.nombre as doc_seccion,
        s.fk_coleccion as doc_coleccion,

        (SELECT nombre FROM material WHERE id_material = l.fk_material_id) as material_nombre,
        ARRAY(SELECT fk_keyword_palabra FROM keyword_rel_documento kw WHERE kw.fk_documento_id = d.id_documento)
          as doc_keyword,

        ARRAY(${personQuery('ph.nombre')}) as ph_nombres,
        ARRAY(${personQuery('ph.id_persona_historica')}) as ph_ids,
        ${relationsQuery} as linea_relaciones,
        ARRAY(SELECT lru.valor || ' ' || u.nombre as valor_nombre FROM linea_rel_unidad lru JOIN unidad u ON lru.fk_unidad_nombre = u.nombre 
          WHERE lru.fk_linea_id = l.id_linea AND u.tipo = 'Peso')
          as linea_unidad_pesos,
        ARRAY(SELECT lru.valor || ' ' || u.nombre as valor_nombre FROM linea_rel_unidad lru JOIN unidad u ON lru.fk_unidad_nombre = u.nombre 
          WHERE lru.fk_linea_id = l.id_linea AND u.tipo = 'Medida')
          as linea_unidad_medidas,
        ARRAY(SELECT lru.valor || ' ' || u.nombre as valor_nombre FROM linea_rel_unidad lru JOIN unidad u ON lru.fk_unidad_nombre = u.nombre 
          WHERE lru.fk_linea_id = l.id_linea AND u.tipo = 'Moneda')
          as linea_unidad_precios

      FROM documento d
      INNER JOIN pertenencia p ON d.id_documento = p.fk_documento_id
      LEFT JOIN seccion s ON d.fk_seccion_id = s.id_seccion
      INNER JOIN pertenencia p_emision ON d.id_documento = p_emision.fk_documento_id AND p_emision.tipo_atr_doc = 'Emisión'
      LEFT JOIN pertenencia_rel_lugar pl ON pl.fk_pertenencia_id = p_emision.id_pertenencia
      LEFT JOIN lugar l_inicio ON pl.fk_lugar_id = l_inicio.id_lugar
      ${geomJoins('l_inicio')}
      INNER JOIN pertenencia_rel_agrupacion_bienes pab on pab.fk_pertenencia_id = p.id_pertenencia
      INNER JOIN agrupacion_bienes ab on ab.id_agrupacion_bienes = pab.fk_agrupacion_bienes_id
      INNER JOIN linea l on l.fk_agrupacion_bienes_id = ab.id_agrupacion_bienes
      LEFT JOIN lugar lg ON lg.id_lugar = l.fk_lugar_id
      ${geomJoins('lg')}
      INNER JOIN objeto o on o.id_objeto = l.fk_objeto_id
      WHERE TRUE ${secretQuery}
    ) as data
    WHERE TRUE ${filter.sql} ${sortQuery} ${pagingQuery}
  `;
  makeResponse({
    res, filter, query,
    fileReads: [{
      filepath: '/uploads/documento',
      idKey: 'doc_id'
    }],
    removeConfidencialImg: !req.user
  });
});

router.post('/archeo/person', validateSearchBody, parseJWT, (req, res) => {
  // const { access_archeology } = (req.user || {});
  const secretQuery = req.user ? '' : 'AND COALESCE(ia.confidencial, FALSE) = FALSE ';
  const {sortQuery, pagingQuery} = getSortAndPaging(req.body);  
  const filter = getFilterQuery(req.body.filter, req.body.join, req.body.value_join);
  const viz = req.body.viz;
  const query = `
    SELECT DISTINCT ${viz.length > 0 ? viz : '*'},
      exca_id, exca_geom, ia_id, ia_ue,
      regexp_replace(ia_ue, '\\d+', '') as ia_ue_only_text,
      substring(ia_ue, '\\d+')::int as ia_ue_only_numbers,
      count(*) OVER() AS full_count
    FROM (
      SELECT
        exca.id_entierro as exca_id,
        exca.nomenclatura_sitio as exca_sitio,
        exca.lugar as exca_lugar,
        st_astext(exca.place_geometry) as exca_geom,
        ia.id_individuo_arqueologico as ia_id,
        ia.estatura as ia_estatura,
        ia.unid_estratigrafica as ia_ue,
        ia.tipo = 'enterramiento' as ia_tipo,
        ia.sexo as ia_sexo,
        ia.filiacion_poblacional as ia_poblacion,
        ia.posicion_cuerpo as ia_pos_cuerpo,
        ir.id_individuo_resto as resto_id,
        ir.fk_resto_variable as resto_variable,
        ir.fk_especie_nombre as resto_especie_id,
        (SELECT nombre || ' / ' || english FROM especie WHERE nombre = ir.fk_especie_nombre) 
          as resto_especie,
        ARRAY(SELECT fk_lote_edades FROM lote_edades_rel_individuo_arqueologico WHERE fk_individuo_arqueologico = ia.id_individuo_arqueologico)
          as ia_edades,
        (COALESCE(rc.calibrated_date_2s_start, NULLIF(ia.periodo_inicio, '')::integer, 1970) || '-01-01')::date
          as ia_fecha_inicio,
        (COALESCE(rc.calibrated_date_2s_end, NULLIF(ia.periodo_fin, '')::integer, 1970) || '-01-01')::date
          as ia_fecha_fin,
        ARRAY(SELECT a.id_anomalia::varchar FROM anomalia a JOIN anomalia_rel_individuo_resto ar ON ar.fk_anomalia_id = a.id_anomalia WHERE ar.fk_individuo_resto_id = ir.id_individuo_resto)
          as resto_anomalia_ids,
        ARRAY(SELECT a.nombre FROM anomalia a JOIN anomalia_rel_individuo_resto ar ON ar.fk_anomalia_id = a.id_anomalia WHERE ar.fk_individuo_resto_id = ir.id_individuo_resto)
          as resto_anomalias,
        (SELECT (r.traduccion || ' - ' || cri.fk_categoria_resto_nombre) as nombre FROM resto r 
          JOIN resto_rel_categoria_resto_indice rrcri ON rrcri.fk_resto_variable = r.variable
          JOIN categoria_resto_indice cri ON cri.id_categoria_resto_indice = rrcri.fk_categoria_resto_indice_id    
          WHERE r.variable = ir.fk_resto_variable)
          as resto_nombre,
        ARRAY(SELECT l.cantidad || ' ' || oa.nombre 
          FROM individuo_arqueologico_rel_linea iarl
          JOIN linea l on l.id_linea = iarl.fk_linea
          JOIN objeto_arqueologico_rel_linea oarl ON oarl.fk_linea = l.id_linea
          JOIN objeto_arqueologico oa ON oa.id_objeto = oarl.fk_objeto_arqueologico
          WHERE iarl.fk_individuo_arqueologico = ia.id_individuo_arqueologico)
          as ia_objetos_ajuar,
        (SELECT valor FROM estado_rel_individuo_arqueologico WHERE fk_individuo_arqueologico_id = ia.id_individuo_arqueologico 
          AND fk_estado_tipo_cons_repre = 'Conservación' AND fk_estado_elemento = 'Cráneo')
          as ia_cons_craneo
        
      FROM entierro exca
      JOIN individuo_arqueologico ia ON ia.fk_entierro = exca.id_entierro
      LEFT JOIN individuo_resto ir ON ir.fk_individuo_arqueologico_id = ia.id_individuo_arqueologico
      LEFT JOIN radiocarbon_dating rc ON ia.fk_radiocarbon_dating_id = rc.id_radiocarbon_dating
      WHERE TRUE ${secretQuery}
    ) as data
    WHERE TRUE ${filter.sql} ${sortQuery} ${pagingQuery}
  `;
  makeResponse({
    res, filter, query,
    fileReads: [
      {
        filepath: '/uploads/individuo_arqueologico',
        idKey: 'ia_id',
        fileKey: 'files_ue'
      },
      {
        filepath: '/uploads/resto',
        idKey: 'resto_id',
        fileKey: 'files_resto'
      }
    ]
  });
});

router.post('/archeo/object', validateSearchBody, parseJWT, (req, res) => {
  // const { access_archeology } = (req.user || {});
  const secretQuery = req.user ? '' : 'AND COALESCE(ia.confidencial, FALSE) = FALSE ';
  const {sortQuery, pagingQuery} = getSortAndPaging(req.body);
  const filter = getFilterQuery(req.body.filter, req.body.join, req.body.value_join);
  const viz = req.body.viz;
  const query = `
    SELECT DISTINCT ${viz.length > 0 ? viz : '*'}, 
      exca_id, exca_geom, ia_id, ia_ue, ${geomKeys('lg')},
      regexp_replace(ia_ue, '\\d+', '') as ia_ue_only_text,
      substring(ia_ue, '\\d+')::int as ia_ue_only_numbers,
      count(*) OVER() AS full_count 
    FROM (
      SELECT
        exca.id_entierro as exca_id,
        exca.nomenclatura_sitio as exca_sitio,
        exca.lugar as exca_lugar,
        st_astext(exca.place_geometry) as exca_geom,
        ia.id_individuo_arqueologico as ia_id,
        ia.tipo = 'enterramiento' as ia_tipo,
        ia.unid_estratigrafica as ia_ue,
        (COALESCE(rc.calibrated_date_2s_start, NULLIF(ia.periodo_inicio, '')::integer, 1970) || '-01-01')::date
          as ia_fecha_inicio,
        (COALESCE(rc.calibrated_date_2s_end, NULLIF(ia.periodo_fin, '')::integer, 1970) || '-01-01')::date
          as ia_fecha_fin,

        iarl.origen as linea_origen,
        iarl.tipo as oa_tipo,
        oa.nombre as objeto_nombre,
        oa.id_objeto,
        l.id_linea,
        l.descripcion as linea_descripcion,
        l.cantidad as linea_cantidad,
        l.calidad as linea_calidad,
        l.estado as linea_estado,
        l.color as linea_color,
        ${geomSelect('lg')},
        (SELECT nombre FROM material WHERE id_material = l.fk_material_id) as material_nombre,

        ARRAY(SELECT lru.valor || ' ' || u.nombre as valor_nombre FROM linea_rel_unidad lru JOIN unidad u ON lru.fk_unidad_nombre = u.nombre 
          WHERE lru.fk_linea_id = l.id_linea AND u.tipo = 'Peso')
          as linea_unidad_pesos,
        ARRAY(SELECT lru.valor || ' ' || u.nombre as valor_nombre FROM linea_rel_unidad lru JOIN unidad u ON lru.fk_unidad_nombre = u.nombre 
          WHERE lru.fk_linea_id = l.id_linea AND u.tipo = 'Medida')
          as linea_unidad_medidas,
        ARRAY(SELECT lru.valor || ' ' || u.nombre as valor_nombre FROM linea_rel_unidad lru JOIN unidad u ON lru.fk_unidad_nombre = u.nombre 
          WHERE lru.fk_linea_id = l.id_linea AND u.tipo = 'Moneda')
          as linea_unidad_precios

      FROM entierro exca
      JOIN individuo_arqueologico ia ON ia.fk_entierro = exca.id_entierro
      LEFT JOIN radiocarbon_dating rc ON ia.fk_radiocarbon_dating_id = rc.id_radiocarbon_dating
      JOIN individuo_arqueologico_rel_linea iarl ON iarl.fk_individuo_arqueologico = ia.id_individuo_arqueologico
      JOIN linea l on l.id_linea = iarl.fk_linea
      LEFT JOIN lugar lg ON lg.id_lugar = l.fk_lugar_id
      ${geomJoins('lg')}
      JOIN objeto_arqueologico_rel_linea oarl ON oarl.fk_linea = l.id_linea
      JOIN objeto_arqueologico oa ON oa.id_objeto = oarl.fk_objeto_arqueologico
      WHERE TRUE ${secretQuery}
    ) as data
    WHERE TRUE ${filter.sql} ${sortQuery} ${pagingQuery}
  `;
  makeResponse({
    res, filter, query,
    fileReads: [
      {
        filepath: '/uploads/individuo_arqueologico',
        idKey: 'ia_id'
      }
    ]
  });
});

router.post('/isotopy/person', validateSearchBody, parseJWT, (req, res) => {
  // const { access_archeology } = (req.user || {});
  const secretQuery = req.user ? '' : 'AND COALESCE(ia.confidencial, FALSE) = FALSE ';
  const {sortQuery, pagingQuery} = getSortAndPaging(req.body);  
  const filter = getFilterQuery(req.body.filter, req.body.join, req.body.value_join);
  const viz = req.body.viz;
  const query = `
    SELECT ${viz.length > 0 ? viz : '*'}, exca_id, ia_id, sample_id, count(*) OVER() AS full_count FROM (
      SELECT
        exca.id_entierro as exca_id,
        exca.nomenclatura_sitio as exca_sitio,
        exca.lugar as exca_lugar,
        ia.id_individuo_arqueologico as ia_id,
        ia.unid_estratigrafica as ia_ue,
        ia.tipo as ia_tipo,
        ia.sexo as ia_sexo,
        ia.filiacion_poblacional as ia_poblacion,
        ia.posicion_cuerpo as ia_pos_cuerpo,
        ir.fk_resto_variable as resto_variable,
        ir.fk_especie_nombre as resto_especie_id,
        (SELECT nombre || ' / ' || english FROM especie WHERE nombre = ir.fk_especie_nombre) 
          as resto_especie,
        ARRAY(SELECT fk_lote_edades FROM lote_edades_rel_individuo_arqueologico WHERE fk_individuo_arqueologico = ia.id_individuo_arqueologico)
          as ia_edades,
        (COALESCE(rc.calibrated_date_2s_start, NULLIF(ia.periodo_inicio, '')::integer, 1970) || '-01-01')::date
          as ia_fecha_inicio,
        (COALESCE(rc.calibrated_date_2s_end, NULLIF(ia.periodo_fin, '')::integer, 1970) || '-01-01')::date
          as ia_fecha_fin,
        ARRAY(SELECT a.nombre FROM anomalia a JOIN anomalia_rel_individuo_resto ar ON ar.fk_anomalia_id = a.id_anomalia WHERE ar.fk_individuo_resto_id = ir.id_individuo_resto)
          as resto_anomalias,
        (SELECT (r.traduccion || ' - ' || cri.fk_categoria_resto_nombre) as nombre FROM resto r 
          JOIN resto_rel_categoria_resto_indice rrcri ON rrcri.fk_resto_variable = r.variable
          JOIN categoria_resto_indice cri ON cri.id_categoria_resto_indice = rrcri.fk_categoria_resto_indice_id    
          WHERE r.variable = ir.fk_resto_variable)
          as resto_nombre,

        samp.name as sample_name,
        samp.id_muestra as sample_id,

        biop.sr87_sr86     as biop__sr87_sr86,
        biop.sr87_sr86_2sd as biop__sr87_sr86_2sd,
        biop.s18op         as biop__s18op,
        biop.s18op_1sd     as biop__s18op_1sd,
        biop.s18oc         as biop__s18oc,
        biop.s18oc_1sd     as biop__s18oc_1sd,
        biop.s13cc         as biop__s13cc,
        biop.s13cc_1sd     as biop__s13cc_1sd,
        coll.s13_ccoll     as coll__s13_ccoll,
        coll.s13_ccoll_1sd as coll__s13_ccoll_1sd,
        coll.s15_ncoll     as coll__s15_ncoll,
        coll.s15_ncoll_1sd as coll__s15_ncoll_1sd,
        
        (CASE WHEN rc.id_radiocarbon_dating IS NULL THEN FALSE ELSE TRUE END) as has_radiocarbon
        
      FROM entierro exca
      JOIN individuo_arqueologico ia ON ia.fk_entierro = exca.id_entierro
      JOIN individuo_resto ir ON ir.fk_individuo_arqueologico_id = ia.id_individuo_arqueologico
      JOIN sample samp ON samp.fk_individuo_resto_id = ir.id_individuo_resto AND samp.type = 'isotopy'
      LEFT JOIN radiocarbon_dating rc ON ia.fk_radiocarbon_dating_id = rc.id_radiocarbon_dating
      LEFT JOIN bioapatite biop ON biop.fk_sample_id = samp.id_muestra
      LEFT JOIN collagen coll ON coll.fk_sample_id = samp.id_muestra
      WHERE TRUE ${secretQuery}
    ) as data
    WHERE TRUE ${filter.sql} ${sortQuery} ${pagingQuery}
  `;
  db.query(query, {replacements: filter.params, type: sequelize.QueryTypes.SELECT})
  .then(data => {
    res.status(200).send(data);
  }).catch(error => {
    res.status(500).send({error: error.message});
  });
});

router.post('/adn/person', validateSearchBody, parseJWT, (req, res) => {
  // const { access_archeology } = (req.user || {});
  const secretQuery = req.user ? '' : 'AND COALESCE(ia.confidencial, FALSE) = FALSE ';
  const {sortQuery, pagingQuery} = getSortAndPaging(req.body);  
  const filter = getFilterQuery(req.body.filter, req.body.join, req.body.value_join);
  const viz = req.body.viz;
  const query = `
    SELECT ${viz.length > 0 ? viz : '*'}, exca_id, ia_id, sample_id, count(*) OVER() AS full_count FROM (
      SELECT
        exca.id_entierro as exca_id,
        exca.nomenclatura_sitio as exca_sitio,
        exca.lugar as exca_lugar,
        ia.id_individuo_arqueologico as ia_id,
        ia.unid_estratigrafica as ia_ue,
        ia.tipo as ia_tipo,
        ia.sexo as ia_sexo,
        ia.filiacion_poblacional as ia_poblacion,
        ia.posicion_cuerpo as ia_pos_cuerpo,
        ir.fk_resto_variable as resto_variable,
        ir.fk_especie_nombre as resto_especie_id,
        (SELECT nombre || ' / ' || english FROM especie WHERE nombre = ir.fk_especie_nombre) 
          as resto_especie,
        ARRAY(SELECT fk_lote_edades FROM lote_edades_rel_individuo_arqueologico WHERE fk_individuo_arqueologico = ia.id_individuo_arqueologico)
          as ia_edades,
        (COALESCE(rc.calibrated_date_2s_start, NULLIF(ia.periodo_inicio, '')::integer, 1970) || '-01-01')::date
          as ia_fecha_inicio,
        (COALESCE(rc.calibrated_date_2s_end, NULLIF(ia.periodo_fin, '')::integer, 1970) || '-01-01')::date
          as ia_fecha_fin,
        ARRAY(SELECT a.nombre FROM anomalia a JOIN anomalia_rel_individuo_resto ar ON ar.fk_anomalia_id = a.id_anomalia WHERE ar.fk_individuo_resto_id = ir.id_individuo_resto)
          as resto_anomalias,
        (SELECT (r.traduccion || ' - ' || cri.fk_categoria_resto_nombre) as nombre FROM resto r 
          JOIN resto_rel_categoria_resto_indice rrcri ON rrcri.fk_resto_variable = r.variable
          JOIN categoria_resto_indice cri ON cri.id_categoria_resto_indice = rrcri.fk_categoria_resto_indice_id    
          WHERE r.variable = ir.fk_resto_variable)
          as resto_nombre,

        samp.name as sample_name,
        samp.id_muestra as sample_id,
        samp.successful as sample_successful,

        (SELECT count(*) FROM mtdna mt WHERE mt.fk_sample_id = samp.id_muestra) 
          as adn_mtdna_count,
        (SELECT count(*) FROM ychromosome _yc WHERE _yc.fk_sample_id = samp.id_muestra) 
          as adn_ychromosome_count,
        (SELECT count(*) FROM wholegenome _wg WHERE _wg.fk_sample_id = samp.id_muestra) 
          as adn_wholegenome_count,

        dna.successful as dna__successful,
        dna.superhaplo as dna__superhaplo,
        dna.haplogroup as dna__haplogroup,
        dna.alter_haplo as dna__alter_haplo,
        dna.haplo_ancest_origin as dna__haplo_ancest_origin,
        dna.possible_mat_relat as dna__possible_mat_relat,

        yc.successful as yc__successful,
        yc.superhaplo as yc__superhaplo,
        yc.haplogroup as yc__haplogroup,
        yc.haplo_ancest_origin as yc__haplo_ancest_origin,
        yc.possible_pat_relat as yc__possible_pat_relat,
        yc.whole_coverage as yc__whole_coverage,
        
        wg.successful as wg__successful,
        wg.whole_coverage as wg__whole_coverage,
        wg.closes_pop as wg__closes_pop,
        wg.ancest_origin as wg__ancest_origin,
        wg.mean_read_depth as wg__mean_read_depth,
        wg.molecular_sex as wg__molecular_sex
 
      FROM entierro exca
      JOIN individuo_arqueologico ia ON ia.fk_entierro = exca.id_entierro
      JOIN individuo_resto ir ON ir.fk_individuo_arqueologico_id = ia.id_individuo_arqueologico
      JOIN sample samp ON samp.fk_individuo_resto_id = ir.id_individuo_resto AND samp.type = 'adn'
      LEFT JOIN mtdna dna ON dna.fk_sample_id = samp.id_muestra
      LEFT JOIN ychromosome yc ON yc.fk_sample_id = samp.id_muestra
      LEFT JOIN wholegenome wg ON wg.fk_sample_id = samp.id_muestra

      LEFT JOIN radiocarbon_dating rc ON ia.fk_radiocarbon_dating_id = rc.id_radiocarbon_dating
      WHERE TRUE ${secretQuery}
    ) as data
    WHERE TRUE ${filter.sql} ${sortQuery} ${pagingQuery}
  `;

  db.query(query, {replacements: filter.params, type: sequelize.QueryTypes.SELECT})
  .then(data => {
    res.status(200).send(data);
  }).catch(error => {
    res.status(500).send({error: error.message});
  });
});

router.post('/triple/person', validateSearchBody, parseJWT, (req, res) => {
  const {sortQuery, pagingQuery} = getSortAndPaging(req.body);  
  const secretQuery = req.user ? '' : 'AND COALESCE(samp.confidencial, FALSE) = FALSE';
  const filter = getFilterQuery(req.body.filter, req.body.join, req.body.value_join);
  const viz = req.body.viz;
  const query = `
    SELECT DISTINCT ${viz.length > 0 ? viz : '*'}, 
      exca_id, ia_id, ia_ue, resto_id, sample_id, sample_type,
      regexp_replace(ia_ue, '\\d+', '') as ia_ue_only_text,
      substring(ia_ue, '\\d+')::int as ia_ue_only_numbers,
      count(*) OVER() AS full_count
    FROM (
      SELECT
        exca.id_entierro as exca_id,
        exca.nomenclatura_sitio as exca_sitio,
        exca.lugar as exca_lugar,
        ia.id_individuo_arqueologico as ia_id,
        ia.unid_estratigrafica as ia_ue,
        ia.tipo as ia_tipo,
        ia.sexo as ia_sexo,
        ia.filiacion_poblacional as ia_poblacion,
        ia.posicion_cuerpo as ia_pos_cuerpo,
        ir.id_individuo_resto as resto_id,
        ir.fk_resto_variable as resto_variable,
        ir.fk_especie_nombre as resto_especie_id,
        (SELECT nombre || ' / ' || english FROM especie WHERE nombre = ir.fk_especie_nombre) 
          as resto_especie,
        ARRAY(SELECT fk_lote_edades FROM lote_edades_rel_individuo_arqueologico WHERE fk_individuo_arqueologico = ia.id_individuo_arqueologico)
          as ia_edades,
        (COALESCE(rc.calibrated_date_2s_start, NULLIF(ia.periodo_inicio, '')::integer, 1970) || '-01-01')::date
          as ia_fecha_inicio,
        (COALESCE(rc.calibrated_date_2s_end, NULLIF(ia.periodo_fin, '')::integer, 1970) || '-01-01')::date
          as ia_fecha_fin,
        ARRAY(SELECT a.id_anomalia::varchar FROM anomalia a JOIN anomalia_rel_individuo_resto ar ON ar.fk_anomalia_id = a.id_anomalia WHERE ar.fk_individuo_resto_id = ir.id_individuo_resto)
          as resto_anomalia_ids,
        ARRAY(SELECT a.nombre FROM anomalia a JOIN anomalia_rel_individuo_resto ar ON ar.fk_anomalia_id = a.id_anomalia WHERE ar.fk_individuo_resto_id = ir.id_individuo_resto)
          as resto_anomalias,
        (SELECT (r.traduccion || ' - ' || cri.fk_categoria_resto_nombre) as nombre FROM resto r 
          JOIN resto_rel_categoria_resto_indice rrcri ON rrcri.fk_resto_variable = r.variable
          JOIN categoria_resto_indice cri ON cri.id_categoria_resto_indice = rrcri.fk_categoria_resto_indice_id    
          WHERE r.variable = ir.fk_resto_variable)
          as resto_nombre,
        ARRAY(SELECT l.cantidad || ' ' || oa.nombre 
          FROM individuo_arqueologico_rel_linea iarl
          JOIN linea l on l.id_linea = iarl.fk_linea
          JOIN objeto_arqueologico_rel_linea oarl ON oarl.fk_linea = l.id_linea
          JOIN objeto_arqueologico oa ON oa.id_objeto = oarl.fk_objeto_arqueologico
          WHERE iarl.fk_individuo_arqueologico = ia.id_individuo_arqueologico)
          as ia_objetos_ajuar,
        (SELECT valor FROM estado_rel_individuo_arqueologico WHERE fk_individuo_arqueologico_id = ia.id_individuo_arqueologico 
          AND fk_estado_tipo_cons_repre = 'Conservación' AND fk_estado_elemento = 'Cráneo')
          as ia_cons_craneo,
        
        (CASE WHEN rc.c_age_bp IS NULL THEN FALSE ELSE TRUE END) as has_radiocarbon,        

        samp.name as sample_name,
        samp.id_muestra as sample_id,
        samp.type as sample_type,
        samp.successful as sample_successful,

        biop.sr87_sr86     as biop__sr87_sr86,
        biop.sr87_sr86_2sd as biop__sr87_sr86_2sd,
        biop.s18op         as biop__s18op,
        biop.s18op_1sd     as biop__s18op_1sd,
        biop.s18oc         as biop__s18oc,
        biop.s18oc_1sd     as biop__s18oc_1sd,
        biop.s13cc         as biop__s13cc,
        biop.s13cc_1sd     as biop__s13cc_1sd,

        coll.s13_ccoll     as coll__s13_ccoll,
        coll.s13_ccoll_1sd as coll__s13_ccoll_1sd,
        coll.s15_ncoll     as coll__s15_ncoll,
        coll.s15_ncoll_1sd as coll__s15_ncoll_1sd,
        coll.quality_criteria as coll__quality_criteria,

        (SELECT count(*) FROM mtdna mt WHERE mt.fk_sample_id = samp.id_muestra) 
          as adn_mtdna_count,
        (SELECT count(*) FROM ychromosome _yc WHERE _yc.fk_sample_id = samp.id_muestra) 
          as adn_ychromosome_count,
        (SELECT count(*) FROM wholegenome _wg WHERE _wg.fk_sample_id = samp.id_muestra) 
          as adn_wholegenome_count,

        dna.successful as dna__successful,
        dna.superhaplo as dna__superhaplo,
        dna.haplogroup as dna__haplogroup,
        dna.alter_haplo as dna__alter_haplo,
        dna.haplo_ancest_origin as dna__haplo_ancest_origin,
        dna.possible_mat_relat as dna__possible_mat_relat,

        yc.successful as yc__successful,
        yc.superhaplo as yc__superhaplo,
        yc.haplogroup as yc__haplogroup,
        yc.haplo_ancest_origin as yc__haplo_ancest_origin,
        yc.possible_pat_relat as yc__possible_pat_relat,
        yc.whole_coverage as yc__whole_coverage,
        
        wg.successful as wg__successful,
        wg.whole_coverage as wg__whole_coverage,
        wg.closes_pop as wg__closes_pop,
        wg.ancest_origin as wg__ancest_origin,
        wg.mean_read_depth as wg__mean_read_depth,
        wg.molecular_sex as wg__molecular_sex
 
      FROM entierro exca
      JOIN individuo_arqueologico ia ON ia.fk_entierro = exca.id_entierro
      JOIN individuo_resto ir ON ir.fk_individuo_arqueologico_id = ia.id_individuo_arqueologico
      JOIN sample samp ON samp.fk_individuo_resto_id = ir.id_individuo_resto
      
      LEFT JOIN mtdna dna ON dna.fk_sample_id = samp.id_muestra
      LEFT JOIN ychromosome yc ON yc.fk_sample_id = samp.id_muestra
      LEFT JOIN wholegenome wg ON wg.fk_sample_id = samp.id_muestra

      LEFT JOIN bioapatite biop ON biop.fk_sample_id = samp.id_muestra
      LEFT JOIN collagen coll ON coll.fk_sample_id = samp.id_muestra

      LEFT JOIN radiocarbon_dating rc ON ia.fk_radiocarbon_dating_id = rc.id_radiocarbon_dating
      WHERE TRUE ${secretQuery} 
    ) as data
    WHERE TRUE ${filter.sql} ${sortQuery} ${pagingQuery}
  `;
  makeResponse({
    res, filter, query,
    fileReads: [
      {
        filepath: '/uploads/individuo_arqueologico',
        idKey: 'ia_id',
        fileKey: 'files_ue'
      },
      {
        filepath: '/uploads/resto',
        idKey: 'resto_id',
        fileKey: 'files_resto'
      }
    ]
  });
})

module.exports = router;
