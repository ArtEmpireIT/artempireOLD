--
-- NOTE:
--
-- File paths need to be edited. Search for /usr/src/api/db/initial and
-- replace it with the path to the directory containing
-- the extracted data files.
--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.2
-- Dumped by pg_dump version 9.6.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

SET search_path = public, pg_catalog;

ALTER TABLE ONLY public.log_acceso DROP CONSTRAINT fk_usuario;
ALTER TABLE ONLY public.documento DROP CONSTRAINT fk_usuario;
ALTER TABLE ONLY public.muestra_rel_url DROP CONSTRAINT fk_url;
ALTER TABLE ONLY public.lote_rel_url DROP CONSTRAINT fk_url;
ALTER TABLE ONLY public.individuo_arqueologico_rel_url DROP CONSTRAINT fk_url;
ALTER TABLE ONLY public.entierro_rel_url DROP CONSTRAINT fk_url;
ALTER TABLE ONLY public.documento_rel_url DROP CONSTRAINT fk_url;
ALTER TABLE ONLY public.referencia_bibliografica DROP CONSTRAINT fk_url;
ALTER TABLE ONLY public.linea_rel_unidad DROP CONSTRAINT fk_unidad;
ALTER TABLE ONLY public.documento_rel_unidad DROP CONSTRAINT fk_unidad;
ALTER TABLE ONLY public.pena_rel_unidad DROP CONSTRAINT fk_unidad;
ALTER TABLE ONLY public.agrupacion_bienes_rel_unidad DROP CONSTRAINT fk_unidad;
ALTER TABLE ONLY public.transporte_rel_objeto DROP CONSTRAINT fk_transporte;
ALTER TABLE ONLY public.navegacion_rel_transporte DROP CONSTRAINT fk_transporte;
ALTER TABLE ONLY public.rel_iti_obj_trans DROP CONSTRAINT fk_transporte;
ALTER TABLE ONLY public.transporte DROP CONSTRAINT fk_transporte;
ALTER TABLE ONLY public.transporte DROP CONSTRAINT fk_tipo_transporte;
ALTER TABLE ONLY public.pertenencia_rel_lugar DROP CONSTRAINT fk_tipo_lugar;
ALTER TABLE ONLY public.documento DROP CONSTRAINT fk_seccion;
ALTER TABLE ONLY public.persona_rol_pertenencia DROP CONSTRAINT fk_rol;
ALTER TABLE ONLY public.resto_rel_categoria_resto_indice DROP CONSTRAINT fk_resto;
ALTER TABLE ONLY public.individuo_lote_resto DROP CONSTRAINT fk_resto;
ALTER TABLE ONLY public.entierro_rel_referencia_bibliografica DROP CONSTRAINT fk_referencia_bibliografica;
ALTER TABLE ONLY public.documento_rel_referencia_bibliografica DROP CONSTRAINT fk_referencia_bibliografica;
ALTER TABLE ONLY public.proyecto_rel_documento DROP CONSTRAINT fk_proyecto;
ALTER TABLE ONLY public.lugar DROP CONSTRAINT fk_polygon;
ALTER TABLE ONLY public.lugar DROP CONSTRAINT fk_point;
ALTER TABLE ONLY public.pertenencia_rel_agrupacion_bienes DROP CONSTRAINT fk_pertenencia;
ALTER TABLE ONLY public.pertenencia_rel_attr_especifico DROP CONSTRAINT fk_pertenencia;
ALTER TABLE ONLY public.persona_rol_pertenencia DROP CONSTRAINT fk_pertenencia;
ALTER TABLE ONLY public.pertenencia_rel_lugar DROP CONSTRAINT fk_pertenencia;
ALTER TABLE ONLY public.pertenencia DROP CONSTRAINT fk_pertenencia;
ALTER TABLE ONLY public.navegacion_rel_persona_rol_pertenencia DROP CONSTRAINT fk_persona_rol_pertenencia;
ALTER TABLE ONLY public.persona_rol_pertenencia DROP CONSTRAINT fk_persona_rol_pertenencia;
ALTER TABLE ONLY public.or_per_lug DROP CONSTRAINT fk_persona_rol_pertenencia;
ALTER TABLE ONLY public.linea DROP CONSTRAINT fk_persona_rol;
ALTER TABLE ONLY public.persona_rol_pertenencia DROP CONSTRAINT fk_persona_historica;
ALTER TABLE ONLY public.persona_historica DROP CONSTRAINT fk_persona_historica;
ALTER TABLE ONLY public.perfil_usuario_rel_permisos_api DROP CONSTRAINT fk_permisos_api;
ALTER TABLE ONLY public.usuario DROP CONSTRAINT fk_perfil_usuario;
ALTER TABLE ONLY public.perfil_usuario_rel_permisos_api DROP CONSTRAINT fk_perfil_usuario;
ALTER TABLE ONLY public.pena_rel_unidad DROP CONSTRAINT fk_pena;
ALTER TABLE ONLY public.pena_rel_miembro DROP CONSTRAINT fk_pena;
ALTER TABLE ONLY public.documento DROP CONSTRAINT fk_pena;
ALTER TABLE ONLY public.rel_iti_obj_trans DROP CONSTRAINT fk_paso_itinerario;
ALTER TABLE ONLY public.origen_persona DROP CONSTRAINT fk_origen_persona;
ALTER TABLE ONLY public.or_per_lug DROP CONSTRAINT fk_origen_persona;
ALTER TABLE ONLY public.transporte_rel_objeto DROP CONSTRAINT fk_objeto;
ALTER TABLE ONLY public.linea DROP CONSTRAINT fk_objeto;
ALTER TABLE ONLY public.objeto DROP CONSTRAINT fk_objeto;
ALTER TABLE ONLY public.navegacion_rel_transporte DROP CONSTRAINT fk_navegacion;
ALTER TABLE ONLY public.navegacion_rel_persona_rol_pertenencia DROP CONSTRAINT fk_navegacion;
ALTER TABLE ONLY public.navegacion_rel_agrupacion_bienes DROP CONSTRAINT fk_navegacion;
ALTER TABLE ONLY public.paso_itinerario DROP CONSTRAINT fk_navegacion;
ALTER TABLE ONLY public.permiso_navegacion DROP CONSTRAINT fk_navegacion;
ALTER TABLE ONLY public.muestra_rel_url DROP CONSTRAINT fk_muestra;
ALTER TABLE ONLY public.adn DROP CONSTRAINT fk_muestra;
ALTER TABLE ONLY public.collagen DROP CONSTRAINT fk_muestra;
ALTER TABLE ONLY public.carbonate DROP CONSTRAINT fk_muestra;
ALTER TABLE ONLY public.phosphates DROP CONSTRAINT fk_muestra;
ALTER TABLE ONLY public.sr DROP CONSTRAINT fk_muestra;
ALTER TABLE ONLY public.almidon DROP CONSTRAINT fk_muestra;
ALTER TABLE ONLY public.pena_rel_miembro DROP CONSTRAINT fk_miembro;
ALTER TABLE ONLY public.agrupacion_bienes DROP CONSTRAINT fk_metodo_pago;
ALTER TABLE ONLY public.linea DROP CONSTRAINT fk_material;
ALTER TABLE ONLY public.material DROP CONSTRAINT fk_material;
ALTER TABLE ONLY public.entierro DROP CONSTRAINT fk_lugar;
ALTER TABLE ONLY public.linea DROP CONSTRAINT fk_lugar;
ALTER TABLE ONLY public.agrupacion_bienes DROP CONSTRAINT fk_lugar;
ALTER TABLE ONLY public.paso_itinerario DROP CONSTRAINT fk_lugar;
ALTER TABLE ONLY public.lugar DROP CONSTRAINT fk_lugar;
ALTER TABLE ONLY public.pertenencia_rel_lugar DROP CONSTRAINT fk_lugar;
ALTER TABLE ONLY public.or_per_lug DROP CONSTRAINT fk_lugar;
ALTER TABLE ONLY public.individuo_lote_resto DROP CONSTRAINT fk_lote;
ALTER TABLE ONLY public.lote_rel_url DROP CONSTRAINT fk_lote;
ALTER TABLE ONLY public.entierro_rel_lote DROP CONSTRAINT fk_lote;
ALTER TABLE ONLY public.lote_genero_edad DROP CONSTRAINT fk_lote;
ALTER TABLE ONLY public.linea_rel_unidad DROP CONSTRAINT fk_linea;
ALTER TABLE ONLY public.lugar DROP CONSTRAINT fk_line;
ALTER TABLE ONLY public.keyword DROP CONSTRAINT fk_keyword;
ALTER TABLE ONLY public.keyword_rel_documento DROP CONSTRAINT fk_keyword;
ALTER TABLE ONLY public.persona_rol_pertenencia DROP CONSTRAINT fk_institucion;
ALTER TABLE ONLY public.anomalia_rel_individuo_resto DROP CONSTRAINT fk_individuo_resto_id;
ALTER TABLE ONLY public.muestra DROP CONSTRAINT fk_individuo_resto;
ALTER TABLE ONLY public.linea DROP CONSTRAINT fk_individuo_arqueologico;
ALTER TABLE ONLY public.individuo_arqueologico_rel_url DROP CONSTRAINT fk_individuo_arqueologico;
ALTER TABLE ONLY public.individuo_lote_resto DROP CONSTRAINT fk_individuo_arqueologico;
ALTER TABLE ONLY public.estado_rel_individuo_arqueologico DROP CONSTRAINT fk_individuo_arqueologico;
ALTER TABLE ONLY public.persona_historica DROP CONSTRAINT fk_individuo_arqueologico;
ALTER TABLE ONLY public.lote_genero_edad DROP CONSTRAINT fk_genero_lote;
ALTER TABLE ONLY public.estado_rel_individuo_arqueologico DROP CONSTRAINT fk_estado;
ALTER TABLE ONLY public.individuo_lote_resto DROP CONSTRAINT fk_especie;
ALTER TABLE ONLY public.entierro DROP CONSTRAINT fk_espacio_entierro;
ALTER TABLE ONLY public.individuo_lote_resto DROP CONSTRAINT fk_entierro;
ALTER TABLE ONLY public.entierro_rel_lote DROP CONSTRAINT fk_entierro;
ALTER TABLE ONLY public.linea DROP CONSTRAINT fk_entierro;
ALTER TABLE ONLY public.entierro_rel_url DROP CONSTRAINT fk_entierro;
ALTER TABLE ONLY public.entierro_rel_referencia_bibliografica DROP CONSTRAINT fk_entierro;
ALTER TABLE ONLY public.lote_genero_edad DROP CONSTRAINT fk_edad_lote;
ALTER TABLE ONLY public.documento_rel_documento DROP CONSTRAINT fk_documento2;
ALTER TABLE ONLY public.documento_rel_documento DROP CONSTRAINT fk_documento1;
ALTER TABLE ONLY public.documento_rel_referencia_bibliografica DROP CONSTRAINT fk_documento;
ALTER TABLE ONLY public.documento_rel_url DROP CONSTRAINT fk_documento;
ALTER TABLE ONLY public.documento_rel_unidad DROP CONSTRAINT fk_documento;
ALTER TABLE ONLY public.navegacion DROP CONSTRAINT fk_documento;
ALTER TABLE ONLY public.proyecto_rel_documento DROP CONSTRAINT fk_documento;
ALTER TABLE ONLY public.pertenencia DROP CONSTRAINT fk_documento;
ALTER TABLE ONLY public.observacion DROP CONSTRAINT fk_documento;
ALTER TABLE ONLY public.atributo_documento DROP CONSTRAINT fk_documento;
ALTER TABLE ONLY public.keyword_rel_documento DROP CONSTRAINT fk_documento;
ALTER TABLE ONLY public.seccion DROP CONSTRAINT fk_coleccion;
ALTER TABLE ONLY public.resto_rel_categoria_resto_indice DROP CONSTRAINT fk_categoria_resto_indice;
ALTER TABLE ONLY public.categoria_resto_indice DROP CONSTRAINT fk_categoria_resto_indice;
ALTER TABLE ONLY public.categoria_resto_rel_anomalia DROP CONSTRAINT fk_categoria_resto;
ALTER TABLE ONLY public.categoria_resto_indice DROP CONSTRAINT fk_categoria_resto;
ALTER TABLE ONLY public.pertenencia_rel_attr_especifico DROP CONSTRAINT fk_attr_especifico;
ALTER TABLE ONLY public.anomalia_rel_individuo_resto DROP CONSTRAINT fk_anomalia;
ALTER TABLE ONLY public.categoria_resto_rel_anomalia DROP CONSTRAINT fk_anomalia;
ALTER TABLE ONLY public.almidon DROP CONSTRAINT fk_almidon;
ALTER TABLE ONLY public.linea DROP CONSTRAINT fk_agrupacion_bienes;
ALTER TABLE ONLY public.agrupacion_bienes_rel_unidad DROP CONSTRAINT fk_agrupacion_bienes;
ALTER TABLE ONLY public.navegacion_rel_agrupacion_bienes DROP CONSTRAINT fk_agrupacion_bienes;
ALTER TABLE ONLY public.rel_iti_obj_trans DROP CONSTRAINT fk_agrupacion_bienes;
ALTER TABLE ONLY public.pertenencia_rel_agrupacion_bienes DROP CONSTRAINT fk_agrupacion_bienes;
ALTER TABLE ONLY public.usuario DROP CONSTRAINT usuario_pkey;
ALTER TABLE ONLY public.url DROP CONSTRAINT url_pkey;
ALTER TABLE ONLY public.unidad DROP CONSTRAINT unidad_pkey;
ALTER TABLE ONLY public.transporte_rel_objeto DROP CONSTRAINT transporte_rel_objeto_pkey;
ALTER TABLE ONLY public.transporte DROP CONSTRAINT transporte_pkey;
ALTER TABLE ONLY public.tipo_transporte DROP CONSTRAINT tipo_transporte_pkey;
ALTER TABLE ONLY public.tipo_lugar DROP CONSTRAINT tipo_lugar_pkey;
ALTER TABLE ONLY public.sr DROP CONSTRAINT sr_pkey;
ALTER TABLE ONLY public.seccion DROP CONSTRAINT seccion_pkey;
ALTER TABLE ONLY public.rol DROP CONSTRAINT rol_pkey;
ALTER TABLE ONLY public.resto_rel_categoria_resto_indice DROP CONSTRAINT resto_rel_categoria_resto_indice_pkey;
ALTER TABLE ONLY public.resto DROP CONSTRAINT resto_pkey;
ALTER TABLE ONLY public.rel_iti_obj_trans DROP CONSTRAINT rel_iti_obj_trans_pkey;
ALTER TABLE ONLY public.referencia_bibliografica DROP CONSTRAINT referencia_bibliografica_pkey;
ALTER TABLE ONLY public.proyecto_rel_documento DROP CONSTRAINT proyecto_rel_documento_pkey;
ALTER TABLE ONLY public.proyecto DROP CONSTRAINT proyecto_pkey;
ALTER TABLE ONLY public.polygon DROP CONSTRAINT polygon_pkey;
ALTER TABLE ONLY public.point DROP CONSTRAINT point_pkey;
ALTER TABLE ONLY public.phosphates DROP CONSTRAINT phosphates_pkey;
ALTER TABLE ONLY public.pertenencia_rel_lugar DROP CONSTRAINT pertenencia_rel_lugar_pkey;
ALTER TABLE ONLY public.pertenencia_rel_attr_especifico DROP CONSTRAINT pertenencia_rel_attr_especifico_pkey;
ALTER TABLE ONLY public.pertenencia_rel_agrupacion_bienes DROP CONSTRAINT pertenencia_rel_agrupacion_bienes_pkey;
ALTER TABLE ONLY public.pertenencia DROP CONSTRAINT pertenencia_pkey;
ALTER TABLE ONLY public.persona_rol_pertenencia DROP CONSTRAINT persona_rol_pertenencia_pkey;
ALTER TABLE ONLY public.persona_historica DROP CONSTRAINT persona_historica_pkey;
ALTER TABLE ONLY public.permisos_api DROP CONSTRAINT permisos_api_pkey;
ALTER TABLE ONLY public.permiso_navegacion DROP CONSTRAINT permiso_navegacion_pkey;
ALTER TABLE ONLY public.perfil_usuario_rel_permisos_api DROP CONSTRAINT perfil_usuario_rel_permisos_api_pkey;
ALTER TABLE ONLY public.perfil_usuario DROP CONSTRAINT perfil_usuario_pkey;
ALTER TABLE ONLY public.pena_rel_unidad DROP CONSTRAINT pena_rel_unidad_pkey;
ALTER TABLE ONLY public.pena_rel_miembro DROP CONSTRAINT pena_rel_miembro_pkey;
ALTER TABLE ONLY public.pena DROP CONSTRAINT pena_id_pkey;
ALTER TABLE ONLY public.paso_itinerario DROP CONSTRAINT paso_itinerario_pkey;
ALTER TABLE ONLY public.origen_persona DROP CONSTRAINT origen_persona_pkey;
ALTER TABLE ONLY public.or_per_lug DROP CONSTRAINT or_per_lug_pkey;
ALTER TABLE ONLY public.observacion DROP CONSTRAINT observacion_pkey;
ALTER TABLE ONLY public.objeto DROP CONSTRAINT objeto_pkey;
ALTER TABLE ONLY public.navegacion_rel_transporte DROP CONSTRAINT navegacion_rel_transporte_pkey;
ALTER TABLE ONLY public.navegacion_rel_persona_rol_pertenencia DROP CONSTRAINT navegacion_rel_persona_rol_pertenencia_pkey;
ALTER TABLE ONLY public.navegacion_rel_agrupacion_bienes DROP CONSTRAINT navegacion_rel_agrupacion_bienes_pkey;
ALTER TABLE ONLY public.navegacion DROP CONSTRAINT navegacion_pkey;
ALTER TABLE ONLY public.muestra_rel_url DROP CONSTRAINT muestra_rel_url_pkey;
ALTER TABLE ONLY public.muestra DROP CONSTRAINT muestra_pkey;
ALTER TABLE ONLY public.miembro DROP CONSTRAINT miembro_pkey;
ALTER TABLE ONLY public.metodo_pago DROP CONSTRAINT metodo_pago_pkey;
ALTER TABLE ONLY public.material DROP CONSTRAINT material_pkey;
ALTER TABLE ONLY public.lugar DROP CONSTRAINT lugar_pkey;
ALTER TABLE ONLY public.lote_rel_url DROP CONSTRAINT lote_rel_url_pkey;
ALTER TABLE ONLY public.lote DROP CONSTRAINT lote_pkey;
ALTER TABLE ONLY public.lote_genero_edad DROP CONSTRAINT lote_genero_edad_pkey;
ALTER TABLE ONLY public.log_acceso DROP CONSTRAINT log_acceso_pkey;
ALTER TABLE ONLY public.linea_rel_unidad DROP CONSTRAINT linea_rel_unidad_pkey;
ALTER TABLE ONLY public.linea DROP CONSTRAINT linea_pkey;
ALTER TABLE ONLY public.line DROP CONSTRAINT like_pkey;
ALTER TABLE ONLY public.keyword_rel_documento DROP CONSTRAINT keyword_rel_documento_pkey;
ALTER TABLE ONLY public.keyword DROP CONSTRAINT keyword_pkey;
ALTER TABLE ONLY public.institucion DROP CONSTRAINT institucion_pkey;
ALTER TABLE ONLY public.individuo_lote_resto DROP CONSTRAINT individuo_resto_pkey;
ALTER TABLE ONLY public.individuo_arqueologico_rel_url DROP CONSTRAINT individuo_arqueologico_rel_url_pkey;
ALTER TABLE ONLY public.individuo_arqueologico DROP CONSTRAINT individuo_arqueologico_pkey;
ALTER TABLE ONLY public.genero_lote DROP CONSTRAINT genero_lote_pkey;
ALTER TABLE ONLY public.estado_rel_individuo_arqueologico DROP CONSTRAINT estado_rel_individuo_arqueologico_pkey;
ALTER TABLE ONLY public.estado DROP CONSTRAINT estado_pkey;
ALTER TABLE ONLY public.especie DROP CONSTRAINT especie_pkey;
ALTER TABLE ONLY public.espacio_entierro DROP CONSTRAINT espacio_entierro_pkey;
ALTER TABLE ONLY public.entierro_rel_url DROP CONSTRAINT entierro_rel_url_pkey;
ALTER TABLE ONLY public.entierro_rel_referencia_bibliografica DROP CONSTRAINT entierro_rel_referencia_bibliografica_pkey;
ALTER TABLE ONLY public.entierro_rel_lote DROP CONSTRAINT entierro_rel_lote_pkey;
ALTER TABLE ONLY public.entierro DROP CONSTRAINT entierro_pkey;
ALTER TABLE ONLY public.edad_lote DROP CONSTRAINT edad_lote_pkey;
ALTER TABLE ONLY public.documento_rel_url DROP CONSTRAINT documento_rel_url_pkey;
ALTER TABLE ONLY public.documento_rel_unidad DROP CONSTRAINT documento_rel_unidad_pkey;
ALTER TABLE ONLY public.documento_rel_referencia_bibliografica DROP CONSTRAINT documento_rel_referencia_bibliografica_pkey;
ALTER TABLE ONLY public.documento_rel_documento DROP CONSTRAINT documento_rel_documento_pkey;
ALTER TABLE ONLY public.documento DROP CONSTRAINT documento_id_pkey;
ALTER TABLE ONLY public.collagen DROP CONSTRAINT collagen_pkey;
ALTER TABLE ONLY public.coleccion DROP CONSTRAINT coleccion_pkey;
ALTER TABLE ONLY public.categoria_resto_rel_anomalia DROP CONSTRAINT categoria_resto_rel_anomalia_pkey;
ALTER TABLE ONLY public.categoria_resto DROP CONSTRAINT categoria_resto_pkey;
ALTER TABLE ONLY public.categoria_resto_indice DROP CONSTRAINT categoria_resto_indice_pkey;
ALTER TABLE ONLY public.carbonate DROP CONSTRAINT carbonate_pkey;
ALTER TABLE ONLY public.attr_especifico DROP CONSTRAINT attr_especifico_pkey;
ALTER TABLE ONLY public.atributo_documento DROP CONSTRAINT atributo_documento_pkey;
ALTER TABLE ONLY public.anomalia_rel_individuo_resto DROP CONSTRAINT anomalia_rel_individuo_resto_pkey;
ALTER TABLE ONLY public.anomalia DROP CONSTRAINT anomalia_pkey;
ALTER TABLE ONLY public.almidon DROP CONSTRAINT almidon_pkey;
ALTER TABLE ONLY public.agrupacion_bienes_rel_unidad DROP CONSTRAINT agrupacion_bienes_rel_unidad_pkey;
ALTER TABLE ONLY public.agrupacion_bienes DROP CONSTRAINT agrupacion_bienes_pkey;
ALTER TABLE ONLY public.adn DROP CONSTRAINT adn_pkey;
DROP TABLE public.usuario;
DROP TABLE public.url;
DROP TABLE public.unidad;
DROP TABLE public.transporte_rel_objeto;
DROP TABLE public.transporte;
DROP TABLE public.tipo_transporte;
DROP TABLE public.tipo_lugar;
DROP TABLE public.sr;
DROP TABLE public.seccion;
DROP TABLE public.rol;
DROP TABLE public.resto_rel_categoria_resto_indice;
DROP TABLE public.resto;
DROP TABLE public.rel_iti_obj_trans;
DROP TABLE public.referencia_bibliografica;
DROP TABLE public.proyecto_rel_documento;
DROP TABLE public.proyecto;
DROP TABLE public.polygon;
DROP TABLE public.point;
DROP TABLE public.phosphates;
DROP TABLE public.pertenencia_rel_lugar;
DROP TABLE public.pertenencia_rel_attr_especifico;
DROP TABLE public.pertenencia_rel_agrupacion_bienes;
DROP TABLE public.pertenencia;
DROP TABLE public.persona_rol_pertenencia;
DROP TABLE public.persona_historica;
DROP TABLE public.permisos_api;
DROP TABLE public.permiso_navegacion;
DROP TABLE public.perfil_usuario_rel_permisos_api;
DROP TABLE public.perfil_usuario;
DROP TABLE public.pena_rel_unidad;
DROP TABLE public.pena_rel_miembro;
DROP TABLE public.pena;
DROP TABLE public.paso_itinerario;
DROP TABLE public.origen_persona;
DROP TABLE public.or_per_lug;
DROP TABLE public.observacion;
DROP TABLE public.objeto;
DROP TABLE public.navegacion_rel_transporte;
DROP TABLE public.navegacion_rel_persona_rol_pertenencia;
DROP TABLE public.navegacion_rel_agrupacion_bienes;
DROP TABLE public.navegacion;
DROP TABLE public.muestra_rel_url;
DROP TABLE public.muestra;
DROP TABLE public.miembro;
DROP TABLE public.metodo_pago;
DROP TABLE public.material;
DROP TABLE public.lugar;
DROP TABLE public.lote_rel_url;
DROP TABLE public.lote_genero_edad;
DROP TABLE public.lote;
DROP TABLE public.log_acceso;
DROP TABLE public.linea_rel_unidad;
DROP TABLE public.linea;
DROP TABLE public.line;
DROP TABLE public.keyword_rel_documento;
DROP TABLE public.keyword;
DROP TABLE public.institucion;
DROP TABLE public.individuo_lote_resto;
DROP TABLE public.individuo_arqueologico_rel_url;
DROP TABLE public.individuo_arqueologico;
DROP SEQUENCE public.id_usuario;
DROP SEQUENCE public.id_url;
DROP SEQUENCE public.id_transporte;
DROP SEQUENCE public.id_sr;
DROP SEQUENCE public.id_seccion;
DROP SEQUENCE public.id_rel_iti_obj_trans;
DROP SEQUENCE public.id_referencia_bibliografica;
DROP SEQUENCE public.id_polygon;
DROP SEQUENCE public.id_point;
DROP SEQUENCE public.id_phosphates;
DROP SEQUENCE public.id_pertenencia;
DROP SEQUENCE public.id_persona_rol_pertenencia;
DROP SEQUENCE public.id_persona_historica;
DROP SEQUENCE public.id_permisos_api;
DROP SEQUENCE public.id_permiso_navegacion;
DROP SEQUENCE public.id_perfil_usuario;
DROP SEQUENCE public.id_pena;
DROP SEQUENCE public.id_paso_itinerario;
DROP SEQUENCE public.id_origen_persona;
DROP SEQUENCE public.id_or_per_lug;
DROP SEQUENCE public.id_observacion;
DROP SEQUENCE public.id_objeto;
DROP SEQUENCE public.id_navegacion;
DROP SEQUENCE public.id_muestra;
DROP SEQUENCE public.id_metodo_pago;
DROP SEQUENCE public.id_material;
DROP SEQUENCE public.id_lote_genero_edad;
DROP SEQUENCE public.id_lote;
DROP SEQUENCE public.id_log_acceso;
DROP SEQUENCE public.id_linea;
DROP SEQUENCE public.id_line;
DROP SEQUENCE public.id_individuo_resto;
DROP SEQUENCE public.id_individuo_arqueologico;
DROP SEQUENCE public.id_coleccion;
DROP TABLE public.genero_lote;
DROP TABLE public.estado_rel_individuo_arqueologico;
DROP TABLE public.estado;
DROP TABLE public.especie;
DROP TABLE public.espacio_entierro;
DROP TABLE public.entierro_rel_url;
DROP TABLE public.entierro_rel_referencia_bibliografica;
DROP TABLE public.entierro_rel_lote;
DROP TABLE public.entierro;
DROP SEQUENCE public.id_entierro;
DROP TABLE public.edad_lote;
DROP TABLE public.documento_rel_url;
DROP TABLE public.documento_rel_unidad;
DROP TABLE public.documento_rel_referencia_bibliografica;
DROP TABLE public.documento_rel_documento;
DROP TABLE public.documento;
DROP SEQUENCE public.id_documento;
DROP TABLE public.collagen;
DROP SEQUENCE public.id_collagen;
DROP TABLE public.coleccion;
DROP TABLE public.categoria_resto_rel_anomalia;
DROP TABLE public.categoria_resto_indice;
DROP SEQUENCE public.id_categoria_resto_indice;
DROP TABLE public.categoria_resto;
DROP TABLE public.carbonate;
DROP SEQUENCE public.id_carbonate;
DROP TABLE public.attr_especifico;
DROP SEQUENCE public.id_attr_especifico;
DROP TABLE public.atributo_documento;
DROP SEQUENCE public.id_atributo_documento;
DROP TABLE public.anomalia_rel_individuo_resto;
DROP TABLE public.anomalia;
DROP SEQUENCE public.id_anomalia;
DROP TABLE public.almidon;
DROP SEQUENCE public.id_almidon;
DROP TABLE public.agrupacion_bienes_rel_unidad;
DROP TABLE public.agrupacion_bienes;
DROP SEQUENCE public.id_agrupacion_bienes;
DROP TABLE public.adn;
DROP SEQUENCE public.id_adn;
DROP EXTENSION postgis;
DROP EXTENSION adminpack;
DROP EXTENSION plpgsql;
DROP SCHEMA public;
--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS 'standard public schema';


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
-- Name: postgis; Type: EXTENSION; Schema: -; Owner:
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


