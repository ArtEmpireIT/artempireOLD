DROP FUNCTION IF EXISTS ae_add_acta_repartimiento(
  id_document numeric,
  emisores json[],
  destinatarios json[],
  testigos json[],
  escribanos json[],
  pregoneros json[]
);

DROP FUNCTION IF EXISTS ae_add_acta_repartimiento(
  id_document numeric,
  personas json[]
);

DROP FUNCTION IF EXISTS ae_add_acta_repartimiento(
  id_document numeric,
  personas json[],
  personas_relacionadas json[]
);

CREATE OR REPLACE FUNCTION ae_add_acta_repartimiento(
  id_document numeric,
  personas json[],
  personas_relacionadas json[]
)
RETURNS numeric as
$$
DECLARE
  _result record;
  _query text;
  _person json;

  _index numeric;
  _root_person_ids jsonb[];
  _ids jsonb;
  _id_agrupacion numeric;

  _inner_person_ids jsonb[];
  _inner_person json;
  _inner_ids jsonb;
  _inner_index numeric;
  _exisiting_relation numeric;

  _id_pertenencia_relacion numeric;
  _id_persona_rol_pertenencia_relacion numeric;

BEGIN

  -- Crear personas principales
  _root_person_ids = ae_add_person_batch(id_document, 'Persona principal'::text, personas::jsonb[]);

  -- En PGSQL los arrays empiezan en 1
  _index = 1;
  FOREACH _person IN ARRAY personas
  LOOP
    _ids = _root_person_ids[_index];

    -- Crear agrupación de bienes si no existe
    IF (_person->>'id_agrupacion')::numeric IS NULL
    THEN 
      _query := format('INSERT INTO agrupacion_bienes (nombre) VALUES (''Acta Repartimiento'') RETURNING id_agrupacion_bienes');
      EXECUTE _query INTO _result;
      _id_agrupacion = _result.id_agrupacion_bienes;

      _query := format(
        'INSERT INTO pertenencia_rel_agrupacion_bienes (fk_pertenencia_id, fk_agrupacion_bienes_id)
        VALUES (%s, %s) RETURNING *',
        (_ids->>'id_pertenencia')::numeric, _id_agrupacion
      );
      EXECUTE _query INTO _result;
    ELSE
      _id_agrupacion = (_person->>'id_agrupacion')::numeric;
    END IF;

    _index = _index + 1;
  END LOOP;

  -- Crear personas relacionadas
  _inner_person_ids = ae_add_person_batch(id_document, 'Persona relacionada'::text, personas_relacionadas::jsonb[]);
  _inner_index = 1;
  FOREACH _inner_person IN ARRAY personas_relacionadas
  LOOP
    _inner_ids = _inner_person_ids[_inner_index];
    _index = (_inner_person->>'person_index')::numeric + 1;
    _ids = _root_person_ids[_index];
    _person = personas[_index];

    PERFORM ae_add_relacion_persona_persona(
      (_ids->>'id_pertenencia')::numeric,
      (_person->>'id_persona_historica')::numeric,
      (_inner_ids->>'id_pertenencia')::numeric,
      (_inner_person->>'id_persona_historica')::numeric,
      'Repartimiento'::text
    );

    _inner_index = _inner_index + 1;
  END LOOP;
  
  RETURN _id_agrupacion;
END;
$$ LANGUAGE plpgsql;
