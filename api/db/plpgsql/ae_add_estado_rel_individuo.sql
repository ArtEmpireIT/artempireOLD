DROP FUNCTION IF EXISTS ae_add_estado_rel_individuo(
  id_individuo_resto numeric,
  estados json[]
);
CREATE OR REPLACE FUNCTION ae_add_estado_rel_individuo(
  id_individuo_resto numeric,
  estados json[]
)
RETURNS numeric as 
$$
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
$$ LANGUAGE plpgsql;
