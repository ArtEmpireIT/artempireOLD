DROP FUNCTION IF EXISTS ae_add_anomalia_rel_resto_individuo(
  id_individuo_resto numeric,
  id_anomalias numeric[]
);
CREATE OR REPLACE FUNCTION ae_add_anomalia_rel_resto_individuo(
  id_individuo_resto numeric,
  id_anomalias numeric[]
)
RETURNS numeric as 
$$
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
$$ LANGUAGE plpgsql;