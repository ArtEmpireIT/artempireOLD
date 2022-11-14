DROP FUNCTION IF EXISTS ae_add_lote_entierro(
  id_entierro numeric,
  unid_estratigrafica text,
  fk_genero_lote_nombre text,
  fk_edad_lote_nombre text,
  cantidad numeric
);

CREATE OR REPLACE FUNCTION ae_add_lote_entierro(
  id_entierro numeric,
  unid_estratigrafica text,
  fk_genero_lote_nombre text,
  fk_edad_lote_nombre text,
  cantidad numeric
)
RETURNS numeric AS
$$
DECLARE
  _r record;
  _q text;
  _id_lote numeric;

BEGIN

  -- Creo el lote
  _q := format('INSERT INTO lote (unid_estratigrafica) VALUES (%L) RETURNING id_lote', unid_estratigrafica);
  EXECUTE _q INTO _r;
  _id_lote = _r.id_lote;

  --Creo el entierro_rel_lote
  _q := format('INSERT INTO entierro_rel_lote (fk_entierro_id, fk_lote_id) VALUES (%s, %s) RETURNING *', id_entierro, _id_lote);
  EXECUTE _q INTO _r;

  --Creo el lote_genero_edad
  _q := format('INSERT INTO lote_genero_edad (fk_lote_id, fk_genero_lote_nombre, fk_edad_lote_nombre, cantidad) VALUES (%s, %L, %L, %L) RETURNING *', _id_lote, fk_genero_lote_nombre, fk_edad_lote_nombre, cantidad);
  EXECUTE _q INTO _r;

  RETURN _id_lote;

END;
$$ LANGUAGE plpgsql;
