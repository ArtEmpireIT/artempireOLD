DROP FUNCTION IF EXISTS ae_add_desglose(numeric, numeric, numeric, text, text, numeric, numeric, text, date, text, numeric, text, text, text, text, text, numeric, numeric, text, numeric, text);
DROP FUNCTION IF EXISTS ae_add_desglose(
  id_documento numeric,
  id_pertenencia numeric,
  id_agrupacion_bienes numeric,
  concepto text,
  mas_info text,
  id_linea numeric,
  unidades jsonb,
  fecha_ingreso date,
  precision_fecha text,
  id_lugar numeric,
  lugar text,
  tipo_lugar text,
  precision_lugar text,
  folio text,
  adelanto text,

  id_persona_historica numeric,
  id_persona_rol_pertenencia numeric,
  nombre_persona_historica text,
  id_pertenencia_prp numeric,
  descripcion_receptor text

);
DROP FUNCTION IF EXISTS ae_add_desglose(
  id_documento numeric,
  id_pertenencia numeric,
  id_agrupacion_bienes numeric,
  concepto text,
  mas_info text,
  id_linea numeric,
  unidades jsonb,
  fecha_ingreso date,
  precision_fecha text,
  id_lugar numeric,
  lugar text,
  tipo_lugar text,
  precision_lugar text,
  folio text,
  adelanto text,

  persons json[]
);
DROP FUNCTION IF EXISTS ae_add_desglose(
  id_documento numeric,
  id_pertenencia numeric,
  id_agrupacion_bienes numeric,
  concepto text,
  mas_info text,
  id_linea numeric,
  unidades json[],
  fecha_ingreso date,
  precision_fecha text,
  id_lugar numeric,
  lugar text,
  tipo_lugar text,
  precision_lugar text,
  folio text,
  adelanto text,

  persons json[]
);
CREATE OR REPLACE FUNCTION ae_add_desglose(
  id_documento numeric,
  id_pertenencia numeric,
  id_agrupacion_bienes numeric,

  objeto text,
  id_objeto numeric,

  concepto text,
  mas_info text,

  id_linea numeric,
  unidades json[],

  fecha_ingreso date,
  precision_fecha text,

  id_lugar numeric,
  lugar text,
  tipo_lugar text,
  precision_lugar text,

  folio text,
  adelanto text,

  persons json[]
)
RETURNS numeric AS
$$
DECLARE
  _r record;
  _q text;
  _documento record;
  _receptor json;
  _unidad jsonb;
  _unidad_nombre text;
  _person json;
  _item json;  
  _ids_person numeric[];
  _id_pertenencia_person numeric;

