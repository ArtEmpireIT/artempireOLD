
DROP FUNCTION IF EXISTS ae_add_agrupacion_bienes(numeric, numeric, text, date, text, text, text, text, text, numeric, numeric);
CREATE OR REPLACE FUNCTION ae_add_agrupacion_bienes(
  id_agrupacion_bienes numeric,
  id_pertenencia numeric,
  nombre text,
  fecha date,
  precision_fecha text,
  adelanto text,
  descripcion text,
  folio text,
  precision_lugar text,
  id_metodo_pago numeric,
  id_lugar numeric
)
RETURNS numeric AS
$$
DECLARE
  _r record;
  _q text;

BEGIN
  
  IF id_agrupacion_bienes IS NULL
  THEN
    _q = format('INSERT INTO agrupacion_bienes
      (nombre, fecha, precision_fecha, adelanto_cont, descripcion_cont, folio_cont, precision_lugar,fk_metodo_pago_id,fk_lugar_id)
      VALUES(''%s'', %L::date,
        ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', %s, %s) RETURNING id_agrupacion_bienes',
      nombre, fecha,
        precision_fecha,
        adelanto,
        descripcion,
        folio,
        precision_lugar,
        quote_nullable(id_metodo_pago),
        quote_nullable(id_lugar)
    );
  ELSE
    _q = format('UPDATE agrupacion_bienes SET
        nombre=''%s'',
        fecha=%L::date,
        precision_fecha=''%s'',
        adelanto_cont=''%s'',
        descripcion_cont=''%s'',
        folio_cont=''%s'',
        fk_metodo_pago_id=%s,
        precision_lugar=''%s'',
        fk_lugar_id=%s WHERE id_agrupacion_bienes=%s RETURNING id_agrupacion_bienes',
        nombre, fecha, precision_fecha, adelanto, descripcion, folio, quote_nullable(id_metodo_pago), precision_lugar, quote_nullable(id_lugar), id_agrupacion_bienes);
  END IF;

  EXECUTE _q INTO _r;
  id_agrupacion_bienes = _r.id_agrupacion_bienes;

  IF id_pertenencia IS NOT NULL
  THEN
    _q := format('DELETE FROM pertenencia_rel_agrupacion_bienes WHERE fk_pertenencia_id=%s AND fk_agrupacion_bienes_id=%L RETURNING fk_agrupacion_bienes_id', id_pertenencia, id_agrupacion_bienes);
    EXECUTE _q INTO _r;
    _q := format('INSERT INTO pertenencia_rel_agrupacion_bienes (fk_pertenencia_id, fk_agrupacion_bienes_id) VALUES (%s, %s) RETURNING fk_agrupacion_bienes_id', id_pertenencia, id_agrupacion_bienes);
    EXECUTE _q INTO _r;
  END IF;

  RETURN id_agrupacion_bienes;

END;
$$ LANGUAGE plpgsql;
--
--


-- INSERT INTO agrupacion_bienes
--       (nombre, fecha, precision_fecha, adelanto_cont, descripcion_cont, folio_cont, precision_lugar,fk_metodo_pago_id,fk_lugar_id)
--       VALUES('Desglose', '2017-08-11'::date, '<', 'Adelanto de 4', 'asdf', '43', 'Referencia - Zona - Edificio', NULL, 17) RETURNING id_agrupacion_bienes
