DROP FUNCTION IF EXISTS ae_add_inventario_bienes(id_document numeric, owner json[], notary json[]);

CREATE OR REPLACE FUNCTION ae_add_inventario_bienes(
  id_document numeric,
  owner json[],
  notary json[]
)
RETURNS numeric AS
$$
DECLARE

  _r record;
  _q text;
  _aux json;

BEGIN

  PERFORM ae_add_person_batch(id_document, 'Propietario'::text, owner::jsonb[]);
  PERFORM ae_add_person_batch(id_document, 'Escribano'::text, notary::jsonb[]);

  RETURN id_document;

END;
$$ LANGUAGE plpgsql;