SET search_path = public, pg_catalog;

--
-- Name: id_adn; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_adn
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_adn OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: adn; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE adn (
    id_adn integer DEFAULT nextval('id_adn'::regclass) NOT NULL,
    library_id character varying(100),
    collection_num character varying(100),
    site_name character varying,
    archeology character varying(500),
    id2 character varying(500),
    material character varying(500),
    c14 character varying(600),
    date_interval character varying(500),
    haplotype character varying,
    haplogroup character varying(500),
    raw_reads double precision,
    marged_reads double precision,
    mapped_reads double precision,
    duplicate_removal_mapp double precision,
    average_coverage double precision,
    "3_deamination" double precision,
    "5_deamination" double precision,
    insert_size double precision,
    contamination_estimate character varying(500),
    fk_muestra_id integer
);


ALTER TABLE adn OWNER TO postgres;

--
-- Name: id_agrupacion_bienes; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_agrupacion_bienes
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_agrupacion_bienes OWNER TO postgres;

--
-- Name: agrupacion_bienes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE agrupacion_bienes (
    id_agrupacion_bienes integer DEFAULT nextval('id_agrupacion_bienes'::regclass) NOT NULL,
    nombre character varying,
    fecha date,
    precision_fecha character varying(5),
    adelanto_cont character varying,
    descripcion_cont character varying,
    folio_cont character varying,
    fk_metodo_pago_id integer,
    fk_lugar_nombre character varying
);


ALTER TABLE agrupacion_bienes OWNER TO postgres;

--
-- Name: agrupacion_bienes_rel_unidad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE agrupacion_bienes_rel_unidad (
    fk_agrupacion_bienes_id integer NOT NULL,
    fk_unidad_nombre character varying NOT NULL,
    valor double precision NOT NULL
);


ALTER TABLE agrupacion_bienes_rel_unidad OWNER TO postgres;

--
-- Name: id_almidon; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_almidon
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_almidon OWNER TO postgres;

--
-- Name: almidon; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE almidon (
    id_almidon integer DEFAULT nextval('id_almidon'::regclass) NOT NULL,
    n_muestra integer,
    n_granos integer,
    morfotipo character varying,
    familia character varying,
    genero character varying,
    especie character varying,
    nombre character varying,
    observaciones character varying,
    fk_muestra_id integer,
    fk_almidon_id integer
);


ALTER TABLE almidon OWNER TO postgres;

--
-- Name: id_anomalia; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_anomalia
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_anomalia OWNER TO postgres;

--
-- Name: anomalia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE anomalia (
    id_anomalia integer DEFAULT nextval('id_anomalia'::regclass) NOT NULL,
    codigo character varying(500),
    nombre character varying,
    descripcion character varying(1500)
);


ALTER TABLE anomalia OWNER TO postgres;

--
-- Name: anomalia_rel_individuo_resto; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE anomalia_rel_individuo_resto (
    fk_anomalia_id integer NOT NULL,
    fk_individuo_resto_id integer NOT NULL
);


ALTER TABLE anomalia_rel_individuo_resto OWNER TO postgres;

--
-- Name: id_atributo_documento; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_atributo_documento
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_atributo_documento OWNER TO postgres;

--
-- Name: atributo_documento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE atributo_documento (
    id_atributo_documento integer DEFAULT nextval('id_atributo_documento'::regclass) NOT NULL,
    nombre character varying(100) NOT NULL,
    descripcion character varying(400),
    v_string character varying(1000),
    v_int integer,
    v_date date,
    v_float double precision,
    v_boolean boolean,
    fk_documento_id integer
);


ALTER TABLE atributo_documento OWNER TO postgres;

--
-- Name: id_attr_especifico; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_attr_especifico
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_attr_especifico OWNER TO postgres;

--
-- Name: attr_especifico; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE attr_especifico (
    id_attr_especifico integer DEFAULT nextval('id_attr_especifico'::regclass) NOT NULL,
    nombre character varying,
    tipo character varying
);


ALTER TABLE attr_especifico OWNER TO postgres;

--
-- Name: id_carbonate; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_carbonate
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_carbonate OWNER TO postgres;

--
-- Name: carbonate; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE carbonate (
    id_carbonate integer DEFAULT nextval('id_carbonate'::regclass) NOT NULL,
    distance_from_cervix double precision,
    s18oc double precision,
    s18oc_1sd double precision,
    s13cc double precision,
    s13cc_1sd double precision,
    comments character varying,
    fk_muestra_id integer
);


ALTER TABLE carbonate OWNER TO postgres;

--
-- Name: categoria_resto; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE categoria_resto (
    nombre character varying NOT NULL,
    descripcion character varying(1000)
);


ALTER TABLE categoria_resto OWNER TO postgres;

--
-- Name: id_categoria_resto_indice; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_categoria_resto_indice
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_categoria_resto_indice OWNER TO postgres;

--
-- Name: categoria_resto_indice; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE categoria_resto_indice (
    id_categoria_resto_indice integer DEFAULT nextval('id_categoria_resto_indice'::regclass) NOT NULL,
    fk_categoria_resto_indice_id integer,
    fk_categoria_resto_nombre character varying
);


ALTER TABLE categoria_resto_indice OWNER TO postgres;

--
-- Name: categoria_resto_rel_anomalia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE categoria_resto_rel_anomalia (
    fk_categoria_resto character varying NOT NULL,
    fk_anomalia_id integer NOT NULL,
    obligatorio boolean NOT NULL
);


ALTER TABLE categoria_resto_rel_anomalia OWNER TO postgres;

--
-- Name: coleccion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE coleccion (
    sigla character varying(30) NOT NULL,
    tipo character varying(100) NOT NULL,
    descripcion character varying(1000),
    nombre character varying(500) NOT NULL
);


ALTER TABLE coleccion OWNER TO postgres;

--
-- Name: id_collagen; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_collagen
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_collagen OWNER TO postgres;

--
-- Name: collagen; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE collagen (
    id_collagen integer DEFAULT nextval('id_collagen'::regclass) NOT NULL,
    distance_from_cervix double precision,
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
    fk_muestra_id integer
);


ALTER TABLE collagen OWNER TO postgres;

