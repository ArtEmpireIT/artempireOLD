DROP FUNCTION IF EXISTS ae_add_interrogatorio_preguntas(
  id_document numeric, 
  preguntas json[]
);
DROP FUNCTION IF EXISTS ae_add_interrogatorio_preguntas(
  id_document numeric, 
  preguntas json[],
  testigos jsonb[]
);

CREATE OR REPLACE FUNCTION ae_add_interrogatorio_preguntas(
  id_document numeric, 
  preguntas json[],
  testigos jsonb[]
)
RETURNS numeric as
$$
DECLARE

  _result record;
  _query text;
  _item json;

  _id_map jsonb;
  _testigos_new jsonb[];

  _testigo jsonb;
  _respuesta jsonb;
  _respuestas_new jsonb;
  
BEGIN

  _id_map = '{}'::jsonb;

  _query := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Pregunta');
  EXECUTE _query INTO _result;

  FOREACH _item IN ARRAY preguntas
  LOOP
    _query := format('INSERT INTO pertenencia (
      tipo_atr_doc, motivo, orden, fk_documento_id
    ) VALUES (%L, %L, %s, %s) RETURNING id_pertenencia', 'Pregunta', _item->>'description', _item->'order', id_document);
    EXECUTE _query INTO _result;
    _id_map = _id_map || jsonb_build_object(_item->>'id_pertenencia', _result.id_pertenencia);
  END LOOP;
  
  _testigos_new = ARRAY[]::jsonb[];
  FOREACH _testigo IN ARRAY testigos
  LOOP
    _respuestas_new = '[]'::jsonb;
    FOR _respuesta IN (SELECT jsonb_array_elements(_testigo->'respuestas'))
    LOOP
      _respuestas_new = _respuestas_new || jsonb_set(_respuesta, '{id_pertenencia_pregunta}'::text[], _id_map->(_respuesta->>'id_pertenencia_pregunta'));
    END LOOP;
    _testigos_new = _testigos_new || jsonb_set(_testigo, '{respuestas}'::text[], _respuestas_new);
  END LOOP;

  RAISE NOTICE 'TESTIGOS (Original) %', testigos;
  RAISE NOTICE 'TESTIGOS (Modified) %', _testigos_new;

  PERFORM ae_add_interrogatorio_respuestas(
    id_document,
    _testigos_new::json[]
  );

  RETURN id_document;

END;
$$ LANGUAGE plpgsql;
