DROP FUNCTION IF EXISTS ae_add_objeto(
  id_documento numeric,
  id_pertenencia numeric,
  id_agrupacion_bienes numeric,
  id_linea numeric,

  descripcion_objeto text,
  calidad text,
  estado text,
  unidades jsonb,

  tipo_atr_doc text,

  numero numeric,
  color text,

  id_material numeric,
  material text,
  fk_material_id numeric,

  id_objeto numeric,
  objeto text,

  id_origen numeric,

  tipo_impuesto text,  

  doPertenencia boolean,
  peopleRelations json[],
  placeRelations json[],
  buyers json[],
  sellers json[]
);
DROP FUNCTION IF EXISTS ae_add_objeto(
  id_linea numeric,
  id_persona_rol_pertenencia numeric,

  id_pertenencia numeric,
  id_documento numeric,
  id_agrupacion_bienes numeric,

  descripcion_objeto text,
  calidad text,
  estado text,
  unidades jsonb,

  campo text,
  numero numeric,
  color text,

  id_material numeric,
  material text,
  fk_material_id numeric,

  id_objeto numeric,
  objeto text,

  id_origen numeric,
  origen text,
  tipo_impuesto text,

  id_persona_historica numeric,
  nombre_persona_historica text,
  descripcion text,
  rol text,
  doPertenencia boolean,

  peopleRelations json[],
  placeRelations json[]
);
DROP FUNCTION IF EXISTS ae_add_objeto(
  id_linea numeric,
  id_persona_rol_pertenencia numeric,

  id_pertenencia numeric,
  id_documento numeric,
  id_agrupacion_bienes numeric,

  descripcion_objeto text,
  calidad text,
  estado text,
  unidades json[],

  campo text,
  numero numeric,
  color text,

  id_material numeric,
  material text,
  fk_material_id numeric,

  id_objeto numeric,
  objeto text,

  id_origen numeric,
  origen text,
  tipo_impuesto text,

  id_persona_historica numeric,
  nombre_persona_historica text,
  descripcion text,
  rol text,
  doPertenencia boolean,

  peopleRelations json[],
  placeRelations json[]
);

CREATE OR REPLACE FUNCTION ae_add_objeto(
  id_documento numeric,
  id_pertenencia numeric,
  id_agrupacion_bienes numeric,
  id_linea numeric,

  descripcion_objeto text,
  calidad text,
  estado text,
  unidades json[],

  tipo_atr_doc text,

  numero numeric,
  color text,

  id_material numeric,
  material text,
  fk_material_id numeric,

  id_objeto numeric,
  objeto text,

  id_origen numeric,

  tipo_impuesto text,  

  doPertenencia boolean default FALSE,

  peopleRelations json[] default ARRAY[]::json[],
  placeRelations json[] default ARRAY[]::json[]

  -- buyers json[] default ARRAY[]::json[],
  -- sellers json[] default ARRAY[]::json[]
)
RETURNS numeric AS
$$
DECLARE
  _r record;
  _unidad json;
  _unidad_nombre text;
  _q text;
  _relacion json;
  id_pertenencia_relacion numeric;
  _id_persona_rol_pertenencia_relacion numeric;

  _person json;
  _is_relation boolean;

