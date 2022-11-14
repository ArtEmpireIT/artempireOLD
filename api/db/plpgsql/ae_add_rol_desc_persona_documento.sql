DROP FUNCTION IF EXISTS ae_add_rol_desc_persona_documento(
  id_documento numeric, 
  id_persona_historica numeric, 
  nombre text, 
  descripcion text, 
  rol text,
  orden numeric,
  is_relation boolean
);

CREATE OR REPLACE FUNCTION ae_add_rol_desc_persona_documento(
  id_documento numeric,
  id_persona_historica numeric,
  nombre text,
  descripcion text,
  rol text,
  orden numeric,
  is_relation boolean DEFAULT false
)
RETURNS json AS
$$
DECLARE

  _r record;
  _q text;
  id_pertenencia_relacion numeric;
  _id_persona_rol_pertenencia_relacion numeric;
  pertenencia_inicio record;

BEGIN

  id_persona_historica = (SELECT ae_add_persona_historica(id_persona_historica, nombre));

  _q := format('SELECT fecha_inicio, precision_inicio FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L', id_documento, 'Emisión');
  EXECUTE _q INTO pertenencia_inicio;

  _q := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, orden, fecha_inicio, precision_inicio) VALUES (%s, %L, %s, %L::date, %L) RETURNING id_pertenencia', id_documento, rol, orden, pertenencia_inicio.fecha_inicio, pertenencia_inicio.precision_inicio);
  EXECUTE _q INTO _r;
  id_pertenencia_relacion := _r.id_pertenencia;

  _q := format('INSERT INTO persona_rol_pertenencia (fk_persona_historica_id, fk_pertenencia_id, descripcion, is_relation) VALUES (%s, %s, %L, %L) RETURNING id_persona_rol_pertenencia', id_persona_historica, id_pertenencia_relacion, descripcion, is_relation);
  EXECUTE _q INTO _r;
  _id_persona_rol_pertenencia_relacion := _r.id_persona_rol_pertenencia;

  _q := format('INSERT INTO rol (nombre) VALUES (%L) ON CONFLICT DO NOTHING RETURNING nombre', rol);
  EXECUTE _q INTO _r;

  _q := format('INSERT INTO persona_rol_pertenencia_rel_rol (fk_rol_nombre, fk_persona_rol_pertenencia)
    VALUES (%L, %s) RETURNING *', rol, _id_persona_rol_pertenencia_relacion);
  EXECUTE _q INTO _r;

  RETURN json_build_object('id_prp', _id_persona_rol_pertenencia_relacion, 'id_pertenencia', id_pertenencia_relacion);

END;
$$ LANGUAGE plpgsql;
