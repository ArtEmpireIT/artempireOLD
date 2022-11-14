DROP FUNCTION IF EXISTS ae_add_carta(id_document numeric, emitters json[], recipients json[]);

CREATE OR REPLACE FUNCTION ae_add_carta(
  id_document numeric,
  emitters json[],
  recipients json[]
)
RETURNS numeric AS
$$
DECLARE

  _r record;
  _q text;
  _aux json;

BEGIN

  PERFORM ae_add_person_batch(id_document, 'Emisor'::text, emitters::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Destinatario'::text, recipients::jsonb[]);

  RETURN id_document;

END;
$$ LANGUAGE plpgsql;
