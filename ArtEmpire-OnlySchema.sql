--
-- PostgreSQL database dump
--

-- Dumped from database version 10.8 (Debian 10.8-1.pgdg90+1)
-- Dumped by pg_dump version 10.8 (Debian 10.8-1.pgdg90+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pruebas; Type: SCHEMA; Schema: -; Owner: geographica
--

CREATE SCHEMA pruebas;


ALTER SCHEMA pruebas OWNER TO geographica;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: adminpack; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS adminpack WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION adminpack; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION adminpack IS 'administrative functions for PostgreSQL';


--
-- Name: pg_buffercache; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pg_buffercache WITH SCHEMA public;


--
-- Name: EXTENSION pg_buffercache; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_buffercache IS 'examine the shared buffer cache';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track execution statistics of all SQL statements executed';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


--
-- Name: ae_add_acta(numeric, json[], json[], json[], json[], json[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_acta(id_document numeric, senders json[], recipients json[], notaries json[], criers json[], witnesses json[]) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
  _result record;
  _query text;
  _item json;

BEGIN

  PERFORM ae_add_person_batch(id_document, 'Emisor'::text, senders::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Participante'::text, recipients::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Notario'::text, notaries::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Pregonero'::text, criers::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Testigo'::text, witnesses::jsonb[]);

  RETURN id_document;
END;
$$;


ALTER FUNCTION public.ae_add_acta(id_document numeric, senders json[], recipients json[], notaries json[], criers json[], witnesses json[]) OWNER TO postgres;

--
-- Name: ae_add_acta_repartimiento(numeric, json[], json[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_acta_repartimiento(id_document numeric, personas json[], personas_relacionadas json[]) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
  _result record;
  _query text;
  _person json;

  _index numeric;
  _root_person_ids jsonb[];
  _ids jsonb;
  _id_agrupacion numeric;

  _inner_person_ids jsonb[];
  _inner_person json;
  _inner_ids jsonb;
  _inner_index numeric;
  _exisiting_relation numeric;

  _id_pertenencia_relacion numeric;
  _id_persona_rol_pertenencia_relacion numeric;

BEGIN

  -- Crear personas principales
  _root_person_ids = ae_add_person_batch(id_document, 'Persona principal'::text, personas::jsonb[]);

  -- En PGSQL los arrays empiezan en 1
  _index = 1;
  FOREACH _person IN ARRAY personas
  LOOP
    _ids = _root_person_ids[_index];

    -- Crear agrupación de bienes si no existe
    IF (_person->>'id_agrupacion')::numeric IS NULL
    THEN 
      _query := format('INSERT INTO agrupacion_bienes (nombre) VALUES (''Acta Repartimiento'') RETURNING id_agrupacion_bienes');
      EXECUTE _query INTO _result;
      _id_agrupacion = _result.id_agrupacion_bienes;

      _query := format(
        'INSERT INTO pertenencia_rel_agrupacion_bienes (fk_pertenencia_id, fk_agrupacion_bienes_id)
        VALUES (%s, %s) RETURNING *',
        (_ids->>'id_pertenencia')::numeric, _id_agrupacion
      );
      EXECUTE _query INTO _result;
    ELSE
      _id_agrupacion = (_person->>'id_agrupacion')::numeric;
    END IF;

    _index = _index + 1;
  END LOOP;

  -- Crear personas relacionadas
  _inner_person_ids = ae_add_person_batch(id_document, 'Persona relacionada'::text, personas_relacionadas::jsonb[]);
  _inner_index = 1;
  FOREACH _inner_person IN ARRAY personas_relacionadas
  LOOP
    _inner_ids = _inner_person_ids[_inner_index];
    _index = (_inner_person->>'person_index')::numeric + 1;
    _ids = _root_person_ids[_index];
    _person = personas[_index];

    PERFORM ae_add_relacion_persona_persona(
      (_ids->>'id_pertenencia')::numeric,
      (_person->>'id_persona_historica')::numeric,
      (_inner_ids->>'id_pertenencia')::numeric,
      (_inner_person->>'id_persona_historica')::numeric,
      'Repartimiento'::text
    );

    _inner_index = _inner_index + 1;
  END LOOP;
  
  RETURN _id_agrupacion;
END;
$$;


ALTER FUNCTION public.ae_add_acta_repartimiento(id_document numeric, personas json[], personas_relacionadas json[]) OWNER TO postgres;

--
-- Name: ae_add_acta_sentencia(numeric, json[], json[], json[], json[], json[], text[], json[], json); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_acta_sentencia(id_document numeric, senders json[], recipients json[], notaries json[], criers json[], witnesses json[], miembros text[], monedas json[], pena json) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
  _result record;
  _pena record;
  _query text;
  _item json;
  _textitem text;

BEGIN

  PERFORM ae_add_person_batch(id_document, 'Emisor'::text, senders::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Destinatario'::text, recipients::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Notario'::text, notaries::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Pregonero'::text, criers::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Testigo'::text, witnesses::jsonb[]);

  -- Buscar pena
  _query := format('SELECT fk_pena_id FROM documento d WHERE d.id_documento = %s', id_document);
  EXECUTE _query INTO _pena;

  -- Borrar relacion pena-documento para evitar delete CASCADE
  _query := format('UPDATE documento SET fk_pena_id = NULL WHERE id_documento = %s RETURNING *', id_document);
  EXECUTE _query INTO _result;

  -- Crear pena
  IF _pena.fk_pena_id IS NOT NULL
  THEN
    _query := format('DELETE FROM pena WHERE id_pena = %s RETURNING *', _pena.fk_pena_id);
    EXECUTE _query INTO _result;
  END IF; 

  _query := format('INSERT INTO pena (destierro_tipo, fecha_ini_dest, fecha_fin_dest, precision_ini_dest, precision_fin_dest, multa, destierro, exculpatoria, perdida_bienes, perdida_bienes_desc, otro, otro_desc, escarnio, azotes, muerte, muerte_medio) values (%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L) RETURNING *',pena->>'destierro_tipo',pena->>'fecha_ini_dest',pena->>'fecha_fin_dest',pena->>'precision_ini_dest',pena->>'precision_fin_dest',pena->>'multa',pena->>'destierro',pena->>'exculpatoria',pena->>'perdida_bienes',pena->>'perdida_bienes_desc',pena->>'otro',pena->>'otro_desc',pena->>'escarnio',pena->>'azotes',pena->>'muerte',pena->>'muerte_medio');
  EXECUTE _query INTO _pena;

  -- Crear relación pena-documento
  _query := format('UPDATE documento SET fk_pena_id = %s WHERE id_documento = %s RETURNING *', _pena.id_pena, id_document);
  EXECUTE _query INTO _result;

  -- Crear miembros
  FOREACH _textitem IN ARRAY miembros
  LOOP
    _query := format('INSERT INTO miembro (texto) VALUES(''%s'') ON CONFLICT DO NOTHING RETURNING texto', _textitem);
    EXECUTE _query INTO _result;
  END LOOP;

  -- Crear relacion pena-miembro
  FOREACH _textitem IN ARRAY miembros
  LOOP
    _query := format('INSERT INTO pena_rel_miembro (fk_pena_id, fk_miembro_texto) VALUES (%s, %L) RETURNING *', _pena.id_pena, _textitem);
    EXECUTE _query INTO _result;
  END LOOP;

  -- Crear unidades (monedas)
  FOREACH _item IN ARRAY monedas
  LOOP
    _query := format('INSERT INTO unidad (nombre, tipo) VALUES(%L, %L) ON CONFLICT DO NOTHING RETURNING *', _item->>'unit', 'Moneda');
    EXECUTE _query INTO _result;
  END LOOP;

  -- Crear relacion pena-unidad
  FOREACH _item IN ARRAY monedas
  LOOP
    _query := format('INSERT INTO pena_rel_unidad (fk_pena_id, fk_unidad_nombre, valor) VALUES (%s, %L, %s) RETURNING *', _pena.id_pena, _item->>'unit', _item->>'value');
    EXECUTE _query INTO _result;
  END LOOP;

  RETURN id_document;
END;
$$;


ALTER FUNCTION public.ae_add_acta_sentencia(id_document numeric, senders json[], recipients json[], notaries json[], criers json[], witnesses json[], miembros text[], monedas json[], pena json) OWNER TO postgres;

--
-- Name: ae_add_adn_sample(numeric, text, text, date, text, text, text, text, numeric, text, numeric, numeric, numeric, numeric, text, text, text, numeric, text, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_adn_sample(id_muestra numeric, name text, unipv_number text, date date, successful text, surface text, overall_preservation text, recorder text, powder_weigth numeric, extraction_method text, concentration numeric, ratio numeric, volume numeric, residual_volume numeric, extraction_place text, storage_loc text, people_cont text, library_ava numeric, comments text, fk_individuo_resto_id numeric) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE

  _r record;
  _q text;
  id_radiocarbon_dating numeric;

BEGIN

  -- Create or update sample
  IF id_muestra IS NULL
  THEN
    _q := format('INSERT INTO sample (
        name, unipv_number, date, successful, surface,
        overall_preservation, recorder, powder_weigth, extraction_method, concentration,
        ratio, volume, residual_volume, extraction_place, storage_loc, people_cont, library_ava,
        comments,
        fk_individuo_resto_id,
        type
      ) VALUES (
        %L, %L, %L::date, %L, %L,
        %L, %L, %L, %L, %L,
        %L, %L, %L, %L, %L, %L, %L,
        %L,
        %s,
        ''adn''
      ) RETURNING id_muestra',
      name, unipv_number, date, successful, surface,
      overall_preservation, recorder, powder_weigth, extraction_method, concentration,
      ratio, volume, residual_volume, extraction_place, storage_loc, people_cont, library_ava,
      comments,
      fk_individuo_resto_id
    );
  ELSE
    _q := format('UPDATE sample SET
        name=%L, unipv_number=%L, date=%L, successful=%L, surface=%L,
        overall_preservation=%L, recorder=%L, powder_weigth=%L, extraction_method=%L, concentration=%L,
        ratio=%L, volume=%L, residual_volume=%L, extraction_place=%L, storage_loc=%L, people_cont=%L, library_ava=%L,
        comments=%L,
        fk_individuo_resto_id=%s,
        type=''adn''
      WHERE id_muestra = %s
      RETURNING id_muestra',
      name, unipv_number, date, successful, surface,
      overall_preservation, recorder, powder_weigth, extraction_method, concentration,
      ratio, volume, residual_volume, extraction_place, storage_loc, people_cont, library_ava,
      comments,
      fk_individuo_resto_id,
      id_muestra
    );
  END IF;
  EXECUTE _q INTO _r;

  IF _r.id_muestra IS NOT NULL
  THEN
    id_muestra = _r.id_muestra;
  END IF;

  RETURN id_muestra;

END;
$$;


ALTER FUNCTION public.ae_add_adn_sample(id_muestra numeric, name text, unipv_number text, date date, successful text, surface text, overall_preservation text, recorder text, powder_weigth numeric, extraction_method text, concentration numeric, ratio numeric, volume numeric, residual_volume numeric, extraction_place text, storage_loc text, people_cont text, library_ava numeric, comments text, fk_individuo_resto_id numeric) OWNER TO postgres;

--
-- Name: ae_add_adn_sample(numeric, text, text, date, text, text, text, text, numeric, text, numeric, numeric, numeric, numeric, text, text, text, numeric, text, numeric, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_adn_sample(id_muestra numeric, name text, unipv_number text, date date, successful text, surface text, overall_preservation text, recorder text, powder_weigth numeric, extraction_method text, concentration numeric, ratio numeric, volume numeric, residual_volume numeric, extraction_place text, storage_loc text, people_cont text, library_ava numeric, comments text, fk_individuo_resto_id numeric, confidencial boolean) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE

  _r record;
  _q text;
  id_radiocarbon_dating numeric;

BEGIN

  -- Create or update sample
  IF id_muestra IS NULL
  THEN
    _q := format('INSERT INTO sample (
        name, unipv_number, date, successful, surface,
        overall_preservation, recorder, powder_weigth, extraction_method, concentration,
        ratio, volume, residual_volume, extraction_place, storage_loc, people_cont, library_ava,
        comments,
        fk_individuo_resto_id, confidencial,
        type
      ) VALUES (
        %L, %L, %L::date, %L, %L,
        %L, %L, %L, %L, %L,
        %L, %L, %L, %L, %L, %L, %L,
        %L,
        %s, %L,
        ''adn''
      ) RETURNING id_muestra',
      name, unipv_number, date, successful, surface,
      overall_preservation, recorder, powder_weigth, extraction_method, concentration,
      ratio, volume, residual_volume, extraction_place, storage_loc, people_cont, library_ava,
      comments,
      fk_individuo_resto_id, confidencial
    );
  ELSE
    _q := format('UPDATE sample SET
        name=%L, unipv_number=%L, date=%L, successful=%L, surface=%L,
        overall_preservation=%L, recorder=%L, powder_weigth=%L, extraction_method=%L, concentration=%L,
        ratio=%L, volume=%L, residual_volume=%L, extraction_place=%L, storage_loc=%L, people_cont=%L, library_ava=%L,
        comments=%L,
        fk_individuo_resto_id=%s, confidencial=%L,
        type=''adn''
      WHERE id_muestra = %s
      RETURNING id_muestra',
      name, unipv_number, date, successful, surface,
      overall_preservation, recorder, powder_weigth, extraction_method, concentration,
      ratio, volume, residual_volume, extraction_place, storage_loc, people_cont, library_ava,
      comments,
      fk_individuo_resto_id, confidencial,
      id_muestra
    );
  END IF;
  EXECUTE _q INTO _r;

  IF _r.id_muestra IS NOT NULL
  THEN
    id_muestra = _r.id_muestra;
  END IF;

  RETURN id_muestra;

END;
$$;


ALTER FUNCTION public.ae_add_adn_sample(id_muestra numeric, name text, unipv_number text, date date, successful text, surface text, overall_preservation text, recorder text, powder_weigth numeric, extraction_method text, concentration numeric, ratio numeric, volume numeric, residual_volume numeric, extraction_place text, storage_loc text, people_cont text, library_ava numeric, comments text, fk_individuo_resto_id numeric, confidencial boolean) OWNER TO postgres;

--
-- Name: ae_add_agrupacion_bienes(numeric, numeric, text, date, text, text, text, text, text, numeric, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_agrupacion_bienes(id_agrupacion_bienes numeric, id_pertenencia numeric, nombre text, fecha date, precision_fecha text, adelanto text, descripcion text, folio text, precision_lugar text, id_metodo_pago numeric, id_lugar numeric) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
  _r record;
  _q text;

BEGIN
  
  IF id_agrupacion_bienes IS NULL
  THEN
    _q = format('INSERT INTO agrupacion_bienes
      (nombre, fecha, precision_fecha, adelanto_cont, descripcion_cont, folio_cont, precision_lugar,fk_metodo_pago_id,fk_lugar_id)
      VALUES(''%s'', %L::date,
        ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', %s, %s) RETURNING id_agrupacion_bienes',
      nombre, fecha,
        precision_fecha,
        adelanto,
        descripcion,
        folio,
        precision_lugar,
        quote_nullable(id_metodo_pago),
        quote_nullable(id_lugar)
    );
  ELSE
    _q = format('UPDATE agrupacion_bienes SET
        nombre=''%s'',
        fecha=%L::date,
        precision_fecha=''%s'',
        adelanto_cont=''%s'',
        descripcion_cont=''%s'',
        folio_cont=''%s'',
        fk_metodo_pago_id=%s,
        precision_lugar=''%s'',
        fk_lugar_id=%s WHERE id_agrupacion_bienes=%s RETURNING id_agrupacion_bienes',
        nombre, fecha, precision_fecha, adelanto, descripcion, folio, quote_nullable(id_metodo_pago), precision_lugar, quote_nullable(id_lugar), id_agrupacion_bienes);
  END IF;

  EXECUTE _q INTO _r;
  id_agrupacion_bienes = _r.id_agrupacion_bienes;

  IF id_pertenencia IS NOT NULL
  THEN
    _q := format('DELETE FROM pertenencia_rel_agrupacion_bienes WHERE fk_pertenencia_id=%s AND fk_agrupacion_bienes_id=%L RETURNING fk_agrupacion_bienes_id', id_pertenencia, id_agrupacion_bienes);
    EXECUTE _q INTO _r;
    _q := format('INSERT INTO pertenencia_rel_agrupacion_bienes (fk_pertenencia_id, fk_agrupacion_bienes_id) VALUES (%s, %s) RETURNING fk_agrupacion_bienes_id', id_pertenencia, id_agrupacion_bienes);
    EXECUTE _q INTO _r;
  END IF;

  RETURN id_agrupacion_bienes;

END;
$$;


ALTER FUNCTION public.ae_add_agrupacion_bienes(id_agrupacion_bienes numeric, id_pertenencia numeric, nombre text, fecha date, precision_fecha text, adelanto text, descripcion text, folio text, precision_lugar text, id_metodo_pago numeric, id_lugar numeric) OWNER TO postgres;

--
-- Name: ae_add_almoneda(numeric, json[], json[], json[], json[], json[], text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_almoneda(id_document numeric, owner json[], executor json[], crier json[], notary json[], witness json[], reason text) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE

  _r record;
  _q text;
  _aux json;

BEGIN

  PERFORM ae_add_person_batch(id_document, 'Propietario'::text, owner::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Albacea'::text, executor::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Pregonero'::text, crier::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Escribano'::text, notary::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Testigo'::text, witness::jsonb[]);

  -- Creo el motivo de la Almoneda
  _q := format('UPDATE documento SET motivo_almoneda=%L
    WHERE id_documento=%s RETURNING id_documento', reason, id_document);

  EXECUTE _q INTO _r;

  RETURN id_document;

END;
$$;


ALTER FUNCTION public.ae_add_almoneda(id_document numeric, owner json[], executor json[], crier json[], notary json[], witness json[], reason text) OWNER TO postgres;

--
-- Name: ae_add_anomalia_rel_resto_individuo(numeric, numeric[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_anomalia_rel_resto_individuo(id_individuo_resto numeric, id_anomalias numeric[]) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
  _result record;
  _query text;
  _item numeric;

BEGIN

  _query := format('
    DELETE FROM anomalia_rel_individuo_resto 
    WHERE fk_individuo_resto_id=%s
    RETURNING * 
  ', id_individuo_resto);
  EXECUTE _query INTO _result;

  FOREACH _item IN ARRAY id_anomalias
  LOOP
    _query := format('
      INSERT INTO anomalia_rel_individuo_resto (fk_anomalia_id, fk_individuo_resto_id) 
      VALUES (%s, %s) RETURNING *
    ', _item, id_individuo_resto);
    EXECUTE _query INTO _result;    
  END LOOP;

  RETURN id_individuo_resto;
END;
$$;


ALTER FUNCTION public.ae_add_anomalia_rel_resto_individuo(id_individuo_resto numeric, id_anomalias numeric[]) OWNER TO postgres;

--
-- Name: ae_add_basic_info(numeric, text, text, text, boolean, text, text, boolean, text, numeric, text[], date, text, numeric, text, date, text, numeric, text, json[], json[], json[], text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_basic_info(id_document numeric, tipo text, subtipo text, signatura text, foliado boolean, des_foliado text, titulo text, firmada boolean, holografa text, seccion numeric, keywords text[], fecha_emision date, precision_fecha_emision text, lugar_emision numeric, precision_lugar_emision text, fecha_recepcion date, precision_fecha_recepcion text, lugar_recepcion numeric, precision_lugar_recepcion text, secretario json[], marginalia_personas json[], marginalia_instituciones json[], relaciones_documentos text[]) RETURNS json
    LANGUAGE plpgsql
    AS $$
DECLARE
  _result record;
  _doc record;
  _query text;
  _item json;
  _textitem text;

BEGIN

  -- Guardar o crear documento
  IF id_document IS NOT NULL
  THEN
    _query := format(
      'UPDATE documento 
      SET tipo=%L, subtipo=%L, signatura=%L, foliado=%L, des_foliado=%L, titulo=%L, firmada=%L, holografa=%L, fk_seccion_id=%L
      WHERE id_documento = %s RETURNING *',
      tipo, subtipo, signatura, foliado, des_foliado, titulo, firmada, holografa, seccion, id_document
    );
  ELSE
    _query := format(
      'INSERT INTO documento 
      (tipo, subtipo, signatura, foliado, des_foliado, titulo, firmada, holografa, fk_seccion_id) 
      VALUES (%L, %L, %L, %L, %L, %L, %L, %L, %s) RETURNING *', 
      tipo, subtipo, signatura, foliado, des_foliado, titulo, firmada, holografa, seccion
    );
  END IF;
  EXECUTE _query INTO _doc;
  id_document = _doc.id_documento;

  -- Crear keywords
  _query := format('DELETE FROM keyword_rel_documento WHERE fk_documento_id=%s RETURNING *', id_document);
  EXECUTE _query INTO _result;

  FOREACH _textitem IN ARRAY keywords
  LOOP
    _query := format('INSERT INTO keyword_rel_documento (fk_documento_id, fk_keyword_palabra) VALUES (%s, %L) RETURNING *', id_document, _textitem);
    EXECUTE _query INTO _result;
  END LOOP;

  -- Crear emision (pertenencia con fecha y lugar)
  _query := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Emisión');
  EXECUTE _query INTO _result;

  _query := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, fecha_inicio, precision_inicio) VALUES (%s, %L, %L::date, %L) RETURNING id_pertenencia', id_document, 'Emisión', fecha_emision, precision_fecha_emision);
  EXECUTE _query INTO _result;

  IF lugar_emision IS NOT NULL
  THEN
    _query := format('INSERT INTO pertenencia_rel_lugar (fk_lugar_id, fk_pertenencia_id, precision_pert_lugar) VALUES (%s, %s, %L) RETURNING *', lugar_emision, _result.id_pertenencia, precision_lugar_emision);
    EXECUTE _query INTO _result;
  END IF;

  -- Crear recepcion (pertenencia con fecha y lugar)
  _query := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Recepción');
  EXECUTE _query INTO _result;

  _query := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, fecha_inicio, precision_inicio) VALUES (%s, %L, %L::date, %L) RETURNING id_pertenencia', id_document, 'Recepción', fecha_recepcion, precision_fecha_recepcion);
  EXECUTE _query INTO _result;

  IF lugar_recepcion IS NOT NULL
  THEN
    _query := format('INSERT INTO pertenencia_rel_lugar (fk_lugar_id, fk_pertenencia_id, precision_pert_lugar) VALUES (%s, %s, %L) RETURNING *', lugar_recepcion, _result.id_pertenencia, precision_lugar_recepcion);
    EXECUTE _query INTO _result;
  END IF;

  PERFORM ae_add_person_batch(id_document, 'Mano_secretario'::text, secretario::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Persona_marginalia'::text, marginalia_personas::jsonb[]);

  -- Crear instituciones marginalia
  _query := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Institucion_marginalia');
  EXECUTE _query INTO _result;

  FOREACH _item IN ARRAY marginalia_instituciones
  LOOP
    PERFORM ae_add_institucion(id_document, NULL, NULL, _item->>'nombre', 'Institucion_marginalia','Institucion_marginalia','Institucion_marginalia', _item->>'descripcion');
  END LOOP;

  -- Crear relaciones documento
  _query := format('DELETE FROM documento_rel_documento WHERE fk_documento1=%s RETURNING *', id_document);
  EXECUTE _query INTO _result;

  FOREACH _textitem IN ARRAY relaciones_documentos
  LOOP
    _query := format('INSERT INTO documento_rel_documento (fk_documento1, fk_documento2) VALUES (%s, %s) RETURNING *', id_document, _textitem);
    EXECUTE _query INTO _result;    
  END LOOP;

  RETURN to_json(_doc);
END;
$$;


ALTER FUNCTION public.ae_add_basic_info(id_document numeric, tipo text, subtipo text, signatura text, foliado boolean, des_foliado text, titulo text, firmada boolean, holografa text, seccion numeric, keywords text[], fecha_emision date, precision_fecha_emision text, lugar_emision numeric, precision_lugar_emision text, fecha_recepcion date, precision_fecha_recepcion text, lugar_recepcion numeric, precision_lugar_recepcion text, secretario json[], marginalia_personas json[], marginalia_instituciones json[], relaciones_documentos text[]) OWNER TO postgres;

--
-- Name: ae_add_biblio(numeric, numeric, text, date, text, text, text, text, numeric, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_biblio(id_documento numeric, id_referencia_bibliografica numeric, autores text, fecha date, titulo text, nombre_tipo text, paginas text, doi text, fk_url_id numeric, isbn text DEFAULT NULL::text, tipo text DEFAULT NULL::text) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
  _r record;
  _q text;
  _documento record;
  _receptor json;
BEGIN


  -- HANDLE Url from doi
  IF doi IS NOT NULL
  THEN
    IF fk_url_id IS NULL
    THEN
      _q := format('INSERT INTO url (url) VALUES(%L) RETURNING id_url', doi);
    ELSE
      _q := format('UPDATE url SET url=%L where id_url=%s RETURNING id_url', doi, fk_url_id);
    END IF;
    EXECUTE _q INTO _r;
    fk_url_id = _r.id_url;
  END IF;

  RAISE NOTICE '%', fk_url_id;


  IF id_referencia_bibliografica IS NULL
  THEN
    _q := format('INSERT INTO referencia_bibliografica (isbn, doi, autores, fecha, paginas, titulo, tipo, nombre_tipo, fk_url_id)
      VALUES (%L, %L, %L, %L::date, %L, %L, %L, %L, %s) RETURNING id_referencia_bibliografica',
      isbn, doi, autores, fecha, paginas, titulo, tipo, nombre_tipo, fk_url_id);
  ELSE
    _q := format('UPDATE referencia_bibliografica SET isbn=%L, doi=%L,
      autores=%L, fecha=%L::date, paginas=%L, titulo=%L, tipo=%L, nombre_tipo=%L, fk_url_id=%s
      WHERE id_referencia_bibliografica=%s RETURNING id_referencia_bibliografica',
      isbn, doi, autores, fecha, paginas, titulo, tipo, nombre_tipo, fk_url_id, id_referencia_bibliografica
    );
  END IF;
  RAISE NOTICE '%', _q;
  EXECUTE _q INTO _r;
  id_referencia_bibliografica = _r.id_referencia_bibliografica;

  -- Document relation
  _q := format('DELETE FROM documento_rel_referencia_bibliografica
    WHERE fk_documento_id=%s AND fk_referencia_bibliografica_id=%s RETURNING *', id_documento, id_referencia_bibliografica);
  EXECUTE _q INTO _r;
  _q := format('INSERT INTO documento_rel_referencia_bibliografica (fk_documento_id, fk_referencia_bibliografica_id)
    VALUES (%s, %s) RETURNING *', id_documento, id_referencia_bibliografica);
  EXECUTE _q INTO _r;

  RETURN id_referencia_bibliografica;

END;
$$;


ALTER FUNCTION public.ae_add_biblio(id_documento numeric, id_referencia_bibliografica numeric, autores text, fecha date, titulo text, nombre_tipo text, paginas text, doi text, fk_url_id numeric, isbn text, tipo text) OWNER TO postgres;

--
-- Name: ae_add_bioapatite(numeric, numeric, text, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_bioapatite(id_bioapatite numeric, fk_sample_id numeric, sub_name text, distance_from_cervix numeric, sr_conc numeric, sr87_sr86 numeric, sr87_sr86_2sd numeric, ag4_po3_yield numeric, s18op numeric, s18op_1sd numeric, s18oc numeric, s18oc_1sd numeric, s13cc numeric, s13cc_1sd numeric, comments text, interpretation text) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
  _r record;
  _q text;
BEGIN

  IF id_bioapatite IS NULL
  THEN
    _q := format('INSERT INTO bioapatite (
        fk_sample_id,
        sub_name,
        distance_from_cervix,
        sr_conc,
        sr87_sr86,
        sr87_sr86_2sd,
        ag4_po3_yield,
        s18op,
        s18op_1sd,
        s18oc,
        s18oc_1sd,
        s13cc,
        s13cc_1sd,
        comments,
        interpretation
      ) VALUES (
        %s, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L
      ) RETURNING id_bioapatite',
      fk_sample_id,
      sub_name,
      distance_from_cervix,
      sr_conc,
      sr87_sr86,
      sr87_sr86_2sd,
      ag4_po3_yield,
      s18op,
      s18op_1sd,
      s18oc,
      s18oc_1sd,
      s13cc,
      s13cc_1sd,
      comments,
      interpretation
    );
  ELSE
    _q := format('UPDATE bioapatite SET fk_sample_id = %s,
        sub_name = %L,
        distance_from_cervix = %L,
        sr_conc = %L,
        sr87_sr86 = %L,
        sr87_sr86_2sd = %L,
        ag4_po3_yield = %L,
        s18op = %L,
        s18op_1sd = %L,
        s18oc = %L,
        s18oc_1sd = %L,
        s13cc = %L,
        s13cc_1sd = %L,
        comments = %L,
        interpretation = %L
      WHERE id_bioapatite = %s 
      RETURNING *',
      fk_sample_id,
      sub_name,
      distance_from_cervix,
      sr_conc,
      sr87_sr86,
      sr87_sr86_2sd,
      ag4_po3_yield,
      s18op,
      s18op_1sd,
      s18oc,
      s18oc_1sd,
      s13cc,
      s13cc_1sd,
      comments,
      interpretation,
      id_bioapatite
    );
  END IF;
  EXECUTE _q INTO _r;

  RETURN id_bioapatite;

END;
$$;


ALTER FUNCTION public.ae_add_bioapatite(id_bioapatite numeric, fk_sample_id numeric, sub_name text, distance_from_cervix numeric, sr_conc numeric, sr87_sr86 numeric, sr87_sr86_2sd numeric, ag4_po3_yield numeric, s18op numeric, s18op_1sd numeric, s18oc numeric, s18oc_1sd numeric, s13cc numeric, s13cc_1sd numeric, comments text, interpretation text) OWNER TO postgres;

--
-- Name: ae_add_carta(numeric, json[], json[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_carta(id_document numeric, emitters json[], recipients json[]) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE

  _r record;
  _q text;
  _aux json;

BEGIN

  PERFORM ae_add_person_batch(id_document, 'Emisor'::text, emitters::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Destinatario'::text, recipients::jsonb[]);

  RETURN id_document;

END;
$$;


ALTER FUNCTION public.ae_add_carta(id_document numeric, emitters json[], recipients json[]) OWNER TO postgres;

--
-- Name: ae_add_collagen(numeric, numeric, text, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, text, text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_collagen(id_collagen numeric, fk_sample_id numeric, sub_name text, distance_from_cervix numeric, collagen_yield numeric, cp numeric, cp_1sd numeric, np numeric, np_1sd numeric, atomic_cn_ratio numeric, s13_ccoll numeric, s13_ccoll_1sd numeric, s15_ncoll numeric, s15_ncoll_1sd numeric, quality_criteria text, quality_comment text, interpretation text, comments text) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
  _r record;
  _q text;
BEGIN

  IF id_collagen IS NULL
  THEN
    _q := format('INSERT INTO collagen (
        fk_sample_id,
        sub_name,
        distance_from_cervix,
        collagen_yield,
        cp,
        cp_1sd,
        np,
        np_1sd,
        atomic_cn_ratio,
        s13_ccoll,
        s13_ccoll_1sd,
        s15_ncoll,
        s15_ncoll_1sd,
        quality_criteria,
        quality_comment,
        comments,
        interpretation
      ) VALUES (
        %s, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L
      ) RETURNING id_collagen',
      fk_sample_id,
      sub_name,
      distance_from_cervix,
      collagen_yield,
      cp,
      cp_1sd,
      np,
      np_1sd,
      atomic_cn_ratio,
      s13_ccoll,
      s13_ccoll_1sd,
      s15_ncoll,
      s15_ncoll_1sd,
      quality_criteria,
      quality_comment,
      comments,
      interpretation
    );
  ELSE
    _q := format('UPDATE collagen SET fk_sample_id = %s,
        sub_name = %L,
        distance_from_cervix = %L,
        collagen_yield = %L,
        cp = %L,
        cp_1sd = %L,
        np = %L,
        np_1sd = %L,
        atomic_cn_ratio = %L,
        s13_ccoll = %L,
        s13_ccoll_1sd = %L,
        s15_ncoll = %L,
        s15_ncoll_1sd = %L,
        quality_criteria = %L,
        quality_comment = %L,
        comments = %L,
        interpretation = %L
      WHERE id_collagen = %s 
      RETURNING *',
      fk_sample_id,
      sub_name,
      distance_from_cervix,
      collagen_yield,
      cp,
      cp_1sd,
      np,
      np_1sd,
      atomic_cn_ratio,
      s13_ccoll,
      s13_ccoll_1sd,
      s15_ncoll,
      s15_ncoll_1sd,
      quality_criteria,
      quality_comment,
      comments,
      interpretation,
      id_collagen
    );
  END IF;
  EXECUTE _q INTO _r;

  RETURN id_collagen;

END;
$$;


ALTER FUNCTION public.ae_add_collagen(id_collagen numeric, fk_sample_id numeric, sub_name text, distance_from_cervix numeric, collagen_yield numeric, cp numeric, cp_1sd numeric, np numeric, np_1sd numeric, atomic_cn_ratio numeric, s13_ccoll numeric, s13_ccoll_1sd numeric, s15_ncoll numeric, s15_ncoll_1sd numeric, quality_criteria text, quality_comment text, interpretation text, comments text) OWNER TO postgres;

--
-- Name: ae_add_compra_venta(numeric, json[], json[], json[], numeric, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_compra_venta(id_document numeric, buyers json[], sellers json[], notaries json[], place numeric, place_precision text) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
  _result record;
  _query text;
  _item json;

BEGIN

  PERFORM ae_add_person_batch(id_document, 'Notario'::text, notaries::jsonb[]);

  -- Crear lugar y precision del lugar
  IF place IS NOT NULL
  THEN
    _query := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Transacción');
    EXECUTE _query INTO _result;
    
    _query := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc) VALUES (%s, %L) RETURNING id_pertenencia', id_document, 'Transacción');
    EXECUTE _query INTO _result;

    _query := format('INSERT INTO pertenencia_rel_lugar (fk_lugar_id, fk_pertenencia_id, precision_pert_lugar) VALUES (%s, %s, %L) RETURNING *', place, _result.id_pertenencia, place_precision);
    EXECUTE _query INTO _result;
  END IF;

  RETURN id_document;
END;
$$;


ALTER FUNCTION public.ae_add_compra_venta(id_document numeric, buyers json[], sellers json[], notaries json[], place numeric, place_precision text) OWNER TO postgres;

--
-- Name: ae_add_contabilidad(numeric, text, text, date, text, date, text, date, text, numeric, text, text, text, json[], json[], json[], json[], json[], json[], json[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_contabilidad(id_document numeric, nombre_institucion text, descripcion_institucion text, fecha_inicio date, precision_inicio text, fecha_fin date, precision_fin text, fecha_ingreso date, precision_fecha_ingreso text, id_lugar_ingreso numeric, tipo_lugar_ingreso text, precision_lugar_ingreso text, adelanto text, tesoreros json[], contadores json[], factores json[], tomadores json[], veedores json[], receptores json[], lineas json[]) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
  _result record;
  _pert_cont record;
  _id_pert_cont numeric;
  _agr_bienes record;
  _id_agr_bienes numeric;
  _query text;
  _item json;
  _item_linea json;
  _linea record;
  _unidad_nombre text;
  _id_lineas numeric[];

BEGIN

  PERFORM ae_add_person_batch(id_document, 'Tesorero'::text, tesoreros::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Contador'::text, contadores::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Factor'::text,   factores::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Tomador'::text,  tomadores::jsonb[]);  
  PERFORM ae_add_person_batch(id_document, 'Veedor'::text,   veedores::jsonb[]);  
  PERFORM ae_add_person_batch(id_document, 'Receptor'::text, receptores::jsonb[]);

  -- Crear institucion
  IF nombre_institucion IS NOT NULL
  THEN
    _item = (
      SELECT json_build_object(
        'id_pertenencia', id_pertenencia,
        'id_prp', id_persona_rol_pertenencia
      )
      FROM pertenencia p
      JOIN persona_rol_pertenencia prp ON prp.fk_pertenencia_id = p.id_pertenencia
      WHERE p.tipo_atr_doc = 'Institución' AND p.fk_documento_id = id_document
    );
    PERFORM ae_add_institucion(
      id_document, 
      (_item->>'id_pertenencia')::numeric,
      (_item->>'id_prp')::numeric,
      nombre_institucion, 
      'Institución','Institución','Institución',
      descripcion_institucion
    );
  END IF;

  -- Crear pertenencia contabilidad (con datos de ej. fiscal)
  _id_pert_cont = (
    SELECT id_pertenencia FROM pertenencia p 
    WHERE p.fk_documento_id = id_document AND p.tipo_atr_doc = 'Contabilidad'
  );
  IF _id_pert_cont IS NULL
  THEN
    _query := format('INSERT INTO pertenencia 
      (fk_documento_id, tipo_atr_doc, fecha_inicio, precision_inicio, fecha_fin, precision_fin) 
      VALUES (%s, %L, %L::date, %L, %L::date, %L)
      RETURNING *', id_document, 'Contabilidad', fecha_inicio, precision_inicio, fecha_fin, precision_fin);
  ELSE 
    _query = format('UPDATE pertenencia SET 
      fecha_inicio = %L::date, precision_inicio = %L,
      fecha_fin = %L::date, precision_fin = %L
    WHERE id_pertenencia = %s
    RETURNING *', fecha_inicio, precision_inicio, fecha_fin, precision_fin, _id_pert_cont); 
  END IF;
  EXECUTE _query INTO _pert_cont;

  _id_agr_bienes = (
    SELECT fk_agrupacion_bienes_id FROM pertenencia_rel_agrupacion_bienes
    WHERE fk_pertenencia_id = _pert_cont.id_pertenencia
  );
  _id_agr_bienes = (SELECT ae_add_agrupacion_bienes(
    _id_agr_bienes,
    _pert_cont.id_pertenencia,
    'Contabilidad', fecha_ingreso, precision_fecha_ingreso,
    adelanto, NULL, NULL, precision_lugar_ingreso, NULL, id_lugar_ingreso
  ));

  IF id_lugar_ingreso IS NOT NULL
  THEN
    _query := format('UPDATE lugar SET fk_tipo_lugar_nombre = %L WHERE id_lugar = %s RETURNING *', tipo_lugar_ingreso, id_lugar_ingreso);
    EXECUTE _query INTO _result;    
  END IF;
  
  -- Crear lineas para agr. bienes
  _id_lineas = ARRAY[]::numeric[];
  FOREACH _item_linea IN ARRAY lineas
  LOOP
    _id_lineas =  _id_lineas || (
      (
        _item_linea->>'id_linea'
      )::numeric
    );

  END LOOP;

  _query = format('DELETE FROM linea WHERE fk_agrupacion_bienes_id = %s
    AND id_linea NOT IN (SELECT unnest(%L::numeric[]))
    RETURNING *', _id_agr_bienes, _id_lineas);
  EXECUTE _query INTO _result;

  FOREACH _item IN ARRAY lineas
  LOOP

    IF _item->>'id_linea' IS NULL
    THEN 
      _query := format('INSERT INTO linea (descripcion, fk_agrupacion_bienes_id) 
        VALUES (%L, %s) RETURNING *', _item->>'tipo', _id_agr_bienes);
    ELSE
      _query := format('UPDATE linea SET descripcion = %L WHERE id_linea = %s RETURNING *', _item->>'tipo', (_item->>'id_linea')::numeric);
    END IF;
    EXECUTE _query INTO _linea;

    _query = format('DELETE FROM linea_rel_unidad WHERE fk_linea_id = %s RETURNING *', _linea.id_linea);
    EXECUTE _query INTO _result;

    _unidad_nombre = (SELECT ae_add_unidad(_item->>'moneda', 'Moneda'));
    _query := format('INSERT INTO linea_rel_unidad (fk_linea_id, fk_unidad_nombre, valor) VALUES (%s, ''%s'', %s) RETURNING *', _linea.id_linea, _unidad_nombre, _item->>'valor');
    EXECUTE _query INTO _result;

  END LOOP;

  RETURN id_document;
END;
$$;


ALTER FUNCTION public.ae_add_contabilidad(id_document numeric, nombre_institucion text, descripcion_institucion text, fecha_inicio date, precision_inicio text, fecha_fin date, precision_fin text, fecha_ingreso date, precision_fecha_ingreso text, id_lugar_ingreso numeric, tipo_lugar_ingreso text, precision_lugar_ingreso text, adelanto text, tesoreros json[], contadores json[], factores json[], tomadores json[], veedores json[], receptores json[], lineas json[]) OWNER TO postgres;

--
-- Name: ae_add_contrato_asiento(numeric, json[], json[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_contrato_asiento(id_document numeric, parts_involved json[], terms json[]) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
  _result record;
  _query text;
  _item json;

BEGIN

  PERFORM ae_add_person_batch(id_document, 'Involucrado'::text, parts_involved::jsonb[]);

  -- Crear condiciones
  _query := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Condición');
  EXECUTE _query INTO _result;

  FOREACH _item IN ARRAY terms
  LOOP
    _query := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, motivo, orden) VALUES (%s, %L, %L, %s) RETURNING id_pertenencia', id_document, 'Condición', _item->>'description', _item->>'order');
    EXECUTE _query INTO _result;
  END LOOP;

  RETURN id_document;
END;
$$;


ALTER FUNCTION public.ae_add_contrato_asiento(id_document numeric, parts_involved json[], terms json[]) OWNER TO postgres;

--
-- Name: ae_add_desglose(numeric, numeric, text, text, numeric, text, date, text, text, text, text, jsonb[], text, text); Type: FUNCTION; Schema: public; Owner: geographica
--

CREATE FUNCTION public.ae_add_desglose(id_documento numeric, id_pertenencia numeric, concepto text, mas_info text, valor numeric, moneda text, fecha_ingreso date, precision_fecha text, lugar_ingreso text, tipo_lugar text, precision_lugar text, receptores jsonb[], folio text, adelanto text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  _r record;
  _q text;
  _documento record;
BEGIN


END;
$$;


ALTER FUNCTION public.ae_add_desglose(id_documento numeric, id_pertenencia numeric, concepto text, mas_info text, valor numeric, moneda text, fecha_ingreso date, precision_fecha text, lugar_ingreso text, tipo_lugar text, precision_lugar text, receptores jsonb[], folio text, adelanto text) OWNER TO geographica;

--
-- Name: ae_add_desglose(numeric, numeric, text, text, numeric, text, date, text, numeric, text, text, text, json[], text, text); Type: FUNCTION; Schema: public; Owner: geographica
--

CREATE FUNCTION public.ae_add_desglose(id_documento numeric, id_pertenencia numeric, concepto text, mas_info text, valor numeric, moneda text, fecha_ingreso date, precision_fecha text, id_lugar numeric, lugar text, tipo_lugar text, precision_lugar text, receptores json[], folio text, adelanto text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  _r record;
  _q text;
  _documento record;
  _receptor json;
BEGIN


  -- Create dict data first

  -- Unidad
  moneda = (SELECT ae_add_unidad(moneda, 'Moneda'));

  -- Lugar
  id_lugar = (SELECT ae_add_lugar(id_lugar, lugar));


END;
$$;


ALTER FUNCTION public.ae_add_desglose(id_documento numeric, id_pertenencia numeric, concepto text, mas_info text, valor numeric, moneda text, fecha_ingreso date, precision_fecha text, id_lugar numeric, lugar text, tipo_lugar text, precision_lugar text, receptores json[], folio text, adelanto text) OWNER TO geographica;

--
-- Name: ae_add_desglose(numeric, numeric, text, text, numeric, text, date, text, numeric, text, text, text, jsonb[], text, text); Type: FUNCTION; Schema: public; Owner: geographica
--

CREATE FUNCTION public.ae_add_desglose(id_documento numeric, id_pertenencia numeric, concepto text, mas_info text, valor numeric, moneda text, fecha_ingreso date, precision_fecha text, id_lugar numeric, lugar text, tipo_lugar text, precision_lugar text, receptores jsonb[], folio text, adelanto text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  _r record;
  _q text;
  _documento record;
BEGIN

  -- Unidad
  PERFORM (SELECT ae_add_unidad(moneda, 'Moneda'));

  -- Lugar
  id_lugar = (SELECT ae_add_lugar(id_lugar, lugar));


END;
$$;


ALTER FUNCTION public.ae_add_desglose(id_documento numeric, id_pertenencia numeric, concepto text, mas_info text, valor numeric, moneda text, fecha_ingreso date, precision_fecha text, id_lugar numeric, lugar text, tipo_lugar text, precision_lugar text, receptores jsonb[], folio text, adelanto text) OWNER TO geographica;

--
-- Name: ae_add_desglose(numeric, numeric, numeric, text, numeric, text, text, numeric, json[], date, text, numeric, text, text, text, text, text, json[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_desglose(id_documento numeric, id_pertenencia numeric, id_agrupacion_bienes numeric, objeto text, id_objeto numeric, concepto text, mas_info text, id_linea numeric, unidades json[], fecha_ingreso date, precision_fecha text, id_lugar numeric, lugar text, tipo_lugar text, precision_lugar text, folio text, adelanto text, persons json[]) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
  _r record;
  _q text;
  _documento record;
  _receptor json;
  _unidad jsonb;
  _unidad_nombre text;
  _person json;
  _item json;  
  _ids_person numeric[];
  _id_pertenencia_person numeric;

BEGIN

  -- Objeto
  id_objeto = (SELECT ae_add_simple_objeto(objeto, id_objeto, NULL));

  IF id_pertenencia IS NULL
  THEN
    _q := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc) 
    VALUES (%s, %L) RETURNING *', id_documento, 'Desglose');
    EXECUTE _q INTO _r;    
    id_pertenencia = _r.id_pertenencia;
  END IF;

  -- Tipo lugar
  IF tipo_lugar IS NOT NULL
  THEN
    -- _q = format('INSERT INTO tipo_lugar (nombre) VALUES (%L) ON CONFLICT DO NOTHING', tipo_lugar);
    -- RAISE NOTICE '%', _q;
    -- PERFORM _q;
    _q = format('UPDATE lugar SET fk_tipo_lugar_nombre=%L WHERE id_lugar=%L RETURNING fk_tipo_lugar_nombre', tipo_lugar, id_lugar);
    EXECUTE _q INTO _r;
  END IF;

  RAISE NOTICE '%', id_lugar;
  -- Agrupacion bienes
  id_agrupacion_bienes = (SELECT ae_add_agrupacion_bienes(
      id_agrupacion_bienes,
      id_pertenencia,
      'Desglose',
      fecha_ingreso,
      precision_fecha,
      adelanto,
      mas_info,
      folio,
      precision_lugar,
      NULL,
      id_lugar));

  RAISE NOTICE 'id_agrupacion_bienes: %', id_agrupacion_bienes;
  -- Linea
  IF id_linea IS NULL
  THEN
    _q = format('INSERT INTO 
        linea(fk_objeto_id, descripcion, fk_agrupacion_bienes_id)
        VALUES(%L, %L, %s) 
      RETURNING id_linea', id_objeto, concepto, id_agrupacion_bienes);
  ELSE
    _q = format('UPDATE linea SET
        fk_objeto_id=%L,
        descripcion=%L,
        fk_agrupacion_bienes_id=%s
      WHERE id_linea=%s RETURNING id_linea', id_objeto, concepto, id_agrupacion_bienes, id_linea);
  END IF;
  EXECUTE _q INTO _r;
  id_linea = _r.id_linea;

  _q := format('DELETE FROM linea_rel_unidad WHERE fk_linea_id=%s RETURNING *', id_linea);
  EXECUTE _q INTO _r;

  FOREACH _unidad IN ARRAY unidades
  LOOP
    _unidad_nombre = (SELECT ae_add_unidad(_unidad->>'moneda', 'Moneda'));
    _q := format('INSERT INTO linea_rel_unidad (fk_linea_id, fk_unidad_nombre, valor) VALUES (%s, ''%s'', %s) RETURNING *', id_linea, _unidad_nombre, _unidad->>'valor');
    EXECUTE _q INTO _r;
  END LOOP;

  -- _q := format('DELETE FROM pertenencia
  --   WHERE tipo_atr_doc = %L AND fk_documento_id = %s 
  --   AND id_pertenencia IN (
  --     SELECT prp.fk_pertenencia_id from persona_rol_pertenencia prp
  --     JOIN persona_rol_pertenencia_rel_linea prpl
  --     ON prpl.fk_persona_rol_pertenencia_id = prp.id_persona_rol_pertenencia
  --     WHERE fk_linea = %s
  --   ) RETURNING *', 'Receptor Desglose', id_documento, id_linea);
  -- EXECUTE _q INTO _r;

  -- FOREACH _item IN ARRAY persons
  -- LOOP
  --   _person = (SELECT ae_add_rol_desc_persona_documento(id_documento, (_item->>'id_persona_historica')::numeric, _item->>'nombre', _item->>'descripcion', 'Receptor Desglose', 0, false));

  --   _q := format('INSERT INTO persona_rol_pertenencia_rel_linea (fk_persona_rol_pertenencia_id, fk_linea) VALUES (%s, %s) RETURNING *', _person->'id_prp', id_linea);
  --   EXECUTE _q INTO _r;
  -- END LOOP;

  _ids_person = ARRAY[]::numeric[];
  FOREACH _item IN ARRAY persons
  LOOP
    _ids_person = _ids_person || (_item->>'id_persona_rol_pertenencia')::numeric;
  END LOOP;

  _q = format('DELETE FROM pertenencia WHERE fk_documento_id = %s AND tipo_atr_doc = %L
    AND id_pertenencia IN (
      SELECT fk_pertenencia_id FROM persona_rol_pertenencia prp
      JOIN persona_rol_pertenencia_rel_linea prpl ON prpl.fk_persona_rol_pertenencia_id = prp.id_persona_rol_pertenencia
      WHERE prpl.fk_linea = %s
      AND prpl.fk_persona_rol_pertenencia_id NOT IN (SELECT unnest(%L::numeric[]))
    ) RETURNING *', id_documento, 'Receptor Desglose', id_linea, _ids_person);
  EXECUTE _q INTO _r;

  FOREACH _item IN ARRAY persons
  LOOP
    _id_pertenencia_person = (
      SELECT fk_pertenencia_id FROM persona_rol_pertenencia
      WHERE id_persona_rol_pertenencia = (_item->>'id_persona_rol_pertenencia')::numeric
    );
    _q := format('
      SELECT ae_add_persona_linea(%s,%L,%s,%L,%s, %L,%L,%L)
    ', id_documento, _id_pertenencia_person, (_item->>'id_persona_historica')::numeric, (_item->>'id_persona_rol_pertenencia')::numeric, id_linea, _item->>'nombre', 'Receptor Desglose', _item->>'descripcion');
    EXECUTE _q INTO _r;
  END LOOP;

  RETURN id_linea;

END;
$$;


ALTER FUNCTION public.ae_add_desglose(id_documento numeric, id_pertenencia numeric, id_agrupacion_bienes numeric, objeto text, id_objeto numeric, concepto text, mas_info text, id_linea numeric, unidades json[], fecha_ingreso date, precision_fecha text, id_lugar numeric, lugar text, tipo_lugar text, precision_lugar text, folio text, adelanto text, persons json[]) OWNER TO postgres;

--
-- Name: ae_add_entierro(numeric, text, text, text, text, text, text, numeric, numeric, numeric, text, text); Type: FUNCTION; Schema: public; Owner: geographica
--

CREATE FUNCTION public.ae_add_entierro(id_entierro numeric, nomenclatura_sitio text, lugar text, anio_fecha text, fk_espacio text, estructura text, forma text, largo numeric, ancho numeric, profundidad numeric, observaciones text, place_geometry text) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.ae_add_entierro(id_entierro numeric, nomenclatura_sitio text, lugar text, anio_fecha text, fk_espacio text, estructura text, forma text, largo numeric, ancho numeric, profundidad numeric, observaciones text, place_geometry text) OWNER TO geographica;

--
-- Name: ae_add_estado_rel_individuo(numeric, json[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_estado_rel_individuo(id_individuo_resto numeric, estados json[]) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE 
  _result record;
  _query text;
  _item json;

BEGIN

  _query := format('
    DELETE FROM estado_rel_individuo_arqueologico
    WHERE fk_individuo_arqueologico_id=%s
    RETURNING * 
  ', id_individuo_resto);
  EXECUTE _query INTO _result;

  FOREACH _item IN ARRAY estados
  LOOP
    _query := format('
      INSERT INTO estado_rel_individuo_arqueologico (fk_estado_tipo_cons_repre, fk_estado_elemento, valor, fk_individuo_arqueologico_id)
      VALUES (%L, %L, %L, %s)
      RETURNING *
    ', _item->>'tipo', _item->>'elemento', _item->>'valor', id_individuo_resto);
    EXECUTE _query INTO _result;
  END LOOP;

  RETURN id_individuo_resto;
END;
$$;


ALTER FUNCTION public.ae_add_estado_rel_individuo(id_individuo_resto numeric, estados json[]) OWNER TO postgres;

--
-- Name: ae_add_genome(numeric, numeric, text, numeric, text, numeric, numeric, numeric, numeric, text, text, text, numeric, numeric, numeric, numeric, text, numeric, numeric, numeric, numeric, text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_genome(id_wholegenome numeric, fk_sample_id numeric, successful text, overall_snps numeric, closes_pop text, overall_error numeric, contamination numeric, ctot_rate numeric, gtoa_rate numeric, ancest_origin text, reference_genome text, seq_strategy text, libraries_seq numeric, raw_reads numeric, mapped_reads numeric, duplicate numeric, molecular_sex text, gc_content numeric, whole_coverage numeric, mean_read_depth numeric, average_length numeric, updated_on text, comments text, interpretation text) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
  _r record;
  _q text;
BEGIN

  IF id_wholegenome IS NULL
  THEN
    _q := format('INSERT INTO wholegenome (
      fk_sample_id,
      successful,
      overall_snps,
      closes_pop,
      overall_error,
      contamination,
      ctot_rate,
      gtoa_rate,
      ancest_origin,
      reference_genome,
      seq_strategy,
      libraries_seq,
      raw_reads,
      mapped_reads,
      duplicate,
      molecular_sex,
      gc_content,
      whole_coverage,
      mean_read_depth,
      average_length,
      updated_on,
      comments,
      interpretation
      ) VALUES (
        %s, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L,
        %L::date, %L, %L
      ) RETURNING id_wholegenome',
      fk_sample_id,
      successful,
      overall_snps,
      closes_pop,
      overall_error,
      contamination,
      ctot_rate,
      gtoa_rate,
      ancest_origin,
      reference_genome,
      seq_strategy,
      libraries_seq,
      raw_reads,
      mapped_reads,
      duplicate,
      molecular_sex,
      gc_content,
      whole_coverage,
      mean_read_depth,
      average_length,
      updated_on,
      comments,
      interpretation
    );
  ELSE
    _q := format('UPDATE wholegenome SET
      fk_sample_id = %s,
      successful = %L,
      overall_snps = %L,
      closes_pop = %L,
      overall_error = %L,
      contamination = %L,
      ctot_rate = %L,
      gtoa_rate = %L,
      ancest_origin = %L,
      reference_genome = %L,
      seq_strategy = %L,
      libraries_seq = %L,
      raw_reads = %L,
      mapped_reads = %L,
      duplicate = %L,
      molecular_sex = %L,
      gc_content = %L,
      whole_coverage = %L,
      mean_read_depth = %L,
      average_length = %L,
      updated_on = %L::date,
      comments = %L,
      interpretation = %L
      WHERE id_wholegenome = %s
      RETURNING *',
      fk_sample_id,
      successful,
      overall_snps,
      closes_pop,
      overall_error,
      contamination,
      ctot_rate,
      gtoa_rate,
      ancest_origin,
      reference_genome,
      seq_strategy,
      libraries_seq,
      raw_reads,
      mapped_reads,
      duplicate,
      molecular_sex,
      gc_content,
      whole_coverage,
      mean_read_depth,
      average_length,
      updated_on,
      comments,
      interpretation,
      id_wholegenome
    );
  END IF;
  EXECUTE _q INTO _r;

  RETURN _r.id_wholegenome;

END;
$$;


ALTER FUNCTION public.ae_add_genome(id_wholegenome numeric, fk_sample_id numeric, successful text, overall_snps numeric, closes_pop text, overall_error numeric, contamination numeric, ctot_rate numeric, gtoa_rate numeric, ancest_origin text, reference_genome text, seq_strategy text, libraries_seq numeric, raw_reads numeric, mapped_reads numeric, duplicate numeric, molecular_sex text, gc_content numeric, whole_coverage numeric, mean_read_depth numeric, average_length numeric, updated_on text, comments text, interpretation text) OWNER TO postgres;

--
-- Name: ae_add_incautacion(numeric, json[], json[], json[], json[], json[], json[], text[], date, text, numeric, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_incautacion(id_document numeric, seized_from json[], ordered_by json[], executioners json[], notaries json[], propietaries json[], witnesses json[], motives text[], date_ date, date_precision text, place numeric, place_precision text) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
  _result record;
  _query text;
  _item json;
  _textitem text;

BEGIN

  PERFORM ae_add_person_batch(id_document, 'Incautado'::text, seized_from::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Comandante'::text, ordered_by::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Ejecutor'::text, executioners::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Notario'::text, notaries::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Propietario'::text, propietaries::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Testigo'::text, witnesses::jsonb[]);

  -- Crear motivos
  _query := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Motivo');
  EXECUTE _query INTO _result;

  FOREACH _textitem IN ARRAY motives
  LOOP
    _query := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, motivo) VALUES (%s, %L, %L) RETURNING id_pertenencia', id_document, 'Motivo', _textitem);
    EXECUTE _query INTO _result;
  END LOOP;

  -- Crear lugar y precision del lugar
  IF place IS NOT NULL
  THEN
    _query := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Lugar de incautación');
    EXECUTE _query INTO _result;
    
    _query := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc) VALUES (%s, %L) RETURNING id_pertenencia', id_document, 'Lugar de incautación');
    EXECUTE _query INTO _result;

    _query := format('INSERT INTO pertenencia_rel_lugar (fk_lugar_id, fk_pertenencia_id, precision_pert_lugar) VALUES (%s, %s, %L) RETURNING *', place, _result.id_pertenencia, place_precision);
    EXECUTE _query INTO _result;
  END IF;

  -- Crear Fecha de incautacion y precision
  _query := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Fecha de incautacion');
  EXECUTE _query INTO _result;

  _query := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, fecha_inicio, precision_inicio) VALUES (%s, %L, %L::date, %L) RETURNING id_pertenencia', id_document, 'Fecha de incautacion', date_, date_precision);
  EXECUTE _query INTO _result;

  RETURN id_document;
END;
$$;


ALTER FUNCTION public.ae_add_incautacion(id_document numeric, seized_from json[], ordered_by json[], executioners json[], notaries json[], propietaries json[], witnesses json[], motives text[], date_ date, date_precision text, place numeric, place_precision text) OWNER TO postgres;

--
-- Name: ae_add_individuo_arquelogico(numeric, numeric, text, text, text, text, numeric, numeric, numeric, text, text, text, text, text, text, numeric, text, text, text, text, text, text, text, text, text, text, numeric, text, json[], json[], json[], json[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_individuo_arquelogico(fk_entierro numeric, id_individuo_arqueologico numeric, unid_estratigrafica text, unid_estratigrafica_asociada text, estructura text, forma text, largo numeric, ancho numeric, profundidad numeric, tipo_enterramiento text, clase_enterramiento text, contenedor text, descomposicion text, periodo_inicio text, periodo_fin text, estatura numeric, catalogo text, sexo text, edad text, posicion_cuerpo text, pos_extremidades_sup text, pos_extremidades_inf text, orientacion_cuerpo text, orientacion_creaneo text, filiacion_poblacional text, observaciones text, nmi_total numeric, tipo text, edades json[], estados json[], restos json[], lineas json[]) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
	_r record;
	_q text;
	_edad json;
	_estado json;
	_resto json;
  _linea json;
BEGIN
	
	-- Individuo arqueologico
	-- tipo podra tomar los valores "enterramiento" o "noent" e indicara si el indiv. arquelogico es de tipo enterramiento o no
	IF id_individuo_arqueologico is NULL 
	THEN
		_q := format('INSERT INTO individuo_arqueologico (
		    catalogo, sexo, edad, filiacion_poblacional, 
		    estatura, periodo_inicio, periodo_fin, unid_estratigrafica, unid_estratigrafica_asociada, 
		    tipo, clase_enterramiento, descomposicion, contenedor, pos_extremidades_inf, 
		    pos_extremidades_sup, posicion_cuerpo, orientacion_cuerpo, orientacion_creaneo, 
		    tipo_enterramiento, fk_entierro, observaciones, 
		    estructura, forma, largo, ancho, profundidad, nmi_total
			) VALUES (
				%L, %L, %L, %L, %s, %L, %L, %L, %L, %L, %L, 
				%L, %L, %L, %L, %L, %L, %L, %L, %s, %L, %L, %L, %s, %s, %s, %s
			) RETURNING id_individuo_arqueologico', catalogo, sexo, edad, filiacion_poblacional, 
			    estatura, periodo_inicio, periodo_fin, unid_estratigrafica, unid_estratigrafica_asociada, 
			    tipo, clase_enterramiento, descomposicion, contenedor, pos_extremidades_inf, 
			    pos_extremidades_sup, posicion_cuerpo, orientacion_cuerpo, orientacion_creaneo, 
			    tipo_enterramiento, fk_entierro, observaciones, 
			    estructura, forma, largo, ancho, profundidad, nmi_total);

	ELSE
		_q := format('UPDATE individuo_arqueologico 
			SET catalogo=%L, sexo=%L, edad=%L, filiacion_poblacional=%L, 
			    estatura=%s, periodo_inicio=%L, periodo_fin=%L, unid_estratigrafica=%L, 
			    unid_estratigrafica_asociada=%L, tipo=%L, clase_enterramiento=%L, 
			    descomposicion=%L, contenedor=%L, pos_extremidades_inf=%L, pos_extremidades_sup=%L, 
			    posicion_cuerpo=%L, orientacion_cuerpo=%L, orientacion_creaneo=%L, 
			    tipo_enterramiento=%L, fk_entierro=%s, 
			    observaciones=%L, estructura=%L, forma=%L, largo=%s, ancho=%s, profundidad=%s, 
			    nmi_total=%s
			WHERE id_individuo_arqueologico=%s RETURNING id_individuo_arqueologico', catalogo, sexo, edad, filiacion_poblacional, 
			    estatura, periodo_inicio, periodo_fin, unid_estratigrafica, unid_estratigrafica_asociada, 
			    tipo, clase_enterramiento, descomposicion, contenedor, pos_extremidades_inf, 
			    pos_extremidades_sup, posicion_cuerpo, orientacion_cuerpo, orientacion_creaneo, 
			    tipo_enterramiento, fk_entierro, observaciones, 
			    estructura, forma, largo, ancho, profundidad, nmi_total, id_individuo_arqueologico);

	END IF;
	EXECUTE _q INTO _r;

	RAISE NOTICE '%', _q;
	IF _r.id_individuo_arqueologico IS NOT NULL
	THEN
	    id_individuo_arqueologico = _r.id_individuo_arqueologico;
	END IF;
	  
	-- Creo los estados
	-- estados sera un array de json y cada elemento contendrá tres propiedades: tipo, valor y elemento. Con esto debera guardarse la relacion del individuo arquelogico con la tabla estado.
	_q := format('DELETE FROM estado_rel_individuo_arqueologico WHERE fk_individuo_arqueologico_id=%s RETURNING *', id_individuo_arqueologico);
	EXECUTE _q INTO _r;
	
	FOREACH _estado IN ARRAY estados
	LOOP	
		_q := format('INSERT INTO estado_rel_individuo_arqueologico (fk_estado_tipo_cons_repre, fk_estado_elemento, fk_individuo_arqueologico_id, valor)
		VALUES (%L, %L, %s, %L) RETURNING *', _estado->>'tipo_cons_represen',_estado->>'elemento',id_individuo_arqueologico, _estado->>'valor');
		EXECUTE _q INTO _r;
	END LOOP;

	-- Creo las edades
	-- edades sera un array de json y cada elemento contendrá dos propiedades: edad recodificada y cantidad. Con esto debera guardarse la relacion del individuo arquelogico con la tabla lote_edades.
	_q := format('DELETE FROM lote_edades_rel_individuo_arqueologico WHERE fk_individuo_arqueologico=%s RETURNING *', id_individuo_arqueologico);
	EXECUTE _q INTO _r;

	FOREACH _edad IN ARRAY edades
	LOOP
		_q := format('INSERT INTO lote_edades_rel_individuo_arqueologico (fk_lote_edades, cantidad, fk_individuo_arqueologico)
		VALUES (%L, %s, %s) RETURNING *', _edad->>'id_edad_recodificada',_edad->>'cantidad',id_individuo_arqueologico);
		EXECUTE _q INTO _r;
	END LOOP;

	/*
	-- REPASAR LA RELACIÓN CON INDIVIDUO_RESTO (INCOMPLETO)
	-- Creo los restos
	-- restos sera un array de json y cada elemento contendrá las propiedades necesarias para guardar los restos con el procedimiento almacenado creado para guardar restos
	_q := format('DELETE FROM individuo_resto WHERE fk_individuo_arqueologico=%s RETURNING *', id_individuo_arqueologico);
	EXECUTE _q INTO _r;

	FOREACH _resto IN ARRAY restos
	LOOP
		PERFORM ae_add_individuo_resto(NULL,_resto->>'fk_resto_variable',_resto->>'fk_especie_nombre',id_individuo_arqueologico,_resto->>'numero',_resto->>'anomalias');
	END LOOP;
	*/
	
	/*
	-- REPASAR LA RELACIÓN CON LINEA (INCOMPLETO)
	-- Creo las lineas
	-- lineas sera un array de json y cada elemento contendrá las propiedades necesarias para guardar los objetos arqueologicos y las lineas relacionadas con el individuo arquelogico usando el procedimiento almacenado creado para ello
	
	_q := format('DELETE FROM individuo_arqueologico_rel_linea WHERE fk_individuo_arqueologico=%s AND fk_linea=%s RETURNING *',_linea->>'id_linea', _linea->>'id_individuo_arqueologico');
	EXECUTE _q INTO _r;
	FOREACH _linea IN ARRAY lineas
	LOOP
		public.ae_add_individuo_resto(numeric, text, text, numeric, numeric, json[])
		_q := format('INSERT INTO individuo_arqueologico_rel_linea(
		fk_individuo_arqueologico, fk_linea, origen, tipo)
		VALUES (%s, %s, %L, %L) RETURNING *', _linea->>'id_individuo_arqueologico', _linea->>'id_linea', _linea->>'origen', _linea->>'tipo');
		EXECUTE _q INTO _r;
	END LOOP;
	*/

	RETURN id_individuo_arqueologico;

END;
$$;


ALTER FUNCTION public.ae_add_individuo_arquelogico(fk_entierro numeric, id_individuo_arqueologico numeric, unid_estratigrafica text, unid_estratigrafica_asociada text, estructura text, forma text, largo numeric, ancho numeric, profundidad numeric, tipo_enterramiento text, clase_enterramiento text, contenedor text, descomposicion text, periodo_inicio text, periodo_fin text, estatura numeric, catalogo text, sexo text, edad text, posicion_cuerpo text, pos_extremidades_sup text, pos_extremidades_inf text, orientacion_cuerpo text, orientacion_creaneo text, filiacion_poblacional text, observaciones text, nmi_total numeric, tipo text, edades json[], estados json[], restos json[], lineas json[]) OWNER TO postgres;

--
-- Name: ae_add_individuo_arquelogico(numeric, numeric, text, text, text, text, numeric, numeric, numeric, text, text, text, text, text, text, numeric, text, text, text, text, text, text, text, text, text, text, numeric, text, boolean, json[], json[], json[], json[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_individuo_arquelogico(fk_entierro numeric, id_individuo_arqueologico numeric, unid_estratigrafica text, unid_estratigrafica_asociada text, estructura text, forma text, largo numeric, ancho numeric, profundidad numeric, tipo_enterramiento text, clase_enterramiento text, contenedor text, descomposicion text, periodo_inicio text, periodo_fin text, estatura numeric, catalogo text, sexo text, edad text, posicion_cuerpo text, pos_extremidades_sup text, pos_extremidades_inf text, orientacion_cuerpo text, orientacion_creaneo text, filiacion_poblacional text, observaciones text, nmi_total numeric, tipo text, confidencial boolean, edades json[], estados json[], restos json[], lineas json[]) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
	_r record;
	_q text;
	_edad json;
	_estado json;
	_resto json;
  _linea json;
BEGIN
	
	-- Individuo arqueologico
	-- tipo podra tomar los valores "enterramiento" o "noent" e indicara si el indiv. arquelogico es de tipo enterramiento o no
	IF id_individuo_arqueologico is NULL 
	THEN
		_q := format('INSERT INTO individuo_arqueologico (
		    catalogo, sexo, edad, filiacion_poblacional, 
		    estatura, periodo_inicio, periodo_fin, unid_estratigrafica, unid_estratigrafica_asociada, 
		    tipo, clase_enterramiento, descomposicion, contenedor, pos_extremidades_inf, 
		    pos_extremidades_sup, posicion_cuerpo, orientacion_cuerpo, orientacion_creaneo, 
		    tipo_enterramiento, fk_entierro, observaciones, 
		    estructura, forma, largo, ancho, profundidad, nmi_total, confidencial
			) VALUES (
				%L, %L, %L, %L, %s, %L, %L, %L, %L, %L, %L, 
				%L, %L, %L, %L, %L, %L, %L, %L, %s, %L, %L, %L, %s, %s, %s, %s, %L
			) RETURNING id_individuo_arqueologico', catalogo, sexo, edad, filiacion_poblacional, 
			    estatura, periodo_inicio, periodo_fin, unid_estratigrafica, unid_estratigrafica_asociada, 
			    tipo, clase_enterramiento, descomposicion, contenedor, pos_extremidades_inf, 
			    pos_extremidades_sup, posicion_cuerpo, orientacion_cuerpo, orientacion_creaneo, 
			    tipo_enterramiento, fk_entierro, observaciones, 
			    estructura, forma, largo, ancho, profundidad, nmi_total, confidencial);

	ELSE
		_q := format('UPDATE individuo_arqueologico 
			SET catalogo=%L, sexo=%L, edad=%L, filiacion_poblacional=%L, 
			    estatura=%s, periodo_inicio=%L, periodo_fin=%L, unid_estratigrafica=%L, 
			    unid_estratigrafica_asociada=%L, tipo=%L, clase_enterramiento=%L, 
			    descomposicion=%L, contenedor=%L, pos_extremidades_inf=%L, pos_extremidades_sup=%L, 
			    posicion_cuerpo=%L, orientacion_cuerpo=%L, orientacion_creaneo=%L, 
			    tipo_enterramiento=%L, fk_entierro=%s, 
			    observaciones=%L, estructura=%L, forma=%L, largo=%s, ancho=%s, profundidad=%s, 
			    nmi_total=%s, confidencial=%L
			WHERE id_individuo_arqueologico=%s RETURNING id_individuo_arqueologico', catalogo, sexo, edad, filiacion_poblacional, 
			    estatura, periodo_inicio, periodo_fin, unid_estratigrafica, unid_estratigrafica_asociada, 
			    tipo, clase_enterramiento, descomposicion, contenedor, pos_extremidades_inf, 
			    pos_extremidades_sup, posicion_cuerpo, orientacion_cuerpo, orientacion_creaneo, 
			    tipo_enterramiento, fk_entierro, observaciones, 
			    estructura, forma, largo, ancho, profundidad, nmi_total, confidencial, id_individuo_arqueologico);

	END IF;
	EXECUTE _q INTO _r;

	RAISE NOTICE '%', _q;
	IF _r.id_individuo_arqueologico IS NOT NULL
	THEN
	    id_individuo_arqueologico = _r.id_individuo_arqueologico;
	END IF;
	  
	-- Creo los estados
	-- estados sera un array de json y cada elemento contendrá tres propiedades: tipo, valor y elemento. Con esto debera guardarse la relacion del individuo arquelogico con la tabla estado.
	_q := format('DELETE FROM estado_rel_individuo_arqueologico WHERE fk_individuo_arqueologico_id=%s RETURNING *', id_individuo_arqueologico);
	EXECUTE _q INTO _r;
	
	FOREACH _estado IN ARRAY estados
	LOOP	
		_q := format('INSERT INTO estado_rel_individuo_arqueologico (fk_estado_tipo_cons_repre, fk_estado_elemento, fk_individuo_arqueologico_id, valor)
		VALUES (%L, %L, %s, %L) RETURNING *', _estado->>'tipo_cons_represen',_estado->>'elemento',id_individuo_arqueologico, _estado->>'valor');
		EXECUTE _q INTO _r;
	END LOOP;

	-- Creo las edades
	-- edades sera un array de json y cada elemento contendrá dos propiedades: edad recodificada y cantidad. Con esto debera guardarse la relacion del individuo arquelogico con la tabla lote_edades.
	_q := format('DELETE FROM lote_edades_rel_individuo_arqueologico WHERE fk_individuo_arqueologico=%s RETURNING *', id_individuo_arqueologico);
	EXECUTE _q INTO _r;

	FOREACH _edad IN ARRAY edades
	LOOP
		_q := format('INSERT INTO lote_edades_rel_individuo_arqueologico (fk_lote_edades, cantidad, fk_individuo_arqueologico)
		VALUES (%L, %s, %s) RETURNING *', _edad->>'id_edad_recodificada',_edad->>'cantidad',id_individuo_arqueologico);
		EXECUTE _q INTO _r;
	END LOOP;

	/*
	-- REPASAR LA RELACIÓN CON INDIVIDUO_RESTO (INCOMPLETO)
	-- Creo los restos
	-- restos sera un array de json y cada elemento contendrá las propiedades necesarias para guardar los restos con el procedimiento almacenado creado para guardar restos
	_q := format('DELETE FROM individuo_resto WHERE fk_individuo_arqueologico=%s RETURNING *', id_individuo_arqueologico);
	EXECUTE _q INTO _r;

	FOREACH _resto IN ARRAY restos
	LOOP
		PERFORM ae_add_individuo_resto(NULL,_resto->>'fk_resto_variable',_resto->>'fk_especie_nombre',id_individuo_arqueologico,_resto->>'numero',_resto->>'anomalias');
	END LOOP;
	*/
	
	/*
	-- REPASAR LA RELACIÓN CON LINEA (INCOMPLETO)
	-- Creo las lineas
	-- lineas sera un array de json y cada elemento contendrá las propiedades necesarias para guardar los objetos arqueologicos y las lineas relacionadas con el individuo arquelogico usando el procedimiento almacenado creado para ello
	
	_q := format('DELETE FROM individuo_arqueologico_rel_linea WHERE fk_individuo_arqueologico=%s AND fk_linea=%s RETURNING *',_linea->>'id_linea', _linea->>'id_individuo_arqueologico');
	EXECUTE _q INTO _r;
	FOREACH _linea IN ARRAY lineas
	LOOP
		public.ae_add_individuo_resto(numeric, text, text, numeric, numeric, json[])
		_q := format('INSERT INTO individuo_arqueologico_rel_linea(
		fk_individuo_arqueologico, fk_linea, origen, tipo)
		VALUES (%s, %s, %L, %L) RETURNING *', _linea->>'id_individuo_arqueologico', _linea->>'id_linea', _linea->>'origen', _linea->>'tipo');
		EXECUTE _q INTO _r;
	END LOOP;
	*/

	RETURN id_individuo_arqueologico;

END;
$$;


ALTER FUNCTION public.ae_add_individuo_arquelogico(fk_entierro numeric, id_individuo_arqueologico numeric, unid_estratigrafica text, unid_estratigrafica_asociada text, estructura text, forma text, largo numeric, ancho numeric, profundidad numeric, tipo_enterramiento text, clase_enterramiento text, contenedor text, descomposicion text, periodo_inicio text, periodo_fin text, estatura numeric, catalogo text, sexo text, edad text, posicion_cuerpo text, pos_extremidades_sup text, pos_extremidades_inf text, orientacion_cuerpo text, orientacion_creaneo text, filiacion_poblacional text, observaciones text, nmi_total numeric, tipo text, confidencial boolean, edades json[], estados json[], restos json[], lineas json[]) OWNER TO postgres;

--
-- Name: ae_add_individuo_resto(numeric, text, text, numeric, numeric, text[]); Type: FUNCTION; Schema: public; Owner: geographica
--

CREATE FUNCTION public.ae_add_individuo_resto(id_individuo_resto numeric, fk_resto_variable text, fk_especie_nombre text, fk_individuo_arqueologico_id numeric, numero numeric, anomalias text[]) RETURNS json
    LANGUAGE plpgsql
    AS $$
DECLARE
  _result record;
  _ind record;
  _query text;
  _item numeric;

BEGIN

  -- -- Especie
  -- IF fk_especie_nombre IS NOT NULL
  -- THEN
  --   _query := format('INSERT INTO especie (nombre) VALUES (%L) ON CONFLICT DO NOTHING RETURNING *', fk_especie_nombre);
  --   EXECUTE _query INTO _result;
  -- END IF;

  -- Individuo_resto
  IF id_individuo_resto is NULL 
  THEN
     _query := format('INSERT INTO individuo_resto(fk_resto_variable, fk_especie_nombre, fk_individuo_arqueologico_id, numero) 
            VALUES (%L, %L, %s, %L) RETURNING *', fk_resto_variable, fk_especie_nombre, fk_individuo_arqueologico_id, numero);
  ELSE
    _query := format('UPDATE individuo_resto 
    SET fk_resto_variable=%L, fk_especie_nombre=%L, fk_individuo_arqueologico_id=%s, numero=%L
    WHERE id_individuo_resto=%s RETURNING *', fk_resto_variable, fk_especie_nombre, fk_individuo_arqueologico_id, numero, id_individuo_resto);
  END IF;
  EXECUTE _query INTO _ind;
  id_individuo_resto = _ind.id_individuo_resto;

  -- Anomalias
  _query := format('DELETE FROM anomalia_rel_individuo_resto WHERE fk_individuo_resto_id=%s RETURNING *', id_individuo_resto);
  EXECUTE _query INTO _result;

  FOREACH _item IN ARRAY anomalias
  LOOP
    _query := format('INSERT INTO anomalia_rel_individuo_resto (fk_individuo_resto_id, fk_anomalia_id) VALUES (%s, %s) RETURNING *', id_individuo_resto, _item);
    EXECUTE _query INTO _result;
  END LOOP;
 
  RETURN to_json(_ind);

END;
$$;


ALTER FUNCTION public.ae_add_individuo_resto(id_individuo_resto numeric, fk_resto_variable text, fk_especie_nombre text, fk_individuo_arqueologico_id numeric, numero numeric, anomalias text[]) OWNER TO geographica;

--
-- Name: ae_add_institucion(numeric, text); Type: FUNCTION; Schema: public; Owner: geographica
--

CREATE FUNCTION public.ae_add_institucion(id_pertenencia numeric, nombre text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  _r record;
  _q text;
BEGIN





END;
$$;


ALTER FUNCTION public.ae_add_institucion(id_pertenencia numeric, nombre text) OWNER TO geographica;

--
-- Name: ae_add_institucion(numeric, numeric, numeric, text, text, text, text, text, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_institucion(id_documento numeric, id_pertenencia numeric, id_persona_rol_pertenencia numeric, nombre text, rol text, motivo text, tipo_atr_doc text, descripcion text, dopertenencia boolean DEFAULT true) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
  _r record;
  _q text;
  _documento record;
  _id_persona_historica numeric;
BEGIN

  _q =  format('
      SELECT
        fecha_inicio,
        precision_inicio
      FROM pertenencia p JOIN documento d ON p.fk_documento_id=d.id_documento
      WHERE p.tipo_atr_doc=''Emisión'' AND d.id_documento = %s', id_documento);
  EXECUTE _q INTO _documento;

  _q := format('SELECT ph.id_persona_historica FROM persona_historica ph WHERE ph.nombre=''Anónimo'' ORDER BY id_persona_historica LIMIT 1');
  EXECUTE _q INTO _r;
  _id_persona_historica = _r.id_persona_historica;

  -- Rol
  _q := format('INSERT INTO rol (nombre) VALUES(''%s'') ON CONFLICT DO NOTHING RETURNING nombre', rol);
  EXECUTE _q INTO _r;

  IF _id_persona_historica IS NULL
  THEN
    -- Anonimo
    _q := format('INSERT INTO persona_historica (nombre) VALUES (''Anónimo'') ON CONFLICT DO NOTHING RETURNING id_persona_historica');
    EXECUTE _q INTO _r;
    _id_persona_historica = _r.id_persona_historica;
  END IF;

  -- Institucion
  _q = format('INSERT INTO institucion (nombre) VALUES (%L) ON CONFLICT DO NOTHING RETURNING nombre', nombre);
  EXECUTE _q INTO _r;
  
  IF doPertenencia
  THEN
    -- Pertenencia
    IF id_pertenencia IS NULL
    THEN
      _q := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, motivo, fecha_inicio, precision_inicio) VALUES
      (%s, ''%s'', ''%s'', ''%s'', ''%s'') RETURNING id_pertenencia', id_documento, tipo_atr_doc, motivo, _documento.fecha_inicio, _documento.precision_inicio);
    ELSE
      _q := format('UPDATE pertenencia SET fk_documento_id=%s, tipo_atr_doc=''%s'', motivo=''%s'' WHERE id_pertenencia=%s RETURNING id_pertenencia', id_documento, tipo_atr_doc, motivo, id_pertenencia);
    END IF;
    EXECUTE _q INTO _r;
    IF _r.id_pertenencia IS NOT NULL
    THEN
      id_pertenencia = _r.id_pertenencia;
    END IF;

  END IF;


  -- Persona_rol_pertenencia
  IF id_persona_rol_pertenencia IS NULL
  THEN
    _q = format('INSERT INTO persona_rol_pertenencia (fk_pertenencia_id, fk_persona_historica_id, descripcion)
    VALUES (%s, %s, %L) RETURNING id_persona_rol_pertenencia', quote_nullable(id_pertenencia), _id_persona_historica, descripcion);
  ELSE
    _q = format('UPDATE persona_rol_pertenencia SET fk_pertenencia_id=%s, fk_persona_historica_id=%s, descripcion=%L
      WHERE id_persona_rol_pertenencia=%s RETURNING id_persona_rol_pertenencia', quote_nullable(id_pertenencia), _id_persona_historica, descripcion, id_persona_rol_pertenencia);
  END IF;
  EXECUTE _q INTO _r;
  IF _r.id_persona_rol_pertenencia IS NOT NULL
  THEN
    id_persona_rol_pertenencia := _r.id_persona_rol_pertenencia;
  END IF;


  -- Persona_rol_pertenencia_rel_rol
  _q = format('DELETE FROM persona_rol_pertenencia_rel_rol WHERE fk_rol_nombre=''%s'' AND fk_persona_rol_pertenencia=%s RETURNING *', rol, id_persona_rol_pertenencia);
  EXECUTE _q INTO _r;
  _q = format('INSERT INTO persona_rol_pertenencia_rel_rol (fk_rol_nombre, fk_persona_rol_pertenencia) VALUES (''%s'', %s) RETURNING *', rol, id_persona_rol_pertenencia);
  EXECUTE _q INTO _r;

  -- Persona_rol_pertenencia_rel_institucion
  -- First deletes
  _q := format('DELETE FROM persona_rol_pertenencia_rel_institucion WHERE fk_persona_rol_pertenencia_id=%s RETURNING *', id_persona_rol_pertenencia);
  EXECUTE _q INTO _r;
  _q := format('INSERT INTO persona_rol_pertenencia_rel_institucion (fk_persona_rol_pertenencia_id, fk_institucion_nombre)
    VALUES (%s, %L) RETURNING *', id_persona_rol_pertenencia, nombre);
  EXECUTE _q INTO _r;

  RETURN _r.fk_persona_rol_pertenencia_id;

END;
$$;


ALTER FUNCTION public.ae_add_institucion(id_documento numeric, id_pertenencia numeric, id_persona_rol_pertenencia numeric, nombre text, rol text, motivo text, tipo_atr_doc text, descripcion text, dopertenencia boolean) OWNER TO postgres;

--
-- Name: ae_add_institucion_linea(numeric, numeric, numeric, text, text, text, boolean); Type: FUNCTION; Schema: public; Owner: geographica
--

CREATE FUNCTION public.ae_add_institucion_linea(id_documento numeric, id_persona_rol_pertenencia numeric, id_linea numeric, nombre text, rol text, descripcion text, dopertenencia boolean DEFAULT true) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
  _r record;
  _q text;
  _documento record;
  _id_persona_historica numeric;
BEGIN

  _q := format('SELECT ph.id_persona_historica FROM persona_historica ph WHERE ph.nombre=''Anónimo'' ORDER BY id_persona_historica LIMIT 1');
  EXECUTE _q INTO _r;
  _id_persona_historica = _r.id_persona_historica;
  RAISE NOTICE '%', _id_persona_historica;

  -- Rol
  _q := format('INSERT INTO rol (nombre) VALUES(''%s'') ON CONFLICT DO NOTHING RETURNING nombre', rol);
  RAISE NOTICE '%', _q;
  EXECUTE _q INTO _r;
  RAISE NOTICE '%', _r.nombre;

  IF _id_persona_historica IS NULL
  THEN
    -- Anonimo
    _q := format('INSERT INTO persona_historica (nombre) VALUES (''Anónimo'') ON CONFLICT DO NOTHING RETURNING id_persona_historica');
    EXECUTE _q INTO _r;
    _id_persona_historica = _r.id_persona_historica;
  END IF;
  RAISE NOTICE '%', _id_persona_historica;

  -- Institucion
  _q = format('INSERT INTO institucion (nombre) VALUES (%L) ON CONFLICT DO NOTHING RETURNING nombre', nombre);
  EXECUTE _q INTO _r;


  -- Persona_rol_pertenencia
  IF id_persona_rol_pertenencia IS NULL
  THEN
    _q = format('INSERT INTO persona_rol_pertenencia (fk_persona_historica_id, descripcion)
    VALUES (%s, %s, %L) RETURNING id_persona_rol_pertenencia', _id_persona_historica, descripcion);
  ELSE
    _q = format('UPDATE persona_rol_pertenencia SET fk_persona_historica_id=%s, descripcion=%L
      WHERE id_persona_rol_pertenencia=%s RETURNING id_persona_rol_pertenencia', _id_persona_historica, descripcion, id_persona_rol_pertenencia);
  END IF;
  RAISE NOTICE '%', _q;
  EXECUTE _q INTO _r;
  IF _r.id_persona_rol_pertenencia IS NOT NULL
  THEN
    id_persona_rol_pertenencia := _r.id_persona_rol_pertenencia;
  END IF;


  -- Persona_rol_pertenencia_rel_rol
  _q = format('DELETE FROM persona_rol_pertenencia_rel_rol WHERE fk_rol_nombre=''%s'' AND fk_persona_rol_pertenencia=%s RETURNING *', rol, id_persona_rol_pertenencia);
  EXECUTE _q INTO _r;
  _q = format('INSERT INTO persona_rol_pertenencia_rel_rol (fk_rol_nombre, fk_persona_rol_pertenencia) VALUES (''%s'', %s) RETURNING *', rol, id_persona_rol_pertenencia);
  EXECUTE _q INTO _r;
  RAISE NOTICE '%', _r.fk_persona_rol_pertenencia;



  -- Persona_rol_pertenencia_rel_institucion
  -- First deletes
  _q := format('DELETE FROM persona_rol_pertenencia_rel_institucion WHERE fk_persona_rol_pertenencia_id=%s RETURNING *', id_persona_rol_pertenencia);
  EXECUTE _q INTO _r;
  _q := format('INSERT INTO persona_rol_pertenencia_rel_institucion (fk_persona_rol_pertenencia_id, fk_institucion_nombre)
    VALUES (%s, %L) RETURNING *', id_persona_rol_pertenencia, nombre);
  EXECUTE _q INTO _r;


  -- First delete
  _q = format('DELETE FROM persona_rol_pertenecia_rel_linea WHERE fk_linea=%s AND fk_persona_rol_pertenencia_id=%s RETURNING *', id_linea, id_personrol_pertenencia);
  EXECUTE _q INTO _r;
  _q = format('INSERT INTO persona_rol_pertenencia_rel_linea (fk_linea, fk_persona_rol_pertenencia_id)
    VALUES (%s, %s) RETURNING *', id_linea, id_persona_rol_pertenencia);
  EXECUTE _q INTO _r;

  RETURN id_persona_rol_pertenencia;

END;
$$;


ALTER FUNCTION public.ae_add_institucion_linea(id_documento numeric, id_persona_rol_pertenencia numeric, id_linea numeric, nombre text, rol text, descripcion text, dopertenencia boolean) OWNER TO geographica;

--
-- Name: ae_add_interrogatorio_preguntas(numeric, json[], jsonb[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_interrogatorio_preguntas(id_document numeric, preguntas json[], testigos jsonb[]) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE

  _result record;
  _query text;
  _item json;

  _id_map jsonb;
  _testigos_new jsonb[];

  _testigo jsonb;
  _respuesta jsonb;
  _respuestas_new jsonb;
  
BEGIN

  _id_map = '{}'::jsonb;

  _query := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Pregunta');
  EXECUTE _query INTO _result;

  FOREACH _item IN ARRAY preguntas
  LOOP
    _query := format('INSERT INTO pertenencia (
      tipo_atr_doc, motivo, orden, fk_documento_id
    ) VALUES (%L, %L, %s, %s) RETURNING id_pertenencia', 'Pregunta', _item->>'description', _item->'order', id_document);
    EXECUTE _query INTO _result;
    _id_map = _id_map || jsonb_build_object(_item->>'id_pertenencia', _result.id_pertenencia);
  END LOOP;
  
  _testigos_new = ARRAY[]::jsonb[];
  FOREACH _testigo IN ARRAY testigos
  LOOP
    _respuestas_new = '[]'::jsonb;
    FOR _respuesta IN (SELECT jsonb_array_elements(_testigo->'respuestas'))
    LOOP
      _respuestas_new = _respuestas_new || jsonb_set(_respuesta, '{id_pertenencia_pregunta}'::text[], _id_map->(_respuesta->>'id_pertenencia_pregunta'));
    END LOOP;
    _testigos_new = _testigos_new || jsonb_set(_testigo, '{respuestas}'::text[], _respuestas_new);
  END LOOP;

  RAISE NOTICE 'TESTIGOS (Original) %', testigos;
  RAISE NOTICE 'TESTIGOS (Modified) %', _testigos_new;

  PERFORM ae_add_interrogatorio_respuestas(
    id_document,
    _testigos_new::json[]
  );

  RETURN id_document;

END;
$$;


ALTER FUNCTION public.ae_add_interrogatorio_preguntas(id_document numeric, preguntas json[], testigos jsonb[]) OWNER TO postgres;

--
-- Name: ae_add_interrogatorio_respuestas(numeric, json[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_interrogatorio_respuestas(id_document numeric, testigos json[]) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE

  _result record;
  _query text;
  _item json;
  _tortura text;
  _respuesta json;

  _testigo_batch jsonb[];
  _testigo_ids jsonb[];
  _index numeric;
  _testigo jsonb;
  
BEGIN

  -- Borrar testigos y respuestas
  -- _query := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND (tipo_atr_doc=%L OR tipo_atr_doc=%L) RETURNING *', id_document, 'Testigo', 'Respuesta');
  -- EXECUTE _query INTO _result;

  _testigo_batch = ARRAY[]::jsonb[];
  FOREACH _item IN ARRAY testigos
  LOOP
    _testigo_batch = _testigo_batch || (
      (_item->'person')::jsonb || jsonb_build_object('descripcion', _item->>'description')
    );
  END LOOP;
  _testigo_ids = ae_add_person_batch(id_document, 'Testigo'::text, _testigo_batch);

  _index = 1;
  FOREACH _item IN ARRAY testigos
  LOOP

    _testigo = _testigo_ids[_index];
    _index = _index + 1;
    
    _query := format(
      'UPDATE pertenencia SET fecha_inicio = %L::date, precision_inicio = %L WHERE id_pertenencia = %s RETURNING *',
      _item->>'date', _item->>'date_precision', _testigo->'id_pertenencia'
    );
    EXECUTE _query INTO _result;   

    -- Borrar torturas
    _query := format('DELETE FROM persona_rol_pertenencia_rel_tortura WHERE fk_persona_rol_pertenencia_id=%s RETURNING *', _testigo->'id_prp');
    EXECUTE _query INTO _result;

    -- Insertar torturas y relacion con prp_testigo
    FOR _tortura IN (SELECT json_array_elements_text(_item->'torturas'))
    LOOP
      _query := format('INSERT INTO tortura (texto) values (%L) ON CONFLICT DO NOTHING RETURNING *', _tortura);
      EXECUTE _query INTO _result;

      _query := format('INSERT INTO persona_rol_pertenencia_rel_tortura (fk_persona_rol_pertenencia_id, fk_tortura_texto) VALUES (%s, %L) RETURNING *', _testigo->'id_prp', _tortura);
      EXECUTE _query INTO _result;      
    END LOOP;

    -- Borrar relaciones testigo-respuesta
    _query := format('DELETE FROM respuesta WHERE fk_persona_rol_pertenencia_id=%s RETURNING *', _testigo->'id_prp');
    EXECUTE _query INTO _result;

    -- Insertar respuestas
    FOR _respuesta IN (SELECT json_array_elements(_item->'respuestas'))
    LOOP
      _query := format('INSERT INTO pertenencia (motivo, fk_pertenencia_id, fk_documento_id, tipo_atr_doc)
      VALUES (%L, %s, %s, %L) RETURNING *', _respuesta->>'description', _respuesta->'id_pertenencia_pregunta', id_document, 'Respuesta');
      EXECUTE _query INTO _result;

      _query := format('INSERT INTO respuesta (fk_pertenencia_id, fk_persona_rol_pertenencia_id)
      VALUES (%s, %s) RETURNING *', _result.id_pertenencia, _testigo->'id_prp');
      EXECUTE _query INTO _result;      
      
    END LOOP;
    
  END LOOP;

  RETURN id_document;

END;
$$;


ALTER FUNCTION public.ae_add_interrogatorio_respuestas(id_document numeric, testigos json[]) OWNER TO postgres;

--
-- Name: ae_add_inventario_bienes(numeric, json[], json[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_inventario_bienes(id_document numeric, owner json[], notary json[]) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE

  _r record;
  _q text;
  _aux json;

BEGIN

  PERFORM ae_add_person_batch(id_document, 'Propietario'::text, owner::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Escribano'::text, notary::jsonb[]);

  RETURN id_document;

END;
$$;


ALTER FUNCTION public.ae_add_inventario_bienes(id_document numeric, owner json[], notary json[]) OWNER TO postgres;

--
-- Name: ae_add_juicio_residencia(numeric, json[], json[], json[], json[], text, json[], json[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_juicio_residencia(id_document numeric, applicant json[], defendant json[], witness json[], notary json[], diligence text, charges json[], appeals json[]) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE

  _r record;
  _q text;
  _aux json;

BEGIN

  PERFORM ae_add_person_batch(id_document, 'Demandante'::text, applicant::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Demandado'::text, defendant::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Testigo'::text, witness::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Escribano'::text, notary::jsonb[]);

  --Creo la diligencia preliminar
  _q := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Deligencia_preliminar');
  EXECUTE _q INTO _r;

  _q := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, motivo) VALUES (%s, %L, %L) RETURNING id_pertenencia', id_document, 'Deligencia_preliminar', diligence);
  EXECUTE _q INTO _r;

  --Crea los cargos
  _q := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Cargo');
  EXECUTE _q INTO _r;

  FOREACH _aux IN ARRAY charges
  LOOP
    _q := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, motivo, orden) VALUES (%s, %L, %L, %s) RETURNING id_pertenencia', id_document, 'Cargo', _aux->>'description', _aux->>'order');
    EXECUTE _q INTO _r;
  END LOOP;

  --Crea las apelaciones
  _q := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Apelacion');
  EXECUTE _q INTO _r;

  FOREACH _aux IN ARRAY appeals
  LOOP
    _q := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, motivo, orden) VALUES (%s, %L, %L, %s) RETURNING id_pertenencia', id_document, 'Apelacion', _aux->>'description', _aux->>'order');
    EXECUTE _q INTO _r;
  END LOOP;


  RETURN id_document;

END;
$$;


ALTER FUNCTION public.ae_add_juicio_residencia(id_document numeric, applicant json[], defendant json[], witness json[], notary json[], diligence text, charges json[], appeals json[]) OWNER TO postgres;

--
-- Name: ae_add_linea_objeto_arqueologico(numeric, numeric, numeric, text, text, text, text, numeric, numeric, text, text, json[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_linea_objeto_arqueologico(linea_id numeric, individuo_arqueologico_id numeric, objeto_arqueologico_id numeric, objeto_arqueologico_nombre text, origen text, tipo text, descripcion text, cantidad numeric, material_id numeric, material_nombre text, color text, unidades json[]) RETURNS json
    LANGUAGE plpgsql
    AS $$
DECLARE
  _result record;
  _obj record;
  _mat record;
  _lin record;
  _lin_ue record;
  _query text;
  _item json;

BEGIN
  -- El individuo arqueologico (unidad estratigrafica) ya esta creado previamente, por lo que no es necesario controlar nada sobre dicha tabla.
  
  -- Insertamos objeto arqueologico
  IF objeto_arqueologico_id is NULL AND objeto_arqueologico_nombre IS NOT NULL
  THEN
    objeto_arqueologico_id := (SELECT o.id_objeto FROM objeto_arqueologico o WHERE lower(o.nombre) = lower(objeto_arqueologico_nombre) LIMIT 1);
    IF objeto_arqueologico_id IS NULL
    THEN
      _query := format('INSERT INTO objeto_arqueologico(nombre) VALUES (%L) ON CONFLICT DO NOTHING RETURNING *', objeto_arqueologico_nombre);  
      EXECUTE _query INTO _obj;
      objeto_arqueologico_id = _obj.id_objeto;
    END IF;
  END IF;
  
  -- Insertamos material
  IF material_id is NULL AND material_nombre IS NOT NULL
  THEN
    --_query := format('INSERT INTO material(nombre) VALUES (%L) ON CONFLICT DO NOTHING RETURNING *', material_nombre);
    --EXECUTE _query INTO _mat;
    --material_id = _mat.id_material; 
    material_id = ae_add_material(material_nombre, material_id, null::numeric);
  END IF;

  -- Insertamos linea
  IF linea_id is NULL
  THEN
    _query := format('INSERT INTO linea(descripcion,cantidad,color,fk_material_id) VALUES (%L,%L,%L,%L) ON CONFLICT DO NOTHING RETURNING *', descripcion, cantidad, lower(color), material_id);
  ELSE
    _query := format('UPDATE linea 
    SET descripcion=%L, cantidad=%L, color=%L, fk_material_id=%L 
    WHERE id_linea=%s RETURNING *', descripcion, cantidad, lower(color), material_id, linea_id);
  END IF;
  EXECUTE _query INTO _lin;
  linea_id = _lin.id_linea; 

  -- Linea <-> Objeto_arqueologico (N:M)
  _query := format('DELETE FROM objeto_arqueologico_rel_linea WHERE fk_linea=%s RETURNING *', linea_id);
  EXECUTE _query INTO _result;

  _query := format('INSERT INTO objeto_arqueologico_rel_linea(fk_objeto_arqueologico,fk_linea) VALUES (%s,%s) ON CONFLICT DO NOTHING RETURNING *', objeto_arqueologico_id, linea_id);
  EXECUTE _query INTO _result;

    -- Linea <-> Unidad (N:M)
  _query := format('DELETE FROM linea_rel_unidad WHERE fk_linea_id=%s RETURNING *', linea_id);
  EXECUTE _query INTO _result;

  FOREACH _item IN ARRAY unidades
  LOOP
    _query := format('INSERT INTO linea_rel_unidad (fk_linea_id, fk_unidad_nombre, valor) VALUES (%s, %L, %L) RETURNING *', linea_id, _item->>'nombre', _item->>'value');
    EXECUTE _query INTO _result;
  END LOOP;
  
  -- Linea <-> Individuo_arqueologico (N:M)
  _query := format('DELETE FROM individuo_arqueologico_rel_linea WHERE fk_linea=%s RETURNING *', linea_id);
  EXECUTE _query INTO _lin_ue;

  _query := format('INSERT INTO individuo_arqueologico_rel_linea(fk_individuo_arqueologico,fk_linea,origen,tipo) VALUES (%s,%s,%L,%L) ON CONFLICT DO NOTHING RETURNING *', individuo_arqueologico_id, linea_id, origen, tipo);
  EXECUTE _query INTO _lin_ue;
  
  RETURN to_json(_lin_ue);

END;
$$;


ALTER FUNCTION public.ae_add_linea_objeto_arqueologico(linea_id numeric, individuo_arqueologico_id numeric, objeto_arqueologico_id numeric, objeto_arqueologico_nombre text, origen text, tipo text, descripcion text, cantidad numeric, material_id numeric, material_nombre text, color text, unidades json[]) OWNER TO postgres;

--
-- Name: ae_add_lote_entierro(numeric, text, text, text, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_lote_entierro(id_entierro numeric, unid_estratigrafica text, fk_genero_lote_nombre text, fk_edad_lote_nombre text, cantidad numeric) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
  _r record;
  _q text;
  _id_lote numeric;

BEGIN

  -- Creo el lote
  _q := format('INSERT INTO lote (unid_estratigrafica) VALUES (%L) RETURNING id_lote', unid_estratigrafica);
  EXECUTE _q INTO _r;
  _id_lote = _r.id_lote;

  --Creo el entierro_rel_lote
  _q := format('INSERT INTO entierro_rel_lote (fk_entierro_id, fk_lote_id) VALUES (%s, %s) RETURNING *', id_entierro, _id_lote);
  EXECUTE _q INTO _r;

  --Creo el lote_genero_edad
  _q := format('INSERT INTO lote_genero_edad (fk_lote_id, fk_genero_lote_nombre, fk_edad_lote_nombre, cantidad) VALUES (%s, %L, %L, %L) RETURNING *', _id_lote, fk_genero_lote_nombre, fk_edad_lote_nombre, cantidad);
  EXECUTE _q INTO _r;

  RETURN _id_lote;

END;
$$;


ALTER FUNCTION public.ae_add_lote_entierro(id_entierro numeric, unid_estratigrafica text, fk_genero_lote_nombre text, fk_edad_lote_nombre text, cantidad numeric) OWNER TO postgres;

--
-- Name: ae_add_lugar(numeric, text); Type: FUNCTION; Schema: public; Owner: geographica
--

CREATE FUNCTION public.ae_add_lugar(id_lugar numeric, lugar text) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
  _r record;
  _q text;

BEGIN

  -- Lugar
  IF id_lugar IS NULL
  THEN
    _q = format('INSERT INTO lugar (nombre) VALUES(''%s'') RETURNING id_lugar', lugar);
  ELSE
    _q = format('UPDATE lugar SET nombre=''%s'' WHERE id_lugar=%s RETURNING id_lugar', lugar, id_lugar);
  END IF;
  EXECUTE _q INTO _r;
  id_lugar = _r.id_lugar;

  RETURN id_lugar;

END;
$$;


ALTER FUNCTION public.ae_add_lugar(id_lugar numeric, lugar text) OWNER TO geographica;

--
-- Name: ae_add_lugar(text, numeric); Type: FUNCTION; Schema: public; Owner: geographica
--

CREATE FUNCTION public.ae_add_lugar(lugar text, id_lugar numeric DEFAULT NULL::numeric) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
  _r record;
  _q text;

BEGIN

  -- Lugar
  IF lugar IS NOT NULL
  THEN

    IF id_lugar IS NULL
    THEN
      _q = format('INSERT INTO lugar (nombre) VALUES(%L) RETURNING id_lugar', lugar);
    ELSE
      _q = format('UPDATE lugar SET nombre=%L WHERE id_lugar=%s RETURNING id_lugar', lugar, id_lugar);
    END IF;
    RAISE NOTICE '%', _q;
    EXECUTE _q INTO _r;
    id_lugar = _r.id_lugar;
  END IF;

  RETURN id_lugar;

END;
$$;


ALTER FUNCTION public.ae_add_lugar(lugar text, id_lugar numeric) OWNER TO geographica;

--
-- Name: ae_add_lugar_complete(numeric, text, text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_lugar_complete(id_lugar numeric, lugar text, tipo_lugar text, localizacion text, region_cont text, geom text, tipo_geom text) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.ae_add_lugar_complete(id_lugar numeric, lugar text, tipo_lugar text, localizacion text, region_cont text, geom text, tipo_geom text) OWNER TO postgres;

--
-- Name: ae_add_material(text, numeric, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_material(material text, id_material numeric DEFAULT NULL::numeric, fk_material_id numeric DEFAULT NULL::numeric) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.ae_add_material(material text, id_material numeric, fk_material_id numeric) OWNER TO postgres;

--
-- Name: ae_add_mtdna(numeric, numeric, text, text, text, text, text, numeric, text, text, text, text, text, text, text, text, text, text, text, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, date, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_mtdna(id_mtdna numeric, fk_sample_id numeric, successful text, haplo_vs_rcrs text, seq_range text, class_method text, haplogroup text, overall_rank numeric, superhaplo text, haplo_ancest_origin text, expect_not_fd_polys text, private_polys text, heteroplasmies text, alter_haplo text, fasta text, bam_file text, vcf_file text, possible_mat_relat text, seq_strategy text, libraries_seq numeric, raw_reads numeric, mapped_reads numeric, whole_coverage numeric, mean_read_depth numeric, fraction numeric, average_length numeric, contamination numeric, updated_on date, comments text, interpretation text) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
  _r record;
  _q text;
BEGIN

  IF id_mtdna IS NULL
  THEN
    _q := format('INSERT INTO mtdna (
      fk_sample_id,
      successful,
      haplo_vs_rcrs,
      seq_range,
      class_method,
      haplogroup,
      overall_rank,
      superhaplo,
      haplo_ancest_origin,
      expect_not_fd_polys,
      private_polys,
      heteroplasmies,
      alter_haplo,
      fastA,
      bam_file,
      vcf_file,
      possible_mat_relat,
      seq_strategy,
      libraries_seq,
      raw_reads,
      mapped_reads,
      whole_coverage,
      mean_read_depth,
      fraction,
      average_length,
      contamination,
      updated_on,
      comments,
      interpretation
      ) VALUES (
        %s, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L,
        %L, %L, %L, %L, %L, %L, %L::date, %L, %L
      ) RETURNING id_mtdna',
      fk_sample_id,
      successful,
      haplo_vs_rcrs,
      seq_range,
      class_method,
      haplogroup,
      overall_rank,
      superhaplo,
      haplo_ancest_origin,
      expect_not_fd_polys,
      private_polys,
      heteroplasmies,
      alter_haplo,
      fastA,
      bam_file,
      vcf_file,
      possible_mat_relat,
      seq_strategy,
      libraries_seq,
      raw_reads,
      mapped_reads,
      whole_coverage,
      mean_read_depth,
      fraction,
      average_length,
      contamination,
      updated_on,
      comments,
      interpretation
    );
  ELSE
    _q := format('UPDATE mtdna SET
      fk_sample_id = %s,
      successful = %L,
      haplo_vs_rcrs = %L,
      seq_range = %L,
      class_method = %L,
      haplogroup = %L,
      overall_rank = %L,
      superhaplo = %L,
      haplo_ancest_origin = %L,
      expect_not_fd_polys = %L,
      private_polys = %L,
      heteroplasmies = %L,
      alter_haplo = %L,
      fastA = %L,
      bam_file = %L,
      vcf_file = %L,
      possible_mat_relat = %L,
      seq_strategy = %L,
      libraries_seq = %L,
      raw_reads = %L,
      mapped_reads = %L,
      whole_coverage = %L,
      mean_read_depth = %L,
      fraction = %L,
      average_length = %L,
      contamination = %L,
      updated_on = %L::date,
      comments = %L,
      interpretation = %L
      WHERE id_mtdna = %s
      RETURNING *',
      fk_sample_id,
      successful,
      haplo_vs_rcrs,
      seq_range,
      class_method,
      haplogroup,
      overall_rank,
      superhaplo,
      haplo_ancest_origin,
      expect_not_fd_polys,
      private_polys,
      heteroplasmies,
      alter_haplo,
      fastA,
      bam_file,
      vcf_file,
      possible_mat_relat,
      seq_strategy,
      libraries_seq,
      raw_reads,
      mapped_reads,
      whole_coverage,
      mean_read_depth,
      fraction,
      average_length,
      contamination,
      updated_on,
      comments,
      interpretation,
      id_mtdna
    );
  END IF;
  EXECUTE _q INTO _r;

  RETURN _r.id_mtdna;

END;
$$;


ALTER FUNCTION public.ae_add_mtdna(id_mtdna numeric, fk_sample_id numeric, successful text, haplo_vs_rcrs text, seq_range text, class_method text, haplogroup text, overall_rank numeric, superhaplo text, haplo_ancest_origin text, expect_not_fd_polys text, private_polys text, heteroplasmies text, alter_haplo text, fasta text, bam_file text, vcf_file text, possible_mat_relat text, seq_strategy text, libraries_seq numeric, raw_reads numeric, mapped_reads numeric, whole_coverage numeric, mean_read_depth numeric, fraction numeric, average_length numeric, contamination numeric, updated_on date, comments text, interpretation text) OWNER TO postgres;

--
-- Name: ae_add_nombramiento(numeric, json[], json[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_nombramiento(id_document numeric, senders json[], recipients json[]) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE

  _result record;
  _query text;
  _recipient json;
  _agr_bienes record;
  _role json;
  _id_objeto numeric;
  _linea record;
  _unit json;
  _resignant json;

  _recipients_batch jsonb[];
  _recipient_ids jsonb[];

  _ids_pertenencia_recipient numeric[];
  _id_pertenencia numeric;
  _index numeric;
  _ids_linea numeric[];
  _ids_resignant numeric[];
  _id_pertenencia_resignant numeric;

BEGIN

  PERFORM ae_add_person_batch(id_document, 'Emisor'::text, senders::jsonb[]);

  -- upsert persona_rol_pertenencia and related for every recipient
  _recipients_batch = ARRAY[]::jsonb[];
  FOREACH _recipient IN ARRAY recipients
  LOOP
    _recipients_batch = _recipients_batch || (
      (_recipient->'recipient')::jsonb || jsonb_build_object('order', (_recipient->>'order')::numeric)
    );
  END LOOP;
  _recipient_ids = ae_add_person_batch(id_document, 'Transacción'::text, _recipients_batch);

  _ids_pertenencia_recipient = ARRAY[]::jsonb[];
  FOREACH _recipient IN ARRAY _recipient_ids
  LOOP
    _ids_pertenencia_recipient = _ids_pertenencia_recipient || (_recipient->>'id_pertenencia')::numeric;
  END LOOP;

  -- delete from agr_bienes where id not related with recipients from input
  _query := format('DELETE FROM agrupacion_bienes ab
    WHERE ab.id_agrupacion_bienes IN (
      SELECT prab.fk_agrupacion_bienes_id FROM pertenencia_rel_agrupacion_bienes prab
      JOIN pertenencia p ON p.id_pertenencia = prab.fk_pertenencia_id
      WHERE p.id_pertenencia NOT IN (SELECT unnest(%L::numeric[]))
      AND p.fk_documento_id = %s
    ) RETURNING *', _ids_pertenencia_recipient, id_document);
  EXECUTE _query INTO _result;

  _index = 1;
  FOREACH _recipient IN ARRAY recipients
  LOOP
    -- create agr_bienes if not exists 
    -- and create relation with id_pertenencia from recipient
    _id_pertenencia = (_recipient_ids[_index]->>'id_pertenencia')::numeric;
    _index = _index + 1;

    _query := format('
      SELECT id_agrupacion_bienes FROM agrupacion_bienes ab 
      INNER JOIN pertenencia_rel_agrupacion_bienes prab ON prab.fk_agrupacion_bienes_id = ab.id_agrupacion_bienes
      WHERE prab.fk_pertenencia_id = %s
    ', _id_pertenencia);
    EXECUTE _query INTO _result;
    RAISE NOTICE 'SELECT agr_bienes query: %', _query;

    _query := format('
      SELECT ae_add_agrupacion_bienes(%L, %s, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
    ', _result.id_agrupacion_bienes, _id_pertenencia);
    EXECUTE _query INTO _agr_bienes;

    _ids_linea = ARRAY[]::numeric[];
    FOR _role IN (SELECT json_array_elements(_recipient->'roles'))
    LOOP
      _ids_linea = _ids_linea || (_role->>'id_linea')::numeric;
    END LOOP;

    -- delete from linea l where l related with agr_bienes and not in array of id_linea from input
    _query := format('DELETE FROM linea l WHERE l.fk_agrupacion_bienes_id = %s
      AND l.id_linea NOT IN (SELECT unnest(%L::numeric[]))
      RETURNING *', _agr_bienes.ae_add_agrupacion_bienes, _ids_linea);
    EXECUTE _query INTO _result;

    FOR _role IN (SELECT json_array_elements(_recipient->'roles'))
    LOOP
      _query := format('INSERT INTO objeto (nombre) VALUES (%L) ON CONFLICT (nombre) DO UPDATE SET nombre = %L RETURNING id_objeto', _role->>'role', _role->>'role');
      EXECUTE _query INTO _result;

      IF _role->>'id_linea' IS NULL
      THEN
        _query := format('
          INSERT INTO linea (fk_agrupacion_bienes_id, descripcion, fk_objeto_id, compra_cargo, condiciones_nombramiento) 
          VALUES (%s, %L, %s, %L, %L) RETURNING *
        ', _agr_bienes.ae_add_agrupacion_bienes, _role->>'motive', _result.id_objeto, _role->>'buy_type', _role->>'role_condition');
      ELSE
        _query := format('UPDATE linea SET 
          fk_agrupacion_bienes_id = %s, descripcion = %L, fk_objeto_id = %s, 
          compra_cargo = %L, condiciones_nombramiento = %L
          WHERE id_linea = %s
          RETURNING *', _agr_bienes.ae_add_agrupacion_bienes, _role->>'motive', _result.id_objeto, _role->>'buy_type', _role->>'role_condition', _role->>'id_linea');
      END IF;
      EXECUTE _query INTO _linea;

      -- delete and insert units
      _query := format('DELETE FROM linea_rel_unidad WHERE fk_linea_id=%s RETURNING *', _linea.id_linea);
      EXECUTE _query INTO _result;
      
      FOR _unit IN (SELECT json_array_elements(_role->'units'))
      LOOP
        _query := format('INSERT INTO unidad (nombre, tipo) VALUES (%L,%L) ON CONFLICT DO NOTHING RETURNING nombre', _unit->>'unit', 'Moneda');
        EXECUTE _query INTO _result;
        _query := format('INSERT INTO linea_rel_unidad (fk_linea_id, fk_unidad_nombre, valor) VALUES (%s, %L, %s) RETURNING *', _linea.id_linea, _unit->>'unit', _unit->>'value');
        EXECUTE _query INTO _result;        
      END LOOP;

      -- delete and insert resignats
      _ids_resignant = ARRAY[]::numeric[];
      FOR _resignant IN (SELECT json_array_elements(_role->'resignant'))
      LOOP
        _ids_resignant = _ids_resignant || (_resignant->>'id_prp')::numeric;
      END LOOP;

      _query = format('DELETE FROM pertenencia WHERE fk_documento_id = %s AND tipo_atr_doc = %L
        AND id_pertenencia IN (
          SELECT fk_pertenencia_id FROM persona_rol_pertenencia prp
          JOIN persona_rol_pertenencia_rel_linea prpl ON prpl.fk_persona_rol_pertenencia_id = prp.id_persona_rol_pertenencia
          WHERE prpl.fk_linea = %s
          AND prpl.fk_persona_rol_pertenencia_id NOT IN (SELECT unnest(%L::numeric[]))
        ) RETURNING *', id_document, 'Renunciante', _linea.id_linea, _ids_resignant);
      EXECUTE _query INTO _result;

      FOR _resignant IN (SELECT json_array_elements(_role->'resignant'))
      LOOP
        _id_pertenencia_resignant = (
          SELECT fk_pertenencia_id FROM persona_rol_pertenencia
          WHERE id_persona_rol_pertenencia = (_resignant->>'id_prp')::numeric
        );
        _query := format('
          SELECT ae_add_persona_linea(%s,%L,%s,%L,%s, %L,%L,%L)
        ', id_document, _id_pertenencia_resignant, (_resignant->>'id_persona_historica')::numeric, (_resignant->>'id_prp')::numeric, _linea.id_linea, _resignant->>'nombre', 'Renunciante', _resignant->>'descripcion');
        EXECUTE _query INTO _result;
      END LOOP;

    END LOOP;

  END LOOP;

  RETURN id_document;

END;
$$;


ALTER FUNCTION public.ae_add_nombramiento(id_document numeric, senders json[], recipients json[]) OWNER TO postgres;

--
-- Name: ae_add_objeto(numeric, numeric, numeric, numeric, text, text, text, json[], text, numeric, text, numeric, text, numeric, numeric, text, numeric, text, boolean, json[], json[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_objeto(id_documento numeric, id_pertenencia numeric, id_agrupacion_bienes numeric, id_linea numeric, descripcion_objeto text, calidad text, estado text, unidades json[], tipo_atr_doc text, numero numeric, color text, id_material numeric, material text, fk_material_id numeric, id_objeto numeric, objeto text, id_origen numeric, tipo_impuesto text, dopertenencia boolean DEFAULT false, peoplerelations json[] DEFAULT ARRAY[]::json[], placerelations json[] DEFAULT ARRAY[]::json[]) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
  _r record;
  _unidad json;
  _unidad_nombre text;
  _q text;
  _relacion json;
  id_pertenencia_relacion numeric;
  _id_persona_rol_pertenencia_relacion numeric;

  _person json;
  _is_relation boolean;

BEGIN

  -- Material
  id_material = (SELECT ae_add_material(material, id_material, fk_material_id));

  -- Objeto
  id_objeto = (SELECT ae_add_simple_objeto(objeto, id_objeto, NULL));

  -- Create agrupacion_bienes if no agrupacion_bienes_id given
  IF id_agrupacion_bienes IS NULL
  THEN
    _q := format('INSERT INTO agrupacion_bienes (nombre) VALUES(null) RETURNING id_agrupacion_bienes');
    EXECUTE _q INTO _r;
    id_agrupacion_bienes = _r.id_agrupacion_bienes;
  END IF;

  -- Pertenencia y pertenencia_rel_agrupacion_bienes
  IF doPertenencia
  THEN
    IF id_pertenencia IS NULL
    THEN
      _q := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc) VALUES (%s, %s) RETURNING id_pertenencia', id_documento, quote_nullable(tipo_atr_doc));
    ELSE
      _q := format('UPDATE pertenencia SET tipo_atr_doc=%s WHERE id_pertenencia=%s RETURNING id_pertenencia', quote_nullable(tipo_atr_doc), id_pertenencia);
    END IF;
    EXECUTE _q INTO _r;
    id_pertenencia = _r.id_pertenencia;

    _q := format('
      INSERT INTO pertenencia_rel_agrupacion_bienes (fk_pertenencia_id, fk_agrupacion_bienes_id)
      VALUES (%s, %s) ON CONFLICT DO NOTHING RETURNING *',
      id_pertenencia, id_agrupacion_bienes
    );
    EXECUTE _q INTO _r;
  END IF;


  -- linea
  IF id_linea IS NULL
  THEN
    _q := format('
      INSERT INTO
        linea(fk_objeto_id, fk_agrupacion_bienes_id, descripcion, cantidad, color, calidad, estado, fk_material_id, fk_lugar_id, tipo_impuesto)
        VALUES (%s, %s, ''%s'', %s, ''%s'', ''%s'',''%s'', %s, %s, %L)
      RETURNING id_linea
    ',quote_nullable(id_objeto), id_agrupacion_bienes, descripcion_objeto, quote_nullable(numero), lower(color), calidad, estado, quote_nullable(id_material), quote_nullable(id_origen), tipo_impuesto);

  ELSE
    _q := format('
      UPDATE linea SET
        fk_objeto_id=%s,
        fk_agrupacion_bienes_id=%s,
        descripcion=%L,
        cantidad=%s,
        color=%L,
        calidad=%L,
        estado=%L,
        fk_material_id=%s,
        fk_lugar_id=%s,
        tipo_impuesto=%L
      WHERE id_linea=%s
      RETURNING id_linea
      ', quote_nullable(id_objeto), id_agrupacion_bienes, descripcion_objeto, quote_nullable(numero), lower(color), calidad, estado, quote_nullable(id_material), quote_nullable(id_origen), tipo_impuesto, id_linea);
  END IF;
  EXECUTE _q INTO _r;
  RAISE NOTICE '%', _q;
  id_linea := _r.id_linea;

  RAISE NOTICE 'id_linea: %', id_linea;

  -- Unidades
  _q := format('DELETE FROM linea_rel_unidad WHERE fk_linea_id=%s RETURNING *', id_linea);
  EXECUTE _q INTO _r;
  FOREACH _unidad IN ARRAY unidades
  LOOP
    _unidad_nombre = (SELECT ae_add_unidad(_unidad->>'nombre', _unidad->>'type'));
    _q := format('INSERT INTO linea_rel_unidad (fk_linea_id, fk_unidad_nombre, valor, es_impuesto) VALUES (%s, ''%s'', %s, %s) RETURNING *', id_linea, _unidad_nombre, _unidad->>'value', _unidad->>'is_tax');
    EXECUTE _q INTO _r;
  END LOOP;


  --Relaciones con personas

  -- Borrar relaciones
  _q := format('
    DELETE FROM pertenencia 
    WHERE fk_documento_id=%s AND id_pertenencia in(
      SELECT p.id_pertenencia
      FROM persona_rol_pertenencia_rel_linea prpl
      LEFT JOIN persona_rol_pertenencia prp on prp.id_persona_rol_pertenencia = prpl.fk_persona_rol_pertenencia_id
      LEFT JOIN pertenencia p on p.id_pertenencia = prp.fk_pertenencia_id
      WHERE p.fk_documento_id = %s AND prpl.fk_linea = %s AND p.tipo_atr_doc = %L
    )
    RETURNING *
  ',id_documento, id_documento, id_linea, 'Creación de relación');

  EXECUTE _q INTO _r;

  -- Borrar compradores y vendedores 
  _q := format('
    DELETE FROM pertenencia 
    WHERE fk_documento_id=%s 
    AND (tipo_atr_doc = %L OR tipo_atr_doc = %L OR tipo_atr_doc = %L)
    AND id_pertenencia NOT IN (
      SELECT p.id_pertenencia FROM pertenencia p
      JOIN persona_rol_pertenencia prp ON prp.fk_pertenencia_id = p.id_pertenencia
      JOIN persona_rol_pertenencia_rel_linea prpl ON prpl.fk_persona_rol_pertenencia_id = prp.id_persona_rol_pertenencia
      WHERE p.fk_documento_id = %s
      AND prpl.fk_linea <> %s
    ) RETURNING *
  ',id_documento, 'Comprador','Vendedor','Creación de relación', id_documento, id_linea);

  EXECUTE _q INTO _r;

  _q := format('
    DELETE FROM persona_rol_pertenencia_rel_linea WHERE fk_linea = %s
    RETURNING *
  ', id_linea);
  EXECUTE _q INTO _r;
  
  FOREACH _relacion IN ARRAY peopleRelations
  LOOP
    _person = (
      SELECT json_build_object(
        'id_p', p.id_pertenencia,
        'id_prp', prp.id_persona_rol_pertenencia,
        'tipo_attr', p.tipo_atr_doc
      )
      FROM pertenencia p
      JOIN persona_rol_pertenencia prp ON prp.fk_pertenencia_id = p.id_pertenencia
      WHERE p.fk_documento_id = id_documento
      AND (p.tipo_atr_doc = 'Comprador' OR p.tipo_atr_doc = 'Vendedor' OR p.tipo_atr_doc = 'Creación de relación' or prp.is_relation = true) 
      AND prp.fk_persona_historica_id = (_relacion->>'id')::numeric
    );

    IF _person IS NULL
    THEN

      _is_relation := _relacion->>'role' = 'Creación de relación';

      _person = (SELECT ae_add_rol_desc_persona_documento(id_documento, (_relacion->>'id')::numeric, _relacion->>'nombre', _relacion->>'descripcion', _relacion->>'role', 0, _is_relation));
      _id_persona_rol_pertenencia_relacion = _person->'id_prp';        

    ELSE
      _id_persona_rol_pertenencia_relacion = _person->'id_prp';  

    END IF;

    _q := format('INSERT INTO persona_rol_pertenencia_rel_linea (fk_persona_rol_pertenencia_id, fk_linea) VALUES (%s, %s) RETURNING *', _id_persona_rol_pertenencia_relacion, id_linea);
    EXECUTE _q INTO _r;

  END LOOP;
  
  --Relaciones con lugares
  _q := format(' DELETE FROM linea_rel_lugar WHERE fk_linea_id=%s RETURNING *', id_linea);
  EXECUTE _q INTO _r;

  FOREACH _relacion IN ARRAY placeRelations
  LOOP
    _q := format('INSERT INTO linea_rel_lugar (fk_linea_id, fk_lugar_id, descripcion_lugar) VALUES (%s, %s, %L) RETURNING *', id_linea, _relacion->>'id', _relacion->>'descripcion');
    EXECUTE _q INTO _r;
  END LOOP;

  RETURN id_linea;

END;
$$;


ALTER FUNCTION public.ae_add_objeto(id_documento numeric, id_pertenencia numeric, id_agrupacion_bienes numeric, id_linea numeric, descripcion_objeto text, calidad text, estado text, unidades json[], tipo_atr_doc text, numero numeric, color text, id_material numeric, material text, fk_material_id numeric, id_objeto numeric, objeto text, id_origen numeric, tipo_impuesto text, dopertenencia boolean, peoplerelations json[], placerelations json[]) OWNER TO postgres;

--
-- Name: ae_add_objeto(numeric, numeric, numeric, numeric, text, text, text, jsonb, text, numeric, text, numeric, text, numeric, numeric, text, numeric, text, boolean, json[], json[]); Type: FUNCTION; Schema: public; Owner: geographica
--

CREATE FUNCTION public.ae_add_objeto(id_documento numeric, id_pertenencia numeric, id_agrupacion_bienes numeric, id_linea numeric, descripcion_objeto text, calidad text, estado text, unidades jsonb, tipo_atr_doc text, numero numeric, color text, id_material numeric, material text, fk_material_id numeric, id_objeto numeric, objeto text, id_origen numeric, tipo_impuesto text, dopertenencia boolean DEFAULT false, peoplerelations json[] DEFAULT ARRAY[]::json[], placerelations json[] DEFAULT ARRAY[]::json[]) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
  _r record;
  _unidad jsonb;
  _unidad_nombre text;
  _q text;
  _relacion json;
  id_pertenencia_relacion numeric;
  _id_persona_rol_pertenencia_relacion numeric;

  _person json;
  _is_relation boolean;

BEGIN

  -- Material
  id_material = (SELECT ae_add_material(material, id_material, fk_material_id));

  -- Objeto
  id_objeto = (SELECT ae_add_simple_objeto(objeto, id_objeto, NULL));

  -- Create agrupacion_bienes if no agrupacion_bienes_id given
  IF id_agrupacion_bienes IS NULL
  THEN
    _q := format('INSERT INTO agrupacion_bienes (nombre) VALUES(null) RETURNING id_agrupacion_bienes');
    EXECUTE _q INTO _r;
    id_agrupacion_bienes = _r.id_agrupacion_bienes;
  END IF;

  -- Pertenencia y pertenencia_rel_agrupacion_bienes
  IF doPertenencia
  THEN
    IF id_pertenencia IS NULL
    THEN
      _q := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc) VALUES (%s, %s) RETURNING id_pertenencia', id_documento, quote_nullable(tipo_atr_doc));
    ELSE
      _q := format('UPDATE pertenencia SET tipo_atr_doc=%s WHERE id_pertenencia=%s RETURNING id_pertenencia', quote_nullable(tipo_atr_doc), id_pertenencia);
    END IF;
    EXECUTE _q INTO _r;
    id_pertenencia = _r.id_pertenencia;

    _q := format('
      INSERT INTO pertenencia_rel_agrupacion_bienes (fk_pertenencia_id, fk_agrupacion_bienes_id)
      VALUES (%s, %s) ON CONFLICT DO NOTHING RETURNING *',
      id_pertenencia, id_agrupacion_bienes
    );
    EXECUTE _q INTO _r;
  END IF;


  -- linea
  IF id_linea IS NULL
  THEN
    _q := format('
      INSERT INTO
        linea(fk_objeto_id, fk_agrupacion_bienes_id, descripcion, cantidad, color, calidad, estado, fk_material_id, fk_lugar_id, tipo_impuesto)
        VALUES (%s, %s, ''%s'', %s, ''%s'', ''%s'',''%s'', %s, %s, %L)
      RETURNING id_linea
    ',quote_nullable(id_objeto), id_agrupacion_bienes, descripcion_objeto, quote_nullable(numero), lower(color), calidad, estado, quote_nullable(id_material), quote_nullable(id_origen), tipo_impuesto);

  ELSE
    _q := format('
      UPDATE linea SET
        fk_objeto_id=%s,
        fk_agrupacion_bienes_id=%s,
        descripcion=''%s'',
        cantidad=%s,
        color=''%s'',
        calidad=''%s'',
        estado=''%s'',
        fk_material_id=%s,
        fk_lugar_id=%s,
        tipo_impuesto=%L
      WHERE id_linea=%s
      RETURNING id_linea
      ', quote_nullable(id_objeto), id_agrupacion_bienes, descripcion_objeto, quote_nullable(numero), lower(color), calidad, estado, quote_nullable(id_material), quote_nullable(id_origen), tipo_impuesto, id_linea);
  END IF;
  EXECUTE _q INTO _r;
  RAISE NOTICE '%', _q;
  id_linea := _r.id_linea;

  RAISE NOTICE 'id_linea: %', id_linea;

  -- Unidades
  _q := format('DELETE FROM linea_rel_unidad WHERE fk_linea_id=%s RETURNING *', id_linea);
  EXECUTE _q INTO _r;
  FOR _unidad IN (SELECT jsonb_array_elements(unidades))
  LOOP
    _unidad_nombre = (SELECT ae_add_unidad(_unidad->>'nombre', _unidad->>'type'));
    _q := format('INSERT INTO linea_rel_unidad (fk_linea_id, fk_unidad_nombre, valor, es_impuesto) VALUES (%s, ''%s'', %s, %s) RETURNING *', id_linea, _unidad_nombre, _unidad->>'value', _unidad->>'is_tax');
    EXECUTE _q INTO _r;
  END LOOP;


  --Relaciones con personas

  -- Borrar relaciones
  _q := format('
    DELETE FROM pertenencia 
    WHERE fk_documento_id=%s AND id_pertenencia in(
      SELECT p.id_pertenencia
      FROM persona_rol_pertenencia_rel_linea prpl
      LEFT JOIN persona_rol_pertenencia prp on prp.id_persona_rol_pertenencia = prpl.fk_persona_rol_pertenencia_id
      LEFT JOIN pertenencia p on p.id_pertenencia = prp.fk_pertenencia_id
      WHERE p.fk_documento_id = %s AND prpl.fk_linea = %s AND p.tipo_atr_doc = %L
    )
    RETURNING *
  ',id_documento, id_documento, id_linea, 'Creación de relación');

  EXECUTE _q INTO _r;

  -- Borrar compradores y vendedores 
  _q := format('
    DELETE FROM pertenencia 
    WHERE fk_documento_id=%s 
    AND (tipo_atr_doc = %L OR tipo_atr_doc = %L OR tipo_atr_doc = %L)
    AND id_pertenencia NOT IN (
      SELECT p.id_pertenencia FROM pertenencia p
      JOIN persona_rol_pertenencia prp ON prp.fk_pertenencia_id = p.id_pertenencia
      JOIN persona_rol_pertenencia_rel_linea prpl ON prpl.fk_persona_rol_pertenencia_id = prp.id_persona_rol_pertenencia
      WHERE p.fk_documento_id = %s
      AND prpl.fk_linea <> %s
    ) RETURNING *
  ',id_documento, 'Comprador','Vendedor','Creación de relación', id_documento, id_linea);

  EXECUTE _q INTO _r;

  _q := format('
    DELETE FROM persona_rol_pertenencia_rel_linea WHERE fk_linea = %s
    RETURNING *
  ', id_linea);
  EXECUTE _q INTO _r;
  
  FOREACH _relacion IN ARRAY peopleRelations
  LOOP
    _person = (
      SELECT json_build_object(
        'id_p', p.id_pertenencia,
        'id_prp', prp.id_persona_rol_pertenencia,
        'tipo_attr', p.tipo_atr_doc
      )
      FROM pertenencia p
      JOIN persona_rol_pertenencia prp ON prp.fk_pertenencia_id = p.id_pertenencia
      WHERE p.fk_documento_id = id_documento
      AND (p.tipo_atr_doc = 'Comprador' OR p.tipo_atr_doc = 'Vendedor' OR p.tipo_atr_doc = 'Creación de relación') 
      AND prp.fk_persona_historica_id = (_relacion->>'id')::numeric
    );

    IF _person IS NULL
    THEN

      _is_relation := _relacion->>'role' = 'Creación de relación';

      _person = (SELECT ae_add_rol_desc_persona_documento(id_documento, (_relacion->>'id')::numeric, _relacion->>'nombre', _relacion->>'descripcion', _relacion->>'role', 0, _is_relation));
      _id_persona_rol_pertenencia_relacion = _person->'id_prp';        

    ELSE
      _id_persona_rol_pertenencia_relacion = _person->'id_prp';  

    END IF;

    _q := format('INSERT INTO persona_rol_pertenencia_rel_linea (fk_persona_rol_pertenencia_id, fk_linea) VALUES (%s, %s) RETURNING *', _id_persona_rol_pertenencia_relacion, id_linea);
    EXECUTE _q INTO _r;

  END LOOP;
  
  --Relaciones con lugares
  _q := format(' DELETE FROM linea_rel_lugar WHERE fk_linea_id=%s RETURNING *', id_linea);
  EXECUTE _q INTO _r;

  FOREACH _relacion IN ARRAY placeRelations
  LOOP
    _q := format('INSERT INTO linea_rel_lugar (fk_linea_id, fk_lugar_id, descripcion_lugar) VALUES (%s, %s, %L) RETURNING *', id_linea, _relacion->>'id', _relacion->>'descripcion');
    EXECUTE _q INTO _r;
  END LOOP;

  RETURN id_linea;

END;
$$;


ALTER FUNCTION public.ae_add_objeto(id_documento numeric, id_pertenencia numeric, id_agrupacion_bienes numeric, id_linea numeric, descripcion_objeto text, calidad text, estado text, unidades jsonb, tipo_atr_doc text, numero numeric, color text, id_material numeric, material text, fk_material_id numeric, id_objeto numeric, objeto text, id_origen numeric, tipo_impuesto text, dopertenencia boolean, peoplerelations json[], placerelations json[]) OWNER TO geographica;

--
-- Name: ae_add_objeto(numeric, numeric, numeric, numeric, numeric, text, text, text, jsonb, text, numeric, text, numeric, text, numeric, numeric, text, numeric, text, numeric, text, text, text, boolean, json[], json[]); Type: FUNCTION; Schema: public; Owner: geographica
--

CREATE FUNCTION public.ae_add_objeto(id_linea numeric, id_persona_rol_pertenencia numeric, id_pertenencia numeric, id_documento numeric, id_agrupacion_bienes numeric, descripcion_objeto text, calidad text, estado text, unidades jsonb, campo text, numero numeric, color text, id_material numeric, material text, fk_material_id numeric, id_objeto numeric, objeto text, id_origen numeric, origen text, id_persona_historica numeric, nombre_persona_historica text, descripcion text, rol text, dopertenencia boolean DEFAULT false, peoplerelations json[] DEFAULT ARRAY[]::json[], placerelations json[] DEFAULT ARRAY[]::json[]) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
  _r record;
  _unidad jsonb;
  _unidad_nombre text;
  _q text;
  _relacion json;
  id_pertenencia_relacion numeric;
  _id_persona_rol_pertenencia_relacion numeric;

BEGIN

  -- Material
  id_material = (SELECT ae_add_material(material, id_material, fk_material_id));

  -- Objeto
  id_objeto = (SELECT ae_add_simple_objeto(objeto, id_objeto, NULL));

  -- Lugar
  -- id_origen = (SELECT ae_add_lugar(id_origen, origen));

  -- Pertenencia
  IF doPertenencia
  THEN
    IF id_pertenencia IS NULL
    THEN
      _q := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc) VALUES (%s, %s) RETURNING id_pertenencia', id_documento, quote_nullable(campo));
    ELSE
      _q := format('UPDATE pertenencia SET tipo_atr_doc=%s WHERE id_pertenencia=%s RETURNING id_pertenencia', quote_nullable(campo), id_pertenencia);
    END IF;
    EXECUTE _q INTO _r;
    id_pertenencia = _r.id_pertenencia;
  END IF;


  -- PRP
  IF nombre_persona_historica IS NOT NULL
  THEN
    id_persona_rol_pertenencia = (SELECT ae_add_persona(
      id_documento,
      id_persona_historica,
      NULL,
      id_persona_rol_pertenencia,
      nombre_persona_historica,
      rol,
      campo,
      campo,
      descripcion,
      FALSE
    ));
  END IF;

  -- Agrupacion bienes IF object form, ELSE, almoneda, etc
  IF id_agrupacion_bienes IS NULL
  THEN
    _q := format('INSERT INTO agrupacion_bienes (nombre) VALUES(null) RETURNING id_agrupacion_bienes');
    EXECUTE _q INTO _r;
    id_agrupacion_bienes = _r.id_agrupacion_bienes;
  END IF;

  RAISE NOTICE 'id_agrupacion_bienes: %', id_agrupacion_bienes;


  IF doPertenencia
  THEN
    _q := format('INSERT INTO pertenencia_rel_agrupacion_bienes (fk_pertenencia_id, fk_agrupacion_bienes_id)
        VALUES (%s, %s) ON CONFLICT DO NOTHING RETURNING *', id_pertenencia, id_agrupacion_bienes);
    EXECUTE _q INTO _r;
  END IF;

  -- linea
  IF id_linea IS NULL
  THEN
    _q := format('
      INSERT INTO
       linea(fk_objeto_id, fk_agrupacion_bienes_id, descripcion, cantidad, color, calidad, estado, fk_material_id, fk_lugar_id)
       VALUES (%s, %s, ''%s'', %s, ''%s'', ''%s'',''%s'', %s, %s)
      RETURNING id_linea',
       quote_nullable(id_objeto), id_agrupacion_bienes, descripcion_objeto, quote_nullable(numero), color, calidad, estado, quote_nullable(id_material), quote_nullable(id_origen));

    raise notice 'INSERT INTO';

  ELSE
    _q := format('
      UPDATE linea SET
        fk_objeto_id=%s,
        fk_agrupacion_bienes_id=%s,
        descripcion=''%s'',
        cantidad=%s,
        color=''%s'',
        calidad=''%s'',
        estado=''%s'',
        fk_material_id=%s,
        fk_lugar_id=%s
      WHERE id_linea=%s
      RETURNING id_linea
      ', quote_nullable(id_objeto), id_agrupacion_bienes, descripcion_objeto, quote_nullable(numero), color, calidad, estado, quote_nullable(id_material), quote_nullable(id_origen), id_linea);
  END IF;
  EXECUTE _q INTO _r;
  RAISE NOTICE '%', _q;
  id_linea := _r.id_linea;

  RAISE NOTICE 'id_linea: %', id_linea;

  IF id_persona_rol_pertenencia IS NOT NULL
  THEN
    -- PRP - linea
    -- First, deletes
    _q:= format('DELETE FROM persona_rol_pertenencia_rel_linea WHERE fk_persona_rol_pertenencia_id=%s AND fk_linea=%s RETURNING *',
      id_persona_rol_pertenencia, id_linea);
    EXECUTE _q INTO _r;
    -- Then inserts
    _q := format('INSERT INTO persona_rol_pertenencia_rel_linea (fk_persona_rol_pertenencia_id, fk_linea) VALUES(%s, %s) RETURNING *', id_persona_rol_pertenencia, id_linea);
    EXECUTE _q INTO _r;
  END IF;


  -- Linea
  -- First deletes
  _q := format('DELETE FROM linea_rel_unidad WHERE fk_linea_id=%s RETURNING *', id_linea);
  EXECUTE _q INTO _r;
  -- THEN, inserts foreach
  FOR _unidad IN SELECT * FROM json_array_elements(unidades::json)
  LOOP

    -- raise notice '%', _unidad;

    _unidad_nombre = (SELECT ae_add_unidad(_unidad->>'nombre', _unidad->>'type'));
    _q := format('INSERT INTO linea_rel_unidad (fk_linea_id, fk_unidad_nombre, valor, es_impuesto) VALUES (%s, ''%s'', %s, %s) RETURNING *', id_linea, _unidad_nombre, _unidad->>'value', _unidad->>'is_tax');
    RAISE NOTICE '%', _q;
    EXECUTE _q INTO _r;
  END LOOP;

  --Relaciones con personas

  _q := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND id_pertenencia in(
                SELECT p.id_pertenencia
                FROM persona_rol_pertenencia_rel_linea prpl
                LEFT JOIN persona_rol_pertenencia prp on prp.id_persona_rol_pertenencia = prpl.fk_persona_rol_pertenencia_id
                LEFT JOIN pertenencia p on p.id_pertenencia = prp.fk_pertenencia_id
                WHERE p.fk_documento_id = %s AND prpl.fk_linea = %s)
                RETURNING *', id_documento, id_documento, id_linea);

  EXECUTE _q INTO _r;

  FOREACH _relacion IN ARRAY peopleRelations
  LOOP
    _q := format('INSERT INTO pertenencia (fk_documento_id, motivo) VALUES (%s, %L) RETURNING id_pertenencia', id_documento, 'Creación de relación');
    EXECUTE _q INTO _r;
    id_pertenencia_relacion := _r.id_pertenencia;

    _q := format('INSERT INTO persona_rol_pertenencia (fk_persona_historica_id, fk_pertenencia_id, descripcion) VALUES (%s, %s, %L) RETURNING id_persona_rol_pertenencia', _relacion->>'id', id_pertenencia_relacion, _relacion->>'descripcion');
    EXECUTE _q INTO _r;
    _id_persona_rol_pertenencia_relacion := _r.id_persona_rol_pertenencia;

    _q := format('INSERT INTO persona_rol_pertenencia_rel_linea (fk_persona_rol_pertenencia_id, fk_linea) VALUES (%s, %s) RETURNING *', _id_persona_rol_pertenencia_relacion, id_linea);
    EXECUTE _q INTO _r;

  END LOOP;

  --Relaciones con lugares

  _q := format(' DELETE FROM linea_rel_lugar WHERE fk_linea_id=%s RETURNING *', id_linea);
  EXECUTE _q INTO _r;

  FOREACH _relacion IN ARRAY placeRelations
  LOOP
    _q := format('INSERT INTO linea_rel_lugar (fk_linea_id, fk_lugar_id, descripcion_lugar) VALUES (%s, %s, %L) RETURNING *', id_linea, _relacion->>'id', _relacion->>'descripcion');
    EXECUTE _q INTO _r;

  END LOOP;

  RETURN id_linea;

END;
$$;


ALTER FUNCTION public.ae_add_objeto(id_linea numeric, id_persona_rol_pertenencia numeric, id_pertenencia numeric, id_documento numeric, id_agrupacion_bienes numeric, descripcion_objeto text, calidad text, estado text, unidades jsonb, campo text, numero numeric, color text, id_material numeric, material text, fk_material_id numeric, id_objeto numeric, objeto text, id_origen numeric, origen text, id_persona_historica numeric, nombre_persona_historica text, descripcion text, rol text, dopertenencia boolean, peoplerelations json[], placerelations json[]) OWNER TO geographica;

--
-- Name: ae_add_person_batch(numeric, text, jsonb[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_person_batch(id_document numeric, role text, people jsonb[]) RETURNS jsonb[]
    LANGUAGE plpgsql
    AS $$
DECLARE
  _result record;
  _query text;
  _person jsonb;
  _prp_ids numeric[];
  _pert_id numeric;
  _new_ids jsonb[];

BEGIN

  _prp_ids = ARRAY[]::numeric[];
  FOREACH _person IN ARRAY people
  LOOP
    _prp_ids = _prp_ids || (_person->>'id_prp')::numeric;
  END LOOP;

  _query = format('DELETE FROM pertenencia 
    WHERE fk_documento_id=%s 
    AND tipo_atr_doc=%L
    AND id_pertenencia NOT IN (
      SELECT fk_pertenencia_id FROM persona_rol_pertenencia
      WHERE id_persona_rol_pertenencia = ANY(%L)
    ) RETURNING *', id_document, role, _prp_ids);
  EXECUTE _query INTO _result;

  _new_ids = ARRAY[]::jsonb[];
  FOREACH _person IN ARRAY people
  LOOP
    IF (_person->>'id_prp')::numeric IS NULL
    THEN
      _new_ids = _new_ids || (
        ae_add_rol_desc_persona_documento(
          id_document,
          (_person->>'id_persona_historica')::numeric,
          _person->>'nombre',
          _person->>'descripcion',
          role,
          COALESCE((_person->>'order')::numeric, 0),
          COALESCE((_person->>'is_relation')::boolean, FALSE)
        )
      )::jsonb;
    ELSE
      _query = format('UPDATE persona_rol_pertenencia SET descripcion = %L 
        WHERE id_persona_rol_pertenencia = %s RETURNING *', _person->>'descripcion', _person->>'id_prp');
      EXECUTE _query INTO _result;

      _pert_id = _result.fk_pertenencia_id;

      _query = format('UPDATE pertenencia SET orden = %s 
        WHERE id_pertenencia = %s RETURNING *', COALESCE((_person->>'order')::numeric, 0), _pert_id);
      EXECUTE _query INTO _result;

      _new_ids = _new_ids || (
        jsonb_build_object(
          'id_prp', (_person->>'id_prp')::numeric,
          'id_pertenencia', _pert_id
        )
      );
    END IF;
    
  END LOOP;

  RETURN _new_ids;

END;
$$;


ALTER FUNCTION public.ae_add_person_batch(id_document numeric, role text, people jsonb[]) OWNER TO postgres;

--
-- Name: ae_add_persona(numeric, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_persona(id_persona_historica numeric, nombre_persona_historica text, genero text DEFAULT NULL::text) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.ae_add_persona(id_persona_historica numeric, nombre_persona_historica text, genero text) OWNER TO postgres;

--
-- Name: ae_add_persona_historica(numeric, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_persona_historica(id_persona_historica numeric, nombre_persona_historica text) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.ae_add_persona_historica(id_persona_historica numeric, nombre_persona_historica text) OWNER TO postgres;

--
-- Name: ae_add_persona_linea(numeric, numeric, numeric, numeric, numeric, text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_persona_linea(id_documento numeric, id_pertenencia numeric, id_persona_historica numeric, id_persona_rol_pertenencia numeric, id_linea numeric, nombre_persona_historica text, rol text, descripcion text) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
  _r record;
  _q text;
BEGIN

  id_persona_historica := (SELECT ae_add_persona_historica(id_persona_historica, nombre_persona_historica));

  IF id_pertenencia IS NULL
  THEN
    _q := format('SELECT fecha_inicio, precision_inicio FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L', id_documento, 'Emisión');
    EXECUTE _q INTO _r;

    _q = format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, fecha_inicio, precision_inicio) VALUES (%s, %L, %L::date, %L) RETURNING id_pertenencia', id_documento, rol, _r.fecha_inicio, _r.precision_inicio);
    EXECUTE _q INTO _r;
    id_pertenencia = _r.id_pertenencia;
  END IF;

  -- Rol
  _q := format('INSERT INTO rol (nombre) VALUES(''%s'') ON CONFLICT DO NOTHING RETURNING nombre', rol);
  EXECUTE _q INTO _r;

  -- Persona_rol_pertenencia
  IF id_persona_rol_pertenencia IS NULL
  THEN
    _q := format('
      INSERT INTO persona_rol_pertenencia (fk_persona_historica_id, descripcion, fk_pertenencia_id)
      VALUES (%s, %L, %s) RETURNING id_persona_rol_pertenencia
    ', id_persona_historica, descripcion, id_pertenencia);
  ELSE
    _q := format('
      UPDATE persona_rol_pertenencia SET descripcion = %L
      WHERE id_persona_rol_pertenencia = %s 
      RETURNING id_persona_rol_pertenencia
    ', descripcion, id_persona_rol_pertenencia);
  END IF;
  EXECUTE _q INTO _r;

  IF _r.id_persona_rol_pertenencia IS NOT NULL
  THEN
    id_persona_rol_pertenencia := _r.id_persona_rol_pertenencia;
  END IF;

  -- Persona_rol_pertenencia_rel_rol
  _q := format('DELETE FROM persona_rol_pertenencia_rel_rol WHERE fk_rol_nombre=''%s'' AND fk_persona_rol_pertenencia=%s RETURNING *', rol, id_persona_rol_pertenencia);
  EXECUTE _q INTO _r;
  _q := format('INSERT INTO persona_rol_pertenencia_rel_rol (fk_rol_nombre, fk_persona_rol_pertenencia) VALUES (''%s'', %s) RETURNING *', rol, id_persona_rol_pertenencia);
  EXECUTE _q INTO _r;

  -- First delete
  _q := format('DELETE FROM persona_rol_pertenencia_rel_linea WHERE fk_linea=%s AND fk_persona_rol_pertenencia_id=%s RETURNING *', id_linea, id_persona_rol_pertenencia);
  EXECUTE _q INTO _r;
  _q := format('INSERT INTO persona_rol_pertenencia_rel_linea (fk_linea, fk_persona_rol_pertenencia_id)
    VALUES (%s, %s) RETURNING *', id_linea, id_persona_rol_pertenencia);
  EXECUTE _q INTO _r;

  RETURN id_persona_rol_pertenencia;

END;
$$;


ALTER FUNCTION public.ae_add_persona_linea(id_documento numeric, id_pertenencia numeric, id_persona_historica numeric, id_persona_rol_pertenencia numeric, id_linea numeric, nombre_persona_historica text, rol text, descripcion text) OWNER TO postgres;

--
-- Name: ae_add_persona_rol_pertenencia(numeric, text, text, numeric, date, date, text, text, text, numeric, numeric, numeric, numeric, text, text, text[], text[], text[], numeric, text, text, date, text, numeric, text, json[], json[], json[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_persona_rol_pertenencia(id_persona_historica numeric, nombre_persona_historica text, genero text, id_pertenencia numeric, fecha_inicio date, fecha_fin date, precision_inicio text, precision_fin text, campo text, fk_documento_id numeric, id_persona_rol_pertenencia numeric, edad_min numeric, edad_max numeric, descripcion text, edad_recodificada text, roles text[], cargos text[], ocupaciones text[], id_lugar numeric, lugar text, nombre_institucion text, fecha_creacion_institucion date, descripcion_institucion text, id_lugar_institucion numeric, lugar_institucion text, objectrelations json[], placerelations json[], peoplerelations json[]) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.ae_add_persona_rol_pertenencia(id_persona_historica numeric, nombre_persona_historica text, genero text, id_pertenencia numeric, fecha_inicio date, fecha_fin date, precision_inicio text, precision_fin text, campo text, fk_documento_id numeric, id_persona_rol_pertenencia numeric, edad_min numeric, edad_max numeric, descripcion text, edad_recodificada text, roles text[], cargos text[], ocupaciones text[], id_lugar numeric, lugar text, nombre_institucion text, fecha_creacion_institucion date, descripcion_institucion text, id_lugar_institucion numeric, lugar_institucion text, objectrelations json[], placerelations json[], peoplerelations json[]) OWNER TO postgres;

--
-- Name: ae_add_pertenencia_rel_lugar(numeric, text, text, text, text, text, text, text, numeric, numeric, json[], json[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_pertenencia_rel_lugar(id_lugar numeric, lugar text, tipo_lugar text, campo text, localizacion text, region_cont text, geom text, tipo_geom text, id_pertenencia numeric, fk_documento_id numeric, peoplerelations json[], objectrelations json[]) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.ae_add_pertenencia_rel_lugar(id_lugar numeric, lugar text, tipo_lugar text, campo text, localizacion text, region_cont text, geom text, tipo_geom text, id_pertenencia numeric, fk_documento_id numeric, peoplerelations json[], objectrelations json[]) OWNER TO postgres;

--
-- Name: ae_add_pleito_entre_partes(numeric, json[], json[], json[], json[], json[], json[], json[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_pleito_entre_partes(id_document numeric, applicant json[], defendant json[], witness json[], notary json[], accusations json[], allegations json[], appeals json[]) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE

  _r record;
  _q text;
  _aux json;

BEGIN

  PERFORM ae_add_person_batch(id_document, 'Demandante'::text, applicant::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Demandado'::text, defendant::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Testigo'::text, witness::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Escribano'::text, notary::jsonb[]);

  --Crea las acusaciones
  _q := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Acusacion');
  EXECUTE _q INTO _r;

  FOREACH _aux IN ARRAY accusations
  LOOP
    _q := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, motivo, orden) VALUES (%s, %L, %L, %s) RETURNING id_pertenencia', id_document, 'Acusacion', _aux->>'description', _aux->>'order');
    EXECUTE _q INTO _r;
  END LOOP;

  --Creo los alegatos
  _q := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Alegato');
  EXECUTE _q INTO _r;

  FOREACH _aux IN ARRAY allegations
  LOOP
    _q := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, motivo, orden) VALUES (%s, %L, %L, %s) RETURNING id_pertenencia', id_document, 'Alegato', _aux->>'description', _aux->>'order');
    EXECUTE _q INTO _r;
  END LOOP;

  --Crea las apelaciones
  _q := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Apelacion');
  EXECUTE _q INTO _r;

  FOREACH _aux IN ARRAY appeals
  LOOP
    _q := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, motivo, orden) VALUES (%s, %L, %L, %s) RETURNING id_pertenencia', id_document, 'Apelacion', _aux->>'description', _aux->>'order');
    EXECUTE _q INTO _r;
  END LOOP;

  RETURN id_document;

END;
$$;


ALTER FUNCTION public.ae_add_pleito_entre_partes(id_document numeric, applicant json[], defendant json[], witness json[], notary json[], accusations json[], allegations json[], appeals json[]) OWNER TO postgres;

--
-- Name: ae_add_poder(numeric, json[], json[], json[], json[], json[], text[], numeric, text, json[], date, text, date, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_poder(id_document numeric, senders json[], sender_witnesees json[], recipients json[], presentation_witnesses json[], notaries json[], powers text[], area_of_application numeric, area_precision text, resignations json[], start_date date, start_date_precision text, end_date date, end_date_precision text) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE

  _result record;
  _query text;
  _item json;
  _textitem text;

BEGIN

  PERFORM ae_add_person_batch(id_document, 'Emisor'::text, senders::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Testigo de emisión'::text, sender_witnesees::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Destinatario'::text, recipients::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Testigo de presentación'::text, presentation_witnesses::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Notario'::text, notaries::jsonb[]);

  -- Crear poderes
  _query := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Poder');
  EXECUTE _query INTO _result;

  FOREACH _textitem IN ARRAY powers
  LOOP
    _query := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, motivo) VALUES (%s, %L, %L) RETURNING id_pertenencia', id_document, 'Poder', _textitem);
    EXECUTE _query INTO _result;
  END LOOP;

  -- Crear Ámbito de apliación (lugar)
  IF area_of_application IS NOT NULL
  THEN
    _query := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Ámbito de aplicación');
    EXECUTE _query INTO _result;
    
    _query := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc) VALUES (%s, %L) RETURNING id_pertenencia', id_document, 'Ámbito de aplicación');
    EXECUTE _query INTO _result;

    _query := format('INSERT INTO pertenencia_rel_lugar (fk_lugar_id, fk_pertenencia_id, precision_pert_lugar) VALUES (%s, %s, %L) RETURNING *', area_of_application, _result.id_pertenencia, area_precision);
    EXECUTE _query INTO _result;
  END IF;

  -- Crear renuncias
  _query := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc LIKE %L RETURNING *', id_document, 'renuncia#%');
  EXECUTE _query INTO _result;

  FOREACH _item IN ARRAY resignations
  LOOP
    _query := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, motivo) VALUES (%s, %L, %L) RETURNING id_pertenencia', id_document, format('renuncia#%s', _item->>'type'), _item->>'description');
    EXECUTE _query INTO _result;
  END LOOP;

  -- Crear plazo de vigencia
  _query := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Plazo de vigencia');
  EXECUTE _query INTO _result;

  _query := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, fecha_inicio, fecha_fin, precision_inicio, precision_fin) VALUES (%s, %L, %L::date, %L::date, %L, %L) RETURNING id_pertenencia', id_document, 'Plazo de vigencia', start_date, end_date, start_date_precision, end_date_precision);
  EXECUTE _query INTO _result;

  RETURN id_document;

END;
$$;


ALTER FUNCTION public.ae_add_poder(id_document numeric, senders json[], sender_witnesees json[], recipients json[], presentation_witnesses json[], notaries json[], powers text[], area_of_application numeric, area_precision text, resignations json[], start_date date, start_date_precision text, end_date date, end_date_precision text) OWNER TO postgres;

--
-- Name: ae_add_relacion_meritos(numeric, json[], json[], json[], json[], json[], json[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_relacion_meritos(id_document numeric, applicant json[], protagonist json[], witness json[], notary json[], allegations json[], requests json[]) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE

  _r record;
  _q text;
  _aux json;

BEGIN

  PERFORM ae_add_person_batch(id_document, 'Demandante'::text, applicant::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Protagonista'::text, protagonist::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Testigo'::text, witness::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Escribano'::text, notary::jsonb[]);

  --Creo los alegatos
  _q := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Alegato');
  EXECUTE _q INTO _r;

  FOREACH _aux IN ARRAY allegations
  LOOP
    _q := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, motivo, orden) VALUES (%s, %L, %L, %s) RETURNING id_pertenencia', id_document, 'Alegato', _aux->>'description', _aux->>'order');
    EXECUTE _q INTO _r;
  END LOOP;

  --Crea las solicitudes
  _q := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Solicitud');
  EXECUTE _q INTO _r;

  FOREACH _aux IN ARRAY requests
  LOOP
    _q := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, motivo, orden) VALUES (%s, %L, %L, %s) RETURNING id_pertenencia', id_document, 'Solicitud', _aux->>'description', _aux->>'order');
    EXECUTE _q INTO _r;
  END LOOP;


  RETURN id_document;

END;
$$;


ALTER FUNCTION public.ae_add_relacion_meritos(id_document numeric, applicant json[], protagonist json[], witness json[], notary json[], allegations json[], requests json[]) OWNER TO postgres;

--
-- Name: ae_add_relacion_persona_persona(numeric, numeric, numeric, numeric, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_relacion_persona_persona(id_pertenencia numeric, id_persona_historica numeric, id_pertenencia_relacion numeric, id_persona_historica_relacion numeric, descripcion text) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE 
  _result record;
  _query text;
  _exisiting_relation numeric;
  _id_persona_rol_pertenencia_relacion numeric;

BEGIN

  _exisiting_relation = (
    SELECT count(*) FROM persona_rol_pertenencia prp_count
    INNER JOIN persona_rol_pertenencia prp_count_origin
      ON prp_count.fk_persona_rol_pertenencia_id = prp_count_origin.id_persona_rol_pertenencia
    WHERE prp_count.fk_pertenencia_id = id_pertenencia_relacion
      AND prp_count_origin.fk_pertenencia_id = id_pertenencia
      AND prp_count.is_relation = TRUE
      AND prp_count_origin.is_relation = TRUE
  );

  IF _exisiting_relation = 0
  THEN

    _query := format(
      'INSERT INTO persona_rol_pertenencia (fk_persona_historica_id, fk_pertenencia_id, descripcion, is_relation) 
        VALUES (%s, %s, %L, true) RETURNING id_persona_rol_pertenencia', 
      id_persona_historica, id_pertenencia, descripcion
    );
    EXECUTE _query INTO _result;
    _id_persona_rol_pertenencia_relacion := _result.id_persona_rol_pertenencia;

    _query := format(
      'INSERT INTO persona_rol_pertenencia (fk_persona_historica_id, fk_pertenencia_id, descripcion, fk_persona_rol_pertenencia_id, is_relation)
        VALUES (%s, %s, %L, %s, true) RETURNING id_persona_rol_pertenencia',
      id_persona_historica_relacion, id_pertenencia_relacion,
      descripcion, _id_persona_rol_pertenencia_relacion
    );
    EXECUTE _query INTO _result;
  END IF;

  RETURN _exisiting_relation;
END;
$$;


ALTER FUNCTION public.ae_add_relacion_persona_persona(id_pertenencia numeric, id_persona_historica numeric, id_pertenencia_relacion numeric, id_persona_historica_relacion numeric, descripcion text) OWNER TO postgres;

--
-- Name: ae_add_respuesta(numeric, numeric, numeric, numeric, text, text, date, text, text, text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_respuesta(id_pregunta numeric, id_respuesta numeric, id_persona_rol_pertenencia numeric, id_persona_historica numeric, nombre_persona_historica text, descripcion text, fecha date, precison text, respuesta text, torturas text[]) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
  _pregunta record;
  _respuesta record;
  _tortura text;
  _r record;
  _q text;

BEGIN

  --
  EXECUTE format('SELECT * FROM pertenencia WHERE id_pertenencia=%s', id_pregunta) INTO _pregunta;
  RAISE NOTICE '%', _pregunta;

  -- First, inserts regular relation with persona
  id_persona_rol_pertenencia := (SELECT ae_add_persona(
    _pregunta.fk_documento_id,
    id_persona_historica,
    id_respuesta,
    id_persona_rol_pertenencia,
    nombre_persona_historica,
    'Testigo',
    respuesta,
    'Respuesta',
    descripcion));

  _q := format('
      SELECT *
      FROM pertenencia
      WHERE id_pertenencia=
      (SELECT fk_pertenencia_id FROM persona_rol_pertenencia prp
        WHERE prp.id_persona_rol_pertenencia=%s)', id_persona_rol_pertenencia);
  EXECUTE _q INTO _respuesta;

  RAISE NOTICE 'RESPUESTA: %', _respuesta;
  -- Then fixes data
  id_respuesta = _respuesta.id_pertenencia;

  _q = format('UPDATE pertenencia SET
      motivo=''%s'',
      fk_documento_id=%s,
      fk_pertenencia_id=%s,
      orden=%s,
      precision_inicio=''%s'',
      tipo_atr_doc=''Respuesta'' ',
      respuesta,
      _pregunta.fk_documento_id,
      _pregunta.id_pertenencia,
      _pregunta.orden,
      precison);

    IF fecha IS NOT NULL
    THEN
      _q := format('%s
        ,fecha_inicio=''%s''::date
        WHERE id_pertenencia=%s RETURNING id_pertenencia',
        _q,
        fecha,
        id_respuesta);
    ELSE
      _q := format('%s
        , fecha_inicio=NULL
        WHERE id_pertenencia=%s RETURNING id_pertenencia',
        _q,
        id_respuesta);
    END IF;

  EXECUTE _q INTO _r;

  -- Handle torturas
  -- First delete
  _q := format('DELETE FROM persona_rol_pertenencia_rel_tortura WHERE fk_persona_rol_pertenencia_id=%s RETURNING *', id_persona_rol_pertenencia);
  EXECUTE _q INTO _r;

  -- THEN, inserts foreach
  FOREACH _tortura IN ARRAY torturas
  LOOP
    RAISE NOTICE '%', _tortura;
    _q := format('INSERT INTO tortura (texto) VALUES (''%s'') ON CONFLICT DO NOTHING RETURNING texto', _tortura);
    -- RAISE NOTICE '%', _q;
    EXECUTE _q INTO _r;
    _q := format('INSERT INTO persona_rol_pertenencia_rel_tortura (fk_persona_rol_pertenencia_id, fk_tortura_texto)
      VALUES (%s, ''%s'') RETURNING *', id_persona_rol_pertenencia, _tortura);
    RAISE NOTICE '%', _q;
    EXECUTE _q INTO _r;
  END LOOP;



  RETURN id_respuesta;

END;
$$;


ALTER FUNCTION public.ae_add_respuesta(id_pregunta numeric, id_respuesta numeric, id_persona_rol_pertenencia numeric, id_persona_historica numeric, nombre_persona_historica text, descripcion text, fecha date, precison text, respuesta text, torturas text[]) OWNER TO postgres;

--
-- Name: ae_add_rol_desc_persona_documento(numeric, numeric, text, text, text, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_rol_desc_persona_documento(id_documento numeric, id_persona_historica numeric, nombre text, descripcion text, rol text, orden numeric) RETURNS json
    LANGUAGE plpgsql
    AS $$
DECLARE

  _r record;
  _q text;
  id_pertenencia_relacion numeric;
  _id_persona_rol_pertenencia_relacion numeric;

BEGIN

  id_persona_historica = (SELECT ae_add_persona_historica(id_persona_historica, nombre));

  _q := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, orden) VALUES (%s, %L, %s) RETURNING id_pertenencia', id_documento, rol, orden);
  EXECUTE _q INTO _r;
  id_pertenencia_relacion := _r.id_pertenencia;

  _q := format('INSERT INTO persona_rol_pertenencia (fk_persona_historica_id, fk_pertenencia_id, descripcion) VALUES (%s, %s, %L) RETURNING id_persona_rol_pertenencia', id_persona_historica, id_pertenencia_relacion, descripcion);
  EXECUTE _q INTO _r;
  _id_persona_rol_pertenencia_relacion := _r.id_persona_rol_pertenencia;

  _q := format('INSERT INTO rol (nombre) VALUES (%L) ON CONFLICT DO NOTHING RETURNING nombre', rol);
  EXECUTE _q INTO _r;

  _q := format('INSERT INTO persona_rol_pertenencia_rel_rol (fk_rol_nombre, fk_persona_rol_pertenencia)
    VALUES (%L, %s) RETURNING *', rol, _id_persona_rol_pertenencia_relacion);
  EXECUTE _q INTO _r;

  RETURN json_build_object('id_prp', _id_persona_rol_pertenencia_relacion, 'id_pertenencia', id_pertenencia_relacion);

END;
$$;


ALTER FUNCTION public.ae_add_rol_desc_persona_documento(id_documento numeric, id_persona_historica numeric, nombre text, descripcion text, rol text, orden numeric) OWNER TO postgres;

--
-- Name: ae_add_rol_desc_persona_documento(numeric, numeric, text, text, text, numeric, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_rol_desc_persona_documento(id_documento numeric, id_persona_historica numeric, nombre text, descripcion text, rol text, orden numeric, is_relation boolean DEFAULT false) RETURNS json
    LANGUAGE plpgsql
    AS $$
DECLARE

  _r record;
  _q text;
  id_pertenencia_relacion numeric;
  _id_persona_rol_pertenencia_relacion numeric;
  pertenencia_inicio record;

BEGIN

  id_persona_historica = (SELECT ae_add_persona_historica(id_persona_historica, nombre));

  _q := format('SELECT fecha_inicio, precision_inicio FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L', id_documento, 'Emisión');
  EXECUTE _q INTO pertenencia_inicio;

  _q := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, orden, fecha_inicio, precision_inicio) VALUES (%s, %L, %s, %L::date, %L) RETURNING id_pertenencia', id_documento, rol, orden, pertenencia_inicio.fecha_inicio, pertenencia_inicio.precision_inicio);
  EXECUTE _q INTO _r;
  id_pertenencia_relacion := _r.id_pertenencia;

  _q := format('INSERT INTO persona_rol_pertenencia (fk_persona_historica_id, fk_pertenencia_id, descripcion, is_relation) VALUES (%s, %s, %L, %L) RETURNING id_persona_rol_pertenencia', id_persona_historica, id_pertenencia_relacion, descripcion, is_relation);
  EXECUTE _q INTO _r;
  _id_persona_rol_pertenencia_relacion := _r.id_persona_rol_pertenencia;

  _q := format('INSERT INTO rol (nombre) VALUES (%L) ON CONFLICT DO NOTHING RETURNING nombre', rol);
  EXECUTE _q INTO _r;

  _q := format('INSERT INTO persona_rol_pertenencia_rel_rol (fk_rol_nombre, fk_persona_rol_pertenencia)
    VALUES (%L, %s) RETURNING *', rol, _id_persona_rol_pertenencia_relacion);
  EXECUTE _q INTO _r;

  RETURN json_build_object('id_prp', _id_persona_rol_pertenencia_relacion, 'id_pertenencia', id_pertenencia_relacion);

END;
$$;


ALTER FUNCTION public.ae_add_rol_desc_persona_documento(id_documento numeric, id_persona_historica numeric, nombre text, descripcion text, rol text, orden numeric, is_relation boolean) OWNER TO postgres;

--
-- Name: ae_add_rol_descp_para_documento(numeric, numeric, text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_rol_descp_para_documento(id_documento numeric, id_persona_historica numeric, nombre text, descripcion text, rol text) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE

  _r record;
  _q text;
  id_pertenencia_relacion numeric;
  _id_persona_rol_pertenencia_relacion numeric;
  pertenencia_inicio record;

BEGIN

  id_persona_historica = (SELECT ae_add_persona_historica(id_persona_historica, nombre));
  
  _q := format('SELECT fecha_inicio, precision_inicio FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L', id_documento, 'Emisión');
  EXECUTE _q INTO pertenencia_inicio;

  _q := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, fecha_inicio, precision_inicio) VALUES (%s, %L, %L::date, %L) RETURNING id_pertenencia', id_documento, rol, pertenencia_inicio.fecha_inicio, pertenencia_inicio.precision_inicio);
  EXECUTE _q INTO _r;
  id_pertenencia_relacion := _r.id_pertenencia;

  _q := format('INSERT INTO persona_rol_pertenencia (fk_persona_historica_id, fk_pertenencia_id, descripcion) VALUES (%s, %s, %L) RETURNING id_persona_rol_pertenencia', id_persona_historica, id_pertenencia_relacion, descripcion);
  EXECUTE _q INTO _r;
  _id_persona_rol_pertenencia_relacion := _r.id_persona_rol_pertenencia;

  _q := format('INSERT INTO rol (nombre) VALUES (%L) ON CONFLICT DO NOTHING RETURNING nombre', rol);
  EXECUTE _q INTO _r;

  _q := format('INSERT INTO persona_rol_pertenencia_rel_rol (fk_rol_nombre, fk_persona_rol_pertenencia)
    VALUES (%L, %s) RETURNING *', rol, _id_persona_rol_pertenencia_relacion);
  EXECUTE _q INTO _r;

  RETURN _id_persona_rol_pertenencia_relacion;

END;
$$;


ALTER FUNCTION public.ae_add_rol_descp_para_documento(id_documento numeric, id_persona_historica numeric, nombre text, descripcion text, rol text) OWNER TO postgres;

--
-- Name: ae_add_sample(numeric, text, numeric, date, text, text, text, numeric, text, text, text, text, text, text, text, numeric, text, json, numeric, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_sample(id_muestra numeric, name text, ma_number numeric, date date, surface text, overall_preservation text, recorder text, crown_height numeric, tooth_abrasion text, state text, color text, consistency text, microcracks text, sediment_particles text, comments text, fk_individuo_resto_id numeric, material text, radiocarbon json, id_individuo_arqeuologico numeric, confidencial boolean) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE

  _r record;
  _q text;
  id_radiocarbon_dating numeric;

BEGIN

  -- Create or update sample
  IF id_muestra IS NULL
  THEN
    _q := format('INSERT INTO sample (
        name, ma_number, date, surface, 
        overall_preservation, recorder, crown_height, tooth_abrasion, state, 
        color, consistency, microcracks, sediment_particles, comments,
        fk_individuo_resto_id, confidencial
      ) VALUES (
        %L, %L, %L::date, %L,
        %L, %L, %L, %L, %L,
        %L, %L, %L, %L, %L,
        %s, %L
      ) RETURNING id_muestra', 
      name, ma_number, date, surface, overall_preservation, 
      recorder, crown_height, tooth_abrasion, state, 
      color, consistency, microcracks, sediment_particles, comments, 
      fk_individuo_resto_id, confidencial
    );
  ELSE
    _q := format('UPDATE sample SET  
        name=%L, ma_number=%L, date=%L::date, surface=%L,
        overall_preservation=%L, recorder=%L, crown_height=%L, tooth_abrasion=%L, state=%L,
        color=%L, consistency=%L, microcracks=%L, sediment_particles=%L, comments=%L,
        fk_individuo_resto_id=%s, confidencial=%L
      WHERE id_muestra = %s
      RETURNING id_muestra', 
      name, ma_number, date, surface, overall_preservation, 
      recorder, crown_height, tooth_abrasion, state, 
      color, consistency, microcracks, sediment_particles, comments, 
      fk_individuo_resto_id, confidencial,
      id_muestra
    );
  END IF;
  EXECUTE _q INTO _r;

  IF _r.id_muestra IS NOT NULL
  THEN
    id_muestra = _r.id_muestra;
  END IF;

  IF material IS NOT NULL
  THEN
    -- Delete and insert material - sample relation
    _q := format('DELETE FROM sample_rel_material_sample WHERE fk_sample_id = %s RETURNING *', id_muestra);
    EXECUTE _q INTO _r;

    _q := format('INSERT INTO sample_rel_material_sample (fk_sample_id, fk_material_sample_material) 
    VALUES (%s, %L) RETURNING *', id_muestra, material);
    EXECUTE _q INTO _r;
  END IF;

  -- check radiocarbon for insert or update
  IF (radiocarbon->'id_radiocarbon_dating')::text = 'null'
  THEN
    _q := format('INSERT INTO radiocarbon_dating (
        c_age_bp, years, 
        calibrated_date_1s_start, ad_bc_1s, calibrated_date_1s_end, ad_bc_1s_end,
        calibrated_date_2s_start, ad_bc_2s, calibrated_date_2s_end, ad_bc_2s_end,
        s13, cn, comments
      ) VALUES (
        %s, %s,
        %s, %L, %s, %L,
        %s, %L, %s, %L,
        %s, %s, %L
      )
      RETURNING *',
      radiocarbon->'c_age_bp', radiocarbon->'years', 
      radiocarbon->'calibrated_date_1s_start', radiocarbon->>'ad_bc_1s', radiocarbon->'calibrated_date_1s_end', radiocarbon->>'ad_bc_1s_end',
      radiocarbon->'calibrated_date_2s_start', radiocarbon->>'ad_bc_2s', radiocarbon->'calibrated_date_2s_end', radiocarbon->>'ad_bc_2s_end',
      radiocarbon->'s13', radiocarbon->'cn', radiocarbon->>'comments'
    );
  ELSE
    _q := format('UPDATE radiocarbon_dating 
      SET c_age_bp=%s, years=%s, 
        calibrated_date_1s_start=%s, ad_bc_1s=%L, calibrated_date_1s_end=%s, ad_bc_1s_end=%L,
        calibrated_date_2s_start=%s, ad_bc_2s=%L, calibrated_date_2s_end=%s, ad_bc_2s_end=%L,
        s13=%s, cn=%s, comments=%L
      WHERE id_radiocarbon_dating = %s
      RETURNING *',
      radiocarbon->'c_age_bp', radiocarbon->'years', 
      radiocarbon->'calibrated_date_1s_start', radiocarbon->>'ad_bc_1s', radiocarbon->'calibrated_date_1s_end', radiocarbon->>'ad_bc_1s_end',
      radiocarbon->'calibrated_date_2s_start', radiocarbon->>'ad_bc_2s', radiocarbon->'calibrated_date_2s_end', radiocarbon->>'ad_bc_2s_end',
      radiocarbon->'s13', radiocarbon->'cn', radiocarbon->>'comments', radiocarbon->'id_radiocarbon_dating'
    );
  END IF;
  RAISE NOTICE 'RADIOCARBON QUERY: %', _q;
  EXECUTE _q INTO _r;
  RAISE NOTICE 'RADIOCARBON RESULT: %', _r;

  id_radiocarbon_dating := _r.id_radiocarbon_dating;

  _q := format('UPDATE individuo_arqueologico 
    SET fk_radiocarbon_dating_id=%s
    WHERE id_individuo_arqueologico=%s
    RETURNING *',
    id_radiocarbon_dating,
    id_individuo_arqeuologico
  );
  EXECUTE _q INTO _r;

  RETURN id_muestra;

END;
$$;


ALTER FUNCTION public.ae_add_sample(id_muestra numeric, name text, ma_number numeric, date date, surface text, overall_preservation text, recorder text, crown_height numeric, tooth_abrasion text, state text, color text, consistency text, microcracks text, sediment_particles text, comments text, fk_individuo_resto_id numeric, material text, radiocarbon json, id_individuo_arqeuologico numeric, confidencial boolean) OWNER TO postgres;

--
-- Name: ae_add_simple_objeto(text, numeric, numeric); Type: FUNCTION; Schema: public; Owner: geographica
--

CREATE FUNCTION public.ae_add_simple_objeto(objeto text, id_objeto numeric DEFAULT NULL::numeric, fk_objeto_id numeric DEFAULT NULL::numeric) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.ae_add_simple_objeto(objeto text, id_objeto numeric, fk_objeto_id numeric) OWNER TO geographica;

--
-- Name: ae_add_testamento(numeric, json[], json[], json[], json[], json[], json[], text, json[], text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_testamento(id_document numeric, testamentary json[], executor json[], heir json[], notary json[], witnesses_issue json[], witnesses_opening json[], preamble text, mandas json[], burial_arrangement text) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE

  _r record;
  _q text;
  _aux json;

BEGIN

  PERFORM ae_add_person_batch(id_document, 'Testamentario'::text, testamentary::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Albacea'::text, executor::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Heredero'::text, heir::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Escribano'::text, notary::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Testigo de emisión'::text, witnesses_issue::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Testigo de apertura'::text, witnesses_opening::jsonb[]);

  --Crea las mandas
  _q := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Manda');
  EXECUTE _q INTO _r;

  FOREACH _aux IN ARRAY mandas
  LOOP
    _q := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, motivo, orden) VALUES (%s, %L, %L, %s) RETURNING id_pertenencia', id_document, 'Manda', _aux->>'description', _aux->>'order');
    EXECUTE _q INTO _r;
  END LOOP;

  --Guardo preámbulo
  _q := format('
    UPDATE documento SET preambulo_testamento=%L
    WHERE id_documento=%s RETURNING id_documento',
    preamble, id_document);

  EXECUTE _q INTO _r;

  --Guardo la disposición del enterramiento
  _q := format('
    UPDATE documento SET disp_ente_testamento=%L
    WHERE id_documento=%s RETURNING id_documento',
    burial_arrangement, id_document);

  EXECUTE _q INTO _r;

  RETURN id_document;

END;
$$;


ALTER FUNCTION public.ae_add_testamento(id_document numeric, testamentary json[], executor json[], heir json[], notary json[], witnesses_issue json[], witnesses_opening json[], preamble text, mandas json[], burial_arrangement text) OWNER TO postgres;

--
-- Name: ae_add_unidad(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_unidad(unidad text, tipo text) RETURNS text
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.ae_add_unidad(unidad text, tipo text) OWNER TO postgres;

--
-- Name: ae_add_unidades_agrupacion(numeric, json[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_unidades_agrupacion(id_agrupacion numeric, units json[]) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.ae_add_unidades_agrupacion(id_agrupacion numeric, units json[]) OWNER TO postgres;

--
-- Name: ae_add_visita(numeric, json[], json[], json[], json[], text, json[], json[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_visita(id_document numeric, applicant json[], defendant json[], witness json[], notary json[], diligence text, accusations json[], appeals json[]) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE

  _r record;
  _q text;
  _aux json;

BEGIN

  PERFORM ae_add_person_batch(id_document, 'Demandante'::text, applicant::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Demandado'::text, defendant::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Testigo'::text, witness::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Escribano'::text, notary::jsonb[]);

  --Creo la diligencia preliminar
  _q := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Deligencia_preliminar');
  EXECUTE _q INTO _r;

  _q := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, motivo) VALUES (%s, %L, %L) RETURNING id_pertenencia', id_document, 'Deligencia_preliminar', diligence);
  EXECUTE _q INTO _r;

  --Crea las acusaciones
  _q := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Acusacion');
  EXECUTE _q INTO _r;

  FOREACH _aux IN ARRAY accusations
  LOOP
    _q := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, motivo, orden) VALUES (%s, %L, %L, %s) RETURNING id_pertenencia', id_document, 'Acusacion', _aux->>'description', _aux->>'order');
    EXECUTE _q INTO _r;
  END LOOP;

  --Crea las apelaciones
  _q := format('DELETE FROM pertenencia WHERE fk_documento_id=%s AND tipo_atr_doc=%L RETURNING *', id_document, 'Apelacion');
  EXECUTE _q INTO _r;

  FOREACH _aux IN ARRAY appeals
  LOOP
    _q := format('INSERT INTO pertenencia (fk_documento_id, tipo_atr_doc, motivo, orden) VALUES (%s, %L, %L, %s) RETURNING id_pertenencia', id_document, 'Apelacion', _aux->>'description', _aux->>'order');
    EXECUTE _q INTO _r;
  END LOOP;


  RETURN id_document;

END;
$$;


ALTER FUNCTION public.ae_add_visita(id_document numeric, applicant json[], defendant json[], witness json[], notary json[], diligence text, accusations json[], appeals json[]) OWNER TO postgres;

--
-- Name: ae_add_ychromosome(numeric, numeric, text, numeric, text, text, text, text, text, text, numeric, numeric, numeric, numeric, numeric, numeric, text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ae_add_ychromosome(id_ychromosome numeric, fk_sample_id numeric, successful text, snps_hit numeric, class_method text, haplogroup text, superhaplo text, haplo_ancest_origin text, possible_pat_relat text, seq_strategy text, libraries_seq numeric, raw_reads numeric, mapped_reads numeric, whole_coverage numeric, mean_read_depth numeric, average_length numeric, updated_on text, comments text, interpretation text) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
  _r record;
  _q text;
BEGIN

  IF id_ychromosome IS NULL
  THEN
    _q := format('INSERT INTO ychromosome (
      fk_sample_id,
      successful,
      snps_hit,
      class_method,
      haplogroup,
      superhaplo,
      haplo_ancest_origin,
      possible_pat_relat,
      seq_strategy,
      libraries_seq,
      raw_reads,
      mapped_reads,
      whole_coverage,
      mean_read_depth,
      average_length,
      updated_on,
      comments,
      interpretation
      ) VALUES (
        %s, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L,
        %L::date, %L, %L
      ) RETURNING id_ychromosome',
      fk_sample_id,
      successful,
      snps_hit,
      class_method,
      haplogroup,
      superhaplo,
      haplo_ancest_origin,
      possible_pat_relat,
      seq_strategy,
      libraries_seq,
      raw_reads,
      mapped_reads,
      whole_coverage,
      mean_read_depth,
      average_length,
      updated_on,
      comments,
      interpretation
    );
  ELSE
    _q := format('UPDATE ychromosome SET
      fk_sample_id = %s,
      successful = %L,
      snps_hit = %L,
      class_method = %L,
      haplogroup = %L,
      superhaplo = %L,
      haplo_ancest_origin = %L,
      possible_pat_relat = %L,
      seq_strategy = %L,
      libraries_seq = %L,
      raw_reads = %L,
      mapped_reads = %L,
      whole_coverage = %L,
      mean_read_depth = %L,
      average_length = %L,
      updated_on = %L::date,
      comments = %L,
      interpretation = %L
      WHERE id_ychromosome = %s
      RETURNING *',
      fk_sample_id,
      successful,
      snps_hit,
      class_method,
      haplogroup,
      superhaplo,
      haplo_ancest_origin,
      possible_pat_relat,
      seq_strategy,
      libraries_seq,
      raw_reads,
      mapped_reads,
      whole_coverage,
      mean_read_depth,
      average_length,
      updated_on,
      comments,
      interpretation,
      id_ychromosome
    );
  END IF;
  EXECUTE _q INTO _r;

  RETURN _r.id_ychromosome;

END;
$$;


ALTER FUNCTION public.ae_add_ychromosome(id_ychromosome numeric, fk_sample_id numeric, successful text, snps_hit numeric, class_method text, haplogroup text, superhaplo text, haplo_ancest_origin text, possible_pat_relat text, seq_strategy text, libraries_seq numeric, raw_reads numeric, mapped_reads numeric, whole_coverage numeric, mean_read_depth numeric, average_length numeric, updated_on text, comments text, interpretation text) OWNER TO postgres;

--
-- Name: cdb_rectanglegrid(public.geometry, double precision, double precision, public.geometry); Type: FUNCTION; Schema: public; Owner: geographica
--

CREATE FUNCTION public.cdb_rectanglegrid(ext public.geometry, width double precision, height double precision, origin public.geometry DEFAULT NULL::public.geometry) RETURNS SETOF public.geometry
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
  h GEOMETRY; -- rectangle cell
  hstep FLOAT8; -- horizontal step
  vstep FLOAT8; -- vertical step
  hw FLOAT8; -- half width
  hh FLOAT8; -- half height
  vstart FLOAT8;
  hstart FLOAT8;
  hend FLOAT8;
  vend FLOAT8;
  xoff FLOAT8;
  yoff FLOAT8;
  xgrd FLOAT8;
  ygrd FLOAT8;
  x FLOAT8;
  y FLOAT8;
  srid INTEGER;
BEGIN

  srid := ST_SRID(ext);

  xoff := 0; 
  yoff := 0;

  IF origin IS NOT NULL THEN
    IF ST_SRID(origin) != srid THEN
      RAISE EXCEPTION 'SRID mismatch between extent (%) and origin (%)', srid, ST_SRID(origin);
    END IF;
    xoff := ST_X(origin);
    yoff := ST_Y(origin);
  END IF;

  --RAISE DEBUG 'X offset: %', xoff;
  --RAISE DEBUG 'Y offset: %', yoff;

  hw := width/2.0;
  hh := height/2.0;

  xgrd := hw;
  ygrd := hh;
  --RAISE DEBUG 'X grid size: %', xgrd;
  --RAISE DEBUG 'Y grid size: %', ygrd;

  hstep := width;
  vstep := height;

  -- Tweak horizontal start on hstep grid from origin 
  hstart := xoff + ceil((ST_XMin(ext)-xoff)/hstep)*hstep; 
  --RAISE DEBUG 'hstart: %', hstart;

  -- Tweak vertical start on vstep grid from origin 
  vstart := yoff + ceil((ST_Ymin(ext)-yoff)/vstep)*vstep; 
  --RAISE DEBUG 'vstart: %', vstart;

  hend := ST_XMax(ext);
  vend := ST_YMax(ext);

  --RAISE DEBUG 'hend: %', hend;
  --RAISE DEBUG 'vend: %', vend;

  x := hstart;
  WHILE x < hend LOOP -- over X
    y := vstart;
    h := ST_MakeEnvelope(x-hw, y-hh, x+hw, y+hh, srid);
    WHILE y < vend LOOP -- over Y
      RETURN NEXT h;
      h := ST_Translate(h, 0, vstep);
      y := yoff + round(((y + vstep)-yoff)/ygrd)*ygrd; -- round to grid
    END LOOP;
    x := xoff + round(((x + hstep)-xoff)/xgrd)*xgrd; -- round to grid
  END LOOP;

  RETURN;
END
$$;


ALTER FUNCTION public.cdb_rectanglegrid(ext public.geometry, width double precision, height double precision, origin public.geometry) OWNER TO geographica;

--
-- Name: trigger_set_timestamp(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trigger_set_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.trigger_set_timestamp() OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: tabla_prueba; Type: TABLE; Schema: pruebas; Owner: geographica
--

CREATE TABLE pruebas.tabla_prueba (
    id_material integer,
    nombre text,
    id integer NOT NULL
);


ALTER TABLE pruebas.tabla_prueba OWNER TO geographica;

--
-- Name: tabla_prueba_id_seq; Type: SEQUENCE; Schema: pruebas; Owner: geographica
--

CREATE SEQUENCE pruebas.tabla_prueba_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pruebas.tabla_prueba_id_seq OWNER TO geographica;

--
-- Name: tabla_prueba_id_seq; Type: SEQUENCE OWNED BY; Schema: pruebas; Owner: geographica
--

ALTER SEQUENCE pruebas.tabla_prueba_id_seq OWNED BY pruebas.tabla_prueba.id;


--
-- Name: id_agrupacion_bienes; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_agrupacion_bienes
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_agrupacion_bienes OWNER TO postgres;

--
-- Name: agrupacion_bienes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.agrupacion_bienes (
    id_agrupacion_bienes integer DEFAULT nextval('public.id_agrupacion_bienes'::regclass) NOT NULL,
    nombre character varying,
    fecha date,
    precision_fecha character varying(5),
    adelanto_cont character varying,
    descripcion_cont character varying,
    folio_cont character varying,
    fk_metodo_pago_id integer,
    precision_lugar character varying(250),
    fk_lugar_id integer,
    insertdatetime timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone
);


ALTER TABLE public.agrupacion_bienes OWNER TO postgres;

--
-- Name: agrupacion_bienes_rel_unidad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.agrupacion_bienes_rel_unidad (
    fk_agrupacion_bienes_id integer NOT NULL,
    fk_unidad_nombre character varying NOT NULL,
    valor double precision NOT NULL,
    insertdatetime timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone
);


ALTER TABLE public.agrupacion_bienes_rel_unidad OWNER TO postgres;

--
-- Name: id_analysis; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_analysis
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_analysis OWNER TO postgres;

--
-- Name: analysis; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.analysis (
    id_analisis integer DEFAULT nextval('public.id_analysis'::regclass) NOT NULL,
    comments character varying,
    distance_from_cervix double precision,
    sub_name character varying,
    ma_number integer,
    fk_sample_id integer
);


ALTER TABLE public.analysis OWNER TO postgres;

--
-- Name: id_anomalia; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_anomalia
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_anomalia OWNER TO postgres;

--
-- Name: anomalia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.anomalia (
    id_anomalia integer DEFAULT nextval('public.id_anomalia'::regclass) NOT NULL,
    codigo character varying(500),
    nombre character varying,
    descripcion character varying(1500),
    fk_anomalia_id integer,
    traduccion character varying
);
ALTER TABLE ONLY public.anomalia ALTER COLUMN id_anomalia SET STATISTICS 1;


ALTER TABLE public.anomalia OWNER TO postgres;

--
-- Name: anomalia_rel_individuo_resto; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.anomalia_rel_individuo_resto (
    fk_anomalia_id integer NOT NULL,
    fk_individuo_resto_id integer NOT NULL,
    insertdatetime timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone
);


ALTER TABLE public.anomalia_rel_individuo_resto OWNER TO postgres;

--
-- Name: id_atributo_documento; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_atributo_documento
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_atributo_documento OWNER TO postgres;

--
-- Name: atributo_documento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.atributo_documento (
    id_atributo_documento integer DEFAULT nextval('public.id_atributo_documento'::regclass) NOT NULL,
    nombre character varying(100) NOT NULL,
    descripcion character varying(400),
    v_string character varying(1000),
    v_int integer,
    v_date date,
    v_float double precision,
    v_boolean boolean,
    fk_documento_id integer
);


ALTER TABLE public.atributo_documento OWNER TO postgres;

--
-- Name: id_attr_especifico; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_attr_especifico
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_attr_especifico OWNER TO postgres;

--
-- Name: attr_especifico; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.attr_especifico (
    id_attr_especifico integer DEFAULT nextval('public.id_attr_especifico'::regclass) NOT NULL,
    nombre character varying,
    tipo character varying
);


ALTER TABLE public.attr_especifico OWNER TO postgres;

--
-- Name: id_bioapatite; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_bioapatite
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_bioapatite OWNER TO postgres;

--
-- Name: bioapatite; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bioapatite (
    id_bioapatite integer DEFAULT nextval('public.id_bioapatite'::regclass) NOT NULL,
    interpretation character varying,
    sr_conc double precision,
    sr87_sr86 double precision,
    sr87_sr86_2sd double precision,
    ag4_po3_yield double precision,
    s18op double precision,
    s18op_1sd double precision,
    s18oc double precision,
    s18oc_1sd double precision,
    s13cc double precision,
    s13cc_1sd double precision,
    quality_criteria character varying,
    quality_comment character varying,
    comments character varying,
    fk_sample_id integer,
    distance_from_cervix double precision,
    sub_name character varying,
    insertdatetime timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone
);


ALTER TABLE public.bioapatite OWNER TO postgres;

--
-- Name: id_carbonate; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_carbonate
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_carbonate OWNER TO postgres;

--
-- Name: carbonate; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.carbonate (
    id_carbonate integer DEFAULT nextval('public.id_carbonate'::regclass) NOT NULL,
    s18oc double precision,
    s18oc_1sd double precision,
    s13cc double precision,
    s13cc_1sd double precision,
    comments character varying,
    fk_analysis_id integer,
    interpretation character varying
);


ALTER TABLE public.carbonate OWNER TO postgres;

--
-- Name: cargo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cargo (
    nombre character varying NOT NULL
);


ALTER TABLE public.cargo OWNER TO postgres;

--
-- Name: categoria_resto; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categoria_resto (
    nombre character varying NOT NULL,
    descripcion character varying(1000),
    traduccion character varying
);


ALTER TABLE public.categoria_resto OWNER TO postgres;

--
-- Name: id_categoria_resto_indice; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_categoria_resto_indice
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_categoria_resto_indice OWNER TO postgres;

--
-- Name: categoria_resto_indice; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categoria_resto_indice (
    id_categoria_resto_indice integer DEFAULT nextval('public.id_categoria_resto_indice'::regclass) NOT NULL,
    fk_categoria_resto_indice_id integer,
    fk_categoria_resto_nombre character varying
);


ALTER TABLE public.categoria_resto_indice OWNER TO postgres;

--
-- Name: categoria_resto_rel_anomalia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categoria_resto_rel_anomalia (
    fk_categoria_resto character varying NOT NULL,
    fk_anomalia_id integer NOT NULL,
    obligatorio boolean NOT NULL
);


ALTER TABLE public.categoria_resto_rel_anomalia OWNER TO postgres;

--
-- Name: coleccion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.coleccion (
    sigla character varying(30) NOT NULL,
    tipo character varying(100) NOT NULL,
    descripcion character varying(1000),
    nombre character varying(500) NOT NULL
);


ALTER TABLE public.coleccion OWNER TO postgres;

--
-- Name: id_collagen; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_collagen
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_collagen OWNER TO postgres;

--
-- Name: collagen; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.collagen (
    id_collagen integer DEFAULT nextval('public.id_collagen'::regclass) NOT NULL,
    collagen_yield double precision,
    cp double precision,
    cp_1sd double precision,
    np double precision,
    np_1sd double precision,
    atomic_cn_ratio double precision,
    s13_ccoll double precision,
    s13_ccoll_1sd double precision,
    s15_ncoll double precision,
    s15_ncoll_1sd double precision,
    quality_criteria character varying,
    quality_comment character varying,
    comments character varying,
    fk_sample_id integer,
    interpretation character varying,
    distance_from_cervix double precision,
    sub_name character varying,
    insertdatetime timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone
);


ALTER TABLE public.collagen OWNER TO postgres;

--
-- Name: django_migrations; Type: TABLE; Schema: public; Owner: geographica
--

CREATE TABLE public.django_migrations (
    id integer NOT NULL,
    app character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    applied timestamp with time zone NOT NULL
);


ALTER TABLE public.django_migrations OWNER TO geographica;

--
-- Name: django_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: geographica
--

CREATE SEQUENCE public.django_migrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_migrations_id_seq OWNER TO geographica;

--
-- Name: django_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: geographica
--

ALTER SEQUENCE public.django_migrations_id_seq OWNED BY public.django_migrations.id;


--
-- Name: id_dna_extraction; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_dna_extraction
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_dna_extraction OWNER TO postgres;

--
-- Name: dna_extraction; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dna_extraction (
    id_dna_extraction integer DEFAULT nextval('public.id_dna_extraction'::regclass) NOT NULL,
    sample_name character varying,
    fk_analysis_id integer,
    unipv_number integer,
    skeletal character varying,
    surface character varying(250),
    overall character varying(250),
    date date,
    recorder character varying(250),
    concentration double precision,
    ratio double precision,
    comments character varying
);


ALTER TABLE public.dna_extraction OWNER TO postgres;

--
-- Name: id_documento; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_documento
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_documento OWNER TO postgres;

--
-- Name: documento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.documento (
    id_documento integer DEFAULT nextval('public.id_documento'::regclass) NOT NULL,
    version_doc integer,
    titulo character varying,
    foliado boolean,
    des_foliado character varying(250),
    firmada boolean,
    holografa character varying(50),
    resumen character varying,
    transcripcion character varying,
    transcripcion_tipo character varying(50),
    adelanto_cont character varying,
    soporte character varying(1500),
    migracion character varying(1500),
    fecha_confi_datos date,
    fecha_confi_img date,
    tipo character varying(1500),
    subtipo character varying(1500),
    motivo_almoneda character varying,
    preambulo_testamento character varying,
    disp_ente_testamento character varying,
    diligencias_visita character varying,
    fk_usuario_id integer,
    fk_seccion_id integer,
    fk_pena_id integer,
    signatura character varying(500),
    confidencial_datos boolean,
    confidencial_img boolean,
    insertdatetime timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone
);


ALTER TABLE public.documento OWNER TO postgres;

--
-- Name: documento_rel_documento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.documento_rel_documento (
    fk_documento1 integer NOT NULL,
    fk_documento2 integer NOT NULL
);


ALTER TABLE public.documento_rel_documento OWNER TO postgres;

--
-- Name: documento_rel_referencia_bibliografica; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.documento_rel_referencia_bibliografica (
    fk_documento_id integer NOT NULL,
    fk_referencia_bibliografica_id integer NOT NULL
);


ALTER TABLE public.documento_rel_referencia_bibliografica OWNER TO postgres;

--
-- Name: documento_rel_unidad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.documento_rel_unidad (
    fk_documento_id integer NOT NULL,
    fk_unidad_nombre character varying NOT NULL,
    valor double precision NOT NULL
);


ALTER TABLE public.documento_rel_unidad OWNER TO postgres;

--
-- Name: documento_rel_url; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.documento_rel_url (
    fk_documento_id integer NOT NULL,
    fk_url_id integer NOT NULL,
    inicio_pag integer,
    fin_pag integer,
    insertdatetime timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone
);


ALTER TABLE public.documento_rel_url OWNER TO postgres;

--
-- Name: id_entierro; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_entierro
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_entierro OWNER TO postgres;

--
-- Name: entierro; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.entierro (
    id_entierro integer DEFAULT nextval('public.id_entierro'::regclass) NOT NULL,
    nomenclatura_sitio character varying,
    lugar character varying,
    fk_espacio_nombre character varying(250),
    estructura character varying(500),
    forma character varying(500),
    largo double precision,
    ancho double precision,
    profundidad double precision,
    observaciones character varying,
    anio_fecha character varying,
    place_geometry public.geometry(Point,4326),
    insertdatetime timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone
);


ALTER TABLE public.entierro OWNER TO postgres;

--
-- Name: entierro_rel_url; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.entierro_rel_url (
    fk_entierro_id integer NOT NULL,
    fk_url_id integer NOT NULL
);


ALTER TABLE public.entierro_rel_url OWNER TO postgres;

--
-- Name: espacio_entierro; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.espacio_entierro (
    nombre character varying NOT NULL,
    fk_espacio_entierro character varying
);


ALTER TABLE public.espacio_entierro OWNER TO postgres;

--
-- Name: especie; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.especie (
    nombre character varying NOT NULL,
    descripcion character varying(1000),
    latin character varying(1000),
    english character varying(1000)
);


ALTER TABLE public.especie OWNER TO postgres;

--
-- Name: estado; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.estado (
    tipo_cons_represen character varying NOT NULL,
    elemento character varying NOT NULL
);


ALTER TABLE public.estado OWNER TO postgres;

--
-- Name: estado_rel_individuo_arqueologico; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.estado_rel_individuo_arqueologico (
    fk_estado_tipo_cons_repre character varying NOT NULL,
    fk_estado_elemento character varying NOT NULL,
    fk_individuo_arqueologico_id integer NOT NULL,
    valor character varying(100) NOT NULL
);


ALTER TABLE public.estado_rel_individuo_arqueologico OWNER TO postgres;

--
-- Name: id_almidon; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_almidon
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_almidon OWNER TO postgres;

--
-- Name: id_audna; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_audna
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_audna OWNER TO postgres;

--
-- Name: id_coleccion; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_coleccion
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_coleccion OWNER TO postgres;

--
-- Name: id_individuo_arqueologico; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_individuo_arqueologico
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_individuo_arqueologico OWNER TO postgres;

--
-- Name: id_individuo_resto; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_individuo_resto
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_individuo_resto OWNER TO postgres;

--
-- Name: id_line; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_line
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_line OWNER TO postgres;

--
-- Name: id_linea; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_linea
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_linea OWNER TO postgres;

--
-- Name: id_log_acceso; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_log_acceso
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_log_acceso OWNER TO postgres;

--
-- Name: id_lote; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_lote
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_lote OWNER TO postgres;

--
-- Name: id_lote_genero_edad; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_lote_genero_edad
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_lote_genero_edad OWNER TO postgres;

--
-- Name: id_lugar; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_lugar
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_lugar OWNER TO postgres;

--
-- Name: id_material; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_material
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_material OWNER TO postgres;

--
-- Name: id_metodo_pago; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_metodo_pago
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_metodo_pago OWNER TO postgres;

--
-- Name: id_mtdna; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_mtdna
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_mtdna OWNER TO postgres;

--
-- Name: id_muestra; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_muestra
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_muestra OWNER TO postgres;

--
-- Name: id_navegacion; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_navegacion
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_navegacion OWNER TO postgres;

--
-- Name: id_objeto; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_objeto
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_objeto OWNER TO postgres;

--
-- Name: id_objeto_arqueologico_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_objeto_arqueologico_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_objeto_arqueologico_seq OWNER TO postgres;

--
-- Name: id_observacion; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_observacion
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_observacion OWNER TO postgres;

--
-- Name: id_or_per_lug; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_or_per_lug
    START WITH 2
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_or_per_lug OWNER TO postgres;

--
-- Name: id_origen_persona; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_origen_persona
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_origen_persona OWNER TO postgres;

--
-- Name: id_paso_itinerario; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_paso_itinerario
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_paso_itinerario OWNER TO postgres;

--
-- Name: id_pena; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_pena
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_pena OWNER TO postgres;

--
-- Name: id_perfil_usuario; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_perfil_usuario
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_perfil_usuario OWNER TO postgres;

--
-- Name: id_permiso_navegacion; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_permiso_navegacion
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_permiso_navegacion OWNER TO postgres;

--
-- Name: id_permisos_api; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_permisos_api
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_permisos_api OWNER TO postgres;

--
-- Name: id_persona_historica; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_persona_historica
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_persona_historica OWNER TO postgres;

--
-- Name: id_persona_rol_pertenencia; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_persona_rol_pertenencia
    START WITH 2
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_persona_rol_pertenencia OWNER TO postgres;

--
-- Name: id_pertenencia; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_pertenencia
    START WITH 3
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_pertenencia OWNER TO postgres;

--
-- Name: id_phosphates; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_phosphates
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_phosphates OWNER TO postgres;

--
-- Name: id_point; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_point
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_point OWNER TO postgres;

--
-- Name: id_polygon; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_polygon
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_polygon OWNER TO postgres;

--
-- Name: id_radiocarbon_dating; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_radiocarbon_dating
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_radiocarbon_dating OWNER TO postgres;

--
-- Name: id_referencia_bibliografica; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_referencia_bibliografica
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_referencia_bibliografica OWNER TO postgres;

--
-- Name: id_rel_iti_obj_trans; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_rel_iti_obj_trans
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_rel_iti_obj_trans OWNER TO postgres;

--
-- Name: id_seccion; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_seccion
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_seccion OWNER TO postgres;

--
-- Name: id_sr; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_sr
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_sr OWNER TO postgres;

--
-- Name: id_transporte; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_transporte
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_transporte OWNER TO postgres;

--
-- Name: id_url; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_url
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_url OWNER TO postgres;

--
-- Name: id_usuario; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_usuario
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_usuario OWNER TO postgres;

--
-- Name: id_wholegenome; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_wholegenome
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_wholegenome OWNER TO postgres;

--
-- Name: id_ychromosome; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_ychromosome
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_ychromosome OWNER TO postgres;

--
-- Name: individuo_arqueologico; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.individuo_arqueologico (
    id_individuo_arqueologico integer DEFAULT nextval('public.id_individuo_arqueologico'::regclass) NOT NULL,
    catalogo character varying(250),
    sexo character varying(250),
    edad character varying(250),
    filiacion_poblacional character varying(250),
    estatura double precision,
    periodo_inicio character varying(4),
    periodo_fin character varying(4),
    unid_estratigrafica character varying(150) NOT NULL,
    unid_estratigrafica_asociada character varying(150),
    tipo character varying,
    clase_enterramiento character varying,
    descomposicion character varying,
    contenedor character varying,
    pos_extremidades_inf character varying,
    pos_extremidades_sup character varying,
    posicion_cuerpo character varying,
    orientacion_cuerpo character varying,
    orientacion_creaneo character varying,
    tipo_enterramiento character varying,
    fk_radiocarbon_dating_id integer,
    fk_entierro integer NOT NULL,
    observaciones character varying,
    estructura character varying(500),
    forma character varying(500),
    largo double precision,
    ancho double precision,
    profundidad double precision,
    nmi_total integer,
    insertdatetime timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone,
    confidencial boolean DEFAULT false NOT NULL
);


ALTER TABLE public.individuo_arqueologico OWNER TO postgres;

--
-- Name: individuo_arqueologico_rel_linea; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.individuo_arqueologico_rel_linea (
    fk_individuo_arqueologico integer NOT NULL,
    fk_linea integer NOT NULL,
    origen character varying,
    tipo character varying(100) NOT NULL,
    insertdatetime timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone
);


ALTER TABLE public.individuo_arqueologico_rel_linea OWNER TO postgres;

--
-- Name: individuo_arqueologico_rel_url; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.individuo_arqueologico_rel_url (
    fk_individuo_arqueologico_id integer NOT NULL,
    fk_url_id integer NOT NULL
);


ALTER TABLE public.individuo_arqueologico_rel_url OWNER TO postgres;

--
-- Name: individuo_resto; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.individuo_resto (
    id_individuo_resto integer DEFAULT nextval('public.id_individuo_resto'::regclass) NOT NULL,
    fk_resto_variable character varying,
    fk_especie_nombre character varying,
    fk_individuo_arqueologico_id integer NOT NULL,
    numero integer,
    insertdatetime timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone
);


ALTER TABLE public.individuo_resto OWNER TO postgres;

--
-- Name: individuo_resto_rel_url; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.individuo_resto_rel_url (
    fk_individuo_resto integer NOT NULL,
    fk_url integer NOT NULL
);


ALTER TABLE public.individuo_resto_rel_url OWNER TO postgres;

--
-- Name: institucion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.institucion (
    nombre character varying NOT NULL,
    fecha_creacion date,
    descripcion character varying
);


ALTER TABLE public.institucion OWNER TO postgres;

--
-- Name: keyword; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.keyword (
    palabra character varying NOT NULL,
    key_indice character varying(9),
    fk_keyword character varying(100)
);


ALTER TABLE public.keyword OWNER TO postgres;

--
-- Name: keyword_rel_documento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.keyword_rel_documento (
    fk_keyword_palabra character varying(100) NOT NULL,
    fk_documento_id integer NOT NULL
);


ALTER TABLE public.keyword_rel_documento OWNER TO postgres;

--
-- Name: line; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.line (
    geom_wgs84 public.geometry(LineString,4326),
    id_line integer DEFAULT nextval('public.id_line'::regclass) NOT NULL,
    geom_nad27 public.geometry(LineString,26718)
);


ALTER TABLE public.line OWNER TO postgres;

--
-- Name: linea; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.linea (
    id_linea integer DEFAULT nextval('public.id_linea'::regclass) NOT NULL,
    descripcion character varying,
    estado character varying,
    calidad character varying,
    color character varying,
    cantidad integer,
    tipo_impuesto character varying,
    info_cont character varying,
    compra_nomb character varying,
    fk_material_id integer,
    fk_agrupacion_bienes_id integer,
    fk_objeto_id integer,
    fk_entierro_id integer,
    fk_individuo_arqueologico integer,
    tipo_obj character varying,
    fecha date,
    precision_fecha character varying(5),
    fk_lugar_id integer,
    precision_lugar character varying(250),
    descripcion_lugar character varying,
    compra_cargo character varying,
    condiciones_nombramiento character varying,
    insertdatetime timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone
);


ALTER TABLE public.linea OWNER TO postgres;

--
-- Name: linea_rel_lugar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.linea_rel_lugar (
    fk_linea_id integer NOT NULL,
    fk_lugar_id integer NOT NULL,
    precision_lugar character varying(250),
    descripcion_lugar character varying
);


ALTER TABLE public.linea_rel_lugar OWNER TO postgres;

--
-- Name: linea_rel_unidad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.linea_rel_unidad (
    fk_linea_id integer NOT NULL,
    fk_unidad_nombre character varying NOT NULL,
    valor double precision NOT NULL,
    es_impuesto boolean DEFAULT false NOT NULL
);


ALTER TABLE public.linea_rel_unidad OWNER TO postgres;

--
-- Name: log_acceso; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.log_acceso (
    id_log_acceso integer DEFAULT nextval('public.id_log_acceso'::regclass) NOT NULL,
    inicio_sesion timestamp with time zone,
    fin_sesion timestamp with time zone,
    fk_usuario integer,
    fecha date,
    ip integer,
    token character varying
);


ALTER TABLE public.log_acceso OWNER TO postgres;

--
-- Name: lote; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lote (
    id_lote integer DEFAULT nextval('public.id_lote'::regclass) NOT NULL,
    tipo character varying,
    nmi integer,
    estructura_nmi character varying,
    observaciones character varying,
    unid_estratigrafica character varying(150)
);


ALTER TABLE public.lote OWNER TO postgres;

--
-- Name: lote_edades; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lote_edades (
    id_edad_recodificada character varying NOT NULL
);


ALTER TABLE public.lote_edades OWNER TO postgres;

--
-- Name: lote_edades_rel_individuo_arqueologico; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lote_edades_rel_individuo_arqueologico (
    fk_lote_edades character varying NOT NULL,
    fk_individuo_arqueologico integer NOT NULL,
    cantidad integer
);


ALTER TABLE public.lote_edades_rel_individuo_arqueologico OWNER TO postgres;

--
-- Name: lugar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lugar (
    nombre character varying NOT NULL,
    region_cont character varying,
    localizacion character varying,
    longitud character varying,
    latitud character varying,
    sistema_ref character varying(500),
    coor_macro character varying,
    coor_micro character varying,
    zona character varying(500),
    hemisferio character varying(100),
    fk_polygon_id integer,
    fk_line_id integer,
    fk_point_id integer,
    altitud character varying,
    prop_geologicas character varying,
    id_lugar integer DEFAULT nextval('public.id_lugar'::regclass) NOT NULL,
    fk_lugar_id integer,
    fk_tipo_lugar_nombre character varying,
    insertdatetime timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone
);


ALTER TABLE public.lugar OWNER TO postgres;

--
-- Name: maps; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.maps (
    id integer NOT NULL,
    title text,
    description text,
    link text
);


ALTER TABLE public.maps OWNER TO postgres;

--
-- Name: maps_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.maps_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.maps_id_seq OWNER TO postgres;

--
-- Name: maps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.maps_id_seq OWNED BY public.maps.id;


--
-- Name: material; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.material (
    id_material integer DEFAULT nextval('public.id_material'::regclass) NOT NULL,
    nombre character varying NOT NULL,
    fk_material_id integer
);


ALTER TABLE public.material OWNER TO postgres;

--
-- Name: material_sample; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.material_sample (
    material character varying NOT NULL,
    fk_material character varying
);


ALTER TABLE public.material_sample OWNER TO postgres;

--
-- Name: metodo_pago; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.metodo_pago (
    id_metodo_pago integer DEFAULT nextval('public.id_metodo_pago'::regclass) NOT NULL,
    tipo character varying(500),
    plazo_credito character varying(500),
    interes_credito character varying(500)
);


ALTER TABLE public.metodo_pago OWNER TO postgres;

--
-- Name: miembro; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.miembro (
    texto character varying NOT NULL
);


ALTER TABLE public.miembro OWNER TO postgres;

--
-- Name: TABLE miembro; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.miembro IS 'Tabla para indicar los miembros perdidos en una pena de sentencia';


--
-- Name: mtdna; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mtdna (
    id_mtdna integer DEFAULT nextval('public.id_mtdna'::regclass) NOT NULL,
    fk_sample_id integer,
    haplo_vs_rcrs character varying,
    seq_range character varying,
    haplogroup character varying(150),
    overall_rank double precision,
    superhaplo character varying(50),
    haplo_ancest_origin character varying(150),
    expect_not_fd_polys character varying(1000),
    private_polys character varying(1000),
    heteroplasmies character varying(255),
    fasta character varying,
    possible_mat_relat character varying(1000),
    seq_strategy character varying(500),
    libraries_seq integer,
    raw_reads integer,
    mapped_reads integer,
    whole_coverage double precision,
    mean_read_depth double precision,
    fraction double precision,
    average_length double precision,
    comments character varying,
    interpretation character varying,
    successful character varying(100),
    class_method character varying(150),
    alter_haplo character varying(150),
    bam_file character varying,
    insertdatetime timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone,
    contamination double precision,
    updated_on date,
    vcf_file character varying
);


ALTER TABLE public.mtdna OWNER TO postgres;

--
-- Name: muestra_rel_url; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.muestra_rel_url (
    fk_muestra_id integer NOT NULL,
    fk_url_id integer NOT NULL
);


ALTER TABLE public.muestra_rel_url OWNER TO postgres;

--
-- Name: navegacion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.navegacion (
    id_navegacion integer DEFAULT nextval('public.id_navegacion'::regclass) NOT NULL,
    fecha_inicio date,
    precision_inicio character varying(5),
    fecha_fin date,
    precision_fin character varying(5),
    motivo character varying,
    fk_documento_id integer
);


ALTER TABLE public.navegacion OWNER TO postgres;

--
-- Name: navegacion_rel_agrupacion_bienes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.navegacion_rel_agrupacion_bienes (
    fk_navegacion_id integer NOT NULL,
    fk_agrupacion_bienes_id integer NOT NULL
);


ALTER TABLE public.navegacion_rel_agrupacion_bienes OWNER TO postgres;

--
-- Name: navegacion_rel_persona_rol_pertenencia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.navegacion_rel_persona_rol_pertenencia (
    fk_persona_rol_pertenencia_id integer NOT NULL,
    fk_navegacion_id integer NOT NULL
);


ALTER TABLE public.navegacion_rel_persona_rol_pertenencia OWNER TO postgres;

--
-- Name: navegacion_rel_transporte; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.navegacion_rel_transporte (
    fk_navegacion_id integer NOT NULL,
    fk_transporte_id integer NOT NULL,
    tipo_navegacion character varying
);


ALTER TABLE public.navegacion_rel_transporte OWNER TO postgres;

--
-- Name: objeto; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.objeto (
    id_objeto integer DEFAULT nextval('public.id_objeto'::regclass) NOT NULL,
    tipo character varying,
    nombre character varying,
    fk_objeto_id integer
);


ALTER TABLE public.objeto OWNER TO postgres;

--
-- Name: objeto_arqueologico; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.objeto_arqueologico (
    id_objeto integer DEFAULT nextval('public.id_objeto_arqueologico_seq'::regclass) NOT NULL,
    nombre character varying,
    insertdatetime timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone
);


ALTER TABLE public.objeto_arqueologico OWNER TO postgres;

--
-- Name: objeto_arqueologico_rel_linea; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.objeto_arqueologico_rel_linea (
    fk_objeto_arqueologico integer NOT NULL,
    fk_linea integer NOT NULL
);


ALTER TABLE public.objeto_arqueologico_rel_linea OWNER TO postgres;

--
-- Name: observacion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.observacion (
    id_observacion integer DEFAULT nextval('public.id_observacion'::regclass) NOT NULL,
    texto character varying,
    fk_documento integer
);


ALTER TABLE public.observacion OWNER TO postgres;

--
-- Name: ocupacion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ocupacion (
    nombre character varying NOT NULL
);


ALTER TABLE public.ocupacion OWNER TO postgres;

--
-- Name: or_per_lug; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.or_per_lug (
    id_or_per_lug integer DEFAULT nextval('public.id_or_per_lug'::regclass) NOT NULL,
    fk_origen_persona_id integer NOT NULL,
    fk_persona_rol_pertenencia_id integer NOT NULL,
    fk_lugar_id integer,
    precision_lugar character varying(250)
);


ALTER TABLE public.or_per_lug OWNER TO postgres;

--
-- Name: origen_persona; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.origen_persona (
    id_origen_persona integer DEFAULT nextval('public.id_origen_persona'::regclass) NOT NULL,
    nombre character varying,
    descripcion character varying,
    fk_origen_persona_id integer
);


ALTER TABLE public.origen_persona OWNER TO postgres;

--
-- Name: paleobotany; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.paleobotany (
    id_almidon integer DEFAULT nextval('public.id_almidon'::regclass) NOT NULL,
    sample_number integer,
    number_grains integer,
    morphotype character varying,
    family character varying,
    genus character varying,
    species character varying,
    name character varying,
    comments character varying,
    fk_muestra_id integer,
    fk_almidon_id integer,
    tipo_almidon_fitolito character varying,
    depth_fitolito double precision,
    concentration_fitolito double precision
);


ALTER TABLE public.paleobotany OWNER TO postgres;

--
-- Name: paso_itinerario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.paso_itinerario (
    id_paso_itinerario integer DEFAULT nextval('public.id_paso_itinerario'::regclass) NOT NULL,
    fecha date,
    tipo character varying,
    descripcion character varying,
    fk_navegacion_id integer,
    precision_paso character varying,
    fk_lugar_id integer
);


ALTER TABLE public.paso_itinerario OWNER TO postgres;

--
-- Name: pena; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pena (
    id_pena integer DEFAULT nextval('public.id_pena'::regclass) NOT NULL,
    destierro_tipo character varying(250),
    fecha_ini_dest date,
    fecha_fin_dest date,
    precision_ini_dest character varying(150),
    precision_fin_dest character varying(150),
    multa boolean,
    destierro boolean,
    exculpatoria boolean,
    perdida_bienes boolean,
    perdida_bienes_desc character varying(500),
    otro boolean,
    otro_desc character varying,
    escarnio boolean,
    azotes boolean,
    muerte boolean,
    muerte_medio character varying(500)
);


ALTER TABLE public.pena OWNER TO postgres;

--
-- Name: pena_rel_miembro; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pena_rel_miembro (
    fk_pena_id integer NOT NULL,
    fk_miembro_texto character varying NOT NULL
);


ALTER TABLE public.pena_rel_miembro OWNER TO postgres;

--
-- Name: pena_rel_unidad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pena_rel_unidad (
    fk_pena_id integer NOT NULL,
    fk_unidad_nombre character varying NOT NULL,
    valor double precision NOT NULL
);


ALTER TABLE public.pena_rel_unidad OWNER TO postgres;

--
-- Name: perfil_usuario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.perfil_usuario (
    id_perfil_usuario integer DEFAULT nextval('public.id_perfil_usuario'::regclass) NOT NULL,
    nombre character varying(500),
    descripcion character varying(1000)
);


ALTER TABLE public.perfil_usuario OWNER TO postgres;

--
-- Name: perfil_usuario_rel_permisos_api; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.perfil_usuario_rel_permisos_api (
    fk_perfil_usuario integer NOT NULL,
    fk_permisos_api integer NOT NULL
);


ALTER TABLE public.perfil_usuario_rel_permisos_api OWNER TO postgres;

--
-- Name: permiso_navegacion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.permiso_navegacion (
    id_permiso_navegacion integer DEFAULT nextval('public.id_permiso_navegacion'::regclass) NOT NULL,
    lugar_emision character varying,
    fecha_emision date,
    puerto_salida character varying,
    puerto_llegada character varying,
    mercancias character varying,
    autoridad character varying(500),
    observacion character varying,
    fk_navegacion_id integer
);


ALTER TABLE public.permiso_navegacion OWNER TO postgres;

--
-- Name: permisos_api; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.permisos_api (
    id_permisos_api integer DEFAULT nextval('public.id_permisos_api'::regclass) NOT NULL,
    nombre character varying(250) NOT NULL,
    crear boolean,
    borrar boolean,
    modificar boolean,
    lectura boolean
);


ALTER TABLE public.permisos_api OWNER TO postgres;

--
-- Name: persona_historica; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.persona_historica (
    id_persona_historica integer DEFAULT nextval('public.id_persona_historica'::regclass) NOT NULL,
    nombre character varying NOT NULL,
    genero character varying(250),
    fk_persona_historica integer,
    fk_individuo_arqueologico_id integer,
    insertdatetime timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone
);


ALTER TABLE public.persona_historica OWNER TO postgres;

--
-- Name: persona_rol_pertenencia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.persona_rol_pertenencia (
    id_persona_rol_pertenencia integer DEFAULT nextval('public.id_persona_rol_pertenencia'::regclass) NOT NULL,
    edad_min integer,
    edad_max integer,
    descripcion character varying,
    edad_recodificada character varying(200),
    fk_persona_historica_id integer,
    fk_pertenencia_id integer,
    fk_persona_rol_pertenencia_id integer,
    is_relation boolean DEFAULT false NOT NULL,
    insertdatetime timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone
);


ALTER TABLE public.persona_rol_pertenencia OWNER TO postgres;

--
-- Name: persona_rol_pertenencia_rel_cargo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.persona_rol_pertenencia_rel_cargo (
    fk_cargo_nombre character varying NOT NULL,
    fk_persona_rol_pertenencia_id integer NOT NULL,
    insertdatetime timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone
);


ALTER TABLE public.persona_rol_pertenencia_rel_cargo OWNER TO postgres;

--
-- Name: persona_rol_pertenencia_rel_institucion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.persona_rol_pertenencia_rel_institucion (
    fk_persona_rol_pertenencia_id integer NOT NULL,
    fk_institucion_nombre character varying NOT NULL,
    insertdatetime timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone
);


ALTER TABLE public.persona_rol_pertenencia_rel_institucion OWNER TO postgres;

--
-- Name: persona_rol_pertenencia_rel_linea; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.persona_rol_pertenencia_rel_linea (
    fk_persona_rol_pertenencia_id integer NOT NULL,
    fk_linea integer NOT NULL,
    insertdatetime timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone
);


ALTER TABLE public.persona_rol_pertenencia_rel_linea OWNER TO postgres;

--
-- Name: persona_rol_pertenencia_rel_lugar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.persona_rol_pertenencia_rel_lugar (
    fk_persona_rol_pertenencia_id integer NOT NULL,
    fk_lugar_id integer NOT NULL,
    insertdatetime timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone
);


ALTER TABLE public.persona_rol_pertenencia_rel_lugar OWNER TO postgres;

--
-- Name: persona_rol_pertenencia_rel_ocupacion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.persona_rol_pertenencia_rel_ocupacion (
    fk_persona_rol_pertenencia_id integer NOT NULL,
    fk_ocupacion_nombre character varying NOT NULL,
    insertdatetime timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone
);


ALTER TABLE public.persona_rol_pertenencia_rel_ocupacion OWNER TO postgres;

--
-- Name: persona_rol_pertenencia_rel_rol; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.persona_rol_pertenencia_rel_rol (
    fk_rol_nombre character varying NOT NULL,
    fk_persona_rol_pertenencia integer NOT NULL,
    insertdatetime timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone
);


ALTER TABLE public.persona_rol_pertenencia_rel_rol OWNER TO postgres;

--
-- Name: persona_rol_pertenencia_rel_tortura; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.persona_rol_pertenencia_rel_tortura (
    fk_persona_rol_pertenencia_id integer NOT NULL,
    fk_tortura_texto character varying(250) NOT NULL,
    insertdatetime timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone
);


ALTER TABLE public.persona_rol_pertenencia_rel_tortura OWNER TO postgres;

--
-- Name: pertenencia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pertenencia (
    id_pertenencia integer DEFAULT nextval('public.id_pertenencia'::regclass) NOT NULL,
    fecha_inicio date,
    fecha_fin date,
    precision_inicio character varying(5),
    precision_fin character varying(5),
    motivo character varying,
    orden integer,
    tipo_atr_doc character varying(500),
    fk_documento_id integer,
    fk_pertenencia_id integer,
    insertdatetime timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone
);


ALTER TABLE public.pertenencia OWNER TO postgres;

--
-- Name: pertenencia_rel_agrupacion_bienes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pertenencia_rel_agrupacion_bienes (
    fk_pertenencia_id integer NOT NULL,
    fk_agrupacion_bienes_id integer NOT NULL,
    insertdatetime timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone
);


ALTER TABLE public.pertenencia_rel_agrupacion_bienes OWNER TO postgres;

--
-- Name: pertenencia_rel_attr_especifico; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pertenencia_rel_attr_especifico (
    fk_pertenencia_id integer NOT NULL,
    fk_attr_especifico_id integer NOT NULL
);


ALTER TABLE public.pertenencia_rel_attr_especifico OWNER TO postgres;

--
-- Name: pertenencia_rel_lugar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pertenencia_rel_lugar (
    fk_pertenencia_id integer NOT NULL,
    tipo_lugar character varying,
    precision_pert_lugar character varying(250),
    fk_lugar_id integer NOT NULL,
    insertdatetime timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone
);


ALTER TABLE public.pertenencia_rel_lugar OWNER TO postgres;

--
-- Name: phosphates; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.phosphates (
    id_phosphates integer DEFAULT nextval('public.id_phosphates'::regclass) NOT NULL,
    phosphate_yield double precision,
    s18op double precision,
    s18op_1sd double precision,
    comments character varying,
    fk_analysis_id integer,
    interpretation character varying
);


ALTER TABLE public.phosphates OWNER TO postgres;

--
-- Name: point; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.point (
    geom_wgs84 public.geometry(Point,4326),
    id_point integer DEFAULT nextval('public.id_point'::regclass) NOT NULL,
    geom_nad27 public.geometry(Point,26718)
);


ALTER TABLE public.point OWNER TO postgres;

--
-- Name: polygon; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.polygon (
    geom_wgs84 public.geometry(Polygon,4326),
    id_polygon integer DEFAULT nextval('public.id_polygon'::regclass) NOT NULL,
    geom_nad27 public.geometry(Polygon,26718)
);


ALTER TABLE public.polygon OWNER TO postgres;

--
-- Name: proyecto; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.proyecto (
    nombre character varying NOT NULL,
    descripcion character varying(500)
);


ALTER TABLE public.proyecto OWNER TO postgres;

--
-- Name: proyecto_rel_documento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.proyecto_rel_documento (
    fk_proyecto_nombre character varying NOT NULL,
    fk_documento_id integer NOT NULL
);


ALTER TABLE public.proyecto_rel_documento OWNER TO postgres;

--
-- Name: radiocarbon_dating; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.radiocarbon_dating (
    id_radiocarbon_dating integer DEFAULT nextval('public.id_radiocarbon_dating'::regclass) NOT NULL,
    c_age_bp integer,
    years integer,
    s13 double precision,
    cn double precision,
    comments character varying,
    ad_bc_1s character varying(2),
    ad_bc_2s character varying(2),
    ad_bc_1s_end character varying(2),
    ad_bc_2s_end character varying(2),
    calibrated_date_1s_start integer,
    calibrated_date_1s_end integer,
    calibrated_date_2s_start integer,
    calibrated_date_2s_end integer,
    insertdatetime timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone
);


ALTER TABLE public.radiocarbon_dating OWNER TO postgres;

--
-- Name: referencia_bibliografica; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.referencia_bibliografica (
    id_referencia_bibliografica integer DEFAULT nextval('public.id_referencia_bibliografica'::regclass) NOT NULL,
    isbn character varying,
    doi character varying,
    autores character varying,
    fecha date,
    paginas character varying(150),
    titulo character varying,
    tipo character varying,
    nombre_tipo character varying,
    fk_url_id integer
);


ALTER TABLE public.referencia_bibliografica OWNER TO postgres;

--
-- Name: rel_iti_obj_trans; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rel_iti_obj_trans (
    id_rel_iti_obj_trans integer DEFAULT nextval('public.id_rel_iti_obj_trans'::regclass) NOT NULL,
    fk_paso_itinerario_id integer,
    fk_transporte_id integer,
    fk_agrupacion_bienes_id integer
);


ALTER TABLE public.rel_iti_obj_trans OWNER TO postgres;

--
-- Name: respuesta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.respuesta (
    fk_pertenencia_id integer NOT NULL,
    fk_persona_rol_pertenencia_id integer NOT NULL
);


ALTER TABLE public.respuesta OWNER TO postgres;

--
-- Name: resto; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.resto (
    variable character varying NOT NULL,
    nombre character varying,
    avatar character varying,
    traduccion character varying,
    insertdatetime timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone
);


ALTER TABLE public.resto OWNER TO postgres;

--
-- Name: resto_rel_categoria_resto_indice; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.resto_rel_categoria_resto_indice (
    fk_resto_variable character varying NOT NULL,
    fk_categoria_resto_indice_id integer NOT NULL
);


ALTER TABLE public.resto_rel_categoria_resto_indice OWNER TO postgres;

--
-- Name: rol; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rol (
    nombre character varying NOT NULL,
    descripcion character varying(500)
);


ALTER TABLE public.rol OWNER TO postgres;

--
-- Name: sample; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sample (
    id_muestra integer DEFAULT nextval('public.id_muestra'::regclass) NOT NULL,
    date date,
    ma_number integer,
    recorder character varying(150),
    overall_preservation character varying(250),
    sediment_particles character varying(500),
    microcracks character varying(500),
    consistency character varying(500),
    color character varying(500),
    comments character varying,
    name character varying(100),
    crown_height double precision,
    tooth_abrasion character varying(250),
    surface character varying(500),
    state character varying,
    fk_individuo_resto_id integer,
    collector character varying(250),
    geo_properties character varying,
    ratio double precision,
    successful character varying(100),
    unipv_number character varying,
    concentration double precision,
    extraction_method character varying,
    powder_weigth integer,
    insertdatetime timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone,
    type text DEFAULT 'isotopy'::text,
    volume double precision,
    residual_volume double precision,
    extraction_place character varying(500),
    storage_loc character varying(500),
    people_cont character varying(500),
    library_ava double precision,
    confidencial boolean DEFAULT false
);


ALTER TABLE public.sample OWNER TO postgres;

--
-- Name: sample_rel_material_sample; Type: TABLE; Schema: public; Owner: geographica
--

CREATE TABLE public.sample_rel_material_sample (
    fk_sample_id integer NOT NULL,
    fk_material_sample_material character varying NOT NULL
);


ALTER TABLE public.sample_rel_material_sample OWNER TO geographica;

--
-- Name: seccion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.seccion (
    nombre character varying NOT NULL,
    descripcion character varying(1000),
    fk_coleccion character varying(300) NOT NULL,
    id_seccion integer DEFAULT nextval('public.id_seccion'::regclass) NOT NULL
);


ALTER TABLE public.seccion OWNER TO postgres;

--
-- Name: sr; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sr (
    id_sr integer DEFAULT nextval('public.id_sr'::regclass) NOT NULL,
    sr_concentration double precision,
    d87sr_86sr double precision,
    d87sr_86sr_2sd double precision,
    comments character varying,
    fk_analysis_id integer NOT NULL,
    interpretation character varying
);


ALTER TABLE public.sr OWNER TO postgres;

--
-- Name: tipo_lugar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tipo_lugar (
    nombre character varying NOT NULL,
    fk_tipo_lugar character varying
);


ALTER TABLE public.tipo_lugar OWNER TO postgres;

--
-- Name: tipo_lugar_rel_lugar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tipo_lugar_rel_lugar (
    fk_tipo_lugar_nombre character varying NOT NULL,
    fk_lugar_id integer NOT NULL
);


ALTER TABLE public.tipo_lugar_rel_lugar OWNER TO postgres;

--
-- Name: tipo_transporte; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tipo_transporte (
    nombre_tipo character varying(1500) NOT NULL,
    descripcion character varying(2500)
);


ALTER TABLE public.tipo_transporte OWNER TO postgres;

--
-- Name: tortura; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tortura (
    texto character varying(250) NOT NULL
);


ALTER TABLE public.tortura OWNER TO postgres;

--
-- Name: transporte; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transporte (
    id_transporte integer DEFAULT nextval('public.id_transporte'::regclass) NOT NULL,
    tipo character varying(500),
    nombre character varying,
    tonelaje character varying(250),
    bandera character varying(500),
    observaciones character varying(1000),
    fk_transporte_id integer,
    fk_tipo_transporte character varying
);


ALTER TABLE public.transporte OWNER TO postgres;

--
-- Name: transporte_rel_objeto; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transporte_rel_objeto (
    fk_transporte_id integer NOT NULL,
    fk_objeto_id integer NOT NULL
);


ALTER TABLE public.transporte_rel_objeto OWNER TO postgres;

--
-- Name: unidad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.unidad (
    nombre character varying NOT NULL,
    tipo character varying(500),
    insertdatetime timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone
);


ALTER TABLE public.unidad OWNER TO postgres;

--
-- Name: url; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.url (
    id_url integer DEFAULT nextval('public.id_url'::regclass) NOT NULL,
    url character varying,
    tipo character varying(250),
    descripcion character varying,
    motivo_conf character varying(250)
);


ALTER TABLE public.url OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username text NOT NULL,
    password text NOT NULL,
    access_history boolean DEFAULT false NOT NULL,
    access_archeology boolean DEFAULT false NOT NULL,
    access_isotopes boolean DEFAULT false NOT NULL,
    access_dna boolean DEFAULT false NOT NULL,
    access_maps boolean
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: usuario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuario (
    id_usuario integer DEFAULT nextval('public.id_usuario'::regclass) NOT NULL,
    nombre character varying NOT NULL,
    apellidos character varying(250),
    institucion character varying(500),
    departamento character varying(250),
    posicion character varying(250),
    estado character varying(250),
    pass character varying,
    avatar character varying,
    email character varying(500),
    email_adicional character varying(500),
    biografia character varying,
    telefono integer,
    skype character varying(250),
    dni character varying(30),
    fk_perfil_usuario integer
);


ALTER TABLE public.usuario OWNER TO postgres;

--
-- Name: wholegenome; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.wholegenome (
    id_wholegenome integer DEFAULT nextval('public.id_wholegenome'::regclass) NOT NULL,
    fk_sample_id integer,
    ancest_origin character varying(150),
    fastq_file character varying,
    seq_strategy character varying(500),
    raw_reads integer,
    mapped_reads integer,
    whole_coverage double precision,
    mean_read_depth double precision,
    average_length double precision,
    comments character varying,
    interpretation character varying,
    successful character varying,
    bam_file character varying,
    overall_snps integer,
    closes_pop character varying(150),
    libraries_seq integer,
    insertdatetime timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone,
    overall_error double precision,
    contamination double precision,
    ctot_rate double precision,
    gtoa_rate double precision,
    reference_genome character varying(200),
    duplicate double precision,
    molecular_sex character varying,
    gc_content double precision,
    updated_on date
);


ALTER TABLE public.wholegenome OWNER TO postgres;

--
-- Name: ychromosome; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ychromosome (
    id_ychromosome integer DEFAULT nextval('public.id_ychromosome'::regclass) NOT NULL,
    fk_sample_id integer,
    haplogroup character varying(150),
    superhaplo character varying(50),
    haplo_ancest_origin character varying(150),
    possible_pat_relat character varying(1000),
    seq_strategy character varying(500),
    libraries_seq integer,
    raw_reads integer,
    mapped_reads integer,
    whole_coverage double precision,
    mean_read_depth double precision,
    average_length double precision,
    comments character varying,
    interpretation character varying,
    successful character varying,
    snps_hit integer,
    snps character varying,
    class_method character varying(150),
    bam_file character varying,
    insertdatetime timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone,
    vcf_file character varying,
    updated_on date
);


ALTER TABLE public.ychromosome OWNER TO postgres;

--
-- Name: tabla_prueba id; Type: DEFAULT; Schema: pruebas; Owner: geographica
--

ALTER TABLE ONLY pruebas.tabla_prueba ALTER COLUMN id SET DEFAULT nextval('pruebas.tabla_prueba_id_seq'::regclass);


--
-- Name: django_migrations id; Type: DEFAULT; Schema: public; Owner: geographica
--

ALTER TABLE ONLY public.django_migrations ALTER COLUMN id SET DEFAULT nextval('public.django_migrations_id_seq'::regclass);


--
-- Name: maps id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maps ALTER COLUMN id SET DEFAULT nextval('public.maps_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: tabla_prueba prueba_primary; Type: CONSTRAINT; Schema: pruebas; Owner: geographica
--

ALTER TABLE ONLY pruebas.tabla_prueba
    ADD CONSTRAINT prueba_primary PRIMARY KEY (id);


--
-- Name: dna_extraction adn_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dna_extraction
    ADD CONSTRAINT adn_pkey PRIMARY KEY (id_dna_extraction);


--
-- Name: agrupacion_bienes agrupacion_bienes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agrupacion_bienes
    ADD CONSTRAINT agrupacion_bienes_pkey PRIMARY KEY (id_agrupacion_bienes);


--
-- Name: agrupacion_bienes_rel_unidad agrupacion_bienes_rel_unidad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agrupacion_bienes_rel_unidad
    ADD CONSTRAINT agrupacion_bienes_rel_unidad_pkey PRIMARY KEY (fk_agrupacion_bienes_id, fk_unidad_nombre);


--
-- Name: paleobotany almidon_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paleobotany
    ADD CONSTRAINT almidon_pkey PRIMARY KEY (id_almidon);


--
-- Name: anomalia anomalia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.anomalia
    ADD CONSTRAINT anomalia_pkey PRIMARY KEY (id_anomalia);


--
-- Name: anomalia_rel_individuo_resto anomalia_rel_individuo_resto_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.anomalia_rel_individuo_resto
    ADD CONSTRAINT anomalia_rel_individuo_resto_pkey PRIMARY KEY (fk_anomalia_id, fk_individuo_resto_id);


--
-- Name: atributo_documento atributo_documento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.atributo_documento
    ADD CONSTRAINT atributo_documento_pkey PRIMARY KEY (id_atributo_documento);


--
-- Name: attr_especifico attr_especifico_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attr_especifico
    ADD CONSTRAINT attr_especifico_pkey PRIMARY KEY (id_attr_especifico);


--
-- Name: bioapatite bioapatite_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bioapatite
    ADD CONSTRAINT bioapatite_pkey PRIMARY KEY (id_bioapatite);


--
-- Name: carbonate carbonate_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.carbonate
    ADD CONSTRAINT carbonate_pkey PRIMARY KEY (id_carbonate);


--
-- Name: cargo cargo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cargo
    ADD CONSTRAINT cargo_pkey PRIMARY KEY (nombre);


--
-- Name: categoria_resto_indice categoria_resto_indice_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria_resto_indice
    ADD CONSTRAINT categoria_resto_indice_pkey PRIMARY KEY (id_categoria_resto_indice);


--
-- Name: categoria_resto categoria_resto_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria_resto
    ADD CONSTRAINT categoria_resto_pkey PRIMARY KEY (nombre);


--
-- Name: categoria_resto_rel_anomalia categoria_resto_rel_anomalia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria_resto_rel_anomalia
    ADD CONSTRAINT categoria_resto_rel_anomalia_pkey PRIMARY KEY (fk_categoria_resto, fk_anomalia_id);


--
-- Name: coleccion coleccion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.coleccion
    ADD CONSTRAINT coleccion_pkey PRIMARY KEY (nombre);


--
-- Name: collagen collagen_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collagen
    ADD CONSTRAINT collagen_pkey PRIMARY KEY (id_collagen);


--
-- Name: django_migrations django_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: geographica
--

ALTER TABLE ONLY public.django_migrations
    ADD CONSTRAINT django_migrations_pkey PRIMARY KEY (id);


--
-- Name: documento documento_id_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documento
    ADD CONSTRAINT documento_id_pkey PRIMARY KEY (id_documento);


--
-- Name: documento_rel_documento documento_rel_documento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documento_rel_documento
    ADD CONSTRAINT documento_rel_documento_pkey PRIMARY KEY (fk_documento2, fk_documento1);


--
-- Name: documento_rel_referencia_bibliografica documento_rel_referencia_bibliografica_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documento_rel_referencia_bibliografica
    ADD CONSTRAINT documento_rel_referencia_bibliografica_pkey PRIMARY KEY (fk_documento_id, fk_referencia_bibliografica_id);


--
-- Name: documento_rel_unidad documento_rel_unidad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documento_rel_unidad
    ADD CONSTRAINT documento_rel_unidad_pkey PRIMARY KEY (fk_documento_id, fk_unidad_nombre);


--
-- Name: documento_rel_url documento_rel_url_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documento_rel_url
    ADD CONSTRAINT documento_rel_url_pkey PRIMARY KEY (fk_documento_id, fk_url_id);


--
-- Name: entierro entierro_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entierro
    ADD CONSTRAINT entierro_pkey PRIMARY KEY (id_entierro);


--
-- Name: entierro_rel_url entierro_rel_url_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entierro_rel_url
    ADD CONSTRAINT entierro_rel_url_pkey PRIMARY KEY (fk_entierro_id, fk_url_id);


--
-- Name: espacio_entierro espacio_entierro_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.espacio_entierro
    ADD CONSTRAINT espacio_entierro_pkey PRIMARY KEY (nombre);


--
-- Name: especie especie_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.especie
    ADD CONSTRAINT especie_pkey PRIMARY KEY (nombre);


--
-- Name: estado estado_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estado
    ADD CONSTRAINT estado_pkey PRIMARY KEY (tipo_cons_represen, elemento);


--
-- Name: estado_rel_individuo_arqueologico estado_rel_individuo_arqueologico_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estado_rel_individuo_arqueologico
    ADD CONSTRAINT estado_rel_individuo_arqueologico_pkey PRIMARY KEY (fk_estado_tipo_cons_repre, fk_estado_elemento, fk_individuo_arqueologico_id);


--
-- Name: individuo_arqueologico individuo_arqueologico_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individuo_arqueologico
    ADD CONSTRAINT individuo_arqueologico_pkey PRIMARY KEY (id_individuo_arqueologico);


--
-- Name: individuo_arqueologico_rel_url individuo_arqueologico_rel_url_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individuo_arqueologico_rel_url
    ADD CONSTRAINT individuo_arqueologico_rel_url_pkey PRIMARY KEY (fk_individuo_arqueologico_id, fk_url_id);


--
-- Name: individuo_resto individuo_resto_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individuo_resto
    ADD CONSTRAINT individuo_resto_pkey PRIMARY KEY (id_individuo_resto);


--
-- Name: institucion institucion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.institucion
    ADD CONSTRAINT institucion_pkey PRIMARY KEY (nombre);


--
-- Name: keyword keyword_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.keyword
    ADD CONSTRAINT keyword_pkey PRIMARY KEY (palabra);


--
-- Name: keyword_rel_documento keyword_rel_documento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.keyword_rel_documento
    ADD CONSTRAINT keyword_rel_documento_pkey PRIMARY KEY (fk_keyword_palabra, fk_documento_id);


--
-- Name: line like_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.line
    ADD CONSTRAINT like_pkey PRIMARY KEY (id_line);


--
-- Name: linea linea_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.linea
    ADD CONSTRAINT linea_pkey PRIMARY KEY (id_linea);


--
-- Name: linea_rel_lugar linea_rel_lugar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.linea_rel_lugar
    ADD CONSTRAINT linea_rel_lugar_pkey PRIMARY KEY (fk_linea_id, fk_lugar_id);


--
-- Name: linea_rel_unidad linea_rel_unidad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.linea_rel_unidad
    ADD CONSTRAINT linea_rel_unidad_pkey PRIMARY KEY (fk_linea_id, fk_unidad_nombre, es_impuesto);


--
-- Name: log_acceso log_acceso_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log_acceso
    ADD CONSTRAINT log_acceso_pkey PRIMARY KEY (id_log_acceso);


--
-- Name: lote lote_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lote
    ADD CONSTRAINT lote_pkey PRIMARY KEY (id_lote);


--
-- Name: lugar lugar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lugar
    ADD CONSTRAINT lugar_pkey PRIMARY KEY (id_lugar);


--
-- Name: material material_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.material
    ADD CONSTRAINT material_pkey PRIMARY KEY (id_material);


--
-- Name: metodo_pago metodo_pago_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.metodo_pago
    ADD CONSTRAINT metodo_pago_pkey PRIMARY KEY (id_metodo_pago);


--
-- Name: miembro miembro_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.miembro
    ADD CONSTRAINT miembro_pkey PRIMARY KEY (texto);


--
-- Name: mtdna mtdna_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mtdna
    ADD CONSTRAINT mtdna_pkey PRIMARY KEY (id_mtdna);


--
-- Name: sample muestra_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sample
    ADD CONSTRAINT muestra_pkey PRIMARY KEY (id_muestra);


--
-- Name: muestra_rel_url muestra_rel_url_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.muestra_rel_url
    ADD CONSTRAINT muestra_rel_url_pkey PRIMARY KEY (fk_muestra_id, fk_url_id);


--
-- Name: navegacion navegacion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.navegacion
    ADD CONSTRAINT navegacion_pkey PRIMARY KEY (id_navegacion);


--
-- Name: navegacion_rel_agrupacion_bienes navegacion_rel_agrupacion_bienes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.navegacion_rel_agrupacion_bienes
    ADD CONSTRAINT navegacion_rel_agrupacion_bienes_pkey PRIMARY KEY (fk_navegacion_id, fk_agrupacion_bienes_id);


--
-- Name: navegacion_rel_persona_rol_pertenencia navegacion_rel_persona_rol_pertenencia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.navegacion_rel_persona_rol_pertenencia
    ADD CONSTRAINT navegacion_rel_persona_rol_pertenencia_pkey PRIMARY KEY (fk_persona_rol_pertenencia_id, fk_navegacion_id);


--
-- Name: navegacion_rel_transporte navegacion_rel_transporte_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.navegacion_rel_transporte
    ADD CONSTRAINT navegacion_rel_transporte_pkey PRIMARY KEY (fk_navegacion_id, fk_transporte_id);


--
-- Name: objeto nombre_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.objeto
    ADD CONSTRAINT nombre_unique UNIQUE (nombre);


--
-- Name: objeto objeto_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.objeto
    ADD CONSTRAINT objeto_pkey PRIMARY KEY (id_objeto);


--
-- Name: observacion observacion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.observacion
    ADD CONSTRAINT observacion_pkey PRIMARY KEY (id_observacion);


--
-- Name: ocupacion ocupacion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ocupacion
    ADD CONSTRAINT ocupacion_pkey PRIMARY KEY (nombre);


--
-- Name: or_per_lug or_per_lug_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.or_per_lug
    ADD CONSTRAINT or_per_lug_pkey PRIMARY KEY (id_or_per_lug);


--
-- Name: origen_persona origen_persona_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.origen_persona
    ADD CONSTRAINT origen_persona_pkey PRIMARY KEY (id_origen_persona);


--
-- Name: paso_itinerario paso_itinerario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paso_itinerario
    ADD CONSTRAINT paso_itinerario_pkey PRIMARY KEY (id_paso_itinerario);


--
-- Name: pena pena_id_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pena
    ADD CONSTRAINT pena_id_pkey PRIMARY KEY (id_pena);


--
-- Name: pena_rel_miembro pena_rel_miembro_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pena_rel_miembro
    ADD CONSTRAINT pena_rel_miembro_pkey PRIMARY KEY (fk_pena_id, fk_miembro_texto);


--
-- Name: pena_rel_unidad pena_rel_unidad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pena_rel_unidad
    ADD CONSTRAINT pena_rel_unidad_pkey PRIMARY KEY (fk_pena_id, fk_unidad_nombre);


--
-- Name: perfil_usuario perfil_usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.perfil_usuario
    ADD CONSTRAINT perfil_usuario_pkey PRIMARY KEY (id_perfil_usuario);


--
-- Name: perfil_usuario_rel_permisos_api perfil_usuario_rel_permisos_api_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.perfil_usuario_rel_permisos_api
    ADD CONSTRAINT perfil_usuario_rel_permisos_api_pkey PRIMARY KEY (fk_perfil_usuario, fk_permisos_api);


--
-- Name: permiso_navegacion permiso_navegacion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permiso_navegacion
    ADD CONSTRAINT permiso_navegacion_pkey PRIMARY KEY (id_permiso_navegacion);


--
-- Name: permisos_api permisos_api_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permisos_api
    ADD CONSTRAINT permisos_api_pkey PRIMARY KEY (id_permisos_api);


--
-- Name: persona_historica persona_historica_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persona_historica
    ADD CONSTRAINT persona_historica_pkey PRIMARY KEY (id_persona_historica);


--
-- Name: persona_rol_pertenencia persona_rol_pertenencia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persona_rol_pertenencia
    ADD CONSTRAINT persona_rol_pertenencia_pkey PRIMARY KEY (id_persona_rol_pertenencia);


--
-- Name: persona_rol_pertenencia_rel_cargo persona_rol_pertenencia_rel_cargo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persona_rol_pertenencia_rel_cargo
    ADD CONSTRAINT persona_rol_pertenencia_rel_cargo_pkey PRIMARY KEY (fk_cargo_nombre, fk_persona_rol_pertenencia_id);


--
-- Name: persona_rol_pertenencia_rel_institucion persona_rol_pertenencia_rel_institucion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persona_rol_pertenencia_rel_institucion
    ADD CONSTRAINT persona_rol_pertenencia_rel_institucion_pkey PRIMARY KEY (fk_persona_rol_pertenencia_id, fk_institucion_nombre);


--
-- Name: persona_rol_pertenencia_rel_linea persona_rol_pertenencia_rel_linea_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persona_rol_pertenencia_rel_linea
    ADD CONSTRAINT persona_rol_pertenencia_rel_linea_pkey PRIMARY KEY (fk_persona_rol_pertenencia_id, fk_linea);


--
-- Name: persona_rol_pertenencia_rel_lugar persona_rol_pertenencia_rel_lugar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persona_rol_pertenencia_rel_lugar
    ADD CONSTRAINT persona_rol_pertenencia_rel_lugar_pkey PRIMARY KEY (fk_persona_rol_pertenencia_id, fk_lugar_id);


--
-- Name: persona_rol_pertenencia_rel_ocupacion persona_rol_pertenencia_rel_ocupacion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persona_rol_pertenencia_rel_ocupacion
    ADD CONSTRAINT persona_rol_pertenencia_rel_ocupacion_pkey PRIMARY KEY (fk_persona_rol_pertenencia_id, fk_ocupacion_nombre);


--
-- Name: persona_rol_pertenencia_rel_rol persona_rol_pertenencia_rel_rol_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persona_rol_pertenencia_rel_rol
    ADD CONSTRAINT persona_rol_pertenencia_rel_rol_pkey PRIMARY KEY (fk_rol_nombre, fk_persona_rol_pertenencia);


--
-- Name: persona_rol_pertenencia_rel_tortura persona_rol_pertenencia_rel_tortura_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persona_rol_pertenencia_rel_tortura
    ADD CONSTRAINT persona_rol_pertenencia_rel_tortura_pkey PRIMARY KEY (fk_persona_rol_pertenencia_id, fk_tortura_texto);


--
-- Name: pertenencia pertenencia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pertenencia
    ADD CONSTRAINT pertenencia_pkey PRIMARY KEY (id_pertenencia);


--
-- Name: pertenencia_rel_agrupacion_bienes pertenencia_rel_agrupacion_bienes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pertenencia_rel_agrupacion_bienes
    ADD CONSTRAINT pertenencia_rel_agrupacion_bienes_pkey PRIMARY KEY (fk_pertenencia_id, fk_agrupacion_bienes_id);


--
-- Name: pertenencia_rel_attr_especifico pertenencia_rel_attr_especifico_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pertenencia_rel_attr_especifico
    ADD CONSTRAINT pertenencia_rel_attr_especifico_pkey PRIMARY KEY (fk_pertenencia_id, fk_attr_especifico_id);


--
-- Name: pertenencia_rel_lugar pertenencia_rel_lugar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pertenencia_rel_lugar
    ADD CONSTRAINT pertenencia_rel_lugar_pkey PRIMARY KEY (fk_pertenencia_id, fk_lugar_id);


--
-- Name: phosphates phosphates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.phosphates
    ADD CONSTRAINT phosphates_pkey PRIMARY KEY (id_phosphates);


--
-- Name: individuo_arqueologico_rel_linea pk_individuo_arqueologico_rel_linea; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individuo_arqueologico_rel_linea
    ADD CONSTRAINT pk_individuo_arqueologico_rel_linea PRIMARY KEY (fk_individuo_arqueologico, fk_linea);


--
-- Name: individuo_resto_rel_url pk_individuo_resto_rel_url; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individuo_resto_rel_url
    ADD CONSTRAINT pk_individuo_resto_rel_url PRIMARY KEY (fk_individuo_resto, fk_url);


--
-- Name: lote_edades pk_lote_edades; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lote_edades
    ADD CONSTRAINT pk_lote_edades PRIMARY KEY (id_edad_recodificada);


--
-- Name: lote_edades_rel_individuo_arqueologico pk_lote_edades_rel_individuo_arqueologico; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lote_edades_rel_individuo_arqueologico
    ADD CONSTRAINT pk_lote_edades_rel_individuo_arqueologico PRIMARY KEY (fk_lote_edades, fk_individuo_arqueologico);


--
-- Name: objeto_arqueologico pk_objeto_arqueologico; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.objeto_arqueologico
    ADD CONSTRAINT pk_objeto_arqueologico PRIMARY KEY (id_objeto);


--
-- Name: objeto_arqueologico_rel_linea pk_objeto_arqueologico_linea; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.objeto_arqueologico_rel_linea
    ADD CONSTRAINT pk_objeto_arqueologico_linea PRIMARY KEY (fk_objeto_arqueologico, fk_linea);


--
-- Name: material_sample pkey_material_sample; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.material_sample
    ADD CONSTRAINT pkey_material_sample PRIMARY KEY (material);


--
-- Name: sample_rel_material_sample pkey_sample_rel_material_sample; Type: CONSTRAINT; Schema: public; Owner: geographica
--

ALTER TABLE ONLY public.sample_rel_material_sample
    ADD CONSTRAINT pkey_sample_rel_material_sample PRIMARY KEY (fk_sample_id, fk_material_sample_material);


--
-- Name: point point_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.point
    ADD CONSTRAINT point_pkey PRIMARY KEY (id_point);


--
-- Name: polygon polygon_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.polygon
    ADD CONSTRAINT polygon_pkey PRIMARY KEY (id_polygon);


--
-- Name: proyecto proyecto_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proyecto
    ADD CONSTRAINT proyecto_pkey PRIMARY KEY (nombre);


--
-- Name: proyecto_rel_documento proyecto_rel_documento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proyecto_rel_documento
    ADD CONSTRAINT proyecto_rel_documento_pkey PRIMARY KEY (fk_proyecto_nombre, fk_documento_id);


--
-- Name: radiocarbon_dating radiocarbon_dating_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.radiocarbon_dating
    ADD CONSTRAINT radiocarbon_dating_pkey PRIMARY KEY (id_radiocarbon_dating);


--
-- Name: referencia_bibliografica referencia_bibliografica_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.referencia_bibliografica
    ADD CONSTRAINT referencia_bibliografica_pkey PRIMARY KEY (id_referencia_bibliografica);


--
-- Name: rel_iti_obj_trans rel_iti_obj_trans_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rel_iti_obj_trans
    ADD CONSTRAINT rel_iti_obj_trans_pkey PRIMARY KEY (id_rel_iti_obj_trans);


--
-- Name: respuesta respuesta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.respuesta
    ADD CONSTRAINT respuesta_pkey PRIMARY KEY (fk_pertenencia_id, fk_persona_rol_pertenencia_id);


--
-- Name: resto resto_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resto
    ADD CONSTRAINT resto_pkey PRIMARY KEY (variable);


--
-- Name: resto_rel_categoria_resto_indice resto_rel_categoria_resto_indice_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resto_rel_categoria_resto_indice
    ADD CONSTRAINT resto_rel_categoria_resto_indice_pkey PRIMARY KEY (fk_resto_variable, fk_categoria_resto_indice_id);


--
-- Name: rol rol_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rol
    ADD CONSTRAINT rol_pkey PRIMARY KEY (nombre);


--
-- Name: analysis sample_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.analysis
    ADD CONSTRAINT sample_pkey PRIMARY KEY (id_analisis);


--
-- Name: seccion seccion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seccion
    ADD CONSTRAINT seccion_pkey PRIMARY KEY (id_seccion);


--
-- Name: ychromosome sexchromosome_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ychromosome
    ADD CONSTRAINT sexchromosome_pkey PRIMARY KEY (id_ychromosome);


--
-- Name: sr sr_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sr
    ADD CONSTRAINT sr_pkey PRIMARY KEY (id_sr);


--
-- Name: tipo_lugar tipo_lugar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipo_lugar
    ADD CONSTRAINT tipo_lugar_pkey PRIMARY KEY (nombre);


--
-- Name: tipo_lugar_rel_lugar tipo_lugar_rel_lugar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipo_lugar_rel_lugar
    ADD CONSTRAINT tipo_lugar_rel_lugar_pkey PRIMARY KEY (fk_tipo_lugar_nombre, fk_lugar_id);


--
-- Name: tipo_transporte tipo_transporte_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipo_transporte
    ADD CONSTRAINT tipo_transporte_pkey PRIMARY KEY (nombre_tipo);


--
-- Name: tortura tortura_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tortura
    ADD CONSTRAINT tortura_pkey PRIMARY KEY (texto);


--
-- Name: transporte transporte_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transporte
    ADD CONSTRAINT transporte_pkey PRIMARY KEY (id_transporte);


--
-- Name: transporte_rel_objeto transporte_rel_objeto_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transporte_rel_objeto
    ADD CONSTRAINT transporte_rel_objeto_pkey PRIMARY KEY (fk_transporte_id, fk_objeto_id);


--
-- Name: unidad unidad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unidad
    ADD CONSTRAINT unidad_pkey PRIMARY KEY (nombre);


--
-- Name: url url_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.url
    ADD CONSTRAINT url_pkey PRIMARY KEY (id_url);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id_usuario);


--
-- Name: wholegenome wholegnome_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wholegenome
    ADD CONSTRAINT wholegnome_pkey PRIMARY KEY (id_wholegenome);


--
-- Name: documento set_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.documento FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_timestamp();


--
-- Name: pertenencia set_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.pertenencia FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_timestamp();


--
-- Name: lugar set_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.lugar FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_timestamp();


--
-- Name: linea set_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.linea FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_timestamp();


--
-- Name: agrupacion_bienes set_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.agrupacion_bienes FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_timestamp();


--
-- Name: entierro set_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.entierro FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_timestamp();


--
-- Name: individuo_arqueologico set_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.individuo_arqueologico FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_timestamp();


--
-- Name: sample set_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.sample FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_timestamp();


--
-- Name: radiocarbon_dating set_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.radiocarbon_dating FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_timestamp();


--
-- Name: collagen set_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.collagen FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_timestamp();


--
-- Name: bioapatite set_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.bioapatite FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_timestamp();


--
-- Name: mtdna set_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.mtdna FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_timestamp();


--
-- Name: ychromosome set_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.ychromosome FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_timestamp();


--
-- Name: wholegenome set_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.wholegenome FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_timestamp();


--
-- Name: persona_rol_pertenencia set_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.persona_rol_pertenencia FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_timestamp();


--
-- Name: persona_rol_pertenencia_rel_cargo set_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.persona_rol_pertenencia_rel_cargo FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_timestamp();


--
-- Name: persona_rol_pertenencia_rel_institucion set_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.persona_rol_pertenencia_rel_institucion FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_timestamp();


--
-- Name: persona_rol_pertenencia_rel_linea set_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.persona_rol_pertenencia_rel_linea FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_timestamp();


--
-- Name: persona_rol_pertenencia_rel_lugar set_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.persona_rol_pertenencia_rel_lugar FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_timestamp();


--
-- Name: persona_rol_pertenencia_rel_ocupacion set_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.persona_rol_pertenencia_rel_ocupacion FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_timestamp();


--
-- Name: persona_rol_pertenencia_rel_rol set_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.persona_rol_pertenencia_rel_rol FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_timestamp();


--
-- Name: persona_rol_pertenencia_rel_tortura set_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.persona_rol_pertenencia_rel_tortura FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_timestamp();


--
-- Name: pertenencia_rel_agrupacion_bienes set_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.pertenencia_rel_agrupacion_bienes FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_timestamp();


--
-- Name: pertenencia_rel_lugar set_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.pertenencia_rel_lugar FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_timestamp();


--
-- Name: agrupacion_bienes_rel_unidad set_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.agrupacion_bienes_rel_unidad FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_timestamp();


--
-- Name: anomalia_rel_individuo_resto set_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.anomalia_rel_individuo_resto FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_timestamp();


--
-- Name: documento_rel_url set_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.documento_rel_url FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_timestamp();


--
-- Name: individuo_arqueologico_rel_linea set_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.individuo_arqueologico_rel_linea FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_timestamp();


--
-- Name: individuo_resto set_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.individuo_resto FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_timestamp();


--
-- Name: objeto_arqueologico set_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.objeto_arqueologico FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_timestamp();


--
-- Name: persona_historica set_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.persona_historica FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_timestamp();


--
-- Name: resto set_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.resto FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_timestamp();


--
-- Name: unidad set_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.unidad FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_timestamp();


--
-- Name: pertenencia_rel_agrupacion_bienes fk_agrupacion_bienes; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pertenencia_rel_agrupacion_bienes
    ADD CONSTRAINT fk_agrupacion_bienes FOREIGN KEY (fk_agrupacion_bienes_id) REFERENCES public.agrupacion_bienes(id_agrupacion_bienes) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: rel_iti_obj_trans fk_agrupacion_bienes; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rel_iti_obj_trans
    ADD CONSTRAINT fk_agrupacion_bienes FOREIGN KEY (fk_agrupacion_bienes_id) REFERENCES public.agrupacion_bienes(id_agrupacion_bienes) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: navegacion_rel_agrupacion_bienes fk_agrupacion_bienes; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.navegacion_rel_agrupacion_bienes
    ADD CONSTRAINT fk_agrupacion_bienes FOREIGN KEY (fk_agrupacion_bienes_id) REFERENCES public.agrupacion_bienes(id_agrupacion_bienes) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: agrupacion_bienes_rel_unidad fk_agrupacion_bienes; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agrupacion_bienes_rel_unidad
    ADD CONSTRAINT fk_agrupacion_bienes FOREIGN KEY (fk_agrupacion_bienes_id) REFERENCES public.agrupacion_bienes(id_agrupacion_bienes) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: linea fk_agrupacion_bienes; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.linea
    ADD CONSTRAINT fk_agrupacion_bienes FOREIGN KEY (fk_agrupacion_bienes_id) REFERENCES public.agrupacion_bienes(id_agrupacion_bienes) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: paleobotany fk_almidon; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paleobotany
    ADD CONSTRAINT fk_almidon FOREIGN KEY (fk_almidon_id) REFERENCES public.paleobotany(id_almidon) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: carbonate fk_analysis_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.carbonate
    ADD CONSTRAINT fk_analysis_id FOREIGN KEY (fk_analysis_id) REFERENCES public.analysis(id_analisis) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: phosphates fk_analysis_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.phosphates
    ADD CONSTRAINT fk_analysis_id FOREIGN KEY (fk_analysis_id) REFERENCES public.analysis(id_analisis) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sr fk_analysis_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sr
    ADD CONSTRAINT fk_analysis_id FOREIGN KEY (fk_analysis_id) REFERENCES public.analysis(id_analisis) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: dna_extraction fk_analysis_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dna_extraction
    ADD CONSTRAINT fk_analysis_id FOREIGN KEY (fk_analysis_id) REFERENCES public.analysis(id_analisis) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: categoria_resto_rel_anomalia fk_anomalia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria_resto_rel_anomalia
    ADD CONSTRAINT fk_anomalia FOREIGN KEY (fk_anomalia_id) REFERENCES public.anomalia(id_anomalia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: anomalia_rel_individuo_resto fk_anomalia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.anomalia_rel_individuo_resto
    ADD CONSTRAINT fk_anomalia FOREIGN KEY (fk_anomalia_id) REFERENCES public.anomalia(id_anomalia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: anomalia fk_anomalia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.anomalia
    ADD CONSTRAINT fk_anomalia FOREIGN KEY (fk_anomalia_id) REFERENCES public.anomalia(id_anomalia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pertenencia_rel_attr_especifico fk_attr_especifico; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pertenencia_rel_attr_especifico
    ADD CONSTRAINT fk_attr_especifico FOREIGN KEY (fk_attr_especifico_id) REFERENCES public.attr_especifico(id_attr_especifico) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: persona_rol_pertenencia_rel_cargo fk_cargo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persona_rol_pertenencia_rel_cargo
    ADD CONSTRAINT fk_cargo FOREIGN KEY (fk_cargo_nombre) REFERENCES public.cargo(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: categoria_resto_indice fk_categoria_resto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria_resto_indice
    ADD CONSTRAINT fk_categoria_resto FOREIGN KEY (fk_categoria_resto_nombre) REFERENCES public.categoria_resto(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: categoria_resto_rel_anomalia fk_categoria_resto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria_resto_rel_anomalia
    ADD CONSTRAINT fk_categoria_resto FOREIGN KEY (fk_categoria_resto) REFERENCES public.categoria_resto(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: categoria_resto_indice fk_categoria_resto_indice; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria_resto_indice
    ADD CONSTRAINT fk_categoria_resto_indice FOREIGN KEY (fk_categoria_resto_indice_id) REFERENCES public.categoria_resto_indice(id_categoria_resto_indice) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: resto_rel_categoria_resto_indice fk_categoria_resto_indice; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resto_rel_categoria_resto_indice
    ADD CONSTRAINT fk_categoria_resto_indice FOREIGN KEY (fk_categoria_resto_indice_id) REFERENCES public.categoria_resto_indice(id_categoria_resto_indice) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: seccion fk_coleccion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seccion
    ADD CONSTRAINT fk_coleccion FOREIGN KEY (fk_coleccion) REFERENCES public.coleccion(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: keyword_rel_documento fk_documento; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.keyword_rel_documento
    ADD CONSTRAINT fk_documento FOREIGN KEY (fk_documento_id) REFERENCES public.documento(id_documento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: atributo_documento fk_documento; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.atributo_documento
    ADD CONSTRAINT fk_documento FOREIGN KEY (fk_documento_id) REFERENCES public.documento(id_documento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: observacion fk_documento; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.observacion
    ADD CONSTRAINT fk_documento FOREIGN KEY (fk_documento) REFERENCES public.documento(id_documento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pertenencia fk_documento; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pertenencia
    ADD CONSTRAINT fk_documento FOREIGN KEY (fk_documento_id) REFERENCES public.documento(id_documento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: proyecto_rel_documento fk_documento; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proyecto_rel_documento
    ADD CONSTRAINT fk_documento FOREIGN KEY (fk_documento_id) REFERENCES public.documento(id_documento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: navegacion fk_documento; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.navegacion
    ADD CONSTRAINT fk_documento FOREIGN KEY (fk_documento_id) REFERENCES public.documento(id_documento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: documento_rel_unidad fk_documento; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documento_rel_unidad
    ADD CONSTRAINT fk_documento FOREIGN KEY (fk_documento_id) REFERENCES public.documento(id_documento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: documento_rel_url fk_documento; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documento_rel_url
    ADD CONSTRAINT fk_documento FOREIGN KEY (fk_documento_id) REFERENCES public.documento(id_documento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: documento_rel_referencia_bibliografica fk_documento; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documento_rel_referencia_bibliografica
    ADD CONSTRAINT fk_documento FOREIGN KEY (fk_documento_id) REFERENCES public.documento(id_documento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: documento_rel_documento fk_documento1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documento_rel_documento
    ADD CONSTRAINT fk_documento1 FOREIGN KEY (fk_documento1) REFERENCES public.documento(id_documento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: documento_rel_documento fk_documento2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documento_rel_documento
    ADD CONSTRAINT fk_documento2 FOREIGN KEY (fk_documento2) REFERENCES public.documento(id_documento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: entierro_rel_url fk_entierro; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entierro_rel_url
    ADD CONSTRAINT fk_entierro FOREIGN KEY (fk_entierro_id) REFERENCES public.entierro(id_entierro) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: linea fk_entierro; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.linea
    ADD CONSTRAINT fk_entierro FOREIGN KEY (fk_entierro_id) REFERENCES public.entierro(id_entierro) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: individuo_arqueologico fk_entierro; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individuo_arqueologico
    ADD CONSTRAINT fk_entierro FOREIGN KEY (fk_entierro) REFERENCES public.entierro(id_entierro) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: entierro fk_espacio_entierro; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entierro
    ADD CONSTRAINT fk_espacio_entierro FOREIGN KEY (fk_espacio_nombre) REFERENCES public.espacio_entierro(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: espacio_entierro fk_espacio_entierro_nombre; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.espacio_entierro
    ADD CONSTRAINT fk_espacio_entierro_nombre FOREIGN KEY (fk_espacio_entierro) REFERENCES public.espacio_entierro(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: individuo_resto fk_especie; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individuo_resto
    ADD CONSTRAINT fk_especie FOREIGN KEY (fk_especie_nombre) REFERENCES public.especie(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: estado_rel_individuo_arqueologico fk_estado; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estado_rel_individuo_arqueologico
    ADD CONSTRAINT fk_estado FOREIGN KEY (fk_estado_tipo_cons_repre, fk_estado_elemento) REFERENCES public.estado(tipo_cons_represen, elemento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: persona_historica fk_individuo_arqueologico; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persona_historica
    ADD CONSTRAINT fk_individuo_arqueologico FOREIGN KEY (fk_individuo_arqueologico_id) REFERENCES public.individuo_arqueologico(id_individuo_arqueologico) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: estado_rel_individuo_arqueologico fk_individuo_arqueologico; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estado_rel_individuo_arqueologico
    ADD CONSTRAINT fk_individuo_arqueologico FOREIGN KEY (fk_individuo_arqueologico_id) REFERENCES public.individuo_arqueologico(id_individuo_arqueologico) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: individuo_resto fk_individuo_arqueologico; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individuo_resto
    ADD CONSTRAINT fk_individuo_arqueologico FOREIGN KEY (fk_individuo_arqueologico_id) REFERENCES public.individuo_arqueologico(id_individuo_arqueologico) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: individuo_arqueologico_rel_url fk_individuo_arqueologico; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individuo_arqueologico_rel_url
    ADD CONSTRAINT fk_individuo_arqueologico FOREIGN KEY (fk_individuo_arqueologico_id) REFERENCES public.individuo_arqueologico(id_individuo_arqueologico) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: linea fk_individuo_arqueologico; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.linea
    ADD CONSTRAINT fk_individuo_arqueologico FOREIGN KEY (fk_individuo_arqueologico) REFERENCES public.individuo_arqueologico(id_individuo_arqueologico) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lote_edades_rel_individuo_arqueologico fk_individuo_arqueologico; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lote_edades_rel_individuo_arqueologico
    ADD CONSTRAINT fk_individuo_arqueologico FOREIGN KEY (fk_individuo_arqueologico) REFERENCES public.individuo_arqueologico(id_individuo_arqueologico) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: individuo_arqueologico_rel_linea fk_individuo_arqueologico; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individuo_arqueologico_rel_linea
    ADD CONSTRAINT fk_individuo_arqueologico FOREIGN KEY (fk_individuo_arqueologico) REFERENCES public.individuo_arqueologico(id_individuo_arqueologico) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sample fk_individuo_resto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sample
    ADD CONSTRAINT fk_individuo_resto FOREIGN KEY (fk_individuo_resto_id) REFERENCES public.individuo_resto(id_individuo_resto) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: individuo_resto_rel_url fk_individuo_resto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individuo_resto_rel_url
    ADD CONSTRAINT fk_individuo_resto FOREIGN KEY (fk_individuo_resto) REFERENCES public.individuo_resto(id_individuo_resto) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: anomalia_rel_individuo_resto fk_individuo_resto_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.anomalia_rel_individuo_resto
    ADD CONSTRAINT fk_individuo_resto_id FOREIGN KEY (fk_individuo_resto_id) REFERENCES public.individuo_resto(id_individuo_resto) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: persona_rol_pertenencia_rel_institucion fk_institucion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persona_rol_pertenencia_rel_institucion
    ADD CONSTRAINT fk_institucion FOREIGN KEY (fk_institucion_nombre) REFERENCES public.institucion(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: keyword_rel_documento fk_keyword; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.keyword_rel_documento
    ADD CONSTRAINT fk_keyword FOREIGN KEY (fk_keyword_palabra) REFERENCES public.keyword(palabra) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: keyword fk_keyword; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.keyword
    ADD CONSTRAINT fk_keyword FOREIGN KEY (fk_keyword) REFERENCES public.keyword(palabra) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lugar fk_line; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lugar
    ADD CONSTRAINT fk_line FOREIGN KEY (fk_line_id) REFERENCES public.line(id_line) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: linea_rel_unidad fk_linea; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.linea_rel_unidad
    ADD CONSTRAINT fk_linea FOREIGN KEY (fk_linea_id) REFERENCES public.linea(id_linea) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: persona_rol_pertenencia_rel_linea fk_linea; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persona_rol_pertenencia_rel_linea
    ADD CONSTRAINT fk_linea FOREIGN KEY (fk_linea) REFERENCES public.linea(id_linea) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: linea_rel_lugar fk_linea; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.linea_rel_lugar
    ADD CONSTRAINT fk_linea FOREIGN KEY (fk_linea_id) REFERENCES public.linea(id_linea) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: individuo_arqueologico_rel_linea fk_linea; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individuo_arqueologico_rel_linea
    ADD CONSTRAINT fk_linea FOREIGN KEY (fk_linea) REFERENCES public.linea(id_linea) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: objeto_arqueologico_rel_linea fk_linea; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.objeto_arqueologico_rel_linea
    ADD CONSTRAINT fk_linea FOREIGN KEY (fk_linea) REFERENCES public.linea(id_linea) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lote_edades_rel_individuo_arqueologico fk_lote_edades; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lote_edades_rel_individuo_arqueologico
    ADD CONSTRAINT fk_lote_edades FOREIGN KEY (fk_lote_edades) REFERENCES public.lote_edades(id_edad_recodificada) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: or_per_lug fk_lugar; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.or_per_lug
    ADD CONSTRAINT fk_lugar FOREIGN KEY (fk_lugar_id) REFERENCES public.lugar(id_lugar) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pertenencia_rel_lugar fk_lugar; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pertenencia_rel_lugar
    ADD CONSTRAINT fk_lugar FOREIGN KEY (fk_lugar_id) REFERENCES public.lugar(id_lugar) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lugar fk_lugar; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lugar
    ADD CONSTRAINT fk_lugar FOREIGN KEY (fk_lugar_id) REFERENCES public.lugar(id_lugar) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: paso_itinerario fk_lugar; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paso_itinerario
    ADD CONSTRAINT fk_lugar FOREIGN KEY (fk_lugar_id) REFERENCES public.lugar(id_lugar) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: agrupacion_bienes fk_lugar; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agrupacion_bienes
    ADD CONSTRAINT fk_lugar FOREIGN KEY (fk_lugar_id) REFERENCES public.lugar(id_lugar) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tipo_lugar_rel_lugar fk_lugar; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipo_lugar_rel_lugar
    ADD CONSTRAINT fk_lugar FOREIGN KEY (fk_lugar_id) REFERENCES public.lugar(id_lugar) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: persona_rol_pertenencia_rel_lugar fk_lugar; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persona_rol_pertenencia_rel_lugar
    ADD CONSTRAINT fk_lugar FOREIGN KEY (fk_lugar_id) REFERENCES public.lugar(id_lugar) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: linea_rel_lugar fk_lugar; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.linea_rel_lugar
    ADD CONSTRAINT fk_lugar FOREIGN KEY (fk_lugar_id) REFERENCES public.lugar(id_lugar) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: linea fk_lugar; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.linea
    ADD CONSTRAINT fk_lugar FOREIGN KEY (fk_lugar_id) REFERENCES public.lugar(id_lugar) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: material fk_material; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.material
    ADD CONSTRAINT fk_material FOREIGN KEY (fk_material_id) REFERENCES public.material(id_material) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: linea fk_material; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.linea
    ADD CONSTRAINT fk_material FOREIGN KEY (fk_material_id) REFERENCES public.material(id_material) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: material_sample fk_material_sample; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.material_sample
    ADD CONSTRAINT fk_material_sample FOREIGN KEY (fk_material) REFERENCES public.material_sample(material) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sample_rel_material_sample fk_material_sample; Type: FK CONSTRAINT; Schema: public; Owner: geographica
--

ALTER TABLE ONLY public.sample_rel_material_sample
    ADD CONSTRAINT fk_material_sample FOREIGN KEY (fk_material_sample_material) REFERENCES public.material_sample(material) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: agrupacion_bienes fk_metodo_pago; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agrupacion_bienes
    ADD CONSTRAINT fk_metodo_pago FOREIGN KEY (fk_metodo_pago_id) REFERENCES public.metodo_pago(id_metodo_pago) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pena_rel_miembro fk_miembro; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pena_rel_miembro
    ADD CONSTRAINT fk_miembro FOREIGN KEY (fk_miembro_texto) REFERENCES public.miembro(texto) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: paleobotany fk_muestra; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paleobotany
    ADD CONSTRAINT fk_muestra FOREIGN KEY (fk_muestra_id) REFERENCES public.sample(id_muestra) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: muestra_rel_url fk_muestra; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.muestra_rel_url
    ADD CONSTRAINT fk_muestra FOREIGN KEY (fk_muestra_id) REFERENCES public.sample(id_muestra) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: permiso_navegacion fk_navegacion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permiso_navegacion
    ADD CONSTRAINT fk_navegacion FOREIGN KEY (fk_navegacion_id) REFERENCES public.navegacion(id_navegacion) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: paso_itinerario fk_navegacion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paso_itinerario
    ADD CONSTRAINT fk_navegacion FOREIGN KEY (fk_navegacion_id) REFERENCES public.navegacion(id_navegacion) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: navegacion_rel_agrupacion_bienes fk_navegacion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.navegacion_rel_agrupacion_bienes
    ADD CONSTRAINT fk_navegacion FOREIGN KEY (fk_navegacion_id) REFERENCES public.navegacion(id_navegacion) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: navegacion_rel_persona_rol_pertenencia fk_navegacion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.navegacion_rel_persona_rol_pertenencia
    ADD CONSTRAINT fk_navegacion FOREIGN KEY (fk_navegacion_id) REFERENCES public.navegacion(id_navegacion) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: navegacion_rel_transporte fk_navegacion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.navegacion_rel_transporte
    ADD CONSTRAINT fk_navegacion FOREIGN KEY (fk_navegacion_id) REFERENCES public.navegacion(id_navegacion) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: objeto fk_objeto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.objeto
    ADD CONSTRAINT fk_objeto FOREIGN KEY (fk_objeto_id) REFERENCES public.objeto(id_objeto) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: linea fk_objeto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.linea
    ADD CONSTRAINT fk_objeto FOREIGN KEY (fk_objeto_id) REFERENCES public.objeto(id_objeto) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: transporte_rel_objeto fk_objeto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transporte_rel_objeto
    ADD CONSTRAINT fk_objeto FOREIGN KEY (fk_objeto_id) REFERENCES public.objeto(id_objeto) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: objeto_arqueologico_rel_linea fk_objeto_arqueologico; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.objeto_arqueologico_rel_linea
    ADD CONSTRAINT fk_objeto_arqueologico FOREIGN KEY (fk_objeto_arqueologico) REFERENCES public.objeto_arqueologico(id_objeto) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: persona_rol_pertenencia_rel_ocupacion fk_ocupacion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persona_rol_pertenencia_rel_ocupacion
    ADD CONSTRAINT fk_ocupacion FOREIGN KEY (fk_ocupacion_nombre) REFERENCES public.ocupacion(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: or_per_lug fk_origen_persona; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.or_per_lug
    ADD CONSTRAINT fk_origen_persona FOREIGN KEY (fk_origen_persona_id) REFERENCES public.origen_persona(id_origen_persona) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: origen_persona fk_origen_persona; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.origen_persona
    ADD CONSTRAINT fk_origen_persona FOREIGN KEY (fk_origen_persona_id) REFERENCES public.origen_persona(id_origen_persona) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: rel_iti_obj_trans fk_paso_itinerario; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rel_iti_obj_trans
    ADD CONSTRAINT fk_paso_itinerario FOREIGN KEY (fk_paso_itinerario_id) REFERENCES public.paso_itinerario(id_paso_itinerario) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: documento fk_pena; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documento
    ADD CONSTRAINT fk_pena FOREIGN KEY (fk_pena_id) REFERENCES public.pena(id_pena) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pena_rel_miembro fk_pena; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pena_rel_miembro
    ADD CONSTRAINT fk_pena FOREIGN KEY (fk_pena_id) REFERENCES public.pena(id_pena) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pena_rel_unidad fk_pena; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pena_rel_unidad
    ADD CONSTRAINT fk_pena FOREIGN KEY (fk_pena_id) REFERENCES public.pena(id_pena) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: perfil_usuario_rel_permisos_api fk_perfil_usuario; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.perfil_usuario_rel_permisos_api
    ADD CONSTRAINT fk_perfil_usuario FOREIGN KEY (fk_perfil_usuario) REFERENCES public.perfil_usuario(id_perfil_usuario) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: usuario fk_perfil_usuario; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT fk_perfil_usuario FOREIGN KEY (fk_perfil_usuario) REFERENCES public.perfil_usuario(id_perfil_usuario) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: perfil_usuario_rel_permisos_api fk_permisos_api; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.perfil_usuario_rel_permisos_api
    ADD CONSTRAINT fk_permisos_api FOREIGN KEY (fk_permisos_api) REFERENCES public.permisos_api(id_permisos_api) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: persona_historica fk_persona_historica; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persona_historica
    ADD CONSTRAINT fk_persona_historica FOREIGN KEY (fk_persona_historica) REFERENCES public.persona_historica(id_persona_historica) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: persona_rol_pertenencia fk_persona_historica; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persona_rol_pertenencia
    ADD CONSTRAINT fk_persona_historica FOREIGN KEY (fk_persona_historica_id) REFERENCES public.persona_historica(id_persona_historica) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: or_per_lug fk_persona_rol_pertenencia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.or_per_lug
    ADD CONSTRAINT fk_persona_rol_pertenencia FOREIGN KEY (fk_persona_rol_pertenencia_id) REFERENCES public.persona_rol_pertenencia(id_persona_rol_pertenencia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: persona_rol_pertenencia fk_persona_rol_pertenencia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persona_rol_pertenencia
    ADD CONSTRAINT fk_persona_rol_pertenencia FOREIGN KEY (fk_persona_rol_pertenencia_id) REFERENCES public.persona_rol_pertenencia(id_persona_rol_pertenencia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: navegacion_rel_persona_rol_pertenencia fk_persona_rol_pertenencia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.navegacion_rel_persona_rol_pertenencia
    ADD CONSTRAINT fk_persona_rol_pertenencia FOREIGN KEY (fk_persona_rol_pertenencia_id) REFERENCES public.persona_rol_pertenencia(id_persona_rol_pertenencia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: persona_rol_pertenencia_rel_rol fk_persona_rol_pertenencia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persona_rol_pertenencia_rel_rol
    ADD CONSTRAINT fk_persona_rol_pertenencia FOREIGN KEY (fk_persona_rol_pertenencia) REFERENCES public.persona_rol_pertenencia(id_persona_rol_pertenencia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: persona_rol_pertenencia_rel_cargo fk_persona_rol_pertenencia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persona_rol_pertenencia_rel_cargo
    ADD CONSTRAINT fk_persona_rol_pertenencia FOREIGN KEY (fk_persona_rol_pertenencia_id) REFERENCES public.persona_rol_pertenencia(id_persona_rol_pertenencia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: persona_rol_pertenencia_rel_ocupacion fk_persona_rol_pertenencia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persona_rol_pertenencia_rel_ocupacion
    ADD CONSTRAINT fk_persona_rol_pertenencia FOREIGN KEY (fk_persona_rol_pertenencia_id) REFERENCES public.persona_rol_pertenencia(id_persona_rol_pertenencia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: persona_rol_pertenencia_rel_lugar fk_persona_rol_pertenencia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persona_rol_pertenencia_rel_lugar
    ADD CONSTRAINT fk_persona_rol_pertenencia FOREIGN KEY (fk_persona_rol_pertenencia_id) REFERENCES public.persona_rol_pertenencia(id_persona_rol_pertenencia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: persona_rol_pertenencia_rel_institucion fk_persona_rol_pertenencia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persona_rol_pertenencia_rel_institucion
    ADD CONSTRAINT fk_persona_rol_pertenencia FOREIGN KEY (fk_persona_rol_pertenencia_id) REFERENCES public.persona_rol_pertenencia(id_persona_rol_pertenencia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: respuesta fk_persona_rol_pertenencia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.respuesta
    ADD CONSTRAINT fk_persona_rol_pertenencia FOREIGN KEY (fk_persona_rol_pertenencia_id) REFERENCES public.persona_rol_pertenencia(id_persona_rol_pertenencia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: persona_rol_pertenencia_rel_tortura fk_persona_rol_pertenencia_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persona_rol_pertenencia_rel_tortura
    ADD CONSTRAINT fk_persona_rol_pertenencia_id FOREIGN KEY (fk_persona_rol_pertenencia_id) REFERENCES public.persona_rol_pertenencia(id_persona_rol_pertenencia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: persona_rol_pertenencia_rel_linea fk_persona_rol_petenencia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persona_rol_pertenencia_rel_linea
    ADD CONSTRAINT fk_persona_rol_petenencia FOREIGN KEY (fk_persona_rol_pertenencia_id) REFERENCES public.persona_rol_pertenencia(id_persona_rol_pertenencia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pertenencia fk_pertenencia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pertenencia
    ADD CONSTRAINT fk_pertenencia FOREIGN KEY (fk_pertenencia_id) REFERENCES public.pertenencia(id_pertenencia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pertenencia_rel_lugar fk_pertenencia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pertenencia_rel_lugar
    ADD CONSTRAINT fk_pertenencia FOREIGN KEY (fk_pertenencia_id) REFERENCES public.pertenencia(id_pertenencia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: persona_rol_pertenencia fk_pertenencia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persona_rol_pertenencia
    ADD CONSTRAINT fk_pertenencia FOREIGN KEY (fk_pertenencia_id) REFERENCES public.pertenencia(id_pertenencia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pertenencia_rel_attr_especifico fk_pertenencia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pertenencia_rel_attr_especifico
    ADD CONSTRAINT fk_pertenencia FOREIGN KEY (fk_pertenencia_id) REFERENCES public.pertenencia(id_pertenencia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pertenencia_rel_agrupacion_bienes fk_pertenencia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pertenencia_rel_agrupacion_bienes
    ADD CONSTRAINT fk_pertenencia FOREIGN KEY (fk_pertenencia_id) REFERENCES public.pertenencia(id_pertenencia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: respuesta fk_pertenencia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.respuesta
    ADD CONSTRAINT fk_pertenencia FOREIGN KEY (fk_pertenencia_id) REFERENCES public.pertenencia(id_pertenencia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lugar fk_point; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lugar
    ADD CONSTRAINT fk_point FOREIGN KEY (fk_point_id) REFERENCES public.point(id_point) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lugar fk_polygon; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lugar
    ADD CONSTRAINT fk_polygon FOREIGN KEY (fk_polygon_id) REFERENCES public.polygon(id_polygon) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: proyecto_rel_documento fk_proyecto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proyecto_rel_documento
    ADD CONSTRAINT fk_proyecto FOREIGN KEY (fk_proyecto_nombre) REFERENCES public.proyecto(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: individuo_arqueologico fk_radiocarbon_dating; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individuo_arqueologico
    ADD CONSTRAINT fk_radiocarbon_dating FOREIGN KEY (fk_radiocarbon_dating_id) REFERENCES public.radiocarbon_dating(id_radiocarbon_dating) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: documento_rel_referencia_bibliografica fk_referencia_bibliografica; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documento_rel_referencia_bibliografica
    ADD CONSTRAINT fk_referencia_bibliografica FOREIGN KEY (fk_referencia_bibliografica_id) REFERENCES public.referencia_bibliografica(id_referencia_bibliografica) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: individuo_resto fk_resto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individuo_resto
    ADD CONSTRAINT fk_resto FOREIGN KEY (fk_resto_variable) REFERENCES public.resto(variable) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: resto_rel_categoria_resto_indice fk_resto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resto_rel_categoria_resto_indice
    ADD CONSTRAINT fk_resto FOREIGN KEY (fk_resto_variable) REFERENCES public.resto(variable) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: persona_rol_pertenencia_rel_rol fk_rol; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persona_rol_pertenencia_rel_rol
    ADD CONSTRAINT fk_rol FOREIGN KEY (fk_rol_nombre) REFERENCES public.rol(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sample_rel_material_sample fk_sample; Type: FK CONSTRAINT; Schema: public; Owner: geographica
--

ALTER TABLE ONLY public.sample_rel_material_sample
    ADD CONSTRAINT fk_sample FOREIGN KEY (fk_sample_id) REFERENCES public.sample(id_muestra) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: bioapatite fk_sample; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bioapatite
    ADD CONSTRAINT fk_sample FOREIGN KEY (fk_sample_id) REFERENCES public.sample(id_muestra) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: collagen fk_sample; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collagen
    ADD CONSTRAINT fk_sample FOREIGN KEY (fk_sample_id) REFERENCES public.sample(id_muestra) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mtdna fk_sample; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mtdna
    ADD CONSTRAINT fk_sample FOREIGN KEY (fk_sample_id) REFERENCES public.sample(id_muestra) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ychromosome fk_sample; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ychromosome
    ADD CONSTRAINT fk_sample FOREIGN KEY (fk_sample_id) REFERENCES public.sample(id_muestra) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: wholegenome fk_sample; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wholegenome
    ADD CONSTRAINT fk_sample FOREIGN KEY (fk_sample_id) REFERENCES public.sample(id_muestra) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: analysis fk_sample_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.analysis
    ADD CONSTRAINT fk_sample_id FOREIGN KEY (fk_sample_id) REFERENCES public.sample(id_muestra) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: documento fk_seccion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documento
    ADD CONSTRAINT fk_seccion FOREIGN KEY (fk_seccion_id) REFERENCES public.seccion(id_seccion) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tipo_lugar_rel_lugar fk_tipo_lugar; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipo_lugar_rel_lugar
    ADD CONSTRAINT fk_tipo_lugar FOREIGN KEY (fk_tipo_lugar_nombre) REFERENCES public.tipo_lugar(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lugar fk_tipo_lugar; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lugar
    ADD CONSTRAINT fk_tipo_lugar FOREIGN KEY (fk_tipo_lugar_nombre) REFERENCES public.tipo_lugar(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tipo_lugar fk_tipo_lugar_tipo_lugar; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipo_lugar
    ADD CONSTRAINT fk_tipo_lugar_tipo_lugar FOREIGN KEY (fk_tipo_lugar) REFERENCES public.tipo_lugar(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: transporte fk_tipo_transporte; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transporte
    ADD CONSTRAINT fk_tipo_transporte FOREIGN KEY (fk_tipo_transporte) REFERENCES public.tipo_transporte(nombre_tipo) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: persona_rol_pertenencia_rel_tortura fk_tortura_texto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persona_rol_pertenencia_rel_tortura
    ADD CONSTRAINT fk_tortura_texto FOREIGN KEY (fk_tortura_texto) REFERENCES public.tortura(texto) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: transporte fk_transporte; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transporte
    ADD CONSTRAINT fk_transporte FOREIGN KEY (fk_transporte_id) REFERENCES public.transporte(id_transporte) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: rel_iti_obj_trans fk_transporte; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rel_iti_obj_trans
    ADD CONSTRAINT fk_transporte FOREIGN KEY (fk_transporte_id) REFERENCES public.transporte(id_transporte) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: navegacion_rel_transporte fk_transporte; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.navegacion_rel_transporte
    ADD CONSTRAINT fk_transporte FOREIGN KEY (fk_transporte_id) REFERENCES public.transporte(id_transporte) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: transporte_rel_objeto fk_transporte; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transporte_rel_objeto
    ADD CONSTRAINT fk_transporte FOREIGN KEY (fk_transporte_id) REFERENCES public.transporte(id_transporte) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: agrupacion_bienes_rel_unidad fk_unidad; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agrupacion_bienes_rel_unidad
    ADD CONSTRAINT fk_unidad FOREIGN KEY (fk_unidad_nombre) REFERENCES public.unidad(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pena_rel_unidad fk_unidad; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pena_rel_unidad
    ADD CONSTRAINT fk_unidad FOREIGN KEY (fk_unidad_nombre) REFERENCES public.unidad(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: documento_rel_unidad fk_unidad; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documento_rel_unidad
    ADD CONSTRAINT fk_unidad FOREIGN KEY (fk_unidad_nombre) REFERENCES public.unidad(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: linea_rel_unidad fk_unidad; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.linea_rel_unidad
    ADD CONSTRAINT fk_unidad FOREIGN KEY (fk_unidad_nombre) REFERENCES public.unidad(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: referencia_bibliografica fk_url; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.referencia_bibliografica
    ADD CONSTRAINT fk_url FOREIGN KEY (fk_url_id) REFERENCES public.url(id_url) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: documento_rel_url fk_url; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documento_rel_url
    ADD CONSTRAINT fk_url FOREIGN KEY (fk_url_id) REFERENCES public.url(id_url) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: entierro_rel_url fk_url; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entierro_rel_url
    ADD CONSTRAINT fk_url FOREIGN KEY (fk_url_id) REFERENCES public.url(id_url) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: individuo_arqueologico_rel_url fk_url; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individuo_arqueologico_rel_url
    ADD CONSTRAINT fk_url FOREIGN KEY (fk_url_id) REFERENCES public.url(id_url) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: muestra_rel_url fk_url; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.muestra_rel_url
    ADD CONSTRAINT fk_url FOREIGN KEY (fk_url_id) REFERENCES public.url(id_url) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: individuo_resto_rel_url fk_url; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individuo_resto_rel_url
    ADD CONSTRAINT fk_url FOREIGN KEY (fk_url) REFERENCES public.url(id_url) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: documento fk_usuario; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documento
    ADD CONSTRAINT fk_usuario FOREIGN KEY (fk_usuario_id) REFERENCES public.usuario(id_usuario) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: log_acceso fk_usuario; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log_acceso
    ADD CONSTRAINT fk_usuario FOREIGN KEY (fk_usuario) REFERENCES public.usuario(id_usuario) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

