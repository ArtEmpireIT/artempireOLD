DROP FUNCTION IF EXISTS ae_add_person_batch(
  id_document numeric,
  role text,
  people jsonb[]
);
CREATE OR REPLACE FUNCTION ae_add_person_batch(
  id_document numeric,
  role text,
  people jsonb[]
)
RETURNS jsonb[] as
$$
DECLARE
  _result record;
  _query text;
  _person jsonb;
  _prp_ids numeric[];
  _pert_id numeric;
  _new_ids jsonb[];

BEGIN

  _prp_ids = ARRAY[]::numeric[];
  FOREACH _person IN ARRAY people
  LOOP
    _prp_ids = _prp_ids || (_person->>'id_prp')::numeric;
  END LOOP;

  _query = format('DELETE FROM pertenencia 
    WHERE fk_documento_id=%s 
    AND tipo_atr_doc=%L
    AND id_pertenencia NOT IN (
      SELECT fk_pertenencia_id FROM persona_rol_pertenencia
      WHERE id_persona_rol_pertenencia = ANY(%L)
    ) RETURNING *', id_document, role, _prp_ids);
  EXECUTE _query INTO _result;

  _new_ids = ARRAY[]::jsonb[];
  FOREACH _person IN ARRAY people
  LOOP
    IF (_person->>'id_prp')::numeric IS NULL
    THEN
      _new_ids = _new_ids || (
        ae_add_rol_desc_persona_documento(
          id_document,
          (_person->>'id_persona_historica')::numeric,
          _person->>'nombre',
          _person->>'descripcion',
          role,
          COALESCE((_person->>'order')::numeric, 0),
          COALESCE((_person->>'is_relation')::boolean, FALSE)
        )
      )::jsonb;
    ELSE
      _query = format('UPDATE persona_rol_pertenencia SET descripcion = %L 
        WHERE id_persona_rol_pertenencia = %s RETURNING *', _person->>'descripcion', _person->>'id_prp');
      EXECUTE _query INTO _result;

      _pert_id = _result.fk_pertenencia_id;

      _query = format('UPDATE pertenencia SET orden = %s 
        WHERE id_pertenencia = %s RETURNING *', COALESCE((_person->>'order')::numeric, 0), _pert_id);
      EXECUTE _query INTO _result;

      _new_ids = _new_ids || (
        jsonb_build_object(
          'id_prp', (_person->>'id_prp')::numeric,
          'id_pertenencia', _pert_id
        )
      );
    END IF;
    
  END LOOP;

  RETURN _new_ids;

END;
$$ LANGUAGE plpgsql;