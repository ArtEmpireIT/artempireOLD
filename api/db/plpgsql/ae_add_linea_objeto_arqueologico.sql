DROP FUNCTION IF EXISTS ae_add_linea_objeto_arqueologico(
  numeric,
  numeric,
  numeric,
  text,
  text,
  text,
  text,
  numeric,
  numeric,
  text,
  text,
  json[]
);

CREATE OR REPLACE FUNCTION ae_add_linea_objeto_arqueologico(
    linea_id numeric,
    individuo_arqueologico_id numeric,
    objeto_arqueologico_id numeric,
    objeto_arqueologico_nombre text,
    origen text,
    tipo text,
    descripcion text,
    cantidad numeric,
    material_id numeric,
    material_nombre text,
    color text,
    unidades json[])
  RETURNS json AS
$BODY$
DECLARE
  _result record;
  _obj record;
  _mat record;
  _lin record;
  _lin_ue record;
  _query text;
  _item json;

BEGIN
  -- El individuo arqueologico (unidad estratigrafica) ya esta creado previamente, por lo que no es necesario controlar nada sobre dicha tabla.
  
  -- Insertamos objeto arqueologico
  IF objeto_arqueologico_id is NULL AND objeto_arqueologico_nombre IS NOT NULL
  THEN
    objeto_arqueologico_id := (SELECT o.id_objeto FROM objeto_arqueologico o WHERE lower(o.nombre) = lower(objeto_arqueologico_nombre) LIMIT 1);
    IF objeto_arqueologico_id IS NULL
    THEN
      _query := format('INSERT INTO objeto_arqueologico(nombre) VALUES (%L) ON CONFLICT DO NOTHING RETURNING *', objeto_arqueologico_nombre);  
      EXECUTE _query INTO _obj;
      objeto_arqueologico_id = _obj.id_objeto;
    END IF;
  END IF;
  
  -- Insertamos material
  IF material_id is NULL AND material_nombre IS NOT NULL
  THEN
    --_query := format('INSERT INTO material(nombre) VALUES (%L) ON CONFLICT DO NOTHING RETURNING *', material_nombre);
    --EXECUTE _query INTO _mat;
    --material_id = _mat.id_material; 
    material_id = ae_add_material(material_nombre, material_id, null::numeric);
  END IF;

  -- Insertamos linea
  IF linea_id is NULL
  THEN
    _query := format('INSERT INTO linea(descripcion,cantidad,color,fk_material_id) VALUES (%L,%L,%L,%L) ON CONFLICT DO NOTHING RETURNING *', descripcion, cantidad, lower(color), material_id);
  ELSE
    _query := format('UPDATE linea 
    SET descripcion=%L, cantidad=%L, color=%L, fk_material_id=%L 
    WHERE id_linea=%s RETURNING *', descripcion, cantidad, lower(color), material_id, linea_id);
  END IF;
  EXECUTE _query INTO _lin;
  linea_id = _lin.id_linea; 

  -- Linea <-> Objeto_arqueologico (N:M)
  _query := format('DELETE FROM objeto_arqueologico_rel_linea WHERE fk_linea=%s RETURNING *', linea_id);
  EXECUTE _query INTO _result;

  _query := format('INSERT INTO objeto_arqueologico_rel_linea(fk_objeto_arqueologico,fk_linea) VALUES (%s,%s) ON CONFLICT DO NOTHING RETURNING *', objeto_arqueologico_id, linea_id);
  EXECUTE _query INTO _result;

    -- Linea <-> Unidad (N:M)
  _query := format('DELETE FROM linea_rel_unidad WHERE fk_linea_id=%s RETURNING *', linea_id);
  EXECUTE _query INTO _result;

  FOREACH _item IN ARRAY unidades
  LOOP
    _query := format('INSERT INTO linea_rel_unidad (fk_linea_id, fk_unidad_nombre, valor) VALUES (%s, %L, %L) RETURNING *', linea_id, _item->>'nombre', _item->>'value');
    EXECUTE _query INTO _result;
  END LOOP;
  
  -- Linea <-> Individuo_arqueologico (N:M)
  _query := format('DELETE FROM individuo_arqueologico_rel_linea WHERE fk_linea=%s RETURNING *', linea_id);
  EXECUTE _query INTO _lin_ue;

  _query := format('INSERT INTO individuo_arqueologico_rel_linea(fk_individuo_arqueologico,fk_linea,origen,tipo) VALUES (%s,%s,%L,%L) ON CONFLICT DO NOTHING RETURNING *', individuo_arqueologico_id, linea_id, origen, tipo);
  EXECUTE _query INTO _lin_ue;
  
  RETURN to_json(_lin_ue);

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION ae_add_linea_objeto_arqueologico(numeric, numeric, numeric, text, text, text, text, numeric, numeric, text, text, json[])
  OWNER TO postgres;
