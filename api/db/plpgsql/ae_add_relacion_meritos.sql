DROP FUNCTION IF EXISTS ae_add_relacion_meritos(id_document numeric, applicant json[], protagonist json[], witness json[], notary json[], allegations json[], requests json[]);

CREATE OR REPLACE FUNCTION ae_add_relacion_meritos(
  id_document numeric,
  applicant json[],
  protagonist json[],
  witness json[],
  notary json[],
  allegations json[],
  requests json[]
)
RETURNS numeric AS
$$
DECLARE

  _r record;
  _q text;
  _aux json;

BEGIN

  PERFORM ae_add_person_batch(id_document, 'Demandante'::text, applicant::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Protagonista'::text, protagonist::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Testigo'::text, witness::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Escribano'::text, notary::jsonb[]);

  --Creo los alegatos
  _q := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Alegato');
  EXECUTE _q INTO _r;

  FOREACH _aux IN ARRAY allegations
  LOOP
    _q := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, motivo, orden) VALUES (%s, %L, %L, %s) RETURNING id_pertenencia', id_document, 'Alegato', _aux->>'description', _aux->>'order');
    EXECUTE _q INTO _r;
  END LOOP;

  --Crea las solicitudes
  _q := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Solicitud');
  EXECUTE _q INTO _r;

  FOREACH _aux IN ARRAY requests
  LOOP
    _q := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, motivo, orden) VALUES (%s, %L, %L, %s) RETURNING id_pertenencia', id_document, 'Solicitud', _aux->>'description', _aux->>'order');
    EXECUTE _q INTO _r;
  END LOOP;


  RETURN id_document;

END;
$$ LANGUAGE plpgsql;
