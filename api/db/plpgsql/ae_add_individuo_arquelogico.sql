-- REPASAR LA RELACIÓN CON INDIVIDUO_RESTO (INCOMPLETO)
-- REPASAR LA RELACIÓN CON LINEA (INCOMPLETO)
DROP FUNCTION IF EXISTS ae_add_individuo_arquelogico(
  numeric,
  numeric,
  text,
  text,
  text,
  text,
  numeric,
  numeric,
  numeric,
  text,
  text,
  text,
  text,
  date,
  date,
  numeric,
  text,
  text,
  numeric,
  text,
  text,
  text,
  text,
  text,
  text,
  text,
  numeric,
  text,

  json[],
  json[],
  json[],
  json[]
);

CREATE OR REPLACE FUNCTION ae_add_individuo_arquelogico (
  fk_entierro numeric,
  id_individuo_arqueologico numeric,

  unid_estratigrafica text,
  unid_estratigrafica_asociada text,
  
	estructura text,
  forma text,

  largo numeric,
  ancho numeric,
  profundidad numeric,

  tipo_enterramiento text,
  clase_enterramiento text,

  contenedor text,
  descomposicion text,

  periodo_inicio text,
  periodo_fin text,

  estatura numeric,
  catalogo text,
  sexo text,
  edad text,

  posicion_cuerpo text,
  pos_extremidades_sup text,
  pos_extremidades_inf text,

  orientacion_cuerpo text,
  orientacion_creaneo text,
	
  filiacion_poblacional text,
  observaciones text,
  nmi_total numeric,
	tipo text,
	confidencial boolean,
  
	edades json[],
  estados json[],
  restos json[],
  lineas json[]
)


RETURNS numeric AS
$BODY$
DECLARE
	_r record;
	_q text;
	_edad json;
	_estado json;
	_resto json;
  _linea json;
