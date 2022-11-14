DROP FUNCTION IF EXISTS ae_add_persona(numeric, numeric, numeric, numeric, text, text, text);
DROP FUNCTION IF EXISTS ae_add_persona(numeric, numeric, numeric, numeric, text, text, text, text);
DROP FUNCTION IF EXISTS ae_add_persona(numeric, numeric, numeric, numeric, text, text, text, text, text);
DROP FUNCTION IF EXISTS ae_add_persona(numeric, numeric, numeric, numeric, text, text, text, text, text, boolean);
DROP FUNCTION IF EXISTS ae_add_persona(numeric, numeric, numeric, numeric, text, text, text, text, text, boolean, numeric);
DROP FUNCTION IF EXISTS ae_add_persona(numeric, numeric, numeric, numeric, text, text, text, text, text, boolean, numeric, text, boolean);
DROP FUNCTION IF EXISTS ae_add_persona(numeric, text, text);

CREATE OR REPLACE FUNCTION ae_add_persona(
  id_persona_historica numeric,
  nombre_persona_historica text,
  genero text DEFAULT NULL
)
RETURNS numeric AS
$$
DECLARE
  _r record;
  _q text;
BEGIN

  id_persona_historica := (SELECT ae_add_persona_historica(id_persona_historica, nombre_persona_historica));

  _q := format('
    UPDATE persona_historica SET genero=%L WHERE id_persona_historica=%s RETURNING id_persona_historica
  ', genero, id_persona_historica);

  EXECUTE _q INTO _r;

  RETURN id_persona_historica;

END;
$$ LANGUAGE plpgsql;
