DROP FUNCTION IF EXISTS ae_add_pertenencia_rel_lugar(numeric,text,text,text,text,text,text,text,numeric,numeric,json[],json[]);

CREATE OR REPLACE FUNCTION ae_add_pertenencia_rel_lugar(
  id_lugar numeric,
  lugar text,
  tipo_lugar text,
  campo text,
  localizacion text,
  region_cont text,
  geom text,
  tipo_geom text,
  id_pertenencia numeric,
  fk_documento_id numeric,

  peopleRelations json[],
  objectRelations json[]
)
RETURNS numeric AS
$$
DECLARE
  _r record;
  _r2 record;
  _q text;
  _id_geom numeric;
  fk_geom_name text;

  _relacion json;
  id_pertenencia_relacion numeric;
  _id_persona_rol_pertenencia_relacion numeric;

BEGIN

  -- -- Creo el lugar
  -- id_lugar = (SELECT ae_add_lugar(lugar, id_lugar));
  --
  -- -- Creo el tipo lugar
  -- IF tipo_lugar is NOT NULL THEN
  --   _q := format('INSERT INTO tipo_lugar (nombre) VALUES (%L) ON CONFLICT DO NOTHING RETURNING nombre', tipo_lugar);
  --   EXECUTE _q INTO _r;
  -- END IF;
  --
  -- -- Borro geomtrías asociadas
  -- _q := format('SELECT fk_polygon_id, fk_line_id, fk_point_id FROM lugar WHERE id_lugar=%s', id_lugar);
  -- EXECUTE _q INTO _r2;
  --
  -- -- Para evitar el borrado en cascada al borrar las geometrías asociadas
  -- _q := format('
  --   UPDATE lugar SET
  --   fk_point_id=NULL,
  --   fk_line_id=NULL,
  --   fk_polygon_id=NULL
  --   WHERE id_lugar=%s RETURNING id_lugar',
  --   id_lugar);
  -- EXECUTE _q INTO _r;
  --
  -- _q := format('DELETE FROM point WHERE id_point=%s RETURNING *', coalesce(_r2.fk_point_id::text,'NULL'));
  -- EXECUTE _q INTO _r;
  -- _q := format('DELETE FROM line WHERE id_line=%s RETURNING *', coalesce(_r2.fk_line_id::text,'NULL'));
  -- EXECUTE _q INTO _r;
  -- _q := format('DELETE FROM polygon WHERE id_polygon=%s RETURNING *', coalesce(_r2.fk_polygon_id::text,'NULL'));
  -- EXECUTE _q INTO _r;
  --
  -- -- Creo la geometría
  -- IF geom is NOT NULL THEN
  --
  --   IF tipo_geom = 'Point' or tipo_geom = 'MULTIPOINT' THEN
  --     _q := format('INSERT INTO point (geom_wgs84) VALUES (ST_SetSRID(ST_GeomFromGeoJSON(%L),4326)) RETURNING id_point', geom);
  --     EXECUTE _q INTO _r;
  --     _id_geom = _r.id_point;
  --     fk_geom_name = 'fk_point_id';
  --   ELSIF tipo_geom = 'LineString' OR tipo_geom = 'MultiLineString' THEN
  --     _q := format('INSERT INTO line (geom_wgs84) VALUES (ST_SetSRID(ST_GeomFromGeoJSON(%L),4326)) RETURNING id_line', geom);
  --     EXECUTE _q INTO _r;
  --     _id_geom = _r.id_line;
  --     fk_geom_name = 'fk_line_id';
  --   ELSE
  --     _q := format('INSERT INTO polygon (geom_wgs84) VALUES (ST_SetSRID(ST_GeomFromGeoJSON(%L),4326)) RETURNING id_polygon', geom);
  --     EXECUTE _q INTO _r;
  --     _id_geom = _r.id_polygon;
  --     fk_geom_name = 'fk_polygon_id';
  --   END IF;
  --
  --   _q := format('
  --     UPDATE lugar SET
  --     %s=%s
  --     WHERE id_lugar=%s RETURNING id_lugar',
  --     fk_geom_name, _id_geom, id_lugar);
  --   EXECUTE _q INTO _r;
  --
  -- END IF;
  --
  -- -- Actualizo el lugar
  -- _q := format('
  --   UPDATE lugar SET
  --     region_cont=%L,
  --     localizacion=%L,
  --     fk_tipo_lugar_nombre=%L
  --   WHERE id_lugar=%s RETURNING id_lugar',
  --   region_cont, localizacion, tipo_lugar, id_lugar);
  --
  -- EXECUTE _q INTO _r;

  -- Creo la pertenencia
  IF id_pertenencia IS NULL
  THEN
    _q := format('
      INSERT INTO
       pertenencia(tipo_atr_doc, fk_documento_id)
       VALUES (%L, %s)
      RETURNING id_pertenencia',
       campo, fk_documento_id);
       EXECUTE _q INTO _r;
       id_pertenencia := _r.id_pertenencia;

       -- Creo pertenencia rel lugar
       _q := format('
         INSERT INTO
          pertenencia_rel_lugar(fk_pertenencia_id, fk_lugar_id)
          VALUES (%s, %s)
         RETURNING *',
          id_pertenencia, id_lugar);
       EXECUTE _q INTO _r;

  ELSE
    _q := format('
      UPDATE pertenencia SET
        tipo_atr_doc=%L
      WHERE id_pertenencia=%s
      RETURNING id_pertenencia',
      campo, id_pertenencia);
      EXECUTE _q INTO _r;
  END IF;

  --Relaciones con personas

  _q := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND id_pertenencia in(
                SELECT p.id_pertenencia
                FROM persona_rol_pertenencia_rel_lugar prpl
                LEFT JOIN persona_rol_pertenencia prp on prp.id_persona_rol_pertenencia = prpl.fk_persona_rol_pertenencia_id
                LEFT JOIN pertenencia p on p.id_pertenencia = prp.fk_pertenencia_id
                WHERE p.fk_documento_id = %s AND prpl.fk_lugar_id = %s)
                RETURNING *', fk_documento_id, fk_documento_id, id_lugar);

  EXECUTE _q INTO _r;

  FOREACH _relacion IN ARRAY peopleRelations
  LOOP
    _q := format('INSERT INTO pertenencia (fk_documento_id, motivo) VALUES (%s, %L) RETURNING id_pertenencia', fk_documento_id, 'Creación de relación');
    EXECUTE _q INTO _r;
    id_pertenencia_relacion := _r.id_pertenencia;

    _q := format('INSERT INTO persona_rol_pertenencia (fk_persona_historica_id, fk_pertenencia_id, descripcion, is_relation) VALUES (%s, %s, %L, %L) RETURNING id_persona_rol_pertenencia', _relacion->>'id', id_pertenencia_relacion, _relacion->>'descripcion', true);
    EXECUTE _q INTO _r;
    _id_persona_rol_pertenencia_relacion := _r.id_persona_rol_pertenencia;

    _q := format('INSERT INTO persona_rol_pertenencia_rel_lugar (fk_persona_rol_pertenencia_id, fk_lugar_id) VALUES (%s, %s) RETURNING *', _id_persona_rol_pertenencia_relacion, id_lugar);
    EXECUTE _q INTO _r;

  END LOOP;

  --Relaciones con objetos
  _q := format(' DELETE FROM linea_rel_lugar WHERE fk_lugar_id=%s RETURNING *', id_lugar);
  EXECUTE _q INTO _r;

  FOREACH _relacion IN ARRAY objectRelations
  LOOP
    _q := format('INSERT INTO linea_rel_lugar (fk_linea_id, fk_lugar_id, descripcion_lugar) VALUES (%s, %s, %L) RETURNING *', _relacion->>'id', id_lugar, _relacion->>'descripcion');
    EXECUTE _q INTO _r;

  END LOOP;

  RETURN id_lugar;

END;
$$ LANGUAGE plpgsql;
