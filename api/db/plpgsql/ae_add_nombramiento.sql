DROP FUNCTION IF EXISTS ae_add_nombramiento(
  id_document numeric, 
  senders json[],
  recipients json[]
);

CREATE OR REPLACE FUNCTION ae_add_nombramiento(
  id_document numeric, 
  senders json[],
  recipients json[]
)
RETURNS numeric as
$$
DECLARE

  _result record;
  _query text;
  _recipient json;
  _agr_bienes record;
  _role json;
  _id_objeto numeric;
  _linea record;
  _unit json;
  _resignant json;

  _recipients_batch jsonb[];
  _recipient_ids jsonb[];

  _ids_pertenencia_recipient numeric[];
  _id_pertenencia numeric;
  _index numeric;
  _ids_linea numeric[];
  _ids_resignant numeric[];
  _id_pertenencia_resignant numeric;

BEGIN

  PERFORM ae_add_person_batch(id_document, 'Emisor'::text, senders::jsonb[]);

  -- upsert persona_rol_pertenencia and related for every recipient
  _recipients_batch = ARRAY[]::jsonb[];
  FOREACH _recipient IN ARRAY recipients
  LOOP
    _recipients_batch = _recipients_batch || (
      (_recipient->'recipient')::jsonb || jsonb_build_object('order', (_recipient->>'order')::numeric)
    );
  END LOOP;
  _recipient_ids = ae_add_person_batch(id_document, 'Transacción'::text, _recipients_batch);

  _ids_pertenencia_recipient = ARRAY[]::jsonb[];
  FOREACH _recipient IN ARRAY _recipient_ids
  LOOP
    _ids_pertenencia_recipient = _ids_pertenencia_recipient || (_recipient->>'id_pertenencia')::numeric;
  END LOOP;

  -- delete from agr_bienes where id not related with recipients from input
  _query := format('DELETE FROM agrupacion_bienes ab
    WHERE ab.id_agrupacion_bienes IN (
      SELECT prab.fk_agrupacion_bienes_id FROM pertenencia_rel_agrupacion_bienes prab
      JOIN pertenencia p ON p.id_pertenencia = prab.fk_pertenencia_id
      WHERE p.id_pertenencia NOT IN (SELECT unnest(%L::numeric[]))
      AND p.fk_documento_id = %s
    ) RETURNING *', _ids_pertenencia_recipient, id_document);
  EXECUTE _query INTO _result;

  _index = 1;
  FOREACH _recipient IN ARRAY recipients
  LOOP
    -- create agr_bienes if not exists 
    -- and create relation with id_pertenencia from recipient
    _id_pertenencia = (_recipient_ids[_index]->>'id_pertenencia')::numeric;
    _index = _index + 1;

    _query := format('
      SELECT id_agrupacion_bienes FROM agrupacion_bienes ab 
      INNER JOIN pertenencia_rel_agrupacion_bienes prab ON prab.fk_agrupacion_bienes_id = ab.id_agrupacion_bienes
      WHERE prab.fk_pertenencia_id = %s
    ', _id_pertenencia);
    EXECUTE _query INTO _result;
    RAISE NOTICE 'SELECT agr_bienes query: %', _query;

    _query := format('
      SELECT ae_add_agrupacion_bienes(%L, %s, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
    ', _result.id_agrupacion_bienes, _id_pertenencia);
    EXECUTE _query INTO _agr_bienes;

    _ids_linea = ARRAY[]::numeric[];
    FOR _role IN (SELECT json_array_elements(_recipient->'roles'))
    LOOP
      _ids_linea = _ids_linea || (_role->>'id_linea')::numeric;
    END LOOP;

    -- delete from linea l where l related with agr_bienes and not in array of id_linea from input
    _query := format('DELETE FROM linea l WHERE l.fk_agrupacion_bienes_id = %s
      AND l.id_linea NOT IN (SELECT unnest(%L::numeric[]))
      RETURNING *', _agr_bienes.ae_add_agrupacion_bienes, _ids_linea);
    EXECUTE _query INTO _result;

    FOR _role IN (SELECT json_array_elements(_recipient->'roles'))
    LOOP
      _query := format('INSERT INTO objeto (nombre) VALUES (%L) ON CONFLICT (nombre) DO UPDATE SET nombre = %L RETURNING id_objeto', _role->>'role', _role->>'role');
      EXECUTE _query INTO _result;

      IF _role->>'id_linea' IS NULL
      THEN
        _query := format('
          INSERT INTO linea (fk_agrupacion_bienes_id, descripcion, fk_objeto_id, compra_cargo, condiciones_nombramiento) 
          VALUES (%s, %L, %s, %L, %L) RETURNING *
        ', _agr_bienes.ae_add_agrupacion_bienes, _role->>'motive', _result.id_objeto, _role->>'buy_type', _role->>'role_condition');
      ELSE
        _query := format('UPDATE linea SET 
          fk_agrupacion_bienes_id = %s, descripcion = %L, fk_objeto_id = %s, 
          compra_cargo = %L, condiciones_nombramiento = %L
          WHERE id_linea = %s
          RETURNING *', _agr_bienes.ae_add_agrupacion_bienes, _role->>'motive', _result.id_objeto, _role->>'buy_type', _role->>'role_condition', _role->>'id_linea');
      END IF;
      EXECUTE _query INTO _linea;

      -- delete and insert units
      _query := format('DELETE FROM linea_rel_unidad WHERE fk_linea_id=%s RETURNING *', _linea.id_linea);
      EXECUTE _query INTO _result;
      
      FOR _unit IN (SELECT json_array_elements(_role->'units'))
      LOOP
        _query := format('INSERT INTO unidad (nombre, tipo) VALUES (%L,%L) ON CONFLICT DO NOTHING RETURNING nombre', _unit->>'unit', 'Moneda');
        EXECUTE _query INTO _result;
        _query := format('INSERT INTO linea_rel_unidad (fk_linea_id, fk_unidad_nombre, valor) VALUES (%s, %L, %s) RETURNING *', _linea.id_linea, _unit->>'unit', _unit->>'value');
        EXECUTE _query INTO _result;        
      END LOOP;

      -- delete and insert resignats
      _ids_resignant = ARRAY[]::numeric[];
      FOR _resignant IN (SELECT json_array_elements(_role->'resignant'))
      LOOP
        _ids_resignant = _ids_resignant || (_resignant->>'id_prp')::numeric;
      END LOOP;

      _query = format('DELETE FROM pertenencia WHERE fk_documento_id = %s AND tipo_atr_doc = %L
        AND id_pertenencia IN (
          SELECT fk_pertenencia_id FROM persona_rol_pertenencia prp
          JOIN persona_rol_pertenencia_rel_linea prpl ON prpl.fk_persona_rol_pertenencia_id = prp.id_persona_rol_pertenencia
          WHERE prpl.fk_linea = %s
          AND prpl.fk_persona_rol_pertenencia_id NOT IN (SELECT unnest(%L::numeric[]))
        ) RETURNING *', id_document, 'Renunciante', _linea.id_linea, _ids_resignant);
      EXECUTE _query INTO _result;

      FOR _resignant IN (SELECT json_array_elements(_role->'resignant'))
      LOOP
        _id_pertenencia_resignant = (
          SELECT fk_pertenencia_id FROM persona_rol_pertenencia
          WHERE id_persona_rol_pertenencia = (_resignant->>'id_prp')::numeric
        );
        _query := format('
          SELECT ae_add_persona_linea(%s,%L,%s,%L,%s, %L,%L,%L)
        ', id_document, _id_pertenencia_resignant, (_resignant->>'id_persona_historica')::numeric, (_resignant->>'id_prp')::numeric, _linea.id_linea, _resignant->>'nombre', 'Renunciante', _resignant->>'descripcion');
        EXECUTE _query INTO _result;
      END LOOP;

    END LOOP;

  END LOOP;

  RETURN id_document;

END;
$$ LANGUAGE plpgsql;
