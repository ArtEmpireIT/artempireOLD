DROP FUNCTION IF EXISTS ae_add_institucion(numeric, numeric, numeric, text, text);
DROP FUNCTION IF EXISTS ae_add_institucion(
  id_documento numeric,
  id_pertenencia numeric,
  id_persona_rol_pertenencia numeric,
  nombre text,
  rol text,
  motivo text,
  tipo_atr_doc text,
  descripcion text,
  doPertenencia boolean
);
CREATE OR REPLACE FUNCTION ae_add_institucion(
  id_documento numeric,
  id_pertenencia numeric,
  id_persona_rol_pertenencia numeric,
  nombre text,
  rol text,
  motivo text,
  tipo_atr_doc text,
  descripcion text,
  doPertenencia boolean DEFAULT TRUE
)

-- SELECT ae_add_institucion(
--          66,
--          null,
--          null,
--          'nombre',
--          'Institución',
--          'Institución',
--          'Institución',
--          'descripcion'
--       )

RETURNS numeric AS
$$
DECLARE
  _r record;
  _q text;
  _documento record;
  _id_persona_historica numeric;
BEGIN

  _q =  format('
      SELECT
        fecha_inicio,
        precision_inicio
      FROM pertenencia p JOIN documento d ON p.fk_documento_id=d.id_documento
      WHERE p.tipo_atr_doc=''Emisión'' AND d.id_documento = %s', id_documento);
  EXECUTE _q INTO _documento;

  _q := format('SELECT ph.id_persona_historica FROM persona_historica ph WHERE ph.nombre=''Anónimo'' ORDER BY id_persona_historica LIMIT 1');
  EXECUTE _q INTO _r;
  _id_persona_historica = _r.id_persona_historica;

  -- Rol
  _q := format('INSERT INTO rol (nombre) VALUES(''%s'') ON CONFLICT DO NOTHING RETURNING nombre', rol);
  EXECUTE _q INTO _r;

  IF _id_persona_historica IS NULL
  THEN
    -- Anonimo
    _q := format('INSERT INTO persona_historica (nombre) VALUES (''Anónimo'') ON CONFLICT DO NOTHING RETURNING id_persona_historica');
    EXECUTE _q INTO _r;
    _id_persona_historica = _r.id_persona_historica;
  END IF;

  -- Institucion
  _q = format('INSERT INTO institucion (nombre) VALUES (%L) ON CONFLICT DO NOTHING RETURNING nombre', nombre);
  EXECUTE _q INTO _r;
  
  IF doPertenencia
  THEN
    -- Pertenencia
    IF id_pertenencia IS NULL
    THEN
      _q := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, motivo, fecha_inicio, precision_inicio) VALUES
      (%s, ''%s'', ''%s'', ''%s'', ''%s'') RETURNING id_pertenencia', id_documento, tipo_atr_doc, motivo, _documento.fecha_inicio, _documento.precision_inicio);
    ELSE
      _q := format('UPDATE pertenencia SET fk_documento_id=%s, tipo_atr_doc=''%s'', motivo=''%s'' WHERE id_pertenencia=%s RETURNING id_pertenencia', id_documento, tipo_atr_doc, motivo, id_pertenencia);
    END IF;
    EXECUTE _q INTO _r;
    IF _r.id_pertenencia IS NOT NULL
    THEN
      id_pertenencia = _r.id_pertenencia;
    END IF;

  END IF;


  -- Persona_rol_pertenencia
  IF id_persona_rol_pertenencia IS NULL
  THEN
    _q = format('INSERT INTO persona_rol_pertenencia (fk_pertenencia_id, fk_persona_historica_id, descripcion)
    VALUES (%s, %s, %L) RETURNING id_persona_rol_pertenencia', quote_nullable(id_pertenencia), _id_persona_historica, descripcion);
  ELSE
    _q = format('UPDATE persona_rol_pertenencia SET fk_pertenencia_id=%s, fk_persona_historica_id=%s, descripcion=%L
      WHERE id_persona_rol_pertenencia=%s RETURNING id_persona_rol_pertenencia', quote_nullable(id_pertenencia), _id_persona_historica, descripcion, id_persona_rol_pertenencia);
  END IF;
  EXECUTE _q INTO _r;
  IF _r.id_persona_rol_pertenencia IS NOT NULL
  THEN
    id_persona_rol_pertenencia := _r.id_persona_rol_pertenencia;
  END IF;


  -- Persona_rol_pertenencia_rel_rol
  _q = format('DELETE FROM persona_rol_pertenencia_rel_rol WHERE fk_rol_nombre=''%s'' AND fk_persona_rol_pertenencia=%s RETURNING *', rol, id_persona_rol_pertenencia);
  EXECUTE _q INTO _r;
  _q = format('INSERT INTO persona_rol_pertenencia_rel_rol (fk_rol_nombre, fk_persona_rol_pertenencia) VALUES (''%s'', %s) RETURNING *', rol, id_persona_rol_pertenencia);
  EXECUTE _q INTO _r;

  -- Persona_rol_pertenencia_rel_institucion
  -- First deletes
  _q := format('DELETE FROM persona_rol_pertenencia_rel_institucion WHERE fk_persona_rol_pertenencia_id=%s RETURNING *', id_persona_rol_pertenencia);
  EXECUTE _q INTO _r;
  _q := format('INSERT INTO persona_rol_pertenencia_rel_institucion (fk_persona_rol_pertenencia_id, fk_institucion_nombre)
    VALUES (%s, %L) RETURNING *', id_persona_rol_pertenencia, nombre);
  EXECUTE _q INTO _r;

  RETURN _r.fk_persona_rol_pertenencia_id;

END;
$$ LANGUAGE plpgsql;

-- SELECT ae_add_institucion(
--          66,
--          null,
--          null,
--          'Caja de España',
--          'Albacea',
--          'Institucion??',
--          'Albacea',
--          'Institucion??'
--       )
