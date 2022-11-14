DROP FUNCTION IF EXISTS ae_add_relacion_persona_persona(
  id_pertenencia numeric,
  id_persona_historica numeric,
  id_pertenencia_relacion numeric,
  id_persona_historica_relacion numeric,
  descripcion text
);

CREATE OR REPLACE FUNCTION ae_add_relacion_persona_persona(
  id_pertenencia numeric,
  id_persona_historica numeric,
  id_pertenencia_relacion numeric,
  id_persona_historica_relacion numeric,
  descripcion text
)
RETURNS numeric as
$$
DECLARE 
  _result record;
  _query text;
  _exisiting_relation numeric;
  _id_persona_rol_pertenencia_relacion numeric;

BEGIN

  _exisiting_relation = (
    SELECT count(*) FROM persona_rol_pertenencia prp_count
    INNER JOIN persona_rol_pertenencia prp_count_origin
      ON prp_count.fk_persona_rol_pertenencia_id = prp_count_origin.id_persona_rol_pertenencia
    WHERE prp_count.fk_pertenencia_id = id_pertenencia_relacion
      AND prp_count_origin.fk_pertenencia_id = id_pertenencia
      AND prp_count.is_relation = TRUE
      AND prp_count_origin.is_relation = TRUE
  );

  IF _exisiting_relation = 0
  THEN

    _query := format(
      'INSERT INTO persona_rol_pertenencia (fk_persona_historica_id, fk_pertenencia_id, descripcion, is_relation) 
        VALUES (%s, %s, %L, true) RETURNING id_persona_rol_pertenencia', 
      id_persona_historica, id_pertenencia, descripcion
    );
    EXECUTE _query INTO _result;
    _id_persona_rol_pertenencia_relacion := _result.id_persona_rol_pertenencia;

    _query := format(
      'INSERT INTO persona_rol_pertenencia (fk_persona_historica_id, fk_pertenencia_id, descripcion, fk_persona_rol_pertenencia_id, is_relation)
        VALUES (%s, %s, %L, %s, true) RETURNING id_persona_rol_pertenencia',
      id_persona_historica_relacion, id_pertenencia_relacion,
      descripcion, _id_persona_rol_pertenencia_relacion
    );
    EXECUTE _query INTO _result;
  END IF;

  RETURN _exisiting_relation;
END;
$$ LANGUAGE plpgsql; 