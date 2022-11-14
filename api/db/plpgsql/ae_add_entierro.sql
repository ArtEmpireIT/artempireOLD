CREATE OR REPLACE FUNCTION public.ae_add_entierro (
  id_entierro numeric,
  nomenclatura_sitio text,
  lugar text, 
  anio_fecha text,
  fk_espacio text, -- esto campo debe usarse para guardar una relacion con espacio_entierro
  estructura text,
  forma text, 
  largo numeric,
  ancho numeric,
  profundidad numeric,
  observaciones text,
  place_geometry text
)
RETURNS numeric AS
$BODY$
DECLARE
  _r record;
  _q text;

BEGIN
  -- (Geom_x, geom_y, geom_coords_ref) lo hemos sustituido por un parametro 'geom' global para poder incorporarlo a la tabla 'Entierro'

  -- Entierro
  IF id_entierro is NULL 
  THEN
     _q := format('INSERT INTO entierro(nomenclatura_sitio, lugar, fk_espacio_nombre, estructura, forma, largo, ancho, profundidad, observaciones, anio_fecha, place_geometry) 
            VALUES (%L, %L, %L, %L, %L, %s, %s, %s, %L, %L, ST_SetSRID(ST_GeomFromGeoJSON(%L),4326)) 
            RETURNING id_entierro', nomenclatura_sitio, lugar, fk_espacio, estructura, 
            forma, largo, ancho, profundidad, observaciones, anio_fecha, place_geometry);

  ELSE
    _q := format('UPDATE entierro 
    SET nomenclatura_sitio=%L, lugar=%L, fk_espacio_nombre=%L, estructura=%L, forma=%L, largo=%s, ancho=%s, profundidad=%s, observaciones=%L, anio_fecha=%L, place_geometry=ST_SetSRID(ST_GeomFromGeoJSON(%L),4326) 
    WHERE id_entierro=%s RETURNING id_entierro', nomenclatura_sitio, lugar, fk_espacio, estructura, forma, largo, ancho, profundidad, observaciones, anio_fecha, place_geometry, id_entierro);
  END IF;
  EXECUTE _q INTO _r;

  RAISE NOTICE '%', _q;
  IF _r.id_entierro IS NOT NULL
  THEN
    id_entierro = _r.id_entierro;
  END IF;
  
  RETURN id_entierro;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.ae_add_entierro(numeric, text, text, text, text, text, text, numeric, numeric, numeric, text, text)
  OWNER TO geographica;