BEGIN

  -- Material
  id_material = (SELECT ae_add_material(material, id_material, fk_material_id));

  -- Objeto
  id_objeto = (SELECT ae_add_simple_objeto(objeto, id_objeto, NULL));

  -- Create agrupacion_bienes if no agrupacion_bienes_id given
  IF id_agrupacion_bienes IS NULL
  THEN
    _q := format('INSERT INTO agrupacion_bienes (nombre) VALUES(null) RETURNING id_agrupacion_bienes');
    EXECUTE _q INTO _r;
    id_agrupacion_bienes = _r.id_agrupacion_bienes;
  END IF;

  -- Pertenencia y pertenencia_rel_agrupacion_bienes
  IF doPertenencia
  THEN
    IF id_pertenencia IS NULL
    THEN
      _q := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc) VALUES (%s, %s) RETURNING id_pertenencia', id_documento, quote_nullable(tipo_atr_doc));
    ELSE
      _q := format('UPDATE pertenencia SET tipo_atr_doc=%s WHERE id_pertenencia=%s RETURNING id_pertenencia', quote_nullable(tipo_atr_doc), id_pertenencia);
    END IF;
    EXECUTE _q INTO _r;
    id_pertenencia = _r.id_pertenencia;

    _q := format('
      INSERT INTO pertenencia_rel_agrupacion_bienes (fk_pertenencia_id, fk_agrupacion_bienes_id)
      VALUES (%s, %s) ON CONFLICT DO NOTHING RETURNING *',
      id_pertenencia, id_agrupacion_bienes
    );
    EXECUTE _q INTO _r;
  END IF;


  -- linea
  IF id_linea IS NULL
  THEN
    _q := format('
      INSERT INTO
        linea(fk_objeto_id, fk_agrupacion_bienes_id, descripcion, cantidad, color, calidad, estado, fk_material_id, fk_lugar_id, tipo_impuesto)
        VALUES (%s, %s, ''%s'', %s, ''%s'', ''%s'',''%s'', %s, %s, %L)
      RETURNING id_linea
    ',quote_nullable(id_objeto), id_agrupacion_bienes, descripcion_objeto, quote_nullable(numero), lower(color), calidad, estado, quote_nullable(id_material), quote_nullable(id_origen), tipo_impuesto);

  ELSE
    _q := format('
      UPDATE linea SET
        fk_objeto_id=%s,
        fk_agrupacion_bienes_id=%s,
        descripcion=%L,
        cantidad=%s,
        color=%L,
        calidad=%L,
        estado=%L,
        fk_material_id=%s,
        fk_lugar_id=%s,
        tipo_impuesto=%L
      WHERE id_linea=%s
      RETURNING id_linea
      ', quote_nullable(id_objeto), id_agrupacion_bienes, descripcion_objeto, quote_nullable(numero), lower(color), calidad, estado, quote_nullable(id_material), quote_nullable(id_origen), tipo_impuesto, id_linea);
  END IF;
  EXECUTE _q INTO _r;
  RAISE NOTICE '%', _q;
  id_linea := _r.id_linea;

  RAISE NOTICE 'id_linea: %', id_linea;

  -- Unidades
  _q := format('DELETE FROM linea_rel_unidad WHERE fk_linea_id=%s RETURNING *', id_linea);
  EXECUTE _q INTO _r;
  FOREACH _unidad IN ARRAY unidades
  LOOP
    _unidad_nombre = (SELECT ae_add_unidad(_unidad->>'nombre', _unidad->>'type'));
    _q := format('INSERT INTO linea_rel_unidad (fk_linea_id, fk_unidad_nombre, valor, es_impuesto) VALUES (%s, ''%s'', %s, %s) RETURNING *', id_linea, _unidad_nombre, _unidad->>'value', _unidad->>'is_tax');
    EXECUTE _q INTO _r;
  END LOOP;


  --Relaciones con personas

  -- Borrar relaciones
  _q := format('
    DELETE FROM pertenencia 
    WHERE fk_documento_id=%s AND id_pertenencia in(
      SELECT p.id_pertenencia
      FROM persona_rol_pertenencia_rel_linea prpl
      LEFT JOIN persona_rol_pertenencia prp on prp.id_persona_rol_pertenencia = prpl.fk_persona_rol_pertenencia_id
      LEFT JOIN pertenencia p on p.id_pertenencia = prp.fk_pertenencia_id
      WHERE p.fk_documento_id = %s AND prpl.fk_linea = %s AND p.tipo_atr_doc = %L
    )
    RETURNING *
  ',id_documento, id_documento, id_linea, 'Creación de relación');

  EXECUTE _q INTO _r;

  -- Borrar compradores y vendedores 
  _q := format('
    DELETE FROM pertenencia 
    WHERE fk_documento_id=%s 
    AND (tipo_atr_doc = %L OR tipo_atr_doc = %L OR tipo_atr_doc = %L)
    AND id_pertenencia NOT IN (
      SELECT p.id_pertenencia FROM pertenencia p
      JOIN persona_rol_pertenencia prp ON prp.fk_pertenencia_id = p.id_pertenencia
      JOIN persona_rol_pertenencia_rel_linea prpl ON prpl.fk_persona_rol_pertenencia_id = prp.id_persona_rol_pertenencia
      WHERE p.fk_documento_id = %s
      AND prpl.fk_linea <> %s
    ) RETURNING *
  ',id_documento, 'Comprador','Vendedor','Creación de relación', id_documento, id_linea);

  EXECUTE _q INTO _r;

  _q := format('
    DELETE FROM persona_rol_pertenencia_rel_linea WHERE fk_linea = %s
    RETURNING *
  ', id_linea);
  EXECUTE _q INTO _r;
  
  FOREACH _relacion IN ARRAY peopleRelations
  LOOP
    _person = (
      SELECT json_build_object(
        'id_p', p.id_pertenencia,
        'id_prp', prp.id_persona_rol_pertenencia,
        'tipo_attr', p.tipo_atr_doc
      )
      FROM pertenencia p
      JOIN persona_rol_pertenencia prp ON prp.fk_pertenencia_id = p.id_pertenencia
      WHERE p.fk_documento_id = id_documento
      AND (p.tipo_atr_doc = 'Comprador' OR p.tipo_atr_doc = 'Vendedor' OR p.tipo_atr_doc = 'Creación de relación' or prp.is_relation = true) 
      AND prp.fk_persona_historica_id = (_relacion->>'id')::numeric
    );

    IF _person IS NULL
    THEN

      _is_relation := _relacion->>'role' = 'Creación de relación';

      _person = (SELECT ae_add_rol_desc_persona_documento(id_documento, (_relacion->>'id')::numeric, _relacion->>'nombre', _relacion->>'descripcion', _relacion->>'role', 0, _is_relation));
      _id_persona_rol_pertenencia_relacion = _person->'id_prp';        

    ELSE
      _id_persona_rol_pertenencia_relacion = _person->'id_prp';  

    END IF;

    _q := format('INSERT INTO persona_rol_pertenencia_rel_linea (fk_persona_rol_pertenencia_id, fk_linea) VALUES (%s, %s) RETURNING *', _id_persona_rol_pertenencia_relacion, id_linea);
    EXECUTE _q INTO _r;

  END LOOP;
  
  --Relaciones con lugares
  _q := format(' DELETE FROM linea_rel_lugar WHERE fk_linea_id=%s RETURNING *', id_linea);
  EXECUTE _q INTO _r;

  FOREACH _relacion IN ARRAY placeRelations
  LOOP
    _q := format('INSERT INTO linea_rel_lugar (fk_linea_id, fk_lugar_id, descripcion_lugar) VALUES (%s, %s, %L) RETURNING *', id_linea, _relacion->>'id', _relacion->>'descripcion');
    EXECUTE _q INTO _r;
  END LOOP;

  RETURN id_linea;

END;
$$ LANGUAGE plpgsql;
