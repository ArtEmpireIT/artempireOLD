DROP FUNCTION IF EXISTS ae_add_unidades_agrupacion(
  id_agrupacion numeric,
  units json[]
);

CREATE OR REPLACE FUNCTION ae_add_unidades_agrupacion(
  id_agrupacion numeric,
  units json[]
)
RETURNS numeric AS
$$
DECLARE

  _r record;
  _q text;
  _unit json;
  _unidad_nombre text;

BEGIN

  _q := format('DELETE FROM agrupacion_bienes_rel_unidad WHERE fk_agrupacion_bienes_id=%s RETURNING *', id_agrupacion);
  EXECUTE _q INTO _r;

  FOREACH _unit IN ARRAY units
  LOOP
    _unidad_nombre = (SELECT ae_add_unidad(_unit->>'nombre', _unit->>'type'));
    _q := format('INSERT INTO agrupacion_bienes_rel_unidad (fk_agrupacion_bienes_id, fk_unidad_nombre, valor) VALUES (%s, %L, %s) RETURNING fk_agrupacion_bienes_id', id_agrupacion, _unidad_nombre, _unit->>'value');
    EXECUTE _q INTO _r;
  END LOOP;

  RETURN id_agrupacion;

END;
$$ LANGUAGE plpgsql;
