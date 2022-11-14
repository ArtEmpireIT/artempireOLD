DROP FUNCTION IF EXISTS ae_add_persona_rol_pertenencia(numeric, text, text, numeric, date, date, text, text, text, numeric, numeric, numeric, numeric, text, text, text[], text[], text[], numeric, text, text, date, text, numeric, text, json[], json[], json[]);

CREATE OR REPLACE FUNCTION ae_add_persona_rol_pertenencia(
  id_persona_historica numeric,
  nombre_persona_historica text,
  genero text,

  id_pertenencia numeric,
  fecha_inicio date,
  fecha_fin date,
  precision_inicio text,
  precision_fin text,
  campo text,
  fk_documento_id numeric,

  id_persona_rol_pertenencia numeric,
  edad_min numeric,
  edad_max numeric,
  descripcion text,
  edad_recodificada text,

  roles text[],
  cargos text[],
  ocupaciones text[],

  id_lugar numeric,
  lugar text,

  nombre_institucion text,
  fecha_creacion_institucion date,
  descripcion_institucion text,
  id_lugar_institucion numeric,
  lugar_institucion text,

  objectRelations json[],
  placeRelations json[],
  peopleRelations json[]

)
RETURNS numeric AS
$$
DECLARE

  _r record;
  _q text;
  _rol text;
  _cargo text;
  _ocupacion text;
  _id_pertenencia_anonima numeric;
  _id_persona_rol_pertenencia_institucion numeric;
  _relacion json;
  _person json;
  id_pertenencia_relacion numeric;
  _id_persona_rol_pertenencia_relacion numeric;
  _pertenencias_relacion_personas numeric[];
  _id_linea numeric;
  _id_objeto numeric;
  _sql_stmt text;
  _descripcion_relacion_objetos text[];
  _iterator numeric;

