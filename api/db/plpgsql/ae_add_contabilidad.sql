DROP FUNCTION IF EXISTS ae_add_contabilidad(
  id_document numeric,
  nombre_institucion text,
  descripcion_institucion text,

  fecha_inicio date,
  precision_inicio text,
  fecha_fin date,
  precision_fin text,

  fecha_ingreso date,
  precision_fecha_ingreso text,
  id_lugar_ingreso numeric,
  tipo_lugar_ingreso text,
  precision_lugar_ingreso text,
  adelanto text,

  tesoreros json[],
  contadores json[],
  factores json[],
  tomadores json[],
  veedores json[],
  receptores json[],
  lineas json[]
);

CREATE OR REPLACE FUNCTION ae_add_contabilidad(
  id_document numeric,
  nombre_institucion text,
  descripcion_institucion text,

  fecha_inicio date,
  precision_inicio text,
  fecha_fin date,
  precision_fin text,

  fecha_ingreso date,
  precision_fecha_ingreso text,
  id_lugar_ingreso numeric,
  tipo_lugar_ingreso text,
  precision_lugar_ingreso text,
  adelanto text,

  tesoreros json[],
  contadores json[],
  factores json[],
  tomadores json[],
  veedores json[],
  receptores json[],
  lineas json[]
)
RETURNS numeric as
$$
DECLARE
  _result record;
  _pert_cont record;
  _id_pert_cont numeric;
  _agr_bienes record;
  _id_agr_bienes numeric;
  _query text;
  _item json;
  _item_linea json;
  _linea record;
  _unidad_nombre text;
  _id_lineas numeric[];

BEGIN

  PERFORM ae_add_person_batch(id_document, 'Tesorero'::text, tesoreros::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Contador'::text, contadores::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Factor'::text,   factores::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Tomador'::text,  tomadores::jsonb[]);  
  PERFORM ae_add_person_batch(id_document, 'Veedor'::text,   veedores::jsonb[]);  
  PERFORM ae_add_person_batch(id_document, 'Receptor'::text, receptores::jsonb[]);

  -- Crear institucion
  IF nombre_institucion IS NOT NULL
  THEN
    _item = (
      SELECT json_build_object(
        'id_pertenencia', id_pertenencia,
        'id_prp', id_persona_rol_pertenencia
      )
      FROM pertenencia p
      JOIN persona_rol_pertenencia prp ON prp.fk_pertenencia_id = p.id_pertenencia
      WHERE p.tipo_atr_doc = 'Institución' AND p.fk_documento_id = id_document
    );
    PERFORM ae_add_institucion(
      id_document, 
      (_item->>'id_pertenencia')::numeric,
      (_item->>'id_prp')::numeric,
      nombre_institucion, 
      'Institución','Institución','Institución',
      descripcion_institucion
    );
  END IF;

  -- Crear pertenencia contabilidad (con datos de ej. fiscal)
  _id_pert_cont = (
    SELECT id_pertenencia FROM pertenencia p 
    WHERE p.fk_documento_id = id_document AND p.tipo_atr_doc = 'Contabilidad'
  );
  IF _id_pert_cont IS NULL
  THEN
    _query := format('INSERT INTO pertenencia 
      (fk_documento_id, tipo_atr_doc, fecha_inicio, precision_inicio, fecha_fin, precision_fin) 
      VALUES (%s, %L, %L::date, %L, %L::date, %L)
      RETURNING *', id_document, 'Contabilidad', fecha_inicio, precision_inicio, fecha_fin, precision_fin);
  ELSE 
    _query = format('UPDATE pertenencia SET 
      fecha_inicio = %L::date, precision_inicio = %L,
      fecha_fin = %L::date, precision_fin = %L
    WHERE id_pertenencia = %s
    RETURNING *', fecha_inicio, precision_inicio, fecha_fin, precision_fin, _id_pert_cont); 
  END IF;
  EXECUTE _query INTO _pert_cont;

  _id_agr_bienes = (
    SELECT fk_agrupacion_bienes_id FROM pertenencia_rel_agrupacion_bienes
    WHERE fk_pertenencia_id = _pert_cont.id_pertenencia
  );
  _id_agr_bienes = (SELECT ae_add_agrupacion_bienes(
    _id_agr_bienes,
    _pert_cont.id_pertenencia,
    'Contabilidad', fecha_ingreso, precision_fecha_ingreso,
    adelanto, NULL, NULL, precision_lugar_ingreso, NULL, id_lugar_ingreso
  ));

  IF id_lugar_ingreso IS NOT NULL
  THEN
    _query := format('UPDATE lugar SET fk_tipo_lugar_nombre = %L WHERE id_lugar = %s RETURNING *', tipo_lugar_ingreso, id_lugar_ingreso);
    EXECUTE _query INTO _result;    
  END IF;
  
  -- Crear lineas para agr. bienes
  _id_lineas = ARRAY[]::numeric[];
  FOREACH _item_linea IN ARRAY lineas
  LOOP
    _id_lineas =  _id_lineas || (
      (
        _item_linea->>'id_linea'
      )::numeric
    );

  END LOOP;

  _query = format('DELETE FROM linea WHERE fk_agrupacion_bienes_id = %s
    AND id_linea NOT IN (SELECT unnest(%L::numeric[]))
    RETURNING *', _id_agr_bienes, _id_lineas);
  EXECUTE _query INTO _result;

  FOREACH _item IN ARRAY lineas
  LOOP

    IF _item->>'id_linea' IS NULL
    THEN 
      _query := format('INSERT INTO linea (descripcion, fk_agrupacion_bienes_id) 
        VALUES (%L, %s) RETURNING *', _item->>'tipo', _id_agr_bienes);
    ELSE
      _query := format('UPDATE linea SET descripcion = %L WHERE id_linea = %s RETURNING *', _item->>'tipo', (_item->>'id_linea')::numeric);
    END IF;
    EXECUTE _query INTO _linea;

    _query = format('DELETE FROM linea_rel_unidad WHERE fk_linea_id = %s RETURNING *', _linea.id_linea);
    EXECUTE _query INTO _result;

    _unidad_nombre = (SELECT ae_add_unidad(_item->>'moneda', 'Moneda'));
    _query := format('INSERT INTO linea_rel_unidad (fk_linea_id, fk_unidad_nombre, valor) VALUES (%s, ''%s'', %s) RETURNING *', _linea.id_linea, _unidad_nombre, _item->>'valor');
    EXECUTE _query INTO _result;

  END LOOP;

  RETURN id_document;
END;
$$ LANGUAGE plpgsql;