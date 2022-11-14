DROP FUNCTION IF EXISTS ae_add_visita(id_document numeric, applicant json[], defendant json[], witness json[], notary json[], diligence text, accusations json[], appeals json[]);

CREATE OR REPLACE FUNCTION ae_add_visita(
  id_document numeric,
  applicant json[],
  defendant json[],
  witness json[],
  notary json[],
  diligence text,
  accusations json[],
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

  --Creo la diligencia preliminar
  _q := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Deligencia_preliminar');
  EXECUTE _q INTO _r;

  _q := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, motivo) VALUES (%s, %L, %L) RETURNING id_pertenencia', id_document, 'Deligencia_preliminar', diligence);
  EXECUTE _q INTO _r;

  --Crea las acusaciones
  _q := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Acusacion');
  EXECUTE _q INTO _r;

  FOREACH _aux IN ARRAY accusations
  LOOP
    _q := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, motivo, orden) VALUES (%s, %L, %L, %s) RETURNING id_pertenencia', id_document, 'Acusacion', _aux->>'description', _aux->>'order');
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
