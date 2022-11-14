DROP FUNCTION IF EXISTS ae_add_incautacion(
  id_document numeric,
  seized_from json[],
  ordered_by json[],
  executioners json[],
  notaries json[],
  propietaries json[],
  witnesses json[],

  motives text[],
  date_ date,
  date_precision text,
  place numeric,
  place_precision text
);

CREATE OR REPLACE FUNCTION ae_add_incautacion(
  id_document numeric,
  seized_from json[],
  ordered_by json[],
  executioners json[],
  notaries json[],
  propietaries json[],
  witnesses json[],

  motives text[],
  date_ date,
  date_precision text,
  place numeric,
  place_precision text
)
RETURNS numeric as
$$
DECLARE
  _result record;
  _query text;
  _item json;
  _textitem text;

BEGIN

  PERFORM ae_add_person_batch(id_document, 'Incautado'::text, seized_from::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Comandante'::text, ordered_by::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Ejecutor'::text, executioners::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Notario'::text, notaries::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Propietario'::text, propietaries::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Testigo'::text, witnesses::jsonb[]);

  -- Crear motivos
  _query := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Motivo');
  EXECUTE _query INTO _result;

  FOREACH _textitem IN ARRAY motives
  LOOP
    _query := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, motivo) VALUES (%s, %L, %L) RETURNING id_pertenencia', id_document, 'Motivo', _textitem);
    EXECUTE _query INTO _result;
  END LOOP;

  -- Crear lugar y precision del lugar
  IF place IS NOT NULL
  THEN
    _query := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Lugar de incautación');
    EXECUTE _query INTO _result;
    
    _query := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc) VALUES (%s, %L) RETURNING id_pertenencia', id_document, 'Lugar de incautación');
    EXECUTE _query INTO _result;

    _query := format('INSERT INTO pertenencia_rel_lugar (fk_lugar_id, fk_pertenencia_id, precision_pert_lugar) VALUES (%s, %s, %L) RETURNING *', place, _result.id_pertenencia, place_precision);
    EXECUTE _query INTO _result;
  END IF;

  -- Crear Fecha de incautacion y precision
  _query := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Fecha de incautacion');
  EXECUTE _query INTO _result;

  _query := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, fecha_inicio, precision_inicio) VALUES (%s, %L, %L::date, %L) RETURNING id_pertenencia', id_document, 'Fecha de incautacion', date_, date_precision);
  EXECUTE _query INTO _result;

  RETURN id_document;
END;
$$ LANGUAGE plpgsql;
