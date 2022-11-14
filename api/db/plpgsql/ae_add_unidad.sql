DROP FUNCTION IF EXISTS ae_add_unidad(text, text);
CREATE OR REPLACE FUNCTION ae_add_unidad(
  unidad text,
  tipo text
)
RETURNS text AS
$$
DECLARE
  _r record;
  _q text;
  _documento record;
BEGIN

  -- Unidad
  _q = format('INSERT INTO unidad (nombre, tipo) VALUES (''%s'',''%s'') ON CONFLICT DO NOTHING RETURNING nombre', unidad, tipo);
  raise notice '%', _q;
  EXECUTE _q INTO _r;
  IF _r.nombre IS NULL
  THEN
    RETURN unidad;
  ELSE
    RETURN _r.nombre;
  END IF;

END;
$$ LANGUAGE plpgsql;



-- SELECT ae_add_desglose(124, NULL, NULL, NULL, 'Juan Andante','Marginalia','Marginalia, 124');