--
-- Name: id_documento; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_documento
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_documento OWNER TO postgres;

--
-- Name: documento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE documento (
    id_documento integer DEFAULT nextval('id_documento'::regclass) NOT NULL,
    version integer,
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
    signatura character varying(500)
);


ALTER TABLE documento OWNER TO postgres;

--
-- Name: documento_rel_documento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE documento_rel_documento (
    fk_documento1 integer NOT NULL,
    fk_documento2 integer NOT NULL
);


ALTER TABLE documento_rel_documento OWNER TO postgres;

--
-- Name: documento_rel_referencia_bibliografica; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE documento_rel_referencia_bibliografica (
    fk_documento_id integer NOT NULL,
    fk_referencia_bibliografica_id integer NOT NULL
);


ALTER TABLE documento_rel_referencia_bibliografica OWNER TO postgres;

--
-- Name: documento_rel_unidad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE documento_rel_unidad (
    fk_documento_id integer NOT NULL,
    fk_unidad_nombre character varying NOT NULL,
    valor double precision NOT NULL
);


ALTER TABLE documento_rel_unidad OWNER TO postgres;

--
-- Name: documento_rel_url; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE documento_rel_url (
    fk_documento_id integer NOT NULL,
    fk_url_id integer NOT NULL,
    inicio_pag integer,
    fin_pag integer
);


ALTER TABLE documento_rel_url OWNER TO postgres;

--
-- Name: edad_lote; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE edad_lote (
    nombre character varying(500) NOT NULL,
    edad character varying(500)
);


ALTER TABLE edad_lote OWNER TO postgres;

--
-- Name: id_entierro; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_entierro
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_entierro OWNER TO postgres;

--
-- Name: entierro; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE entierro (
    id_entierro integer DEFAULT nextval('id_entierro'::regclass) NOT NULL,
    nombre character varying,
    tipo character varying,
    fk_espacio_nombre character varying(250),
    estructura character varying(500),
    forma character varying(500),
    largo double precision,
    ancho double precision,
    profundidad double precision,
    fecha date,
    observaciones character varying,
    cal character varying(250),
    fk_lugar_nombre character varying,
    papv character varying(150)
);


ALTER TABLE entierro OWNER TO postgres;

--
-- Name: entierro_rel_lote; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE entierro_rel_lote (
    fk_entierro_id integer NOT NULL,
    fk_lote_id integer NOT NULL
);


ALTER TABLE entierro_rel_lote OWNER TO postgres;

--
-- Name: entierro_rel_referencia_bibliografica; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE entierro_rel_referencia_bibliografica (
    fk_entierro_id integer NOT NULL,
    fk_referencia_bibliografica_id integer NOT NULL
);


ALTER TABLE entierro_rel_referencia_bibliografica OWNER TO postgres;

--
-- Name: entierro_rel_url; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE entierro_rel_url (
    fk_entierro_id integer NOT NULL,
    fk_url_id integer NOT NULL
);


ALTER TABLE entierro_rel_url OWNER TO postgres;

--
-- Name: espacio_entierro; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE espacio_entierro (
    nombre character varying NOT NULL
);


ALTER TABLE espacio_entierro OWNER TO postgres;

--
-- Name: especie; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE especie (
    nombre character varying NOT NULL,
    descripcion character varying(1000)
);


ALTER TABLE especie OWNER TO postgres;

--
-- Name: estado; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE estado (
    tipo_cons_represen character varying NOT NULL,
    elemento character varying NOT NULL
);


ALTER TABLE estado OWNER TO postgres;

--
-- Name: estado_rel_individuo_arqueologico; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE estado_rel_individuo_arqueologico (
    fk_estado_tipo_cons_repre character varying NOT NULL,
    fk_estado_elemento character varying NOT NULL,
    fk_individuo_arqueologico_id integer NOT NULL,
    valor character varying(100) NOT NULL
);


ALTER TABLE estado_rel_individuo_arqueologico OWNER TO postgres;

--
-- Name: genero_lote; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE genero_lote (
    nombre character varying(500) NOT NULL
);


ALTER TABLE genero_lote OWNER TO postgres;

--
-- Name: id_coleccion; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_coleccion
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_coleccion OWNER TO postgres;

--
-- Name: id_individuo_arqueologico; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_individuo_arqueologico
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_individuo_arqueologico OWNER TO postgres;

--
-- Name: id_individuo_resto; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_individuo_resto
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_individuo_resto OWNER TO postgres;

--
-- Name: id_line; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_line
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_line OWNER TO postgres;

--
-- Name: id_linea; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_linea
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_linea OWNER TO postgres;

--
-- Name: id_log_acceso; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_log_acceso
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_log_acceso OWNER TO postgres;

--
-- Name: id_lote; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_lote
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_lote OWNER TO postgres;

--
-- Name: id_lote_genero_edad; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_lote_genero_edad
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_lote_genero_edad OWNER TO postgres;

--
-- Name: id_material; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_material
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_material OWNER TO postgres;

--
-- Name: id_metodo_pago; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_metodo_pago
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_metodo_pago OWNER TO postgres;

--
-- Name: id_muestra; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_muestra
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_muestra OWNER TO postgres;

--
-- Name: id_navegacion; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_navegacion
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_navegacion OWNER TO postgres;

--
-- Name: id_objeto; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_objeto
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_objeto OWNER TO postgres;

--
-- Name: id_observacion; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_observacion
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_observacion OWNER TO postgres;

--
-- Name: id_or_per_lug; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_or_per_lug
    START WITH 2
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_or_per_lug OWNER TO postgres;

--
-- Name: id_origen_persona; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_origen_persona
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_origen_persona OWNER TO postgres;

--
-- Name: id_paso_itinerario; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_paso_itinerario
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_paso_itinerario OWNER TO postgres;

--
-- Name: id_pena; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_pena
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_pena OWNER TO postgres;

--
-- Name: id_perfil_usuario; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_perfil_usuario
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_perfil_usuario OWNER TO postgres;

--
-- Name: id_permiso_navegacion; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_permiso_navegacion
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_permiso_navegacion OWNER TO postgres;

--
-- Name: id_permisos_api; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_permisos_api
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_permisos_api OWNER TO postgres;

--
-- Name: id_persona_historica; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_persona_historica
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_persona_historica OWNER TO postgres;

--
-- Name: id_persona_rol_pertenencia; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_persona_rol_pertenencia
    START WITH 2
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_persona_rol_pertenencia OWNER TO postgres;

--
-- Name: id_pertenencia; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_pertenencia
    START WITH 3
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_pertenencia OWNER TO postgres;

--
-- Name: id_phosphates; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_phosphates
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_phosphates OWNER TO postgres;

--
-- Name: id_point; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_point
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_point OWNER TO postgres;

--
-- Name: id_polygon; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_polygon
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_polygon OWNER TO postgres;

--
-- Name: id_referencia_bibliografica; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_referencia_bibliografica
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_referencia_bibliografica OWNER TO postgres;

--
-- Name: id_rel_iti_obj_trans; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_rel_iti_obj_trans
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_rel_iti_obj_trans OWNER TO postgres;

--
-- Name: id_seccion; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_seccion
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_seccion OWNER TO postgres;

--
-- Name: id_sr; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_sr
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_sr OWNER TO postgres;

--
-- Name: id_transporte; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_transporte
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_transporte OWNER TO postgres;

--
-- Name: id_url; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_url
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_url OWNER TO postgres;

--
-- Name: id_usuario; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE id_usuario
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_usuario OWNER TO postgres;

--
-- Name: individuo_arqueologico; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE individuo_arqueologico (
    id_individuo_arqueologico integer DEFAULT nextval('id_individuo_arqueologico'::regclass) NOT NULL,
    catalogo character varying(250),
    individuo character varying,
    genero character varying(250),
    edad character varying(250),
    edad_recodificada character varying(250),
    filiacion_poblacional character varying(250),
    estatura double precision,
    fecha_inicio date,
    precision_inicio character varying(5),
    fecha_fin date,
    precision_fin character varying(5),
    "13c_12c" character varying,
    codigo_14c character varying,
    unid_estratigrafica character varying(150),
    unid_estratigrafica_asociada character varying(150),
    tipo character varying,
    clase_enterramiento character varying,
    periodo character varying(250),
    cal character varying,
    descomposicion character varying,
    contenedor character varying,
    pos_extremidades_inf character varying,
    pos_extremidades_sup character varying,
    posicion_cuerpo character varying,
    orientacion_cuerpo character varying,
    orientacion_creaneo character varying
);


ALTER TABLE individuo_arqueologico OWNER TO postgres;

--
-- Name: individuo_arqueologico_rel_url; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE individuo_arqueologico_rel_url (
    fk_individuo_arqueologico_id integer NOT NULL,
    fk_url_id integer NOT NULL
);


ALTER TABLE individuo_arqueologico_rel_url OWNER TO postgres;

--
-- Name: individuo_lote_resto; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE individuo_lote_resto (
    id_individuo_resto integer DEFAULT nextval('id_individuo_resto'::regclass) NOT NULL,
    fk_resto_variable character varying,
    fk_especie_nombre character varying,
    fk_individuo_arqueologico_id integer,
    fk_entierro integer,
    cantidad_lote integer,
    fk_lote_id integer
);


ALTER TABLE individuo_lote_resto OWNER TO postgres;

--
-- Name: institucion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE institucion (
    nombre character varying NOT NULL,
    fecha_creacion date,
    descripcion character varying
);


ALTER TABLE institucion OWNER TO postgres;

--
-- Name: keyword; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE keyword (
    palabra character varying NOT NULL,
    key_indice character varying(9),
    fk_keyword character varying(100)
);


ALTER TABLE keyword OWNER TO postgres;

--
-- Name: keyword_rel_documento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE keyword_rel_documento (
    fk_keyword_palabra character varying(100) NOT NULL,
    fk_documento_id integer NOT NULL
);


ALTER TABLE keyword_rel_documento OWNER TO postgres;

--
-- Name: line; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE line (
    geom_wgs84 geometry(LineString,4326),
    id_line integer DEFAULT nextval('id_line'::regclass) NOT NULL,
    geom_nad27 geometry(LineString,26718)
);


ALTER TABLE line OWNER TO postgres;

--
-- Name: linea; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE linea (
    id_linea integer DEFAULT nextval('id_linea'::regclass) NOT NULL,
    descripcion character varying,
    estado character varying,
    calidad character varying,
    color character varying,
    cantidad integer,
    tipo_impuesto character varying,
    info_cont character varying,
    compra_nomb character varying,
    fk_material_id integer,
    fk_lugar_nombre character varying,
    fk_agrupacion_bienes_id integer,
    fk_persona_rol_pertenencia integer,
    fk_objeto_id integer NOT NULL,
    fk_entierro_id integer,
    fk_individuo_arqueologico integer
);


ALTER TABLE linea OWNER TO postgres;

--
-- Name: linea_rel_unidad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE linea_rel_unidad (
    fk_linea_id integer NOT NULL,
    fk_unidad_nombre character varying NOT NULL,
    valor double precision NOT NULL
);


ALTER TABLE linea_rel_unidad OWNER TO postgres;

--
-- Name: log_acceso; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE log_acceso (
    id_log_acceso integer DEFAULT nextval('id_log_acceso'::regclass) NOT NULL,
    inicio_sesion timestamp with time zone,
    fin_sesion timestamp with time zone,
    fk_usuario integer,
    fecha date,
    ip integer,
    token character varying
);


ALTER TABLE log_acceso OWNER TO postgres;

--
-- Name: lote; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE lote (
    id_lote integer DEFAULT nextval('id_lote'::regclass) NOT NULL,
    tipo character varying,
    nmi integer,
    estructura_nmi character varying,
    observaciones character varying,
    unid_estratigrafica character varying(150)
);


ALTER TABLE lote OWNER TO postgres;

--
-- Name: lote_genero_edad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE lote_genero_edad (
    fk_lote_id integer NOT NULL,
    fk_genero_lote_nombre character varying(500) NOT NULL,
    fk_edad_lote_nombre character varying(500) NOT NULL,
    cantidad integer
);


ALTER TABLE lote_genero_edad OWNER TO postgres;

--
-- Name: lote_rel_url; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE lote_rel_url (
    fk_lote_id integer NOT NULL,
    fk_url_id integer NOT NULL
);


ALTER TABLE lote_rel_url OWNER TO postgres;

--
-- Name: lugar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE lugar (
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
    fk_lugar_nombre character varying,
    fk_polygon_id integer,
    fk_line_id integer,
    fk_point_id integer
);


ALTER TABLE lugar OWNER TO postgres;

--
-- Name: material; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE material (
    id_material integer DEFAULT nextval('id_material'::regclass) NOT NULL,
    nombre character varying NOT NULL,
    fk_material_id integer
);


ALTER TABLE material OWNER TO postgres;

--
-- Name: metodo_pago; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE metodo_pago (
    id_metodo_pago integer DEFAULT nextval('id_metodo_pago'::regclass) NOT NULL,
    tipo character varying(500),
    plazo_credito character varying(500),
    interes_credito character varying(500)
);


ALTER TABLE metodo_pago OWNER TO postgres;

--
-- Name: miembro; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE miembro (
    texto character varying NOT NULL
);


ALTER TABLE miembro OWNER TO postgres;

--
-- Name: TABLE miembro; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE miembro IS 'Tabla para indicar los miembros perdidos en una pena de sentencia';


--
-- Name: muestra; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE muestra (
    id_muestra integer DEFAULT nextval('id_muestra'::regclass) NOT NULL,
    fecha date,
    num_muestra integer,
    afiliacion_cronologica character varying,
    grabadora character varying(150),
    preservacion_general character varying(500),
    particulas_sedimento character varying(500),
    microgrietas character varying(500),
    consistencia character varying(500),
    color character varying(500),
    observaciones character varying,
    nombre character varying,
    sub_nombre character varying,
    material character varying,
    altura_corona double precision,
    abrasion_dental character varying(500),
    superficie character varying(500),
    estado character varying,
    fk_individuo_resto_id integer
);


ALTER TABLE muestra OWNER TO postgres;

--
-- Name: muestra_rel_url; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE muestra_rel_url (
    fk_muestra_id integer NOT NULL,
    fk_url_id integer NOT NULL
);


ALTER TABLE muestra_rel_url OWNER TO postgres;

--
-- Name: navegacion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE navegacion (
    id_navegacion integer DEFAULT nextval('id_navegacion'::regclass) NOT NULL,
    fecha_inicio date,
    precision_inicio character varying(5),
    fecha_fin date,
    precision_fin character varying(5),
    motivo character varying,
    fk_documento_id integer
);


ALTER TABLE navegacion OWNER TO postgres;

--
-- Name: navegacion_rel_agrupacion_bienes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE navegacion_rel_agrupacion_bienes (
    fk_navegacion_id integer NOT NULL,
    fk_agrupacion_bienes_id integer NOT NULL
);


ALTER TABLE navegacion_rel_agrupacion_bienes OWNER TO postgres;

--
-- Name: navegacion_rel_persona_rol_pertenencia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE navegacion_rel_persona_rol_pertenencia (
    fk_persona_rol_pertenencia_id integer NOT NULL,
    fk_navegacion_id integer NOT NULL
);


ALTER TABLE navegacion_rel_persona_rol_pertenencia OWNER TO postgres;

--
-- Name: navegacion_rel_transporte; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE navegacion_rel_transporte (
    fk_navegacion_id integer NOT NULL,
    fk_transporte_id integer NOT NULL,
    tipo_navegacion character varying
);


ALTER TABLE navegacion_rel_transporte OWNER TO postgres;

--
-- Name: objeto; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE objeto (
    id_objeto integer DEFAULT nextval('id_objeto'::regclass) NOT NULL,
    tipo character varying,
    nombre character varying,
    fk_objeto_id integer
);


ALTER TABLE objeto OWNER TO postgres;

--
-- Name: observacion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE observacion (
    id_observacion integer DEFAULT nextval('id_observacion'::regclass) NOT NULL,
    texto character varying,
    fk_documento integer
);


ALTER TABLE observacion OWNER TO postgres;

--
-- Name: or_per_lug; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE or_per_lug (
    id_or_per_lug integer DEFAULT nextval('id_or_per_lug'::regclass) NOT NULL,
    fk_origen_persona_id integer NOT NULL,
    fk_lugar_nombre character varying NOT NULL,
    fk_persona_rol_pertenencia_id integer NOT NULL
);


ALTER TABLE or_per_lug OWNER TO postgres;

--
-- Name: origen_persona; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE origen_persona (
    id_origen_persona integer DEFAULT nextval('id_origen_persona'::regclass) NOT NULL,
    nombre character varying,
    descripcion character varying,
    fk_origen_persona_id integer
);


ALTER TABLE origen_persona OWNER TO postgres;

--
-- Name: paso_itinerario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE paso_itinerario (
    id_paso_itinerario integer DEFAULT nextval('id_paso_itinerario'::regclass) NOT NULL,
    "precision" character varying,
    fecha date,
    tipo character varying,
    descripcion character varying,
    fk_navegacion_id integer,
    fk_lugar_nombre character varying
);


ALTER TABLE paso_itinerario OWNER TO postgres;

