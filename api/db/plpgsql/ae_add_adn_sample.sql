DROP FUNCTION IF EXISTS ae_add_adn_sample (
  id_muestra numeric,
  name text,
  unipv_number numeric,
  date date,
  successful text,
  surface text,
  overall_preservation text,
  recorder text,
  powder_weigth numeric,
  extraction_method text,
  concentration numeric,
  ratio numeric,
  volume numeric,
  residual_volume numeric,
  extraction_place text,
  storage_loc text,
  people_cont text,
  library_ava numeric,
  comments text,
  fk_individuo_resto_id numeric
);
DROP FUNCTION IF EXISTS ae_add_adn_sample (
  id_muestra numeric,
  name text,
  unipv_number numeric,
  date date,
  successful text,
  surface text,
  overall_preservation text,
  recorder text,
  powder_weigth numeric,
  extraction_method text,
  concentration numeric,
  ratio numeric,
  volume numeric,
  residual_volume numeric,
  extraction_place text,
  storage_loc text,
  people_cont text,
  library_ava numeric,
  comments text,
  fk_individuo_resto_id numeric,
  confidencial boolean
);

CREATE OR REPLACE FUNCTION ae_add_adn_sample (
  id_muestra numeric,
  name text,
  unipv_number text,
  date date,
  successful text,
  surface text,
  overall_preservation text,
  recorder text,
  powder_weigth numeric,
  extraction_method text,
  concentration numeric,
  ratio numeric,
  volume numeric,
  residual_volume numeric,
  extraction_place text,
  storage_loc text,
  people_cont text,
  library_ava numeric,
  comments text,
  fk_individuo_resto_id numeric,
  confidencial boolean
)
RETURNS numeric as
$$
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
$$ LANGUAGE plpgsql;
