DROP FUNCTION IF EXISTS ae_add_basic_info(
  id_document numeric,
  tipo text,
  subtipo text,
  signatura text,
  foliado boolean,
  des_foliado text,
  titulo text,
  firmada boolean,
  holografa text,

  seccion numeric,
  keywords text[],

  fecha_emision date,
  precision_fecha_emision text,
  lugar_emision numeric,
  precision_lugar_emision text,

  fecha_recepcion date,
  precision_fecha_recepcion text,
  lugar_recepcion numeric,
  precision_lugar_recepcion text,
  
  secretario json[],
  marginalia_personas json[],
  marginalia_instituciones json[]
);

DROP FUNCTION IF EXISTS ae_add_basic_info(
  id_document numeric,
  tipo text,
  subtipo text,
  signatura text,
  foliado boolean,
  des_foliado text,
  titulo text,
  firmada boolean,
  holografa text,

  seccion numeric,
  keywords text[],

  fecha_emision date,
  precision_fecha_emision text,
  lugar_emision numeric,
  precision_lugar_emision text,

  fecha_recepcion date,
  precision_fecha_recepcion text,
  lugar_recepcion numeric,
  precision_lugar_recepcion text,
  
  secretario json[],
  marginalia_personas json[],
  marginalia_instituciones json[],
  relaciones_documentos text[]
);

CREATE OR REPLACE FUNCTION ae_add_basic_info(
  id_document numeric,
  tipo text,
  subtipo text,
  signatura text,
  foliado boolean,
  des_foliado text,
  titulo text,
  firmada boolean,
  holografa text,

  seccion numeric,
  keywords text[],

  fecha_emision date,
  precision_fecha_emision text,
  lugar_emision numeric,
  precision_lugar_emision text,

  fecha_recepcion date,
  precision_fecha_recepcion text,
  lugar_recepcion numeric,
  precision_lugar_recepcion text,

  secretario json[],
  marginalia_personas json[],
  marginalia_instituciones json[],
  relaciones_documentos text[]
)
RETURNS json as
$$
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
$$ LANGUAGE plpgsql;
