DROP FUNCTION IF EXISTS ae_add_sample (
  id_muestra numeric,
  name text,
  ma_number numeric,
  date date,
  surface text,
  overall_preservation text,
  recorder text,
  crown_height numeric,
  tooth_abrasion text,
  state text,
  color text,
  consistency text,
  microcracks text,
  sediment_particles text,
  comments text,

  fk_individuo_resto_id numeric,
  material text,
  radiocarbon json,
  id_individuo_arqeuologico numeric
);
DROP FUNCTION IF EXISTS ae_add_sample (
  id_muestra numeric,
  name text,
  ma_number numeric,
  date date,
  surface text,
  overall_preservation text,
  recorder text,
  crown_height numeric,
  tooth_abrasion text,
  state text,
  color text,
  consistency text,
  microcracks text,
  sediment_particles text,
  comments text,

  fk_individuo_resto_id numeric,
  material text,
  radiocarbon json,
  id_individuo_arqeuologico numeric,
  confidencial boolean
);

CREATE OR REPLACE FUNCTION ae_add_sample (
  id_muestra numeric,
  name text,
  ma_number numeric,
  date date,
  surface text,
  overall_preservation text,
  recorder text,
  crown_height numeric,
  tooth_abrasion text,
  state text,
  color text,
  consistency text,
  microcracks text,
  sediment_particles text,
  comments text,

  fk_individuo_resto_id numeric,
  material text,
  radiocarbon json,
  id_individuo_arqeuologico numeric,
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
$$ LANGUAGE plpgsql;
