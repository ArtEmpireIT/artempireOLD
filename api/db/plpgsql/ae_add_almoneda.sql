DROP FUNCTION IF EXISTS ae_add_almoneda(id_document numeric, owner json[], executor json[], crier json[], notary json[], witness json[], reason text);

CREATE OR REPLACE FUNCTION ae_add_almoneda(
  id_document numeric,
  owner json[],
  executor json[],
  crier json[],
  notary json[],
  witness json[],
  reason text
)
RETURNS numeric AS
$$
DECLARE

  _r record;
  _q text;
  _aux json;

BEGIN

  PERFORM ae_add_person_batch(id_document, 'Propietario'::text, owner::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Albacea'::text, executor::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Pregonero'::text, crier::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Escribano'::text, notary::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Testigo'::text, witness::jsonb[]);

  -- Creo el motivo de la Almoneda
  _q := format('UPDATE documento SET motivo_almoneda=%L
    WHERE id_documento=%s RETURNING id_documento', reason, id_document);

  EXECUTE _q INTO _r;

  RETURN id_document;

END;
$$ LANGUAGE plpgsql;