BEGIN

  -- Objeto
  id_objeto = (SELECT ae_add_simple_objeto(objeto, id_objeto, NULL));

  IF id_pertenencia IS NULL
  THEN
    _q := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc) 
    VALUES (%s, %L) RETURNING *', id_documento, 'Desglose');
    EXECUTE _q INTO _r;    
    id_pertenencia = _r.id_pertenencia;
  END IF;

  -- Tipo lugar
  IF tipo_lugar IS NOT NULL
  THEN
    -- _q = format('INSERT INTO tipo_lugar (nombre) VALUES (%L) ON CONFLICT DO NOTHING', tipo_lugar);
    -- RAISE NOTICE '%', _q;
    -- PERFORM _q;
    _q = format('UPDATE lugar SET fk_tipo_lugar_nombre=%L WHERE id_lugar=%L RETURNING fk_tipo_lugar_nombre', tipo_lugar, id_lugar);
    EXECUTE _q INTO _r;
  END IF;

  RAISE NOTICE '%', id_lugar;
  -- Agrupacion bienes
  id_agrupacion_bienes = (SELECT ae_add_agrupacion_bienes(
      id_agrupacion_bienes,
      id_pertenencia,
      'Desglose',
      fecha_ingreso,
      precision_fecha,
      adelanto,
      mas_info,
      folio,
      precision_lugar,
      NULL,
      id_lugar));

  RAISE NOTICE 'id_agrupacion_bienes: %', id_agrupacion_bienes;
  -- Linea
  IF id_linea IS NULL
  THEN
    _q = format('INSERT INTO 
        linea(fk_objeto_id, descripcion, fk_agrupacion_bienes_id)
        VALUES(%L, %L, %s) 
      RETURNING id_linea', id_objeto, concepto, id_agrupacion_bienes);
  ELSE
    _q = format('UPDATE linea SET
        fk_objeto_id=%L,
        descripcion=%L,
        fk_agrupacion_bienes_id=%s
      WHERE id_linea=%s RETURNING id_linea', id_objeto, concepto, id_agrupacion_bienes, id_linea);
  END IF;
  EXECUTE _q INTO _r;
  id_linea = _r.id_linea;

  _q := format('DELETE FROM linea_rel_unidad WHERE fk_linea_id=%s RETURNING *', id_linea);
  EXECUTE _q INTO _r;

  FOREACH _unidad IN ARRAY unidades
  LOOP
    _unidad_nombre = (SELECT ae_add_unidad(_unidad->>'moneda', 'Moneda'));
    _q := format('INSERT INTO linea_rel_unidad (fk_linea_id, fk_unidad_nombre, valor) VALUES (%s, ''%s'', %s) RETURNING *', id_linea, _unidad_nombre, _unidad->>'valor');
    EXECUTE _q INTO _r;
  END LOOP;

  -- _q := format('DELETE FROM pertenencia
  --   WHERE tipo_atr_doc = %L AND fk_documento_id = %s 
  --   AND id_pertenencia IN (
  --     SELECT prp.fk_pertenencia_id from persona_rol_pertenencia prp
  --     JOIN persona_rol_pertenencia_rel_linea prpl
  --     ON prpl.fk_persona_rol_pertenencia_id = prp.id_persona_rol_pertenencia
  --     WHERE fk_linea = %s
  --   ) RETURNING *', 'Receptor Desglose', id_documento, id_linea);
  -- EXECUTE _q INTO _r;

  -- FOREACH _item IN ARRAY persons
  -- LOOP
  --   _person = (SELECT ae_add_rol_desc_persona_documento(id_documento, (_item->>'id_persona_historica')::numeric, _item->>'nombre', _item->>'descripcion', 'Receptor Desglose', 0, false));

  --   _q := format('INSERT INTO persona_rol_pertenencia_rel_linea (fk_persona_rol_pertenencia_id, fk_linea) VALUES (%s, %s) RETURNING *', _person->'id_prp', id_linea);
  --   EXECUTE _q INTO _r;
  -- END LOOP;

  _ids_person = ARRAY[]::numeric[];
  FOREACH _item IN ARRAY persons
  LOOP
    _ids_person = _ids_person || (_item->>'id_persona_rol_pertenencia')::numeric;
  END LOOP;

  _q = format('DELETE FROM pertenencia WHERE fk_documento_id = %s AND tipo_atr_doc = %L
    AND id_pertenencia IN (
      SELECT fk_pertenencia_id FROM persona_rol_pertenencia prp
      JOIN persona_rol_pertenencia_rel_linea prpl ON prpl.fk_persona_rol_pertenencia_id = prp.id_persona_rol_pertenencia
      WHERE prpl.fk_linea = %s
      AND prpl.fk_persona_rol_pertenencia_id NOT IN (SELECT unnest(%L::numeric[]))
    ) RETURNING *', id_documento, 'Receptor Desglose', id_linea, _ids_person);
  EXECUTE _q INTO _r;

  FOREACH _item IN ARRAY persons
  LOOP
    _id_pertenencia_person = (
      SELECT fk_pertenencia_id FROM persona_rol_pertenencia
      WHERE id_persona_rol_pertenencia = (_item->>'id_persona_rol_pertenencia')::numeric
    );
    _q := format('
      SELECT ae_add_persona_linea(%s,%L,%s,%L,%s, %L,%L,%L)
    ', id_documento, _id_pertenencia_person, (_item->>'id_persona_historica')::numeric, (_item->>'id_persona_rol_pertenencia')::numeric, id_linea, _item->>'nombre', 'Receptor Desglose', _item->>'descripcion');
    EXECUTE _q INTO _r;
  END LOOP;

  RETURN id_linea;

END;
$$ LANGUAGE plpgsql;
