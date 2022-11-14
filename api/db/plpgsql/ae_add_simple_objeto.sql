DROP FUNCTION IF EXISTS ae_add_simple_objeto(numeric, text, text);
CREATE OR REPLACE FUNCTION ae_add_simple_objeto(
  objeto text,
  id_objeto numeric DEFAULT NULL,
  fk_objeto_id numeric DEFAULT NULL
)
RETURNS numeric AS
$$
DECLARE
  _r record;
  _q text;
  _id integer;

BEGIN

  -- RAISE NOTICE '%', objeto;

  -- Objeto
  IF objeto IS NOT NULL
  THEN
    _id := (SELECT o.id_objeto from objeto o where lower(o.nombre) = lower(objeto) LIMIT 1);
    IF _id IS NOT NULL
    THEN
      id_objeto = _id;
    ELSE
      _q := format('INSERT INTO objeto (nombre, fk_objeto_id) VALUES (''%s'', %s) ON CONFLICT (nombre) DO UPDATE SET nombre = ''%s'' RETURNING id_objeto', lower(objeto), quote_nullable(fk_objeto_id), lower(objeto));
      EXECUTE _q INTO _r;
      id_objeto = _r.id_objeto;
    END IF;
    
  END IF;

  RETURN id_objeto;

END;
$$ LANGUAGE plpgsql;

-- SELECT ae_add_simple_objeto(NULL);
-- SELECT ae_add_persona_historica(NULL, 'Raúl Gómez');
-- SELECT ae_add_persona_historica(47, 'Raúl Gómezo');
--
