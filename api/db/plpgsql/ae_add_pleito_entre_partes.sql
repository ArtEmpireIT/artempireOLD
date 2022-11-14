DROP FUNCTION IF EXISTS ae_add_pleito_entre_partes(id_document numeric, applicant json[], defendant json[], witness json[], notary json[], accusations json[], allegations json[], appeals json[]);

CREATE OR REPLACE FUNCTION ae_add_pleito_entre_partes(
  id_document numeric,
  applicant json[],
  defendant json[],
  witness json[],
  notary json[],
  accusations json[],
  allegations json[],
  appeals json[]
)
RETURNS numeric AS
$$
DECLARE

  _r record;
  _q text;
  _aux json;

BEGIN

  PERFORM ae_add_person_batch(id_document, 'Demandante'::text, applicant::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Demandado'::text, defendant::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Testigo'::text, witness::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Escribano'::text, notary::jsonb[]);

  --Crea las acusaciones
  _q := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Acusacion');
  EXECUTE _q INTO _r;

  FOREACH _aux IN ARRAY accusations
  LOOP
    _q := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, motivo, orden) VALUES (%s, %L, %L, %s) RETURNING id_pertenencia', id_document, 'Acusacion', _aux->>'description', _aux->>'order');
    EXECUTE _q INTO _r;
  END LOOP;

  --Creo los alegatos
  _q := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Alegato');
  EXECUTE _q INTO _r;

  FOREACH _aux IN ARRAY allegations
  LOOP
    _q := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, motivo, orden) VALUES (%s, %L, %L, %s) RETURNING id_pertenencia', id_document, 'Alegato', _aux->>'description', _aux->>'order');
    EXECUTE _q INTO _r;
  END LOOP;

  --Crea las apelaciones
  _q := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Apelacion');
  EXECUTE _q INTO _r;

  FOREACH _aux IN ARRAY appeals
  LOOP
    _q := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, motivo, orden) VALUES (%s, %L, %L, %s) RETURNING id_pertenencia', id_document, 'Apelacion', _aux->>'description', _aux->>'order');
    EXECUTE _q INTO _r;
  END LOOP;

  RETURN id_document;

END;
$$ LANGUAGE plpgsql;
