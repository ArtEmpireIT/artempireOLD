DROP FUNCTION IF EXISTS ae_add_testamento(id_document numeric, testamentary json[], executor json[], heir json[], notary json[], witnesses_issue json[], witnesses_opening json[], preamble text, mandas json[], burial_arrangement text);

CREATE OR REPLACE FUNCTION ae_add_testamento(
  id_document numeric,
  testamentary json[],
  executor json[],
  heir json[],
  notary json[],
  witnesses_issue json[],
  witnesses_opening json[],
  preamble text,
  mandas json[],
  burial_arrangement text
)
RETURNS numeric AS
$$
DECLARE

  _r record;
  _q text;
  _aux json;

BEGIN

  PERFORM ae_add_person_batch(id_document, 'Testamentario'::text, testamentary::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Albacea'::text, executor::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Heredero'::text, heir::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Escribano'::text, notary::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Testigo de emisión'::text, witnesses_issue::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Testigo de apertura'::text, witnesses_opening::jsonb[]);

  --Crea las mandas
  _q := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Manda');
  EXECUTE _q INTO _r;

  FOREACH _aux IN ARRAY mandas
  LOOP
    _q := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, motivo, orden) VALUES (%s, %L, %L, %s) RETURNING id_pertenencia', id_document, 'Manda', _aux->>'description', _aux->>'order');
    EXECUTE _q INTO _r;
  END LOOP;

  --Guardo preámbulo
  _q := format('
    UPDATE documento SET preambulo_testamento=%L
    WHERE id_documento=%s RETURNING id_documento',
    preamble, id_document);

  EXECUTE _q INTO _r;

  --Guardo la disposición del enterramiento
  _q := format('
    UPDATE documento SET disp_ente_testamento=%L
    WHERE id_documento=%s RETURNING id_documento',
    burial_arrangement, id_document);

  EXECUTE _q INTO _r;

  RETURN id_document;

END;
$$ LANGUAGE plpgsql;