--
-- Name: pena; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE pena (
    id_pena integer DEFAULT nextval('id_pena'::regclass) NOT NULL,
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


ALTER TABLE pena OWNER TO postgres;

--
-- Name: pena_rel_miembro; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE pena_rel_miembro (
    fk_pena_id integer NOT NULL,
    fk_miembro_texto character varying NOT NULL
);


ALTER TABLE pena_rel_miembro OWNER TO postgres;

--
-- Name: pena_rel_unidad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE pena_rel_unidad (
    fk_pena_id integer NOT NULL,
    fk_unidad_nombre character varying NOT NULL,
    valor double precision NOT NULL
);


ALTER TABLE pena_rel_unidad OWNER TO postgres;

--
-- Name: perfil_usuario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE perfil_usuario (
    id_perfil_usuario integer DEFAULT nextval('id_perfil_usuario'::regclass) NOT NULL,
    nombre character varying(500),
    descripcion character varying(1000)
);


ALTER TABLE perfil_usuario OWNER TO postgres;

--
-- Name: perfil_usuario_rel_permisos_api; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE perfil_usuario_rel_permisos_api (
    fk_perfil_usuario integer NOT NULL,
    fk_permisos_api integer NOT NULL
);


ALTER TABLE perfil_usuario_rel_permisos_api OWNER TO postgres;

--
-- Name: permiso_navegacion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE permiso_navegacion (
    id_permiso_navegacion integer DEFAULT nextval('id_permiso_navegacion'::regclass) NOT NULL,
    lugar_emision character varying,
    fecha_emision date,
    puerto_salida character varying,
    puerto_llegada character varying,
    mercancias character varying,
    autoridad character varying(500),
    observacion character varying,
    fk_navegacion_id integer
);


ALTER TABLE permiso_navegacion OWNER TO postgres;

--
-- Name: permisos_api; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE permisos_api (
    id_permisos_api integer DEFAULT nextval('id_permisos_api'::regclass) NOT NULL,
    nombre character varying(250) NOT NULL,
    crear boolean,
    borrar boolean,
    modificar boolean,
    lectura boolean
);


ALTER TABLE permisos_api OWNER TO postgres;

--
-- Name: persona_historica; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE persona_historica (
    id_persona_historica integer DEFAULT nextval('id_persona_historica'::regclass) NOT NULL,
    nombre character varying NOT NULL,
    genero character varying(250),
    fk_persona_historica integer,
    fk_individuo_arqueologico_id integer
);


ALTER TABLE persona_historica OWNER TO postgres;

--
-- Name: persona_rol_pertenencia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE persona_rol_pertenencia (
    id_persona_rol_pertenencia integer DEFAULT nextval('id_persona_rol_pertenencia'::regclass) NOT NULL,
    edad_min integer,
    edad_max integer,
    oficio character varying,
    descripcion character varying,
    edad_recodificada character varying(200),
    fk_rol_nombre character varying,
    fk_persona_historica_id integer,
    fk_institucion_nombre character varying,
    fk_pertenencia_id integer,
    fk_persona_rol_pertenencia_id integer
);


ALTER TABLE persona_rol_pertenencia OWNER TO postgres;

--
-- Name: pertenencia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE pertenencia (
    id_pertenencia integer NOT NULL,
    fecha_inicio date,
    fecha_fin date,
    precision_inicio character varying(5),
    precision_fin character varying(5),
    motivo character varying,
    orden integer,
    tipo_atr_doc character varying(500),
    fk_documento_id integer,
    fk_pertenencia_id integer
);


ALTER TABLE pertenencia OWNER TO postgres;

--
-- Name: pertenencia_rel_agrupacion_bienes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE pertenencia_rel_agrupacion_bienes (
    fk_pertenencia_id integer NOT NULL,
    fk_agrupacion_bienes_id integer NOT NULL
);


ALTER TABLE pertenencia_rel_agrupacion_bienes OWNER TO postgres;

--
-- Name: pertenencia_rel_attr_especifico; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE pertenencia_rel_attr_especifico (
    fk_pertenencia_id integer NOT NULL,
    fk_attr_especifico_id integer NOT NULL
);


ALTER TABLE pertenencia_rel_attr_especifico OWNER TO postgres;

--
-- Name: pertenencia_rel_lugar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE pertenencia_rel_lugar (
    fk_pertenencia_id integer NOT NULL,
    fk_lugar_nombre character varying NOT NULL,
    tipo_lugar character varying,
    "precision" character varying(250),
    fk_tipo_lugar_nombre character varying
);


ALTER TABLE pertenencia_rel_lugar OWNER TO postgres;

--
-- Name: phosphates; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE phosphates (
    id_phosphates integer DEFAULT nextval('id_phosphates'::regclass) NOT NULL,
    distance_from_cervix double precision,
    phosphate_yield double precision,
    s18op double precision,
    s18op_1sd double precision,
    comments character varying,
    fk_muestra_id integer
);


ALTER TABLE phosphates OWNER TO postgres;

--
-- Name: point; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE point (
    geom_wgs84 geometry(Point,4326),
    id_point integer DEFAULT nextval('id_point'::regclass) NOT NULL,
    geom_nad27 geometry(Point,26718)
);


ALTER TABLE point OWNER TO postgres;

--
-- Name: polygon; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE polygon (
    geom_wgs84 geometry(Polygon,4326),
    id_polygon integer DEFAULT nextval('id_polygon'::regclass) NOT NULL,
    geom_nad27 geometry(Polygon,26718)
);


ALTER TABLE polygon OWNER TO postgres;

--
-- Name: proyecto; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE proyecto (
    nombre character varying NOT NULL,
    descripcion character varying(500)
);


ALTER TABLE proyecto OWNER TO postgres;

--
-- Name: proyecto_rel_documento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE proyecto_rel_documento (
    fk_proyecto_nombre character varying NOT NULL,
    fk_documento_id integer NOT NULL
);


ALTER TABLE proyecto_rel_documento OWNER TO postgres;

--
-- Name: referencia_bibliografica; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE referencia_bibliografica (
    id_referencia_bibliografica integer DEFAULT nextval('id_referencia_bibliografica'::regclass) NOT NULL,
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


ALTER TABLE referencia_bibliografica OWNER TO postgres;

--
-- Name: rel_iti_obj_trans; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE rel_iti_obj_trans (
    id_rel_iti_obj_trans integer DEFAULT nextval('id_rel_iti_obj_trans'::regclass) NOT NULL,
    fk_paso_itinerario_id integer,
    fk_transporte_id integer,
    fk_agrupacion_bienes_id integer
);


ALTER TABLE rel_iti_obj_trans OWNER TO postgres;

--
-- Name: resto; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE resto (
    variable character varying NOT NULL,
    nombre character varying,
    avatar character varying
);


ALTER TABLE resto OWNER TO postgres;

--
-- Name: resto_rel_categoria_resto_indice; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE resto_rel_categoria_resto_indice (
    fk_resto_variable character varying NOT NULL,
    fk_categoria_resto_indice_id integer NOT NULL
);


ALTER TABLE resto_rel_categoria_resto_indice OWNER TO postgres;

--
-- Name: rol; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE rol (
    nombre character varying NOT NULL,
    descripcion character varying(500)
);


ALTER TABLE rol OWNER TO postgres;

--
-- Name: seccion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE seccion (
    nombre character varying NOT NULL,
    descripcion character varying(1000),
    fk_coleccion character varying(300) NOT NULL,
    id_seccion integer DEFAULT nextval('id_seccion'::regclass) NOT NULL
);


ALTER TABLE seccion OWNER TO postgres;

--
-- Name: sr; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE sr (
    id_sr integer DEFAULT nextval('id_sr'::regclass) NOT NULL,
    distance_from_cervix double precision,
    sr_concentration double precision,
    "87sr_86sr" double precision,
    "87sr_86sr_2sd" double precision,
    comments character varying,
    fk_muestra_id integer NOT NULL
);


ALTER TABLE sr OWNER TO postgres;

--
-- Name: tipo_lugar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE tipo_lugar (
    nombre character varying NOT NULL
);


ALTER TABLE tipo_lugar OWNER TO postgres;

--
-- Name: tipo_transporte; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE tipo_transporte (
    nombre_tipo character varying(1500) NOT NULL,
    descripcion character varying(2500)
);


ALTER TABLE tipo_transporte OWNER TO postgres;

--
-- Name: transporte; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE transporte (
    id_transporte integer DEFAULT nextval('id_transporte'::regclass) NOT NULL,
    tipo character varying(500),
    nombre character varying,
    tonelaje character varying(250),
    bandera character varying(500),
    observaciones character varying(1000),
    fk_transporte_id integer,
    fk_tipo_transporte character varying
);


ALTER TABLE transporte OWNER TO postgres;

--
-- Name: transporte_rel_objeto; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE transporte_rel_objeto (
    fk_transporte_id integer NOT NULL,
    fk_objeto_id integer NOT NULL
);


ALTER TABLE transporte_rel_objeto OWNER TO postgres;

--
-- Name: unidad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE unidad (
    nombre character varying NOT NULL,
    tipo character varying(500)
);


ALTER TABLE unidad OWNER TO postgres;

--
-- Name: url; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE url (
    id_url integer DEFAULT nextval('id_url'::regclass) NOT NULL,
    url character varying,
    tipo character varying(250),
    descripcion character varying,
    motivo_conf character varying(250)
);


ALTER TABLE url OWNER TO postgres;

--
-- Name: usuario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE usuario (
    id_usuario integer DEFAULT nextval('id_usuario'::regclass) NOT NULL,
    nombre character varying NOT NULL,
    apellidos character varying(250),
    institucion character varying(500),
    departamento character varying(250),
    posicion character varying(250),
    estado character varying(250),
    password character varying,
    avatar character varying,
    email character varying(500),
    email_adicional character varying(500),
    biografia character varying,
    telefono integer,
    skype character varying(250),
    dni character varying(30),
    fk_perfil_usuario integer
);


ALTER TABLE usuario OWNER TO postgres;

--
-- Data for Name: adn; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY adn (id_adn, library_id, collection_num, site_name, archeology, id2, material, c14, date_interval, haplotype, haplogroup, raw_reads, marged_reads, mapped_reads, duplicate_removal_mapp, average_coverage, "3_deamination", "5_deamination", insert_size, contamination_estimate, fk_muestra_id) FROM stdin;
\.
COPY adn (id_adn, library_id, collection_num, site_name, archeology, id2, material, c14, date_interval, haplotype, haplogroup, raw_reads, marged_reads, mapped_reads, duplicate_removal_mapp, average_coverage, "3_deamination", "5_deamination", insert_size, contamination_estimate, fk_muestra_id) FROM '/usr/src/api/db/initial/4360.dat';

--
-- Data for Name: agrupacion_bienes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY agrupacion_bienes (id_agrupacion_bienes, nombre, fecha, precision_fecha, adelanto_cont, descripcion_cont, folio_cont, fk_metodo_pago_id, fk_lugar_nombre) FROM stdin;
\.
COPY agrupacion_bienes (id_agrupacion_bienes, nombre, fecha, precision_fecha, adelanto_cont, descripcion_cont, folio_cont, fk_metodo_pago_id, fk_lugar_nombre) FROM '/usr/src/api/db/initial/4362.dat';

--
-- Data for Name: agrupacion_bienes_rel_unidad; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY agrupacion_bienes_rel_unidad (fk_agrupacion_bienes_id, fk_unidad_nombre, valor) FROM stdin;
\.
COPY agrupacion_bienes_rel_unidad (fk_agrupacion_bienes_id, fk_unidad_nombre, valor) FROM '/usr/src/api/db/initial/4363.dat';

--
-- Data for Name: almidon; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY almidon (id_almidon, n_muestra, n_granos, morfotipo, familia, genero, especie, nombre, observaciones, fk_muestra_id, fk_almidon_id) FROM stdin;
\.
COPY almidon (id_almidon, n_muestra, n_granos, morfotipo, familia, genero, especie, nombre, observaciones, fk_muestra_id, fk_almidon_id) FROM '/usr/src/api/db/initial/4365.dat';

--
-- Data for Name: anomalia; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY anomalia (id_anomalia, codigo, nombre, descripcion) FROM stdin;
\.
COPY anomalia (id_anomalia, codigo, nombre, descripcion) FROM '/usr/src/api/db/initial/4367.dat';

--
-- Data for Name: anomalia_rel_individuo_resto; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY anomalia_rel_individuo_resto (fk_anomalia_id, fk_individuo_resto_id) FROM stdin;
\.
COPY anomalia_rel_individuo_resto (fk_anomalia_id, fk_individuo_resto_id) FROM '/usr/src/api/db/initial/4368.dat';

--
-- Data for Name: atributo_documento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY atributo_documento (id_atributo_documento, nombre, descripcion, v_string, v_int, v_date, v_float, v_boolean, fk_documento_id) FROM stdin;
\.
COPY atributo_documento (id_atributo_documento, nombre, descripcion, v_string, v_int, v_date, v_float, v_boolean, fk_documento_id) FROM '/usr/src/api/db/initial/4370.dat';

--
-- Data for Name: attr_especifico; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY attr_especifico (id_attr_especifico, nombre, tipo) FROM stdin;
\.
COPY attr_especifico (id_attr_especifico, nombre, tipo) FROM '/usr/src/api/db/initial/4372.dat';

--
-- Data for Name: carbonate; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY carbonate (id_carbonate, distance_from_cervix, s18oc, s18oc_1sd, s13cc, s13cc_1sd, comments, fk_muestra_id) FROM stdin;
\.
COPY carbonate (id_carbonate, distance_from_cervix, s18oc, s18oc_1sd, s13cc, s13cc_1sd, comments, fk_muestra_id) FROM '/usr/src/api/db/initial/4374.dat';

--
-- Data for Name: categoria_resto; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY categoria_resto (nombre, descripcion) FROM stdin;
\.
COPY categoria_resto (nombre, descripcion) FROM '/usr/src/api/db/initial/4375.dat';

--
-- Data for Name: categoria_resto_indice; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY categoria_resto_indice (id_categoria_resto_indice, fk_categoria_resto_indice_id, fk_categoria_resto_nombre) FROM stdin;
\.
COPY categoria_resto_indice (id_categoria_resto_indice, fk_categoria_resto_indice_id, fk_categoria_resto_nombre) FROM '/usr/src/api/db/initial/4377.dat';

--
-- Data for Name: categoria_resto_rel_anomalia; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY categoria_resto_rel_anomalia (fk_categoria_resto, fk_anomalia_id, obligatorio) FROM stdin;
\.
COPY categoria_resto_rel_anomalia (fk_categoria_resto, fk_anomalia_id, obligatorio) FROM '/usr/src/api/db/initial/4378.dat';

--
-- Data for Name: coleccion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY coleccion (sigla, tipo, descripcion, nombre) FROM stdin;
\.
COPY coleccion (sigla, tipo, descripcion, nombre) FROM '/usr/src/api/db/initial/4379.dat';

--
-- Data for Name: collagen; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY collagen (id_collagen, distance_from_cervix, collagen_yield, cp, cp_1sd, np, np_1sd, atomic_cn_ratio, s13_ccoll, s13_ccoll_1sd, s15_ncoll, s15_ncoll_1sd, quality_criteria, quality_comment, comments, fk_muestra_id) FROM stdin;
\.
COPY collagen (id_collagen, distance_from_cervix, collagen_yield, cp, cp_1sd, np, np_1sd, atomic_cn_ratio, s13_ccoll, s13_ccoll_1sd, s15_ncoll, s15_ncoll_1sd, quality_criteria, quality_comment, comments, fk_muestra_id) FROM '/usr/src/api/db/initial/4381.dat';

--
-- Data for Name: documento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY documento (id_documento, version, titulo, foliado, des_foliado, firmada, holografa, resumen, transcripcion, transcripcion_tipo, adelanto_cont, soporte, migracion, fecha_confi_datos, fecha_confi_img, tipo, subtipo, motivo_almoneda, preambulo_testamento, disp_ente_testamento, diligencias_visita, fk_usuario_id, fk_seccion_id, fk_pena_id, signatura) FROM stdin;
\.
COPY documento (id_documento, version, titulo, foliado, des_foliado, firmada, holografa, resumen, transcripcion, transcripcion_tipo, adelanto_cont, soporte, migracion, fecha_confi_datos, fecha_confi_img, tipo, subtipo, motivo_almoneda, preambulo_testamento, disp_ente_testamento, diligencias_visita, fk_usuario_id, fk_seccion_id, fk_pena_id, signatura) FROM '/usr/src/api/db/initial/4383.dat';

--
-- Data for Name: documento_rel_documento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY documento_rel_documento (fk_documento1, fk_documento2) FROM stdin;
\.
COPY documento_rel_documento (fk_documento1, fk_documento2) FROM '/usr/src/api/db/initial/4384.dat';

--
-- Data for Name: documento_rel_referencia_bibliografica; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY documento_rel_referencia_bibliografica (fk_documento_id, fk_referencia_bibliografica_id) FROM stdin;
\.
COPY documento_rel_referencia_bibliografica (fk_documento_id, fk_referencia_bibliografica_id) FROM '/usr/src/api/db/initial/4385.dat';

--
-- Data for Name: documento_rel_unidad; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY documento_rel_unidad (fk_documento_id, fk_unidad_nombre, valor) FROM stdin;
\.
COPY documento_rel_unidad (fk_documento_id, fk_unidad_nombre, valor) FROM '/usr/src/api/db/initial/4386.dat';

--
-- Data for Name: documento_rel_url; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY documento_rel_url (fk_documento_id, fk_url_id, inicio_pag, fin_pag) FROM stdin;
\.
COPY documento_rel_url (fk_documento_id, fk_url_id, inicio_pag, fin_pag) FROM '/usr/src/api/db/initial/4387.dat';

--
-- Data for Name: edad_lote; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY edad_lote (nombre, edad) FROM stdin;
\.
COPY edad_lote (nombre, edad) FROM '/usr/src/api/db/initial/4388.dat';

--
-- Data for Name: entierro; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY entierro (id_entierro, nombre, tipo, fk_espacio_nombre, estructura, forma, largo, ancho, profundidad, fecha, observaciones, cal, fk_lugar_nombre, papv) FROM stdin;
\.
COPY entierro (id_entierro, nombre, tipo, fk_espacio_nombre, estructura, forma, largo, ancho, profundidad, fecha, observaciones, cal, fk_lugar_nombre, papv) FROM '/usr/src/api/db/initial/4390.dat';

--
-- Data for Name: entierro_rel_lote; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY entierro_rel_lote (fk_entierro_id, fk_lote_id) FROM stdin;
\.
COPY entierro_rel_lote (fk_entierro_id, fk_lote_id) FROM '/usr/src/api/db/initial/4391.dat';

--
-- Data for Name: entierro_rel_referencia_bibliografica; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY entierro_rel_referencia_bibliografica (fk_entierro_id, fk_referencia_bibliografica_id) FROM stdin;
\.
COPY entierro_rel_referencia_bibliografica (fk_entierro_id, fk_referencia_bibliografica_id) FROM '/usr/src/api/db/initial/4392.dat';

--
-- Data for Name: entierro_rel_url; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY entierro_rel_url (fk_entierro_id, fk_url_id) FROM stdin;
\.
COPY entierro_rel_url (fk_entierro_id, fk_url_id) FROM '/usr/src/api/db/initial/4393.dat';

--
-- Data for Name: espacio_entierro; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY espacio_entierro (nombre) FROM stdin;
\.
COPY espacio_entierro (nombre) FROM '/usr/src/api/db/initial/4492.dat';

--
-- Data for Name: especie; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY especie (nombre, descripcion) FROM stdin;
\.
COPY especie (nombre, descripcion) FROM '/usr/src/api/db/initial/4394.dat';

--
-- Data for Name: estado; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY estado (tipo_cons_represen, elemento) FROM stdin;
\.
COPY estado (tipo_cons_represen, elemento) FROM '/usr/src/api/db/initial/4395.dat';

--
-- Data for Name: estado_rel_individuo_arqueologico; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY estado_rel_individuo_arqueologico (fk_estado_tipo_cons_repre, fk_estado_elemento, fk_individuo_arqueologico_id, valor) FROM stdin;
\.
COPY estado_rel_individuo_arqueologico (fk_estado_tipo_cons_repre, fk_estado_elemento, fk_individuo_arqueologico_id, valor) FROM '/usr/src/api/db/initial/4396.dat';

--
-- Data for Name: genero_lote; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY genero_lote (nombre) FROM stdin;
\.
COPY genero_lote (nombre) FROM '/usr/src/api/db/initial/4397.dat';

--
-- Name: id_adn; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_adn', 1, false);


--
-- Name: id_agrupacion_bienes; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_agrupacion_bienes', 1, false);


--
-- Name: id_almidon; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_almidon', 1, false);


--
-- Name: id_anomalia; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_anomalia', 1, false);


--
-- Name: id_atributo_documento; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_atributo_documento', 1, false);


--
-- Name: id_attr_especifico; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_attr_especifico', 1, false);


--
-- Name: id_carbonate; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_carbonate', 1, false);


--
-- Name: id_categoria_resto_indice; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_categoria_resto_indice', 1, false);


--
-- Name: id_coleccion; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_coleccion', 1, false);


--
-- Name: id_collagen; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_collagen', 1, false);


--
-- Name: id_documento; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_documento', 1, false);


--
-- Name: id_entierro; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_entierro', 1, false);


--
-- Name: id_individuo_arqueologico; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_individuo_arqueologico', 1, false);


--
-- Name: id_individuo_resto; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_individuo_resto', 1, false);


--
-- Name: id_line; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_line', 1, false);


--
-- Name: id_linea; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_linea', 1, false);


--
-- Name: id_log_acceso; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_log_acceso', 1, false);


--
-- Name: id_lote; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_lote', 1, false);


--
-- Name: id_lote_genero_edad; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_lote_genero_edad', 1, false);


--
-- Name: id_material; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_material', 1, false);


--
-- Name: id_metodo_pago; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_metodo_pago', 1, false);


--
-- Name: id_muestra; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_muestra', 1, false);


--
-- Name: id_navegacion; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_navegacion', 1, false);


--
-- Name: id_objeto; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_objeto', 1, false);


--
-- Name: id_observacion; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_observacion', 1, false);


--
-- Name: id_or_per_lug; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_or_per_lug', 2, false);


--
-- Name: id_origen_persona; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_origen_persona', 1, false);


--
-- Name: id_paso_itinerario; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_paso_itinerario', 1, false);


--
-- Name: id_pena; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_pena', 1, false);


--
-- Name: id_perfil_usuario; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_perfil_usuario', 1, false);


--
-- Name: id_permiso_navegacion; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_permiso_navegacion', 1, false);


--
-- Name: id_permisos_api; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_permisos_api', 1, false);


--
-- Name: id_persona_historica; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_persona_historica', 1, false);


--
-- Name: id_persona_rol_pertenencia; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_persona_rol_pertenencia', 2, false);


--
-- Name: id_pertenencia; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_pertenencia', 3, false);


--
-- Name: id_phosphates; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_phosphates', 1, false);


--
-- Name: id_point; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_point', 1, false);


--
-- Name: id_polygon; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_polygon', 1, false);


--
-- Name: id_referencia_bibliografica; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_referencia_bibliografica', 1, false);


--
-- Name: id_rel_iti_obj_trans; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_rel_iti_obj_trans', 1, false);


--
-- Name: id_seccion; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_seccion', 1, false);


--
-- Name: id_sr; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_sr', 1, false);


--
-- Name: id_transporte; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_transporte', 1, false);


--
-- Name: id_url; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_url', 1, false);


--
-- Name: id_usuario; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('id_usuario', 1, false);


--
-- Data for Name: individuo_arqueologico; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY individuo_arqueologico (id_individuo_arqueologico, catalogo, individuo, genero, edad, edad_recodificada, filiacion_poblacional, estatura, fecha_inicio, precision_inicio, fecha_fin, precision_fin, "13c_12c", codigo_14c, unid_estratigrafica, unid_estratigrafica_asociada, tipo, clase_enterramiento, periodo, cal, descomposicion, contenedor, pos_extremidades_inf, pos_extremidades_sup, posicion_cuerpo, orientacion_cuerpo, orientacion_creaneo) FROM stdin;
\.
COPY individuo_arqueologico (id_individuo_arqueologico, catalogo, individuo, genero, edad, edad_recodificada, filiacion_poblacional, estatura, fecha_inicio, precision_inicio, fecha_fin, precision_fin, "13c_12c", codigo_14c, unid_estratigrafica, unid_estratigrafica_asociada, tipo, clase_enterramiento, periodo, cal, descomposicion, contenedor, pos_extremidades_inf, pos_extremidades_sup, posicion_cuerpo, orientacion_cuerpo, orientacion_creaneo) FROM '/usr/src/api/db/initial/4432.dat';

--
-- Data for Name: individuo_arqueologico_rel_url; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY individuo_arqueologico_rel_url (fk_individuo_arqueologico_id, fk_url_id) FROM stdin;
\.
COPY individuo_arqueologico_rel_url (fk_individuo_arqueologico_id, fk_url_id) FROM '/usr/src/api/db/initial/4433.dat';

--
-- Data for Name: individuo_lote_resto; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY individuo_lote_resto (id_individuo_resto, fk_resto_variable, fk_especie_nombre, fk_individuo_arqueologico_id, fk_entierro, cantidad_lote, fk_lote_id) FROM stdin;
\.
COPY individuo_lote_resto (id_individuo_resto, fk_resto_variable, fk_especie_nombre, fk_individuo_arqueologico_id, fk_entierro, cantidad_lote, fk_lote_id) FROM '/usr/src/api/db/initial/4434.dat';

--
-- Data for Name: institucion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY institucion (nombre, fecha_creacion, descripcion) FROM stdin;
\.
COPY institucion (nombre, fecha_creacion, descripcion) FROM '/usr/src/api/db/initial/4435.dat';

--
-- Data for Name: keyword; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY keyword (palabra, key_indice, fk_keyword) FROM stdin;
\.
COPY keyword (palabra, key_indice, fk_keyword) FROM '/usr/src/api/db/initial/4436.dat';

--
-- Data for Name: keyword_rel_documento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY keyword_rel_documento (fk_keyword_palabra, fk_documento_id) FROM stdin;
\.
COPY keyword_rel_documento (fk_keyword_palabra, fk_documento_id) FROM '/usr/src/api/db/initial/4437.dat';

--
-- Data for Name: line; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY line (geom_wgs84, id_line, geom_nad27) FROM stdin;
\.
COPY line (geom_wgs84, id_line, geom_nad27) FROM '/usr/src/api/db/initial/4438.dat';

--
-- Data for Name: linea; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY linea (id_linea, descripcion, estado, calidad, color, cantidad, tipo_impuesto, info_cont, compra_nomb, fk_material_id, fk_lugar_nombre, fk_agrupacion_bienes_id, fk_persona_rol_pertenencia, fk_objeto_id, fk_entierro_id, fk_individuo_arqueologico) FROM stdin;
\.
COPY linea (id_linea, descripcion, estado, calidad, color, cantidad, tipo_impuesto, info_cont, compra_nomb, fk_material_id, fk_lugar_nombre, fk_agrupacion_bienes_id, fk_persona_rol_pertenencia, fk_objeto_id, fk_entierro_id, fk_individuo_arqueologico) FROM '/usr/src/api/db/initial/4439.dat';

--
-- Data for Name: linea_rel_unidad; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY linea_rel_unidad (fk_linea_id, fk_unidad_nombre, valor) FROM stdin;
\.
COPY linea_rel_unidad (fk_linea_id, fk_unidad_nombre, valor) FROM '/usr/src/api/db/initial/4440.dat';

--
-- Data for Name: log_acceso; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY log_acceso (id_log_acceso, inicio_sesion, fin_sesion, fk_usuario, fecha, ip, token) FROM stdin;
\.
COPY log_acceso (id_log_acceso, inicio_sesion, fin_sesion, fk_usuario, fecha, ip, token) FROM '/usr/src/api/db/initial/4441.dat';

--
-- Data for Name: lote; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY lote (id_lote, tipo, nmi, estructura_nmi, observaciones, unid_estratigrafica) FROM stdin;
\.
COPY lote (id_lote, tipo, nmi, estructura_nmi, observaciones, unid_estratigrafica) FROM '/usr/src/api/db/initial/4442.dat';

--
-- Data for Name: lote_genero_edad; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY lote_genero_edad (fk_lote_id, fk_genero_lote_nombre, fk_edad_lote_nombre, cantidad) FROM stdin;
\.
COPY lote_genero_edad (fk_lote_id, fk_genero_lote_nombre, fk_edad_lote_nombre, cantidad) FROM '/usr/src/api/db/initial/4443.dat';

--
-- Data for Name: lote_rel_url; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY lote_rel_url (fk_lote_id, fk_url_id) FROM stdin;
\.
COPY lote_rel_url (fk_lote_id, fk_url_id) FROM '/usr/src/api/db/initial/4444.dat';

--
-- Data for Name: lugar; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY lugar (nombre, region_cont, localizacion, longitud, latitud, sistema_ref, coor_macro, coor_micro, zona, hemisferio, fk_lugar_nombre, fk_polygon_id, fk_line_id, fk_point_id) FROM stdin;
\.
COPY lugar (nombre, region_cont, localizacion, longitud, latitud, sistema_ref, coor_macro, coor_micro, zona, hemisferio, fk_lugar_nombre, fk_polygon_id, fk_line_id, fk_point_id) FROM '/usr/src/api/db/initial/4445.dat';

--
-- Data for Name: material; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY material (id_material, nombre, fk_material_id) FROM stdin;
\.
COPY material (id_material, nombre, fk_material_id) FROM '/usr/src/api/db/initial/4446.dat';

--
-- Data for Name: metodo_pago; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY metodo_pago (id_metodo_pago, tipo, plazo_credito, interes_credito) FROM stdin;
\.
COPY metodo_pago (id_metodo_pago, tipo, plazo_credito, interes_credito) FROM '/usr/src/api/db/initial/4447.dat';

--
-- Data for Name: miembro; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY miembro (texto) FROM stdin;
\.
COPY miembro (texto) FROM '/usr/src/api/db/initial/4448.dat';

--
-- Data for Name: muestra; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY muestra (id_muestra, fecha, num_muestra, afiliacion_cronologica, grabadora, preservacion_general, particulas_sedimento, microgrietas, consistencia, color, observaciones, nombre, sub_nombre, material, altura_corona, abrasion_dental, superficie, estado, fk_individuo_resto_id) FROM stdin;
\.
COPY muestra (id_muestra, fecha, num_muestra, afiliacion_cronologica, grabadora, preservacion_general, particulas_sedimento, microgrietas, consistencia, color, observaciones, nombre, sub_nombre, material, altura_corona, abrasion_dental, superficie, estado, fk_individuo_resto_id) FROM '/usr/src/api/db/initial/4449.dat';

--
-- Data for Name: muestra_rel_url; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY muestra_rel_url (fk_muestra_id, fk_url_id) FROM stdin;
\.
COPY muestra_rel_url (fk_muestra_id, fk_url_id) FROM '/usr/src/api/db/initial/4450.dat';

--
-- Data for Name: navegacion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY navegacion (id_navegacion, fecha_inicio, precision_inicio, fecha_fin, precision_fin, motivo, fk_documento_id) FROM stdin;
\.
COPY navegacion (id_navegacion, fecha_inicio, precision_inicio, fecha_fin, precision_fin, motivo, fk_documento_id) FROM '/usr/src/api/db/initial/4451.dat';

--
-- Data for Name: navegacion_rel_agrupacion_bienes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY navegacion_rel_agrupacion_bienes (fk_navegacion_id, fk_agrupacion_bienes_id) FROM stdin;
\.
COPY navegacion_rel_agrupacion_bienes (fk_navegacion_id, fk_agrupacion_bienes_id) FROM '/usr/src/api/db/initial/4452.dat';

--
-- Data for Name: navegacion_rel_persona_rol_pertenencia; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY navegacion_rel_persona_rol_pertenencia (fk_persona_rol_pertenencia_id, fk_navegacion_id) FROM stdin;
\.
COPY navegacion_rel_persona_rol_pertenencia (fk_persona_rol_pertenencia_id, fk_navegacion_id) FROM '/usr/src/api/db/initial/4453.dat';

--
-- Data for Name: navegacion_rel_transporte; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY navegacion_rel_transporte (fk_navegacion_id, fk_transporte_id, tipo_navegacion) FROM stdin;
\.
COPY navegacion_rel_transporte (fk_navegacion_id, fk_transporte_id, tipo_navegacion) FROM '/usr/src/api/db/initial/4454.dat';

--
-- Data for Name: objeto; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY objeto (id_objeto, tipo, nombre, fk_objeto_id) FROM stdin;
\.
COPY objeto (id_objeto, tipo, nombre, fk_objeto_id) FROM '/usr/src/api/db/initial/4455.dat';

--
-- Data for Name: observacion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY observacion (id_observacion, texto, fk_documento) FROM stdin;
\.
COPY observacion (id_observacion, texto, fk_documento) FROM '/usr/src/api/db/initial/4456.dat';

--
-- Data for Name: or_per_lug; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY or_per_lug (id_or_per_lug, fk_origen_persona_id, fk_lugar_nombre, fk_persona_rol_pertenencia_id) FROM stdin;
\.
COPY or_per_lug (id_or_per_lug, fk_origen_persona_id, fk_lugar_nombre, fk_persona_rol_pertenencia_id) FROM '/usr/src/api/db/initial/4457.dat';

--
-- Data for Name: origen_persona; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY origen_persona (id_origen_persona, nombre, descripcion, fk_origen_persona_id) FROM stdin;
\.
COPY origen_persona (id_origen_persona, nombre, descripcion, fk_origen_persona_id) FROM '/usr/src/api/db/initial/4458.dat';

--
-- Data for Name: paso_itinerario; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY paso_itinerario (id_paso_itinerario, "precision", fecha, tipo, descripcion, fk_navegacion_id, fk_lugar_nombre) FROM stdin;
\.
COPY paso_itinerario (id_paso_itinerario, "precision", fecha, tipo, descripcion, fk_navegacion_id, fk_lugar_nombre) FROM '/usr/src/api/db/initial/4459.dat';

--
-- Data for Name: pena; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY pena (id_pena, destierro_tipo, fecha_ini_dest, fecha_fin_dest, precision_ini_dest, precision_fin_dest, multa, destierro, exculpatoria, perdida_bienes, perdida_bienes_desc, otro, otro_desc, escarnio, azotes, muerte, muerte_medio) FROM stdin;
\.
COPY pena (id_pena, destierro_tipo, fecha_ini_dest, fecha_fin_dest, precision_ini_dest, precision_fin_dest, multa, destierro, exculpatoria, perdida_bienes, perdida_bienes_desc, otro, otro_desc, escarnio, azotes, muerte, muerte_medio) FROM '/usr/src/api/db/initial/4460.dat';

--
-- Data for Name: pena_rel_miembro; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY pena_rel_miembro (fk_pena_id, fk_miembro_texto) FROM stdin;
\.
COPY pena_rel_miembro (fk_pena_id, fk_miembro_texto) FROM '/usr/src/api/db/initial/4461.dat';

--
-- Data for Name: pena_rel_unidad; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY pena_rel_unidad (fk_pena_id, fk_unidad_nombre, valor) FROM stdin;
\.
COPY pena_rel_unidad (fk_pena_id, fk_unidad_nombre, valor) FROM '/usr/src/api/db/initial/4462.dat';

--
-- Data for Name: perfil_usuario; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY perfil_usuario (id_perfil_usuario, nombre, descripcion) FROM stdin;
\.
COPY perfil_usuario (id_perfil_usuario, nombre, descripcion) FROM '/usr/src/api/db/initial/4463.dat';

--
-- Data for Name: perfil_usuario_rel_permisos_api; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY perfil_usuario_rel_permisos_api (fk_perfil_usuario, fk_permisos_api) FROM stdin;
\.
COPY perfil_usuario_rel_permisos_api (fk_perfil_usuario, fk_permisos_api) FROM '/usr/src/api/db/initial/4464.dat';

--
-- Data for Name: permiso_navegacion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY permiso_navegacion (id_permiso_navegacion, lugar_emision, fecha_emision, puerto_salida, puerto_llegada, mercancias, autoridad, observacion, fk_navegacion_id) FROM stdin;
\.
COPY permiso_navegacion (id_permiso_navegacion, lugar_emision, fecha_emision, puerto_salida, puerto_llegada, mercancias, autoridad, observacion, fk_navegacion_id) FROM '/usr/src/api/db/initial/4465.dat';

--
-- Data for Name: permisos_api; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY permisos_api (id_permisos_api, nombre, crear, borrar, modificar, lectura) FROM stdin;
\.
COPY permisos_api (id_permisos_api, nombre, crear, borrar, modificar, lectura) FROM '/usr/src/api/db/initial/4466.dat';

--
-- Data for Name: persona_historica; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY persona_historica (id_persona_historica, nombre, genero, fk_persona_historica, fk_individuo_arqueologico_id) FROM stdin;
\.
COPY persona_historica (id_persona_historica, nombre, genero, fk_persona_historica, fk_individuo_arqueologico_id) FROM '/usr/src/api/db/initial/4467.dat';

--
-- Data for Name: persona_rol_pertenencia; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY persona_rol_pertenencia (id_persona_rol_pertenencia, edad_min, edad_max, oficio, descripcion, edad_recodificada, fk_rol_nombre, fk_persona_historica_id, fk_institucion_nombre, fk_pertenencia_id, fk_persona_rol_pertenencia_id) FROM stdin;
\.
COPY persona_rol_pertenencia (id_persona_rol_pertenencia, edad_min, edad_max, oficio, descripcion, edad_recodificada, fk_rol_nombre, fk_persona_historica_id, fk_institucion_nombre, fk_pertenencia_id, fk_persona_rol_pertenencia_id) FROM '/usr/src/api/db/initial/4468.dat';

--
-- Data for Name: pertenencia; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY pertenencia (id_pertenencia, fecha_inicio, fecha_fin, precision_inicio, precision_fin, motivo, orden, tipo_atr_doc, fk_documento_id, fk_pertenencia_id) FROM stdin;
\.
COPY pertenencia (id_pertenencia, fecha_inicio, fecha_fin, precision_inicio, precision_fin, motivo, orden, tipo_atr_doc, fk_documento_id, fk_pertenencia_id) FROM '/usr/src/api/db/initial/4469.dat';

--
-- Data for Name: pertenencia_rel_agrupacion_bienes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY pertenencia_rel_agrupacion_bienes (fk_pertenencia_id, fk_agrupacion_bienes_id) FROM stdin;
\.
COPY pertenencia_rel_agrupacion_bienes (fk_pertenencia_id, fk_agrupacion_bienes_id) FROM '/usr/src/api/db/initial/4470.dat';

--
-- Data for Name: pertenencia_rel_attr_especifico; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY pertenencia_rel_attr_especifico (fk_pertenencia_id, fk_attr_especifico_id) FROM stdin;
\.
COPY pertenencia_rel_attr_especifico (fk_pertenencia_id, fk_attr_especifico_id) FROM '/usr/src/api/db/initial/4471.dat';

--
-- Data for Name: pertenencia_rel_lugar; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY pertenencia_rel_lugar (fk_pertenencia_id, fk_lugar_nombre, tipo_lugar, "precision", fk_tipo_lugar_nombre) FROM stdin;
\.
COPY pertenencia_rel_lugar (fk_pertenencia_id, fk_lugar_nombre, tipo_lugar, "precision", fk_tipo_lugar_nombre) FROM '/usr/src/api/db/initial/4472.dat';

--
-- Data for Name: phosphates; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY phosphates (id_phosphates, distance_from_cervix, phosphate_yield, s18op, s18op_1sd, comments, fk_muestra_id) FROM stdin;
\.
COPY phosphates (id_phosphates, distance_from_cervix, phosphate_yield, s18op, s18op_1sd, comments, fk_muestra_id) FROM '/usr/src/api/db/initial/4473.dat';

--
-- Data for Name: point; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY point (geom_wgs84, id_point, geom_nad27) FROM stdin;
\.
COPY point (geom_wgs84, id_point, geom_nad27) FROM '/usr/src/api/db/initial/4474.dat';

--
-- Data for Name: polygon; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY polygon (geom_wgs84, id_polygon, geom_nad27) FROM stdin;
\.
COPY polygon (geom_wgs84, id_polygon, geom_nad27) FROM '/usr/src/api/db/initial/4475.dat';

--
-- Data for Name: proyecto; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY proyecto (nombre, descripcion) FROM stdin;
\.
COPY proyecto (nombre, descripcion) FROM '/usr/src/api/db/initial/4476.dat';

--
-- Data for Name: proyecto_rel_documento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY proyecto_rel_documento (fk_proyecto_nombre, fk_documento_id) FROM stdin;
\.
COPY proyecto_rel_documento (fk_proyecto_nombre, fk_documento_id) FROM '/usr/src/api/db/initial/4477.dat';

--
-- Data for Name: referencia_bibliografica; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY referencia_bibliografica (id_referencia_bibliografica, isbn, doi, autores, fecha, paginas, titulo, tipo, nombre_tipo, fk_url_id) FROM stdin;
\.
COPY referencia_bibliografica (id_referencia_bibliografica, isbn, doi, autores, fecha, paginas, titulo, tipo, nombre_tipo, fk_url_id) FROM '/usr/src/api/db/initial/4478.dat';

--
-- Data for Name: rel_iti_obj_trans; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY rel_iti_obj_trans (id_rel_iti_obj_trans, fk_paso_itinerario_id, fk_transporte_id, fk_agrupacion_bienes_id) FROM stdin;
\.
COPY rel_iti_obj_trans (id_rel_iti_obj_trans, fk_paso_itinerario_id, fk_transporte_id, fk_agrupacion_bienes_id) FROM '/usr/src/api/db/initial/4479.dat';

--
-- Data for Name: resto; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY resto (variable, nombre, avatar) FROM stdin;
\.
COPY resto (variable, nombre, avatar) FROM '/usr/src/api/db/initial/4480.dat';

--
-- Data for Name: resto_rel_categoria_resto_indice; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY resto_rel_categoria_resto_indice (fk_resto_variable, fk_categoria_resto_indice_id) FROM stdin;
\.
COPY resto_rel_categoria_resto_indice (fk_resto_variable, fk_categoria_resto_indice_id) FROM '/usr/src/api/db/initial/4481.dat';

--
-- Data for Name: rol; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY rol (nombre, descripcion) FROM stdin;
\.
COPY rol (nombre, descripcion) FROM '/usr/src/api/db/initial/4482.dat';

--
-- Data for Name: seccion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY seccion (nombre, descripcion, fk_coleccion, id_seccion) FROM stdin;
\.
COPY seccion (nombre, descripcion, fk_coleccion, id_seccion) FROM '/usr/src/api/db/initial/4483.dat';

--
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
\.
COPY spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM '/usr/src/api/db/initial/3889.dat';

--
-- Data for Name: sr; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY sr (id_sr, distance_from_cervix, sr_concentration, "87sr_86sr", "87sr_86sr_2sd", comments, fk_muestra_id) FROM stdin;
\.
COPY sr (id_sr, distance_from_cervix, sr_concentration, "87sr_86sr", "87sr_86sr_2sd", comments, fk_muestra_id) FROM '/usr/src/api/db/initial/4484.dat';

--
-- Data for Name: tipo_lugar; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY tipo_lugar (nombre) FROM stdin;
\.
COPY tipo_lugar (nombre) FROM '/usr/src/api/db/initial/4491.dat';

--
-- Data for Name: tipo_transporte; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY tipo_transporte (nombre_tipo, descripcion) FROM stdin;
\.
COPY tipo_transporte (nombre_tipo, descripcion) FROM '/usr/src/api/db/initial/4485.dat';

--
-- Data for Name: transporte; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY transporte (id_transporte, tipo, nombre, tonelaje, bandera, observaciones, fk_transporte_id, fk_tipo_transporte) FROM stdin;
\.
COPY transporte (id_transporte, tipo, nombre, tonelaje, bandera, observaciones, fk_transporte_id, fk_tipo_transporte) FROM '/usr/src/api/db/initial/4486.dat';

--
-- Data for Name: transporte_rel_objeto; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY transporte_rel_objeto (fk_transporte_id, fk_objeto_id) FROM stdin;
\.
COPY transporte_rel_objeto (fk_transporte_id, fk_objeto_id) FROM '/usr/src/api/db/initial/4487.dat';

--
-- Data for Name: unidad; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY unidad (nombre, tipo) FROM stdin;
\.
COPY unidad (nombre, tipo) FROM '/usr/src/api/db/initial/4488.dat';

--
-- Data for Name: url; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY url (id_url, url, tipo, descripcion, motivo_conf) FROM stdin;
\.
COPY url (id_url, url, tipo, descripcion, motivo_conf) FROM '/usr/src/api/db/initial/4489.dat';

--
-- Data for Name: usuario; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY usuario (id_usuario, nombre, apellidos, institucion, departamento, posicion, estado, password, avatar, email, email_adicional, biografia, telefono, skype, dni, fk_perfil_usuario) FROM stdin;
\.
COPY usuario (id_usuario, nombre, apellidos, institucion, departamento, posicion, estado, password, avatar, email, email_adicional, biografia, telefono, skype, dni, fk_perfil_usuario) FROM '/usr/src/api/db/initial/4490.dat';

--
-- Name: adn adn_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY adn
    ADD CONSTRAINT adn_pkey PRIMARY KEY (id_adn);


--
-- Name: agrupacion_bienes agrupacion_bienes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY agrupacion_bienes
    ADD CONSTRAINT agrupacion_bienes_pkey PRIMARY KEY (id_agrupacion_bienes);


--
-- Name: agrupacion_bienes_rel_unidad agrupacion_bienes_rel_unidad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY agrupacion_bienes_rel_unidad
    ADD CONSTRAINT agrupacion_bienes_rel_unidad_pkey PRIMARY KEY (fk_agrupacion_bienes_id, fk_unidad_nombre);


--
-- Name: almidon almidon_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY almidon
    ADD CONSTRAINT almidon_pkey PRIMARY KEY (id_almidon);


--
-- Name: anomalia anomalia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY anomalia
    ADD CONSTRAINT anomalia_pkey PRIMARY KEY (id_anomalia);


--
-- Name: anomalia_rel_individuo_resto anomalia_rel_individuo_resto_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY anomalia_rel_individuo_resto
    ADD CONSTRAINT anomalia_rel_individuo_resto_pkey PRIMARY KEY (fk_anomalia_id, fk_individuo_resto_id);


--
-- Name: atributo_documento atributo_documento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY atributo_documento
    ADD CONSTRAINT atributo_documento_pkey PRIMARY KEY (id_atributo_documento);


--
-- Name: attr_especifico attr_especifico_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY attr_especifico
    ADD CONSTRAINT attr_especifico_pkey PRIMARY KEY (id_attr_especifico);


--
-- Name: carbonate carbonate_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY carbonate
    ADD CONSTRAINT carbonate_pkey PRIMARY KEY (id_carbonate);


--
-- Name: categoria_resto_indice categoria_resto_indice_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY categoria_resto_indice
    ADD CONSTRAINT categoria_resto_indice_pkey PRIMARY KEY (id_categoria_resto_indice);


--
-- Name: categoria_resto categoria_resto_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY categoria_resto
    ADD CONSTRAINT categoria_resto_pkey PRIMARY KEY (nombre);


--
-- Name: categoria_resto_rel_anomalia categoria_resto_rel_anomalia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY categoria_resto_rel_anomalia
    ADD CONSTRAINT categoria_resto_rel_anomalia_pkey PRIMARY KEY (fk_categoria_resto, fk_anomalia_id);


--
-- Name: coleccion coleccion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY coleccion
    ADD CONSTRAINT coleccion_pkey PRIMARY KEY (nombre);


--
-- Name: collagen collagen_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY collagen
    ADD CONSTRAINT collagen_pkey PRIMARY KEY (id_collagen);


--
-- Name: documento documento_id_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY documento
    ADD CONSTRAINT documento_id_pkey PRIMARY KEY (id_documento);


--
-- Name: documento_rel_documento documento_rel_documento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY documento_rel_documento
    ADD CONSTRAINT documento_rel_documento_pkey PRIMARY KEY (fk_documento2, fk_documento1);


--
-- Name: documento_rel_referencia_bibliografica documento_rel_referencia_bibliografica_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY documento_rel_referencia_bibliografica
    ADD CONSTRAINT documento_rel_referencia_bibliografica_pkey PRIMARY KEY (fk_documento_id, fk_referencia_bibliografica_id);


--
-- Name: documento_rel_unidad documento_rel_unidad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY documento_rel_unidad
    ADD CONSTRAINT documento_rel_unidad_pkey PRIMARY KEY (fk_documento_id, fk_unidad_nombre);


--
-- Name: documento_rel_url documento_rel_url_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY documento_rel_url
    ADD CONSTRAINT documento_rel_url_pkey PRIMARY KEY (fk_documento_id, fk_url_id);


--
-- Name: edad_lote edad_lote_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY edad_lote
    ADD CONSTRAINT edad_lote_pkey PRIMARY KEY (nombre);


--
-- Name: entierro entierro_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY entierro
    ADD CONSTRAINT entierro_pkey PRIMARY KEY (id_entierro);


--
-- Name: entierro_rel_lote entierro_rel_lote_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY entierro_rel_lote
    ADD CONSTRAINT entierro_rel_lote_pkey PRIMARY KEY (fk_entierro_id, fk_lote_id);


--
-- Name: entierro_rel_referencia_bibliografica entierro_rel_referencia_bibliografica_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY entierro_rel_referencia_bibliografica
    ADD CONSTRAINT entierro_rel_referencia_bibliografica_pkey PRIMARY KEY (fk_entierro_id, fk_referencia_bibliografica_id);


--
-- Name: entierro_rel_url entierro_rel_url_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY entierro_rel_url
    ADD CONSTRAINT entierro_rel_url_pkey PRIMARY KEY (fk_entierro_id, fk_url_id);


--
-- Name: espacio_entierro espacio_entierro_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY espacio_entierro
    ADD CONSTRAINT espacio_entierro_pkey PRIMARY KEY (nombre);


--
-- Name: especie especie_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY especie
    ADD CONSTRAINT especie_pkey PRIMARY KEY (nombre);


--
-- Name: estado estado_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY estado
    ADD CONSTRAINT estado_pkey PRIMARY KEY (tipo_cons_represen, elemento);


--
-- Name: estado_rel_individuo_arqueologico estado_rel_individuo_arqueologico_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY estado_rel_individuo_arqueologico
    ADD CONSTRAINT estado_rel_individuo_arqueologico_pkey PRIMARY KEY (fk_estado_tipo_cons_repre, fk_estado_elemento, fk_individuo_arqueologico_id);


--
-- Name: genero_lote genero_lote_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY genero_lote
    ADD CONSTRAINT genero_lote_pkey PRIMARY KEY (nombre);


--
-- Name: individuo_arqueologico individuo_arqueologico_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY individuo_arqueologico
    ADD CONSTRAINT individuo_arqueologico_pkey PRIMARY KEY (id_individuo_arqueologico);


--
-- Name: individuo_arqueologico_rel_url individuo_arqueologico_rel_url_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY individuo_arqueologico_rel_url
    ADD CONSTRAINT individuo_arqueologico_rel_url_pkey PRIMARY KEY (fk_individuo_arqueologico_id, fk_url_id);


--
-- Name: individuo_lote_resto individuo_resto_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY individuo_lote_resto
    ADD CONSTRAINT individuo_resto_pkey PRIMARY KEY (id_individuo_resto);


--
-- Name: institucion institucion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY institucion
    ADD CONSTRAINT institucion_pkey PRIMARY KEY (nombre);


--
-- Name: keyword keyword_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY keyword
    ADD CONSTRAINT keyword_pkey PRIMARY KEY (palabra);


--
-- Name: keyword_rel_documento keyword_rel_documento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY keyword_rel_documento
    ADD CONSTRAINT keyword_rel_documento_pkey PRIMARY KEY (fk_keyword_palabra, fk_documento_id);


--
-- Name: line like_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY line
    ADD CONSTRAINT like_pkey PRIMARY KEY (id_line);


--
-- Name: linea linea_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY linea
    ADD CONSTRAINT linea_pkey PRIMARY KEY (id_linea);


--
-- Name: linea_rel_unidad linea_rel_unidad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY linea_rel_unidad
    ADD CONSTRAINT linea_rel_unidad_pkey PRIMARY KEY (fk_linea_id, fk_unidad_nombre);


--
-- Name: log_acceso log_acceso_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY log_acceso
    ADD CONSTRAINT log_acceso_pkey PRIMARY KEY (id_log_acceso);


--
-- Name: lote_genero_edad lote_genero_edad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY lote_genero_edad
    ADD CONSTRAINT lote_genero_edad_pkey PRIMARY KEY (fk_lote_id, fk_genero_lote_nombre, fk_edad_lote_nombre);


--
-- Name: lote lote_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY lote
    ADD CONSTRAINT lote_pkey PRIMARY KEY (id_lote);


--
-- Name: lote_rel_url lote_rel_url_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY lote_rel_url
    ADD CONSTRAINT lote_rel_url_pkey PRIMARY KEY (fk_lote_id, fk_url_id);


--
-- Name: lugar lugar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY lugar
    ADD CONSTRAINT lugar_pkey PRIMARY KEY (nombre);


--
-- Name: material material_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY material
    ADD CONSTRAINT material_pkey PRIMARY KEY (id_material);


--
-- Name: metodo_pago metodo_pago_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY metodo_pago
    ADD CONSTRAINT metodo_pago_pkey PRIMARY KEY (id_metodo_pago);


--
-- Name: miembro miembro_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY miembro
    ADD CONSTRAINT miembro_pkey PRIMARY KEY (texto);


--
-- Name: muestra muestra_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY muestra
    ADD CONSTRAINT muestra_pkey PRIMARY KEY (id_muestra);


--
-- Name: muestra_rel_url muestra_rel_url_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY muestra_rel_url
    ADD CONSTRAINT muestra_rel_url_pkey PRIMARY KEY (fk_muestra_id, fk_url_id);


--
-- Name: navegacion navegacion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY navegacion
    ADD CONSTRAINT navegacion_pkey PRIMARY KEY (id_navegacion);


--
-- Name: navegacion_rel_agrupacion_bienes navegacion_rel_agrupacion_bienes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY navegacion_rel_agrupacion_bienes
    ADD CONSTRAINT navegacion_rel_agrupacion_bienes_pkey PRIMARY KEY (fk_navegacion_id, fk_agrupacion_bienes_id);


--
-- Name: navegacion_rel_persona_rol_pertenencia navegacion_rel_persona_rol_pertenencia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY navegacion_rel_persona_rol_pertenencia
    ADD CONSTRAINT navegacion_rel_persona_rol_pertenencia_pkey PRIMARY KEY (fk_persona_rol_pertenencia_id, fk_navegacion_id);


--
-- Name: navegacion_rel_transporte navegacion_rel_transporte_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY navegacion_rel_transporte
    ADD CONSTRAINT navegacion_rel_transporte_pkey PRIMARY KEY (fk_navegacion_id, fk_transporte_id);


--
-- Name: objeto objeto_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY objeto
    ADD CONSTRAINT objeto_pkey PRIMARY KEY (id_objeto);


--
-- Name: observacion observacion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY observacion
    ADD CONSTRAINT observacion_pkey PRIMARY KEY (id_observacion);


--
-- Name: or_per_lug or_per_lug_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY or_per_lug
    ADD CONSTRAINT or_per_lug_pkey PRIMARY KEY (id_or_per_lug);


--
-- Name: origen_persona origen_persona_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY origen_persona
    ADD CONSTRAINT origen_persona_pkey PRIMARY KEY (id_origen_persona);


--
-- Name: paso_itinerario paso_itinerario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY paso_itinerario
    ADD CONSTRAINT paso_itinerario_pkey PRIMARY KEY (id_paso_itinerario);


--
-- Name: pena pena_id_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pena
    ADD CONSTRAINT pena_id_pkey PRIMARY KEY (id_pena);


--
-- Name: pena_rel_miembro pena_rel_miembro_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pena_rel_miembro
    ADD CONSTRAINT pena_rel_miembro_pkey PRIMARY KEY (fk_pena_id, fk_miembro_texto);


--
-- Name: pena_rel_unidad pena_rel_unidad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pena_rel_unidad
    ADD CONSTRAINT pena_rel_unidad_pkey PRIMARY KEY (fk_pena_id, fk_unidad_nombre);


--
-- Name: perfil_usuario perfil_usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY perfil_usuario
    ADD CONSTRAINT perfil_usuario_pkey PRIMARY KEY (id_perfil_usuario);


--
-- Name: perfil_usuario_rel_permisos_api perfil_usuario_rel_permisos_api_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY perfil_usuario_rel_permisos_api
    ADD CONSTRAINT perfil_usuario_rel_permisos_api_pkey PRIMARY KEY (fk_perfil_usuario, fk_permisos_api);


--
-- Name: permiso_navegacion permiso_navegacion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY permiso_navegacion
    ADD CONSTRAINT permiso_navegacion_pkey PRIMARY KEY (id_permiso_navegacion);


--
-- Name: permisos_api permisos_api_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY permisos_api
    ADD CONSTRAINT permisos_api_pkey PRIMARY KEY (id_permisos_api);


--
-- Name: persona_historica persona_historica_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY persona_historica
    ADD CONSTRAINT persona_historica_pkey PRIMARY KEY (id_persona_historica);


--
-- Name: persona_rol_pertenencia persona_rol_pertenencia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY persona_rol_pertenencia
    ADD CONSTRAINT persona_rol_pertenencia_pkey PRIMARY KEY (id_persona_rol_pertenencia);


--
-- Name: pertenencia pertenencia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pertenencia
    ADD CONSTRAINT pertenencia_pkey PRIMARY KEY (id_pertenencia);


--
-- Name: pertenencia_rel_agrupacion_bienes pertenencia_rel_agrupacion_bienes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pertenencia_rel_agrupacion_bienes
    ADD CONSTRAINT pertenencia_rel_agrupacion_bienes_pkey PRIMARY KEY (fk_pertenencia_id, fk_agrupacion_bienes_id);


--
-- Name: pertenencia_rel_attr_especifico pertenencia_rel_attr_especifico_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pertenencia_rel_attr_especifico
    ADD CONSTRAINT pertenencia_rel_attr_especifico_pkey PRIMARY KEY (fk_pertenencia_id, fk_attr_especifico_id);


--
-- Name: pertenencia_rel_lugar pertenencia_rel_lugar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pertenencia_rel_lugar
    ADD CONSTRAINT pertenencia_rel_lugar_pkey PRIMARY KEY (fk_pertenencia_id, fk_lugar_nombre);


--
-- Name: phosphates phosphates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY phosphates
    ADD CONSTRAINT phosphates_pkey PRIMARY KEY (id_phosphates);


--
-- Name: point point_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY point
    ADD CONSTRAINT point_pkey PRIMARY KEY (id_point);


--
-- Name: polygon polygon_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY polygon
    ADD CONSTRAINT polygon_pkey PRIMARY KEY (id_polygon);


--
-- Name: proyecto proyecto_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY proyecto
    ADD CONSTRAINT proyecto_pkey PRIMARY KEY (nombre);


--
-- Name: proyecto_rel_documento proyecto_rel_documento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY proyecto_rel_documento
    ADD CONSTRAINT proyecto_rel_documento_pkey PRIMARY KEY (fk_proyecto_nombre, fk_documento_id);


--
-- Name: referencia_bibliografica referencia_bibliografica_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY referencia_bibliografica
    ADD CONSTRAINT referencia_bibliografica_pkey PRIMARY KEY (id_referencia_bibliografica);


--
-- Name: rel_iti_obj_trans rel_iti_obj_trans_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY rel_iti_obj_trans
    ADD CONSTRAINT rel_iti_obj_trans_pkey PRIMARY KEY (id_rel_iti_obj_trans);


--
-- Name: resto resto_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY resto
    ADD CONSTRAINT resto_pkey PRIMARY KEY (variable);


--
-- Name: resto_rel_categoria_resto_indice resto_rel_categoria_resto_indice_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY resto_rel_categoria_resto_indice
    ADD CONSTRAINT resto_rel_categoria_resto_indice_pkey PRIMARY KEY (fk_resto_variable, fk_categoria_resto_indice_id);


--
-- Name: rol rol_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY rol
    ADD CONSTRAINT rol_pkey PRIMARY KEY (nombre);


--
-- Name: seccion seccion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY seccion
    ADD CONSTRAINT seccion_pkey PRIMARY KEY (id_seccion);


--
-- Name: sr sr_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sr
    ADD CONSTRAINT sr_pkey PRIMARY KEY (id_sr);


--
-- Name: tipo_lugar tipo_lugar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tipo_lugar
    ADD CONSTRAINT tipo_lugar_pkey PRIMARY KEY (nombre);


--
-- Name: tipo_transporte tipo_transporte_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tipo_transporte
    ADD CONSTRAINT tipo_transporte_pkey PRIMARY KEY (nombre_tipo);


--
-- Name: transporte transporte_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY transporte
    ADD CONSTRAINT transporte_pkey PRIMARY KEY (id_transporte);


--
-- Name: transporte_rel_objeto transporte_rel_objeto_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY transporte_rel_objeto
    ADD CONSTRAINT transporte_rel_objeto_pkey PRIMARY KEY (fk_transporte_id, fk_objeto_id);


--
-- Name: unidad unidad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY unidad
    ADD CONSTRAINT unidad_pkey PRIMARY KEY (nombre);


--
-- Name: url url_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY url
    ADD CONSTRAINT url_pkey PRIMARY KEY (id_url);


--
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id_usuario);


--
-- Name: pertenencia_rel_agrupacion_bienes fk_agrupacion_bienes; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pertenencia_rel_agrupacion_bienes
    ADD CONSTRAINT fk_agrupacion_bienes FOREIGN KEY (fk_agrupacion_bienes_id) REFERENCES agrupacion_bienes(id_agrupacion_bienes) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: rel_iti_obj_trans fk_agrupacion_bienes; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY rel_iti_obj_trans
    ADD CONSTRAINT fk_agrupacion_bienes FOREIGN KEY (fk_agrupacion_bienes_id) REFERENCES agrupacion_bienes(id_agrupacion_bienes) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: navegacion_rel_agrupacion_bienes fk_agrupacion_bienes; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY navegacion_rel_agrupacion_bienes
    ADD CONSTRAINT fk_agrupacion_bienes FOREIGN KEY (fk_agrupacion_bienes_id) REFERENCES agrupacion_bienes(id_agrupacion_bienes) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: agrupacion_bienes_rel_unidad fk_agrupacion_bienes; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY agrupacion_bienes_rel_unidad
    ADD CONSTRAINT fk_agrupacion_bienes FOREIGN KEY (fk_agrupacion_bienes_id) REFERENCES agrupacion_bienes(id_agrupacion_bienes) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: linea fk_agrupacion_bienes; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY linea
    ADD CONSTRAINT fk_agrupacion_bienes FOREIGN KEY (fk_agrupacion_bienes_id) REFERENCES agrupacion_bienes(id_agrupacion_bienes) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: almidon fk_almidon; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY almidon
    ADD CONSTRAINT fk_almidon FOREIGN KEY (fk_almidon_id) REFERENCES almidon(id_almidon) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: categoria_resto_rel_anomalia fk_anomalia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY categoria_resto_rel_anomalia
    ADD CONSTRAINT fk_anomalia FOREIGN KEY (fk_anomalia_id) REFERENCES anomalia(id_anomalia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: anomalia_rel_individuo_resto fk_anomalia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY anomalia_rel_individuo_resto
    ADD CONSTRAINT fk_anomalia FOREIGN KEY (fk_anomalia_id) REFERENCES anomalia(id_anomalia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pertenencia_rel_attr_especifico fk_attr_especifico; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pertenencia_rel_attr_especifico
    ADD CONSTRAINT fk_attr_especifico FOREIGN KEY (fk_attr_especifico_id) REFERENCES attr_especifico(id_attr_especifico) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: categoria_resto_indice fk_categoria_resto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY categoria_resto_indice
    ADD CONSTRAINT fk_categoria_resto FOREIGN KEY (fk_categoria_resto_nombre) REFERENCES categoria_resto(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: categoria_resto_rel_anomalia fk_categoria_resto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY categoria_resto_rel_anomalia
    ADD CONSTRAINT fk_categoria_resto FOREIGN KEY (fk_categoria_resto) REFERENCES categoria_resto(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: categoria_resto_indice fk_categoria_resto_indice; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY categoria_resto_indice
    ADD CONSTRAINT fk_categoria_resto_indice FOREIGN KEY (fk_categoria_resto_indice_id) REFERENCES categoria_resto_indice(id_categoria_resto_indice) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: resto_rel_categoria_resto_indice fk_categoria_resto_indice; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY resto_rel_categoria_resto_indice
    ADD CONSTRAINT fk_categoria_resto_indice FOREIGN KEY (fk_categoria_resto_indice_id) REFERENCES categoria_resto_indice(id_categoria_resto_indice) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: seccion fk_coleccion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY seccion
    ADD CONSTRAINT fk_coleccion FOREIGN KEY (fk_coleccion) REFERENCES coleccion(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: keyword_rel_documento fk_documento; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY keyword_rel_documento
    ADD CONSTRAINT fk_documento FOREIGN KEY (fk_documento_id) REFERENCES documento(id_documento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: atributo_documento fk_documento; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY atributo_documento
    ADD CONSTRAINT fk_documento FOREIGN KEY (fk_documento_id) REFERENCES documento(id_documento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: observacion fk_documento; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY observacion
    ADD CONSTRAINT fk_documento FOREIGN KEY (fk_documento) REFERENCES documento(id_documento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pertenencia fk_documento; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pertenencia
    ADD CONSTRAINT fk_documento FOREIGN KEY (fk_documento_id) REFERENCES documento(id_documento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: proyecto_rel_documento fk_documento; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY proyecto_rel_documento
    ADD CONSTRAINT fk_documento FOREIGN KEY (fk_documento_id) REFERENCES documento(id_documento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: navegacion fk_documento; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY navegacion
    ADD CONSTRAINT fk_documento FOREIGN KEY (fk_documento_id) REFERENCES documento(id_documento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: documento_rel_unidad fk_documento; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY documento_rel_unidad
    ADD CONSTRAINT fk_documento FOREIGN KEY (fk_documento_id) REFERENCES documento(id_documento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: documento_rel_url fk_documento; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY documento_rel_url
    ADD CONSTRAINT fk_documento FOREIGN KEY (fk_documento_id) REFERENCES documento(id_documento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: documento_rel_referencia_bibliografica fk_documento; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY documento_rel_referencia_bibliografica
    ADD CONSTRAINT fk_documento FOREIGN KEY (fk_documento_id) REFERENCES documento(id_documento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: documento_rel_documento fk_documento1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY documento_rel_documento
    ADD CONSTRAINT fk_documento1 FOREIGN KEY (fk_documento1) REFERENCES documento(id_documento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: documento_rel_documento fk_documento2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY documento_rel_documento
    ADD CONSTRAINT fk_documento2 FOREIGN KEY (fk_documento2) REFERENCES documento(id_documento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lote_genero_edad fk_edad_lote; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY lote_genero_edad
    ADD CONSTRAINT fk_edad_lote FOREIGN KEY (fk_edad_lote_nombre) REFERENCES edad_lote(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: entierro_rel_referencia_bibliografica fk_entierro; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY entierro_rel_referencia_bibliografica
    ADD CONSTRAINT fk_entierro FOREIGN KEY (fk_entierro_id) REFERENCES entierro(id_entierro) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: entierro_rel_url fk_entierro; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY entierro_rel_url
    ADD CONSTRAINT fk_entierro FOREIGN KEY (fk_entierro_id) REFERENCES entierro(id_entierro) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: linea fk_entierro; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY linea
    ADD CONSTRAINT fk_entierro FOREIGN KEY (fk_entierro_id) REFERENCES entierro(id_entierro) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: entierro_rel_lote fk_entierro; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY entierro_rel_lote
    ADD CONSTRAINT fk_entierro FOREIGN KEY (fk_entierro_id) REFERENCES entierro(id_entierro) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: individuo_lote_resto fk_entierro; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY individuo_lote_resto
    ADD CONSTRAINT fk_entierro FOREIGN KEY (fk_entierro) REFERENCES entierro(id_entierro) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: entierro fk_espacio_entierro; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY entierro
    ADD CONSTRAINT fk_espacio_entierro FOREIGN KEY (fk_espacio_nombre) REFERENCES espacio_entierro(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: individuo_lote_resto fk_especie; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY individuo_lote_resto
    ADD CONSTRAINT fk_especie FOREIGN KEY (fk_especie_nombre) REFERENCES especie(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: estado_rel_individuo_arqueologico fk_estado; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY estado_rel_individuo_arqueologico
    ADD CONSTRAINT fk_estado FOREIGN KEY (fk_estado_tipo_cons_repre, fk_estado_elemento) REFERENCES estado(tipo_cons_represen, elemento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lote_genero_edad fk_genero_lote; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY lote_genero_edad
    ADD CONSTRAINT fk_genero_lote FOREIGN KEY (fk_genero_lote_nombre) REFERENCES genero_lote(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: persona_historica fk_individuo_arqueologico; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY persona_historica
    ADD CONSTRAINT fk_individuo_arqueologico FOREIGN KEY (fk_individuo_arqueologico_id) REFERENCES individuo_arqueologico(id_individuo_arqueologico) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: estado_rel_individuo_arqueologico fk_individuo_arqueologico; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY estado_rel_individuo_arqueologico
    ADD CONSTRAINT fk_individuo_arqueologico FOREIGN KEY (fk_individuo_arqueologico_id) REFERENCES individuo_arqueologico(id_individuo_arqueologico) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: individuo_lote_resto fk_individuo_arqueologico; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY individuo_lote_resto
    ADD CONSTRAINT fk_individuo_arqueologico FOREIGN KEY (fk_individuo_arqueologico_id) REFERENCES individuo_arqueologico(id_individuo_arqueologico) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: individuo_arqueologico_rel_url fk_individuo_arqueologico; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY individuo_arqueologico_rel_url
    ADD CONSTRAINT fk_individuo_arqueologico FOREIGN KEY (fk_individuo_arqueologico_id) REFERENCES individuo_arqueologico(id_individuo_arqueologico) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: linea fk_individuo_arqueologico; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY linea
    ADD CONSTRAINT fk_individuo_arqueologico FOREIGN KEY (fk_individuo_arqueologico) REFERENCES individuo_arqueologico(id_individuo_arqueologico) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: muestra fk_individuo_resto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY muestra
    ADD CONSTRAINT fk_individuo_resto FOREIGN KEY (fk_individuo_resto_id) REFERENCES individuo_lote_resto(id_individuo_resto) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: anomalia_rel_individuo_resto fk_individuo_resto_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY anomalia_rel_individuo_resto
    ADD CONSTRAINT fk_individuo_resto_id FOREIGN KEY (fk_individuo_resto_id) REFERENCES individuo_lote_resto(id_individuo_resto) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: persona_rol_pertenencia fk_institucion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY persona_rol_pertenencia
    ADD CONSTRAINT fk_institucion FOREIGN KEY (fk_institucion_nombre) REFERENCES institucion(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: keyword_rel_documento fk_keyword; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY keyword_rel_documento
    ADD CONSTRAINT fk_keyword FOREIGN KEY (fk_keyword_palabra) REFERENCES keyword(palabra) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: keyword fk_keyword; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY keyword
    ADD CONSTRAINT fk_keyword FOREIGN KEY (fk_keyword) REFERENCES keyword(palabra) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lugar fk_line; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY lugar
    ADD CONSTRAINT fk_line FOREIGN KEY (fk_line_id) REFERENCES line(id_line) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: linea_rel_unidad fk_linea; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY linea_rel_unidad
    ADD CONSTRAINT fk_linea FOREIGN KEY (fk_linea_id) REFERENCES linea(id_linea) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lote_genero_edad fk_lote; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY lote_genero_edad
    ADD CONSTRAINT fk_lote FOREIGN KEY (fk_lote_id) REFERENCES lote(id_lote) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: entierro_rel_lote fk_lote; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY entierro_rel_lote
    ADD CONSTRAINT fk_lote FOREIGN KEY (fk_lote_id) REFERENCES lote(id_lote) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lote_rel_url fk_lote; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY lote_rel_url
    ADD CONSTRAINT fk_lote FOREIGN KEY (fk_lote_id) REFERENCES lote(id_lote) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: individuo_lote_resto fk_lote; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY individuo_lote_resto
    ADD CONSTRAINT fk_lote FOREIGN KEY (fk_lote_id) REFERENCES lote(id_lote) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: or_per_lug fk_lugar; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY or_per_lug
    ADD CONSTRAINT fk_lugar FOREIGN KEY (fk_lugar_nombre) REFERENCES lugar(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pertenencia_rel_lugar fk_lugar; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pertenencia_rel_lugar
    ADD CONSTRAINT fk_lugar FOREIGN KEY (fk_lugar_nombre) REFERENCES lugar(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lugar fk_lugar; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY lugar
    ADD CONSTRAINT fk_lugar FOREIGN KEY (fk_lugar_nombre) REFERENCES lugar(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: paso_itinerario fk_lugar; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY paso_itinerario
    ADD CONSTRAINT fk_lugar FOREIGN KEY (fk_lugar_nombre) REFERENCES lugar(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: agrupacion_bienes fk_lugar; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY agrupacion_bienes
    ADD CONSTRAINT fk_lugar FOREIGN KEY (fk_lugar_nombre) REFERENCES lugar(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: linea fk_lugar; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY linea
    ADD CONSTRAINT fk_lugar FOREIGN KEY (fk_lugar_nombre) REFERENCES lugar(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: entierro fk_lugar; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY entierro
    ADD CONSTRAINT fk_lugar FOREIGN KEY (fk_lugar_nombre) REFERENCES lugar(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: material fk_material; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY material
    ADD CONSTRAINT fk_material FOREIGN KEY (fk_material_id) REFERENCES material(id_material) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: linea fk_material; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY linea
    ADD CONSTRAINT fk_material FOREIGN KEY (fk_material_id) REFERENCES material(id_material) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: agrupacion_bienes fk_metodo_pago; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY agrupacion_bienes
    ADD CONSTRAINT fk_metodo_pago FOREIGN KEY (fk_metodo_pago_id) REFERENCES metodo_pago(id_metodo_pago) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pena_rel_miembro fk_miembro; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pena_rel_miembro
    ADD CONSTRAINT fk_miembro FOREIGN KEY (fk_miembro_texto) REFERENCES miembro(texto) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: almidon fk_muestra; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY almidon
    ADD CONSTRAINT fk_muestra FOREIGN KEY (fk_muestra_id) REFERENCES muestra(id_muestra) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sr fk_muestra; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sr
    ADD CONSTRAINT fk_muestra FOREIGN KEY (fk_muestra_id) REFERENCES muestra(id_muestra) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: phosphates fk_muestra; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY phosphates
    ADD CONSTRAINT fk_muestra FOREIGN KEY (fk_muestra_id) REFERENCES muestra(id_muestra) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: carbonate fk_muestra; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY carbonate
    ADD CONSTRAINT fk_muestra FOREIGN KEY (fk_muestra_id) REFERENCES muestra(id_muestra) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: collagen fk_muestra; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY collagen
    ADD CONSTRAINT fk_muestra FOREIGN KEY (fk_muestra_id) REFERENCES muestra(id_muestra) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: adn fk_muestra; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY adn
    ADD CONSTRAINT fk_muestra FOREIGN KEY (fk_muestra_id) REFERENCES muestra(id_muestra) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: muestra_rel_url fk_muestra; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY muestra_rel_url
    ADD CONSTRAINT fk_muestra FOREIGN KEY (fk_muestra_id) REFERENCES muestra(id_muestra) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: permiso_navegacion fk_navegacion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY permiso_navegacion
    ADD CONSTRAINT fk_navegacion FOREIGN KEY (fk_navegacion_id) REFERENCES navegacion(id_navegacion) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: paso_itinerario fk_navegacion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY paso_itinerario
    ADD CONSTRAINT fk_navegacion FOREIGN KEY (fk_navegacion_id) REFERENCES navegacion(id_navegacion) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: navegacion_rel_agrupacion_bienes fk_navegacion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY navegacion_rel_agrupacion_bienes
    ADD CONSTRAINT fk_navegacion FOREIGN KEY (fk_navegacion_id) REFERENCES navegacion(id_navegacion) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: navegacion_rel_persona_rol_pertenencia fk_navegacion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY navegacion_rel_persona_rol_pertenencia
    ADD CONSTRAINT fk_navegacion FOREIGN KEY (fk_navegacion_id) REFERENCES navegacion(id_navegacion) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: navegacion_rel_transporte fk_navegacion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY navegacion_rel_transporte
    ADD CONSTRAINT fk_navegacion FOREIGN KEY (fk_navegacion_id) REFERENCES navegacion(id_navegacion) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: objeto fk_objeto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY objeto
    ADD CONSTRAINT fk_objeto FOREIGN KEY (fk_objeto_id) REFERENCES objeto(id_objeto) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: linea fk_objeto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY linea
    ADD CONSTRAINT fk_objeto FOREIGN KEY (fk_objeto_id) REFERENCES objeto(id_objeto) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: transporte_rel_objeto fk_objeto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY transporte_rel_objeto
    ADD CONSTRAINT fk_objeto FOREIGN KEY (fk_objeto_id) REFERENCES objeto(id_objeto) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: or_per_lug fk_origen_persona; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY or_per_lug
    ADD CONSTRAINT fk_origen_persona FOREIGN KEY (fk_origen_persona_id) REFERENCES origen_persona(id_origen_persona) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: origen_persona fk_origen_persona; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY origen_persona
    ADD CONSTRAINT fk_origen_persona FOREIGN KEY (fk_origen_persona_id) REFERENCES origen_persona(id_origen_persona) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: rel_iti_obj_trans fk_paso_itinerario; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY rel_iti_obj_trans
    ADD CONSTRAINT fk_paso_itinerario FOREIGN KEY (fk_paso_itinerario_id) REFERENCES paso_itinerario(id_paso_itinerario) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: documento fk_pena; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY documento
    ADD CONSTRAINT fk_pena FOREIGN KEY (fk_pena_id) REFERENCES pena(id_pena) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pena_rel_miembro fk_pena; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pena_rel_miembro
    ADD CONSTRAINT fk_pena FOREIGN KEY (fk_pena_id) REFERENCES pena(id_pena) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pena_rel_unidad fk_pena; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pena_rel_unidad
    ADD CONSTRAINT fk_pena FOREIGN KEY (fk_pena_id) REFERENCES pena(id_pena) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: perfil_usuario_rel_permisos_api fk_perfil_usuario; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY perfil_usuario_rel_permisos_api
    ADD CONSTRAINT fk_perfil_usuario FOREIGN KEY (fk_perfil_usuario) REFERENCES perfil_usuario(id_perfil_usuario) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: usuario fk_perfil_usuario; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY usuario
    ADD CONSTRAINT fk_perfil_usuario FOREIGN KEY (fk_perfil_usuario) REFERENCES perfil_usuario(id_perfil_usuario) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: perfil_usuario_rel_permisos_api fk_permisos_api; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY perfil_usuario_rel_permisos_api
    ADD CONSTRAINT fk_permisos_api FOREIGN KEY (fk_permisos_api) REFERENCES permisos_api(id_permisos_api) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: persona_historica fk_persona_historica; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY persona_historica
    ADD CONSTRAINT fk_persona_historica FOREIGN KEY (fk_persona_historica) REFERENCES persona_historica(id_persona_historica) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: persona_rol_pertenencia fk_persona_historica; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY persona_rol_pertenencia
    ADD CONSTRAINT fk_persona_historica FOREIGN KEY (fk_persona_historica_id) REFERENCES persona_historica(id_persona_historica) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: linea fk_persona_rol; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY linea
    ADD CONSTRAINT fk_persona_rol FOREIGN KEY (fk_persona_rol_pertenencia) REFERENCES persona_rol_pertenencia(id_persona_rol_pertenencia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: or_per_lug fk_persona_rol_pertenencia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY or_per_lug
    ADD CONSTRAINT fk_persona_rol_pertenencia FOREIGN KEY (fk_persona_rol_pertenencia_id) REFERENCES persona_rol_pertenencia(id_persona_rol_pertenencia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: persona_rol_pertenencia fk_persona_rol_pertenencia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY persona_rol_pertenencia
    ADD CONSTRAINT fk_persona_rol_pertenencia FOREIGN KEY (fk_persona_rol_pertenencia_id) REFERENCES persona_rol_pertenencia(id_persona_rol_pertenencia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: navegacion_rel_persona_rol_pertenencia fk_persona_rol_pertenencia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY navegacion_rel_persona_rol_pertenencia
    ADD CONSTRAINT fk_persona_rol_pertenencia FOREIGN KEY (fk_persona_rol_pertenencia_id) REFERENCES persona_rol_pertenencia(id_persona_rol_pertenencia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pertenencia fk_pertenencia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pertenencia
    ADD CONSTRAINT fk_pertenencia FOREIGN KEY (fk_pertenencia_id) REFERENCES pertenencia(id_pertenencia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pertenencia_rel_lugar fk_pertenencia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pertenencia_rel_lugar
    ADD CONSTRAINT fk_pertenencia FOREIGN KEY (fk_pertenencia_id) REFERENCES pertenencia(id_pertenencia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: persona_rol_pertenencia fk_pertenencia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY persona_rol_pertenencia
    ADD CONSTRAINT fk_pertenencia FOREIGN KEY (fk_pertenencia_id) REFERENCES pertenencia(id_pertenencia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pertenencia_rel_attr_especifico fk_pertenencia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pertenencia_rel_attr_especifico
    ADD CONSTRAINT fk_pertenencia FOREIGN KEY (fk_pertenencia_id) REFERENCES pertenencia(id_pertenencia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pertenencia_rel_agrupacion_bienes fk_pertenencia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pertenencia_rel_agrupacion_bienes
    ADD CONSTRAINT fk_pertenencia FOREIGN KEY (fk_pertenencia_id) REFERENCES pertenencia(id_pertenencia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lugar fk_point; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY lugar
    ADD CONSTRAINT fk_point FOREIGN KEY (fk_point_id) REFERENCES point(id_point) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lugar fk_polygon; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY lugar
    ADD CONSTRAINT fk_polygon FOREIGN KEY (fk_polygon_id) REFERENCES polygon(id_polygon) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: proyecto_rel_documento fk_proyecto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY proyecto_rel_documento
    ADD CONSTRAINT fk_proyecto FOREIGN KEY (fk_proyecto_nombre) REFERENCES proyecto(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: documento_rel_referencia_bibliografica fk_referencia_bibliografica; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY documento_rel_referencia_bibliografica
    ADD CONSTRAINT fk_referencia_bibliografica FOREIGN KEY (fk_referencia_bibliografica_id) REFERENCES referencia_bibliografica(id_referencia_bibliografica) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: entierro_rel_referencia_bibliografica fk_referencia_bibliografica; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY entierro_rel_referencia_bibliografica
    ADD CONSTRAINT fk_referencia_bibliografica FOREIGN KEY (fk_referencia_bibliografica_id) REFERENCES referencia_bibliografica(id_referencia_bibliografica) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: individuo_lote_resto fk_resto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY individuo_lote_resto
    ADD CONSTRAINT fk_resto FOREIGN KEY (fk_resto_variable) REFERENCES resto(variable) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: resto_rel_categoria_resto_indice fk_resto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY resto_rel_categoria_resto_indice
    ADD CONSTRAINT fk_resto FOREIGN KEY (fk_resto_variable) REFERENCES resto(variable) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: persona_rol_pertenencia fk_rol; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY persona_rol_pertenencia
    ADD CONSTRAINT fk_rol FOREIGN KEY (fk_rol_nombre) REFERENCES rol(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: documento fk_seccion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY documento
    ADD CONSTRAINT fk_seccion FOREIGN KEY (fk_seccion_id) REFERENCES seccion(id_seccion) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pertenencia_rel_lugar fk_tipo_lugar; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pertenencia_rel_lugar
    ADD CONSTRAINT fk_tipo_lugar FOREIGN KEY (fk_tipo_lugar_nombre) REFERENCES tipo_lugar(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: transporte fk_tipo_transporte; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY transporte
    ADD CONSTRAINT fk_tipo_transporte FOREIGN KEY (fk_tipo_transporte) REFERENCES tipo_transporte(nombre_tipo) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: transporte fk_transporte; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY transporte
    ADD CONSTRAINT fk_transporte FOREIGN KEY (fk_transporte_id) REFERENCES transporte(id_transporte) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: rel_iti_obj_trans fk_transporte; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY rel_iti_obj_trans
    ADD CONSTRAINT fk_transporte FOREIGN KEY (fk_transporte_id) REFERENCES transporte(id_transporte) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: navegacion_rel_transporte fk_transporte; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY navegacion_rel_transporte
    ADD CONSTRAINT fk_transporte FOREIGN KEY (fk_transporte_id) REFERENCES transporte(id_transporte) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: transporte_rel_objeto fk_transporte; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY transporte_rel_objeto
    ADD CONSTRAINT fk_transporte FOREIGN KEY (fk_transporte_id) REFERENCES transporte(id_transporte) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: agrupacion_bienes_rel_unidad fk_unidad; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY agrupacion_bienes_rel_unidad
    ADD CONSTRAINT fk_unidad FOREIGN KEY (fk_unidad_nombre) REFERENCES unidad(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pena_rel_unidad fk_unidad; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pena_rel_unidad
    ADD CONSTRAINT fk_unidad FOREIGN KEY (fk_unidad_nombre) REFERENCES unidad(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: documento_rel_unidad fk_unidad; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY documento_rel_unidad
    ADD CONSTRAINT fk_unidad FOREIGN KEY (fk_unidad_nombre) REFERENCES unidad(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: linea_rel_unidad fk_unidad; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY linea_rel_unidad
    ADD CONSTRAINT fk_unidad FOREIGN KEY (fk_unidad_nombre) REFERENCES unidad(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: referencia_bibliografica fk_url; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY referencia_bibliografica
    ADD CONSTRAINT fk_url FOREIGN KEY (fk_url_id) REFERENCES url(id_url) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: documento_rel_url fk_url; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY documento_rel_url
    ADD CONSTRAINT fk_url FOREIGN KEY (fk_url_id) REFERENCES url(id_url) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: entierro_rel_url fk_url; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY entierro_rel_url
    ADD CONSTRAINT fk_url FOREIGN KEY (fk_url_id) REFERENCES url(id_url) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: individuo_arqueologico_rel_url fk_url; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY individuo_arqueologico_rel_url
    ADD CONSTRAINT fk_url FOREIGN KEY (fk_url_id) REFERENCES url(id_url) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lote_rel_url fk_url; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY lote_rel_url
    ADD CONSTRAINT fk_url FOREIGN KEY (fk_url_id) REFERENCES url(id_url) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: muestra_rel_url fk_url; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY muestra_rel_url
    ADD CONSTRAINT fk_url FOREIGN KEY (fk_url_id) REFERENCES url(id_url) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: documento fk_usuario; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY documento
    ADD CONSTRAINT fk_usuario FOREIGN KEY (fk_usuario_id) REFERENCES usuario(id_usuario) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: log_acceso fk_usuario; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY log_acceso
    ADD CONSTRAINT fk_usuario FOREIGN KEY (fk_usuario) REFERENCES usuario(id_usuario) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

