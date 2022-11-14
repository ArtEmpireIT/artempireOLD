DROP FUNCTION IF EXISTS ae_add_compra_venta(
  id_document numeric,
  buyers json[],
  sellers json[],
  notaries json[],
  place numeric,
  place_precision text
);

CREATE OR REPLACE FUNCTION ae_add_compra_venta(
  id_document numeric,
  buyers json[],
  sellers json[],
  notaries json[],
  place numeric,
  place_precision text
)
RETURNS numeric as
$$
DECLARE
  _result record;
  _query text;
  _item json;

BEGIN

  PERFORM ae_add_person_batch(id_document, 'Notario'::text, notaries::jsonb[]);

  -- Crear lugar y precision del lugar
  IF place IS NOT NULL
  THEN
    _query := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Transacción');
    EXECUTE _query INTO _result;
    
    _query := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc) VALUES (%s, %L) RETURNING id_pertenencia', id_document, 'Transacción');
    EXECUTE _query INTO _result;

    _query := format('INSERT INTO pertenencia_rel_lugar (fk_lugar_id, fk_pertenencia_id, precision_pert_lugar) VALUES (%s, %s, %L) RETURNING *', place, _result.id_pertenencia, place_precision);
    EXECUTE _query INTO _result;
  END IF;

  RETURN id_document;
END;
$$ LANGUAGE plpgsql;