BEGIN
  -- Creo la persona histórica
  id_persona_historica = (SELECT ae_add_persona_historica(id_persona_historica, nombre_persona_historica));
  -- IF id_pertenencia IS NOT NULL
  -- THEN
    _q := format('
      UPDATE persona_historica SET
        genero=%L
      WHERE id_persona_historica=%s RETURNING id_persona_historica',
      genero, id_persona_historica);

    EXECUTE _q INTO _r;
  -- END IF;

  -- Creo la pertenencia
  IF id_pertenencia IS NULL
  THEN
    _q := format('
      INSERT INTO
       pertenencia(fecha_inicio, fecha_fin, precision_inicio, precision_fin, tipo_atr_doc, fk_documento_id)
       VALUES (%L::date, %L::date, %L, %L, %L, %s)
      RETURNING id_pertenencia',
       fecha_inicio, fecha_fin, precision_inicio, precision_fin, campo, fk_documento_id);

  ELSE
    _q := format('
      UPDATE pertenencia SET
        fecha_inicio=%L::date,
        fecha_fin=%L::date,
        precision_inicio=%L,
        precision_fin=%L,
        tipo_atr_doc=%L
      WHERE id_pertenencia=%s
      RETURNING id_pertenencia',
      fecha_inicio, fecha_fin, precision_inicio, precision_fin, campo, id_pertenencia);
  END IF;
  EXECUTE _q INTO _r;
  id_pertenencia := _r.id_pertenencia;

  -- Creo la persona_rol_pertenencia
  IF id_persona_rol_pertenencia IS NULL
  THEN
    _q := format('
      INSERT INTO
       persona_rol_pertenencia(edad_min, edad_max, descripcion, edad_recodificada, fk_persona_historica_id, fk_pertenencia_id)
       VALUES (%s, %s, %L, %L, %s, %s)
      RETURNING id_persona_rol_pertenencia',
       coalesce(edad_min::text,'NULL'), coalesce(edad_max::text,'NULL'), descripcion, edad_recodificada, id_persona_historica, id_pertenencia);

  ELSE
    _q := format('
      UPDATE persona_rol_pertenencia SET
        edad_min=%s,
        edad_max=%s,
        descripcion=%L,
        edad_recodificada=%L
      WHERE id_persona_rol_pertenencia=%s
      RETURNING id_persona_rol_pertenencia',
      coalesce(edad_min::text,'NULL'), coalesce(edad_max::text,'NULL'), descripcion, edad_recodificada, id_persona_rol_pertenencia);
  END IF;
  EXECUTE _q INTO _r;
  id_persona_rol_pertenencia := _r.id_persona_rol_pertenencia;

  -- Creo los roles
  _q := format('DELETE FROM persona_rol_pertenencia_rel_rol WHERE fk_persona_rol_pertenencia=%s RETURNING *', id_persona_rol_pertenencia);
  EXECUTE _q INTO _r;

  FOREACH _rol IN ARRAY roles
  LOOP
    _q := format('INSERT INTO rol (nombre) VALUES (%L) ON CONFLICT DO NOTHING RETURNING nombre', _rol);
    EXECUTE _q INTO _r;
    _q := format('INSERT INTO persona_rol_pertenencia_rel_rol (fk_rol_nombre, fk_persona_rol_pertenencia)
      VALUES (%L, %s) RETURNING *', _rol, id_persona_rol_pertenencia);
    EXECUTE _q INTO _r;
  END LOOP;

  --Creo los cargos
  _q := format('DELETE FROM persona_rol_pertenencia_rel_cargo WHERE fk_persona_rol_pertenencia_id=%s RETURNING *', id_persona_rol_pertenencia);
  EXECUTE _q INTO _r;

  FOREACH _cargo IN ARRAY cargos
  LOOP
    _q := format('INSERT INTO cargo (nombre) VALUES (%L) ON CONFLICT DO NOTHING RETURNING nombre', _cargo);
    EXECUTE _q INTO _r;
    _q := format('INSERT INTO persona_rol_pertenencia_rel_cargo (fk_cargo_nombre, fk_persona_rol_pertenencia_id)
      VALUES (%L, %s) RETURNING *', _cargo, id_persona_rol_pertenencia);
    EXECUTE _q INTO _r;
  END LOOP;

  --Creo las ocupaciones
  _q := format('DELETE FROM persona_rol_pertenencia_rel_ocupacion WHERE fk_persona_rol_pertenencia_id=%s RETURNING *', id_persona_rol_pertenencia);
  EXECUTE _q INTO _r;

  FOREACH _ocupacion IN ARRAY ocupaciones
  LOOP
    _q := format('INSERT INTO ocupacion (nombre) VALUES (%L) ON CONFLICT DO NOTHING RETURNING nombre', _ocupacion);
    EXECUTE _q INTO _r;
    _q := format('INSERT INTO persona_rol_pertenencia_rel_ocupacion (fk_ocupacion_nombre, fk_persona_rol_pertenencia_id)
      VALUES (%L, %s) RETURNING *', _ocupacion, id_persona_rol_pertenencia);
    EXECUTE _q INTO _r;
  END LOOP;

  --Creo el lugar origen
  _q := format('DELETE FROM persona_rol_pertenencia_rel_lugar WHERE fk_persona_rol_pertenencia_id=%s RETURNING *', id_persona_rol_pertenencia);
  EXECUTE _q INTO _r;
  id_lugar = (SELECT ae_add_lugar(lugar, id_lugar));

  IF id_lugar IS NOT NULL
  THEN
    _q := format('INSERT INTO persona_rol_pertenencia_rel_lugar (fk_lugar_id, fk_persona_rol_pertenencia_id)
      VALUES (%s, %s) RETURNING *', id_lugar, id_persona_rol_pertenencia);
    EXECUTE _q INTO _r;
  END IF;

  --Creo la institucion
  _q := format('SELECT ph.id_persona_historica FROM persona_historica ph WHERE ph.nombre=''Anónimo'' ORDER BY id_persona_historica LIMIT 1');
  EXECUTE _q INTO _r;
  _id_pertenencia_anonima = _r.id_persona_historica;

  IF _id_pertenencia_anonima IS NULL
  THEN
    _q := format('INSERT INTO persona_historica (nombre) VALUES (''Anónimo'') ON CONFLICT DO NOTHING RETURNING id_persona_historica');
    EXECUTE _q INTO _r;
    _id_pertenencia_anonima := _r.id_persona_historica;
  END IF;

  _q := format('DELETE FROM persona_rol_pertenencia WHERE fk_persona_historica_id=%s AND fk_persona_rol_pertenencia_id=%s RETURNING *', _id_pertenencia_anonima, id_persona_rol_pertenencia);
  EXECUTE _q INTO _r;

  _q := format('DELETE FROM persona_rol_pertenencia_rel_institucion WHERE fk_persona_rol_pertenencia_id=%s RETURNING *', id_persona_rol_pertenencia);
  EXECUTE _q INTO _r;

  IF nombre_institucion IS NOT NULL
  THEN
    _q := format('INSERT INTO institucion (nombre) VALUES (%L) ON CONFLICT DO NOTHING RETURNING nombre', nombre_institucion);
    EXECUTE _q INTO _r;
    _q := format('
      UPDATE institucion SET
        fecha_creacion=%L::date,
        descripcion=%L
      WHERE nombre=%L RETURNING nombre',
      fecha_creacion_institucion, descripcion_institucion, nombre_institucion);
    EXECUTE _q INTO _r;

    _q := format('INSERT INTO persona_rol_pertenencia (fk_persona_historica_id, fk_persona_rol_pertenencia_id)
      VALUES (%s, %s) RETURNING id_persona_rol_pertenencia', _id_pertenencia_anonima, id_persona_rol_pertenencia);
    EXECUTE _q INTO _r;
    _id_persona_rol_pertenencia_institucion := _r.id_persona_rol_pertenencia;

    id_lugar_institucion = (SELECT ae_add_lugar(lugar_institucion, id_lugar_institucion));

    IF id_lugar_institucion IS NOT NULL
    THEN
      _q := format('INSERT INTO persona_rol_pertenencia_rel_lugar (fk_lugar_id, fk_persona_rol_pertenencia_id)
        VALUES (%s, %s) RETURNING *', id_lugar_institucion, _id_persona_rol_pertenencia_institucion);
      EXECUTE _q INTO _r;
    END IF;

    _q := format('INSERT INTO persona_rol_pertenencia_rel_institucion (fk_persona_rol_pertenencia_id, fk_institucion_nombre)
      VALUES (%s, %L) RETURNING *', id_persona_rol_pertenencia, nombre_institucion);
    EXECUTE _q INTO _r;

  END IF;

  --Relaciones con objetos

  -- Guardar las descripciones de las relaciones de objetos antes de eliminar
  --_q := format('SELECT ARRAY(SELECT descripcion::TEXT
  --              FROM persona_rol_pertenencia
  --              WHERE fk_persona_historica_id=%s AND fk_pertenencia_id IN (SELECT id_pertenencia FROM pertenencia WHERE fk_documento_id=%s)
  --              ORDER BY id_persona_rol_pertenencia)',id_persona_historica,fk_documento_id);
  --EXECUTE _q INTO _descripcion_relacion_objetos;
  
  -- Nuevo
  --_descripcion_relacion_objetos = ARRAY[]::text[];
  --FOREACH _relacion IN ARRAY objectRelations
  --LOOP
  --  _descripcion_relacion_objetos = _descripcion_relacion_objetos || (_relacion->>'descripcion')::text;
  --END LOOP;
  --RAISE LOG '%s', _descripcion_relacion_objetos;

  -- Eliminar las relaciones con objetos.
  _q := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND id_pertenencia in(
                SELECT prp.fk_pertenencia_id
                FROM persona_rol_pertenencia_rel_linea prpl
                LEFT JOIN persona_rol_pertenencia prp on prp.id_persona_rol_pertenencia = prpl.fk_persona_rol_pertenencia_id
                WHERE prp.fk_persona_historica_id = %s) RETURNING *', fk_documento_id, id_persona_historica);
  EXECUTE _q INTO _r;
  
  _q := format('DELETE FROM persona_rol_pertenencia_rel_linea WHERE fk_persona_rol_pertenencia_id = %s RETURNING *', id_persona_rol_pertenencia);
  EXECUTE _q INTO _r;

  --_iterator := 0;
  FOREACH _relacion IN ARRAY objectRelations
  LOOP
    
    -- Insertar una pertenencia por cada relacion de objetos.
    _q := format('INSERT INTO pertenencia (fk_documento_id, motivo) VALUES (%s, %L) RETURNING id_pertenencia', fk_documento_id, 'Creación de relación');
    EXECUTE _q INTO _r;
    id_pertenencia_relacion := _r.id_pertenencia;

    -- Insertar persona_rol_pertenencia con las descripciones previamente guardadas.
    _q := format('INSERT INTO persona_rol_pertenencia (fk_persona_historica_id, fk_pertenencia_id, descripcion, is_relation) VALUES (%s, %s, %L, true) RETURNING id_persona_rol_pertenencia', id_persona_historica, id_pertenencia_relacion, _relacion->>'descripcion');
    --_q := format('INSERT INTO persona_rol_pertenencia (fk_persona_historica_id, fk_pertenencia_id, descripcion, is_relation) VALUES (%s, %s, %L, true) RETURNING id_persona_rol_pertenencia', id_persona_historica, id_pertenencia_relacion, _descripcion_relacion_objetos[_iterator]);
    EXECUTE _q INTO _r;
    _id_persona_rol_pertenencia_relacion := _r.id_persona_rol_pertenencia;

    -- Obtener ID de la linea para agregar relaciones de Objetos
    _sql_stmt := format('SELECT id_linea FROM linea l WHERE l.fk_objeto_id = %s AND l.fk_agrupacion_bienes_id IN ( SELECT fk_agrupacion_bienes_id FROM pertenencia_rel_agrupacion_bienes WHERE fk_pertenencia_id IN ( SELECT id_pertenencia FROM pertenencia WHERE fk_documento_id = %s))',_relacion->'id', fk_documento_id);
    EXECUTE _sql_stmt INTO _id_linea;

    IF _id_linea IS NOT NULL
    THEN
      _q := format('INSERT INTO persona_rol_pertenencia_rel_linea (fk_persona_rol_pertenencia_id, fk_linea) VALUES (%s, %s) RETURNING *', _id_persona_rol_pertenencia_relacion, _id_linea);
      EXECUTE _q INTO _r;
    ELSE
      _q := format('INSERT INTO persona_rol_pertenencia_rel_linea (fk_persona_rol_pertenencia_id, fk_linea) VALUES (%s, %s) RETURNING *', _id_persona_rol_pertenencia_relacion, _relacion->'id');
      EXECUTE _q INTO _r;
    END IF;

    --_iterator := _iterator + 1;

  END LOOP;


  --Relaciones con lugares

  _q := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND id_pertenencia in(
                SELECT prp.fk_pertenencia_id
                FROM persona_rol_pertenencia_rel_lugar prpl
                LEFT JOIN persona_rol_pertenencia prp on prp.id_persona_rol_pertenencia = prpl.fk_persona_rol_pertenencia_id
                WHERE prp.fk_persona_historica_id=%s AND prp.fk_pertenencia_id != %s) RETURNING *', fk_documento_id, id_persona_historica, id_pertenencia);

  EXECUTE _q INTO _r;

  FOREACH _relacion IN ARRAY placeRelations
  LOOP
    _q := format('INSERT INTO pertenencia (fk_documento_id, motivo) VALUES (%s, %L) RETURNING id_pertenencia', fk_documento_id, 'Creación de relación');
    EXECUTE _q INTO _r;
    id_pertenencia_relacion := _r.id_pertenencia;

    _q := format('INSERT INTO persona_rol_pertenencia (fk_persona_historica_id, fk_pertenencia_id, descripcion, is_relation) VALUES (%s, %s, %L, true) RETURNING id_persona_rol_pertenencia', id_persona_historica, id_pertenencia_relacion, _relacion->>'descripcion');
    EXECUTE _q INTO _r;
    _id_persona_rol_pertenencia_relacion := _r.id_persona_rol_pertenencia;

    _q := format('INSERT INTO persona_rol_pertenencia_rel_lugar (fk_persona_rol_pertenencia_id, fk_lugar_id) VALUES (%s, %s) RETURNING *', _id_persona_rol_pertenencia_relacion, _relacion->'id');
    EXECUTE _q INTO _r;

  END LOOP;


  --Relaciones con personas

  -- _q := format('DELETE FROM pertenencia 
  --   WHERE fk_documento_id=%s AND id_pertenencia in (
  --     (
  --       SELECT p.id_pertenencia
  --       FROM persona_rol_pertenencia prpb
  --       LEFT JOIN pertenencia p on p.id_pertenencia = prpb.fk_pertenencia_id
  --       LEFT JOIN persona_rol_pertenencia prpa on prpa.id_persona_rol_pertenencia = prpb.fk_persona_rol_pertenencia_id
  --       WHERE p.fk_documento_id = %s AND prpa.fk_persona_historica_id = %s
  --       AND prpa.is_relation = true AND prpb.is_relation = true
  --     ) UNION ALL (
  --       SELECT p.id_pertenencia
  --       FROM persona_rol_pertenencia prpb
  --       LEFT JOIN pertenencia p on p.id_pertenencia = prpb.fk_pertenencia_id
  --       INNER JOIN persona_rol_pertenencia prpa on prpa.id_persona_rol_pertenencia = prpb.fk_persona_rol_pertenencia_id
  --       WHERE p.fk_documento_id = %s AND prpb.fk_persona_historica_id = %s
  --       AND prpa.is_relation = true AND prpb.is_relation = true
  --     )
  --   ) RETURNING *', 
  --   fk_documento_id, 
  --   fk_documento_id, 
  --   id_persona_historica, 
  --   fk_documento_id, 
  --   id_persona_historica);

  _pertenencias_relacion_personas = ARRAY[]::numeric[];
  FOREACH _person IN ARRAY peopleRelations
  LOOP
    _pertenencias_relacion_personas = _pertenencias_relacion_personas || (_person->>'id_pertenencia')::numeric;
  END LOOP;

  _q := format('DELETE FROM persona_rol_pertenencia prp
    WHERE prp.id_persona_rol_pertenencia IN (
      SELECT prp_destination.id_persona_rol_pertenencia
      FROM persona_rol_pertenencia prp_origin
      JOIN persona_rol_pertenencia prp_destination
        ON prp_destination.fk_persona_rol_pertenencia_id = prp_origin.id_persona_rol_pertenencia
      WHERE prp_destination.fk_pertenencia_id != ANY(%L)
        AND prp_origin.fk_pertenencia_id = %s
        AND prp_origin.is_relation = TRUE
        AND prp_destination.is_relation = TRUE

      UNION ALL

      SELECT prp_origin.id_persona_rol_pertenencia
      FROM persona_rol_pertenencia prp_origin
      JOIN persona_rol_pertenencia prp_destination
        ON prp_destination.id_persona_rol_pertenencia = prp_origin.fk_persona_rol_pertenencia_id
      WHERE prp_destination.fk_pertenencia_id != ANY(%L)
        AND prp_origin.fk_pertenencia_id = %s
        AND prp_origin.is_relation = TRUE
        AND prp_destination.is_relation = TRUE
    ) RETURNING *
  ', _pertenencias_relacion_personas, id_pertenencia, _pertenencias_relacion_personas, id_pertenencia);

  EXECUTE _q INTO _r;

  FOREACH _relacion IN ARRAY peopleRelations
  LOOP

    IF (_relacion->>'changedRelationOrder')::BOOLEAN = TRUE
    THEN
      PERFORM ae_add_relacion_persona_persona(
        (_relacion->>'id_pertenencia')::numeric,
        (_relacion->>'id_persona_historica')::numeric,
        id_pertenencia,
        id_persona_historica,
        _relacion->>'descripcion'
      );
    ELSE
      PERFORM ae_add_relacion_persona_persona(
        id_pertenencia,
        id_persona_historica,
        (_relacion->>'id_pertenencia')::numeric,
        (_relacion->>'id_persona_historica')::numeric,
        _relacion->>'descripcion'
      );
    END IF;

  END LOOP;


  RETURN id_persona_rol_pertenencia;

END;
$$ LANGUAGE plpgsql;
