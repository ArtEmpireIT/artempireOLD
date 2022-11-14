DROP FUNCTION IF EXISTS ae_add_acta(
  id_document numeric,
  senders json[],
  recipients json[],
  notaries json[],
  criers json[],
  witnesses json[]
);

CREATE OR REPLACE FUNCTION ae_add_acta(
  id_document numeric,
  senders json[],
  recipients json[],
  notaries json[],
  criers json[],
  witnesses json[]
)
RETURNS numeric as
$$
DECLARE
  _result record;
  _query text;
  _item json;

BEGIN

  PERFORM ae_add_person_batch(id_document, 'Emisor'::text, senders::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Participante'::text, recipients::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Notario'::text, notaries::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Pregonero'::text, criers::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Testigo'::text, witnesses::jsonb[]);

  RETURN id_document;
END;
$$ LANGUAGE plpgsql;
