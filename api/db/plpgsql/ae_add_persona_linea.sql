DROP FUNCTION IF EXISTS ae_add_persona_linea(
  id_documento numeric,
  id_persona_historica numeric,
  id_persona_rol_pertenencia numeric,
  id_linea numeric,
  nombre_persona_historica text,
  rol text,
  descripcion text
);
DROP FUNCTION IF EXISTS ae_add_persona_linea(
  id_documento numeric,
  id_pertenencia numeric,
  id_persona_historica numeric,
  id_persona_rol_pertenencia numeric,
  id_linea numeric,
  nombre_persona_historica text,
  rol text,
  descripcion text
);

CREATE OR REPLACE FUNCTION ae_add_persona_linea(
  id_documento numeric,
  id_pertenencia numeric,
  id_persona_historica numeric,
  id_persona_rol_pertenencia numeric,
  id_linea numeric,
  nombre_persona_historica text,
  rol text,
  descripcion text
)
RETURNS numeric AS
$$
DECLARE
  _r record;
  _q text;
BEGIN

  id_persona_historica := (SELECT ae_add_persona_historica(id_persona_historica, nombre_persona_historica));

  IF id_pertenencia IS NULL
  THEN
    _q := format('SELECT fecha_inicio, precision_inicio FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L', id_documento, 'Emisión');
    EXECUTE _q INTO _r;

    _q = format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, fecha_inicio, precision_inicio) VALUES (%s, %L, %L::date, %L) RETURNING id_pertenencia', id_documento, rol, _r.fecha_inicio, _r.precision_inicio);
    EXECUTE _q INTO _r;
    id_pertenencia = _r.id_pertenencia;
  END IF;

  -- Rol
  _q := format('INSERT INTO rol (nombre) VALUES(''%s'') ON CONFLICT DO NOTHING RETURNING nombre', rol);
  EXECUTE _q INTO _r;

  -- Persona_rol_pertenencia
  IF id_persona_rol_pertenencia IS NULL
  THEN
    _q := format('
      INSERT INTO persona_rol_pertenencia (fk_persona_historica_id, descripcion, fk_pertenencia_id)
      VALUES (%s, %L, %s) RETURNING id_persona_rol_pertenencia
    ', id_persona_historica, descripcion, id_pertenencia);
  ELSE
    _q := format('
      UPDATE persona_rol_pertenencia SET descripcion = %L
      WHERE id_persona_rol_pertenencia = %s 
      RETURNING id_persona_rol_pertenencia
    ', descripcion, id_persona_rol_pertenencia);
  END IF;
  EXECUTE _q INTO _r;

  IF _r.id_persona_rol_pertenencia IS NOT NULL
  THEN
    id_persona_rol_pertenencia := _r.id_persona_rol_pertenencia;
  END IF;

  -- Persona_rol_pertenencia_rel_rol
  _q := format('DELETE FROM persona_rol_pertenencia_rel_rol WHERE fk_rol_nombre=''%s'' AND fk_persona_rol_pertenencia=%s RETURNING *', rol, id_persona_rol_pertenencia);
  EXECUTE _q INTO _r;
  _q := format('INSERT INTO persona_rol_pertenencia_rel_rol (fk_rol_nombre, fk_persona_rol_pertenencia) VALUES (''%s'', %s) RETURNING *', rol, id_persona_rol_pertenencia);
  EXECUTE _q INTO _r;

  -- First delete
  _q := format('DELETE FROM persona_rol_pertenencia_rel_linea WHERE fk_linea=%s AND fk_persona_rol_pertenencia_id=%s RETURNING *', id_linea, id_persona_rol_pertenencia);
  EXECUTE _q INTO _r;
  _q := format('INSERT INTO persona_rol_pertenencia_rel_linea (fk_linea, fk_persona_rol_pertenencia_id)
    VALUES (%s, %s) RETURNING *', id_linea, id_persona_rol_pertenencia);
  EXECUTE _q INTO _r;

  RETURN id_persona_rol_pertenencia;

END;
$$ LANGUAGE plpgsql;
