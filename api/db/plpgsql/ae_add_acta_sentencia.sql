DROP FUNCTION IF EXISTS ae_add_acta_sentencia(
  id_document numeric,
  senders json[],
  recipients json[],
  notaries json[],
  criers json[],
  witnesses json[],

  miembros text[],
  monedas json[],

  pena json
);

CREATE OR REPLACE FUNCTION ae_add_acta_sentencia(
  id_document numeric,
  senders json[],
  recipients json[],
  notaries json[],
  criers json[],
  witnesses json[],

  miembros text[],
  monedas json[],

  pena json
)
RETURNS numeric as
$$
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
$$ LANGUAGE plpgsql;
