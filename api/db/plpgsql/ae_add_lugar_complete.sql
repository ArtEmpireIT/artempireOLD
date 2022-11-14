DROP FUNCTION IF EXISTS ae_add_lugar_complete(id_lugar numeric, lugar text, tipo_lugar text, localizacion text, region_cont text, geom text, tipo_geom text);

CREATE OR REPLACE FUNCTION ae_add_lugar_complete(
  id_lugar numeric,
  lugar text,
  tipo_lugar text,
  localizacion text,
  region_cont text,
  geom text,
  tipo_geom text
)
RETURNS numeric AS
$$
DECLARE
  _r record;
  _r2 record;
  _q text;
  _id_geom numeric;
  fk_geom_name text;

BEGIN

  -- Creo el lugar
  id_lugar = (SELECT ae_add_lugar(lugar, id_lugar));

  -- Creo el tipo lugar
  IF tipo_lugar is NOT NULL THEN
    _q := format('INSERT INTO tipo_lugar (nombre) VALUES (%L) ON CONFLICT DO NOTHING RETURNING nombre', tipo_lugar);
    EXECUTE _q INTO _r;
  END IF;

  -- Borro geomtrías asociadas
  _q := format('SELECT fk_polygon_id, fk_line_id, fk_point_id FROM lugar WHERE id_lugar=%s', id_lugar);
  EXECUTE _q INTO _r2;

  -- Para evitar el borrado en cascada al borrar las geometrías asociadas
  _q := format('
    UPDATE lugar SET
    fk_point_id=NULL,
    fk_line_id=NULL,
    fk_polygon_id=NULL
    WHERE id_lugar=%s RETURNING id_lugar',
    id_lugar);
  EXECUTE _q INTO _r;

  _q := format('DELETE FROM point WHERE id_point=%s RETURNING *', coalesce(_r2.fk_point_id::text,'NULL'));
  EXECUTE _q INTO _r;
  _q := format('DELETE FROM line WHERE id_line=%s RETURNING *', coalesce(_r2.fk_line_id::text,'NULL'));
  EXECUTE _q INTO _r;
  _q := format('DELETE FROM polygon WHERE id_polygon=%s RETURNING *', coalesce(_r2.fk_polygon_id::text,'NULL'));
  EXECUTE _q INTO _r;

  -- Creo la geometría
  IF geom is NOT NULL THEN

    IF tipo_geom = 'Point' or tipo_geom = 'MULTIPOINT' THEN
      _q := format('INSERT INTO point (geom_wgs84) VALUES (ST_SetSRID(ST_GeomFromGeoJSON(%L),4326)) RETURNING id_point', geom);
      EXECUTE _q INTO _r;
      _id_geom = _r.id_point;
      fk_geom_name = 'fk_point_id';
    ELSIF tipo_geom = 'LineString' OR tipo_geom = 'MultiLineString' THEN
      _q := format('INSERT INTO line (geom_wgs84) VALUES (ST_SetSRID(ST_GeomFromGeoJSON(%L),4326)) RETURNING id_line', geom);
      EXECUTE _q INTO _r;
      _id_geom = _r.id_line;
      fk_geom_name = 'fk_line_id';
    ELSE
      _q := format('INSERT INTO polygon (geom_wgs84) VALUES (ST_SetSRID(ST_GeomFromGeoJSON(%L),4326)) RETURNING id_polygon', geom);
      EXECUTE _q INTO _r;
      _id_geom = _r.id_polygon;
      fk_geom_name = 'fk_polygon_id';
    END IF;

    _q := format('
      UPDATE lugar SET
      %s=%s
      WHERE id_lugar=%s RETURNING id_lugar',
      fk_geom_name, _id_geom, id_lugar);
    EXECUTE _q INTO _r;

  END IF;

  -- Actualizo el lugar
  _q := format('
    UPDATE lugar SET
      region_cont=%L,
      localizacion=%L,
      fk_tipo_lugar_nombre=%L
    WHERE id_lugar=%s RETURNING id_lugar',
    region_cont, localizacion, tipo_lugar, id_lugar);

  EXECUTE _q INTO _r;

  RETURN id_lugar;

END;
$$ LANGUAGE plpgsql;