BEGIN
	
	-- Individuo arqueologico
	-- tipo podra tomar los valores "enterramiento" o "noent" e indicara si el indiv. arquelogico es de tipo enterramiento o no
	IF id_individuo_arqueologico is NULL 
	THEN
		_q := format('INSERT INTO individuo_arqueologico (
		    catalogo, sexo, edad, filiacion_poblacional, 
		    estatura, periodo_inicio, periodo_fin, unid_estratigrafica, unid_estratigrafica_asociada, 
		    tipo, clase_enterramiento, descomposicion, contenedor, pos_extremidades_inf, 
		    pos_extremidades_sup, posicion_cuerpo, orientacion_cuerpo, orientacion_creaneo, 
		    tipo_enterramiento, fk_entierro, observaciones, 
		    estructura, forma, largo, ancho, profundidad, nmi_total, confidencial
			) VALUES (
				%L, %L, %L, %L, %s, %L, %L, %L, %L, %L, %L, 
				%L, %L, %L, %L, %L, %L, %L, %L, %s, %L, %L, %L, %s, %s, %s, %s, %L
			) RETURNING id_individuo_arqueologico', catalogo, sexo, edad, filiacion_poblacional, 
			    estatura, periodo_inicio, periodo_fin, unid_estratigrafica, unid_estratigrafica_asociada, 
			    tipo, clase_enterramiento, descomposicion, contenedor, pos_extremidades_inf, 
			    pos_extremidades_sup, posicion_cuerpo, orientacion_cuerpo, orientacion_creaneo, 
			    tipo_enterramiento, fk_entierro, observaciones, 
			    estructura, forma, largo, ancho, profundidad, nmi_total, confidencial);

	ELSE
		_q := format('UPDATE individuo_arqueologico 
			SET catalogo=%L, sexo=%L, edad=%L, filiacion_poblacional=%L, 
			    estatura=%s, periodo_inicio=%L, periodo_fin=%L, unid_estratigrafica=%L, 
			    unid_estratigrafica_asociada=%L, tipo=%L, clase_enterramiento=%L, 
			    descomposicion=%L, contenedor=%L, pos_extremidades_inf=%L, pos_extremidades_sup=%L, 
			    posicion_cuerpo=%L, orientacion_cuerpo=%L, orientacion_creaneo=%L, 
			    tipo_enterramiento=%L, fk_entierro=%s, 
			    observaciones=%L, estructura=%L, forma=%L, largo=%s, ancho=%s, profundidad=%s, 
			    nmi_total=%s, confidencial=%L
			WHERE id_individuo_arqueologico=%s RETURNING id_individuo_arqueologico', catalogo, sexo, edad, filiacion_poblacional, 
			    estatura, periodo_inicio, periodo_fin, unid_estratigrafica, unid_estratigrafica_asociada, 
			    tipo, clase_enterramiento, descomposicion, contenedor, pos_extremidades_inf, 
			    pos_extremidades_sup, posicion_cuerpo, orientacion_cuerpo, orientacion_creaneo, 
			    tipo_enterramiento, fk_entierro, observaciones, 
			    estructura, forma, largo, ancho, profundidad, nmi_total, confidencial, id_individuo_arqueologico);

	END IF;
	EXECUTE _q INTO _r;

	RAISE NOTICE '%', _q;
	IF _r.id_individuo_arqueologico IS NOT NULL
	THEN
	    id_individuo_arqueologico = _r.id_individuo_arqueologico;
	END IF;
	  
	-- Creo los estados
	-- estados sera un array de json y cada elemento contendrá tres propiedades: tipo, valor y elemento. Con esto debera guardarse la relacion del individuo arquelogico con la tabla estado.
	_q := format('DELETE FROM estado_rel_individuo_arqueologico WHERE fk_individuo_arqueologico_id=%s RETURNING *', id_individuo_arqueologico);
	EXECUTE _q INTO _r;
	
	FOREACH _estado IN ARRAY estados
	LOOP	
		_q := format('INSERT INTO estado_rel_individuo_arqueologico (fk_estado_tipo_cons_repre, fk_estado_elemento, fk_individuo_arqueologico_id, valor)
		VALUES (%L, %L, %s, %L) RETURNING *', _estado->>'tipo_cons_represen',_estado->>'elemento',id_individuo_arqueologico, _estado->>'valor');
		EXECUTE _q INTO _r;
	END LOOP;

	-- Creo las edades
	-- edades sera un array de json y cada elemento contendrá dos propiedades: edad recodificada y cantidad. Con esto debera guardarse la relacion del individuo arquelogico con la tabla lote_edades.
	_q := format('DELETE FROM lote_edades_rel_individuo_arqueologico WHERE fk_individuo_arqueologico=%s RETURNING *', id_individuo_arqueologico);
	EXECUTE _q INTO _r;

	FOREACH _edad IN ARRAY edades
	LOOP
		_q := format('INSERT INTO lote_edades_rel_individuo_arqueologico (fk_lote_edades, cantidad, fk_individuo_arqueologico)
		VALUES (%L, %s, %s) RETURNING *', _edad->>'id_edad_recodificada',_edad->>'cantidad',id_individuo_arqueologico);
		EXECUTE _q INTO _r;
	END LOOP;

	/*
	-- REPASAR LA RELACIÓN CON INDIVIDUO_RESTO (INCOMPLETO)
	-- Creo los restos
	-- restos sera un array de json y cada elemento contendrá las propiedades necesarias para guardar los restos con el procedimiento almacenado creado para guardar restos
	_q := format('DELETE FROM individuo_resto WHERE fk_individuo_arqueologico=%s RETURNING *', id_individuo_arqueologico);
	EXECUTE _q INTO _r;

	FOREACH _resto IN ARRAY restos
	LOOP
		PERFORM ae_add_individuo_resto(NULL,_resto->>'fk_resto_variable',_resto->>'fk_especie_nombre',id_individuo_arqueologico,_resto->>'numero',_resto->>'anomalias');
	END LOOP;
	*/
	
	/*
	-- REPASAR LA RELACIÓN CON LINEA (INCOMPLETO)
	-- Creo las lineas
	-- lineas sera un array de json y cada elemento contendrá las propiedades necesarias para guardar los objetos arqueologicos y las lineas relacionadas con el individuo arquelogico usando el procedimiento almacenado creado para ello
	
	_q := format('DELETE FROM individuo_arqueologico_rel_linea WHERE fk_individuo_arqueologico=%s AND fk_linea=%s RETURNING *',_linea->>'id_linea', _linea->>'id_individuo_arqueologico');
	EXECUTE _q INTO _r;
	FOREACH _linea IN ARRAY lineas
	LOOP
		public.ae_add_individuo_resto(numeric, text, text, numeric, numeric, json[])
		_q := format('INSERT INTO individuo_arqueologico_rel_linea(
		fk_individuo_arqueologico, fk_linea, origen, tipo)
		VALUES (%s, %s, %L, %L) RETURNING *', _linea->>'id_individuo_arqueologico', _linea->>'id_linea', _linea->>'origen', _linea->>'tipo');
		EXECUTE _q INTO _r;
	END LOOP;
	*/

	RETURN id_individuo_arqueologico;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
