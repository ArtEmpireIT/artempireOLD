DROP FUNCTION IF EXISTS ae_add_material(text, numeric, numeric);
CREATE OR REPLACE FUNCTION ae_add_material(
  material text,
  id_material numeric DEFAULT NULL,
  fk_material_id numeric DEFAULT NULL
)
RETURNS numeric AS
$$
DECLARE
  _r record;
  _q text;
  _id integer;

BEGIN

  -- Material
  IF material IS NOT NULL
  THEN
    _id := (SELECT m.id_material from material m where lower(m.nombre) = lower(material) LIMIT 1);
    IF _id IS NOT NULL
    THEN
      id_material = _id;
    END IF;

    IF id_material IS NULL
    THEN
      _q := format('INSERT INTO
        material (nombre, fk_material_id) VALUES (''%s'', %s)
        RETURNING id_material',
        lower(material), quote_nullable(fk_material_id));
    ELSE
      _q := format('UPDATE material SET nombre=''%s'', fk_material_id=%s WHERE id_material=%s RETURNING id_material',
          lower(material), quote_nullable(fk_material_id), id_material);
    END IF;

    EXECUTE _q INTO _r;
    id_material = _r.id_material;

  END IF;


  RETURN id_material;

END;
$$ LANGUAGE plpgsql;

-- SELECT ae_add_material('Alpaca', NULL, 87);
