DROP FUNCTION IF EXISTS ae_add_persona_historica(numeric, text);
CREATE OR REPLACE FUNCTION ae_add_persona_historica(
  id_persona_historica numeric,
  nombre_persona_historica text
)
RETURNS numeric AS
$$
DECLARE
  _r record;
  _q text;

BEGIN

  -- Persona historica
  IF id_persona_historica IS NULL
  THEN
    _q := format('INSERT INTO persona_historica (nombre) VALUES (%L) RETURNING id_persona_historica', nombre_persona_historica);
  ELSE
    _q := format('UPDATE persona_historica SET nombre=%L WHERE id_persona_historica=%s RETURNING id_persona_historica', nombre_persona_historica, id_persona_historica);
  END IF;
  EXECUTE _q INTO _r;
  RAISE NOTICE '%', _q;
  IF _r.id_persona_historica IS NOT NULL
  THEN
    id_persona_historica = _r.id_persona_historica;
  END IF;
  -- RAISE NOTICE '%', id_persona_historica;

  RETURN id_persona_historica;

END;
$$ LANGUAGE plpgsql;

-- SELECT ae_add_persona_historica(NULL, 'Raúl Gómez');
-- SELECT ae_add_persona_historica(47, 'Raúl Gómezo');
--
