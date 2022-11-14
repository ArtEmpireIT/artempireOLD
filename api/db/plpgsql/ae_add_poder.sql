DROP FUNCTION IF EXISTS ae_add_poder(
  id_document numeric, 
  senders json[], 
  sender_witnesees json[], 
  recipients json[],
  presentation_witnesses json[], 
  notaries json[],
  powers text[],
  
  area_of_application numeric,
  area_precision text,
  resignations json[],

  start_date date,
  start_date_precision text,
  end_date date,
  end_date_precision text
);

CREATE OR REPLACE FUNCTION ae_add_poder(
  id_document numeric, 
  senders json[], 
  sender_witnesees json[], 
  recipients json[],
  presentation_witnesses json[], 
  notaries json[],
  powers text[],
  
  area_of_application numeric,
  area_precision text,

  resignations json[],

  start_date date,
  start_date_precision text,
  end_date date,
  end_date_precision text
)
RETURNS numeric as
$$
DECLARE

  _result record;
  _query text;
  _item json;
  _textitem text;

BEGIN

  PERFORM ae_add_person_batch(id_document, 'Emisor'::text, senders::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Testigo de emisión'::text, sender_witnesees::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Destinatario'::text, recipients::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Testigo de presentación'::text, presentation_witnesses::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Notario'::text, notaries::jsonb[]);

  -- Crear poderes
  _query := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Poder');
  EXECUTE _query INTO _result;

  FOREACH _textitem IN ARRAY powers
  LOOP
    _query := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, motivo) VALUES (%s, %L, %L) RETURNING id_pertenencia', id_document, 'Poder', _textitem);
    EXECUTE _query INTO _result;
  END LOOP;

  -- Crear Ámbito de apliación (lugar)
  IF area_of_application IS NOT NULL
  THEN
    _query := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Ámbito de aplicación');
    EXECUTE _query INTO _result;
    
    _query := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc) VALUES (%s, %L) RETURNING id_pertenencia', id_document, 'Ámbito de aplicación');
    EXECUTE _query INTO _result;

    _query := format('INSERT INTO pertenencia_rel_lugar (fk_lugar_id, fk_pertenencia_id, precision_pert_lugar) VALUES (%s, %s, %L) RETURNING *', area_of_application, _result.id_pertenencia, area_precision);
    EXECUTE _query INTO _result;
  END IF;

  -- Crear renuncias
  _query := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc LIKE %L RETURNING *', id_document, 'renuncia#%');
  EXECUTE _query INTO _result;

  FOREACH _item IN ARRAY resignations
  LOOP
    _query := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, motivo) VALUES (%s, %L, %L) RETURNING id_pertenencia', id_document, format('renuncia#%s', _item->>'type'), _item->>'description');
    EXECUTE _query INTO _result;
  END LOOP;

  -- Crear plazo de vigencia
  _query := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Plazo de vigencia');
  EXECUTE _query INTO _result;

  _query := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, fecha_inicio, fecha_fin, precision_inicio, precision_fin) VALUES (%s, %L, %L::date, %L::date, %L, %L) RETURNING id_pertenencia', id_document, 'Plazo de vigencia', start_date, end_date, start_date_precision, end_date_precision);
  EXECUTE _query INTO _result;

  RETURN id_document;

END;
$$ LANGUAGE plpgsql;
