DROP fuNCTION IF EXISTS ae_add_individuo_resto(
  numeric, text, text, numeric, numeric, json[]
);
DROP fuNCTION IF EXISTS ae_add_individuo_resto(
  numeric, text, text, numeric, numeric, text[]
);
DROP fuNCTION IF EXISTS ae_add_individuo_resto(
  numeric, text, text, numeric, numeric, numeric[]
);

CREATE OR REPLACE FUNCTION ae_add_individuo_resto (
  id_individuo_resto numeric, -- PK: individuo_resto - id
  fk_resto_variable text, -- FK: resto - variable    
  fk_especie_nombre text, -- FK: especie - nombre
  fk_individuo_arqueologico_id numeric, -- FK: individuo_arqueologico - id
  numero numeric,
  anomalias text[] -- FKS: individuo_resto <-> anomalia
)
RETURNS json AS
$BODY$
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
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION ae_add_individuo_resto(numeric, text, text, numeric, numeric, text[])
  OWNER TO geographica;