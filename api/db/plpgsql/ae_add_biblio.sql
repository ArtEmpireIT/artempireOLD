DROP FUNCTION IF EXISTS ae_add_biblio(
  id_documento numeric,
  id_referencia_bibliografica numeric,
  autores text,
  fecha date,
  titulo text,
  nombre_tipo text,
  paginas text,
  doi text,
  fk_url_id numeric,
  isbn text,
  tipo text
);

CREATE OR REPLACE FUNCTION ae_add_biblio(
  id_documento numeric,
  id_referencia_bibliografica numeric,
  autores text,
  fecha date,
  titulo text,
  nombre_tipo text,
  paginas text,
  doi text,
  fk_url_id numeric,
  isbn text DEFAULT NULL,
  tipo text DEFAULT NULL
)
RETURNS numeric AS
$$
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
$$ LANGUAGE plpgsql;

-- SELECT ae_add_biblio(
--   66,
--   2,
--   'Javier y Javi',
--   now()::date,
--   NULL,
--   NULL,
--   NULL,
--   'http://geographica.gs',
--   36
-- );
