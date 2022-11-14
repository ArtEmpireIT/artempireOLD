DROP FUNCTION IF EXISTS ae_add_interrogatorio_respuestas(
  id_document numeric, 
  testigos json[]
);

CREATE OR REPLACE FUNCTION ae_add_interrogatorio_respuestas(
  id_document numeric, 
  testigos json[]
)
RETURNS numeric as
$$
DECLARE

  _result record;
  _query text;
  _item json;
  _tortura text;
  _respuesta json;

  _testigo_batch jsonb[];
  _testigo_ids jsonb[];
  _index numeric;
  _testigo jsonb;
  
BEGIN

  -- Borrar testigos y respuestas
  -- _query := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND (tipo_atr_doc=%L OR tipo_atr_doc=%L) RETURNING *', id_document, 'Testigo', 'Respuesta');
  -- EXECUTE _query INTO _result;

  _testigo_batch = ARRAY[]::jsonb[];
  FOREACH _item IN ARRAY testigos
  LOOP
    _testigo_batch = _testigo_batch || (
      (_item->'person')::jsonb || jsonb_build_object('descripcion', _item->>'description')
    );
  END LOOP;
  _testigo_ids = ae_add_person_batch(id_document, 'Testigo'::text, _testigo_batch);

  _index = 1;
  FOREACH _item IN ARRAY testigos
  LOOP

    _testigo = _testigo_ids[_index];
    _index = _index + 1;
    
    _query := format(
      'UPDATE pertenencia SET fecha_inicio = %L::date, precision_inicio = %L WHERE id_pertenencia = %s RETURNING *',
      _item->>'date', _item->>'date_precision', _testigo->'id_pertenencia'
    );
    EXECUTE _query INTO _result;   

    -- Borrar torturas
    _query := format('DELETE FROM persona_rol_pertenencia_rel_tortura WHERE fk_persona_rol_pertenencia_id=%s RETURNING *', _testigo->'id_prp');
    EXECUTE _query INTO _result;

    -- Insertar torturas y relacion con prp_testigo
    FOR _tortura IN (SELECT json_array_elements_text(_item->'torturas'))
    LOOP
      _query := format('INSERT INTO tortura (texto) values (%L) ON CONFLICT DO NOTHING RETURNING *', _tortura);
      EXECUTE _query INTO _result;

      _query := format('INSERT INTO persona_rol_pertenencia_rel_tortura (fk_persona_rol_pertenencia_id, fk_tortura_texto) VALUES (%s, %L) RETURNING *', _testigo->'id_prp', _tortura);
      EXECUTE _query INTO _result;      
    END LOOP;

    -- Borrar relaciones testigo-respuesta
    _query := format('DELETE FROM respuesta WHERE fk_persona_rol_pertenencia_id=%s RETURNING *', _testigo->'id_prp');
    EXECUTE _query INTO _result;

    -- Insertar respuestas
    FOR _respuesta IN (SELECT json_array_elements(_item->'respuestas'))
    LOOP
      _query := format('INSERT INTO pertenencia (motivo, fk_pertenencia_id, fk_documento_id, tipo_atr_doc)
      VALUES (%L, %s, %s, %L) RETURNING *', _respuesta->>'description', _respuesta->'id_pertenencia_pregunta', id_document, 'Respuesta');
      EXECUTE _query INTO _result;

      _query := format('INSERT INTO respuesta (fk_pertenencia_id, fk_persona_rol_pertenencia_id)
      VALUES (%s, %s) RETURNING *', _result.id_pertenencia, _testigo->'id_prp');
      EXECUTE _query INTO _result;      
      
    END LOOP;
    
  END LOOP;

  RETURN id_document;

END;
$$ LANGUAGE plpgsql;
