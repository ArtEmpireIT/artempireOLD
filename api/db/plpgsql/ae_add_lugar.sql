
CREATE OR REPLACE FUNCTION ae_add_lugar(
  lugar text,
  id_lugar numeric DEFAULT NULL
)
RETURNS numeric AS
$$
DECLARE
  _r record;
  _q text;

BEGIN

  -- Lugar
  IF lugar IS NOT NULL
  THEN

    IF id_lugar IS NULL
    THEN
      _q = format('INSERT INTO lugar (nombre) VALUES(%L) RETURNING id_lugar', lugar);
    ELSE
      _q = format('UPDATE lugar SET nombre=%L WHERE id_lugar=%s RETURNING id_lugar', lugar, id_lugar);
    END IF;
    RAISE NOTICE '%', _q;
    EXECUTE _q INTO _r;
    id_lugar = _r.id_lugar;
  END IF;

  RETURN id_lugar;

END;
$$ LANGUAGE plpgsql;



-- SELECT ae_add_lugar(12, 'Móstoles');
