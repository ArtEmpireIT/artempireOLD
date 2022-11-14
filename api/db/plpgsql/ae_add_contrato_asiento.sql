DROP FUNCTION IF EXISTS ae_add_contrato_asiento(
  id_document numeric,
  parts_involved json[],
  terms json[]
);

CREATE OR REPLACE FUNCTION ae_add_contrato_asiento(
  id_document numeric,
  parts_involved json[],
  terms json[]
)
RETURNS numeric as
$$
DECLARE
  _result record;
  _query text;
  _item json;

BEGIN

  PERFORM ae_add_person_batch(id_document, 'Involucrado'::text, parts_involved::jsonb[]);

  -- Crear condiciones
  _query := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Condición');
  EXECUTE _query INTO _result;

  FOREACH _item IN ARRAY terms
  LOOP
    _query := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, motivo, orden) VALUES (%s, %L, %L, %s) RETURNING id_pertenencia', id_document, 'Condición', _item->>'description', _item->>'order');
    EXECUTE _query INTO _result;
  END LOOP;

  RETURN id_document;
END;
$$ LANGUAGE plpgsql;