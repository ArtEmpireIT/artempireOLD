DROP FUNCTION IF EXISTS ae_add_bioapatite (
  id_bioapatite numeric,
  fk_sample_id numeric,
  sub_name text,
  distance_from_cervix numeric,
  sr_conc numeric,
  sr87_sr86 numeric,
  sr87_sr86_2sd numeric,
  ag4_po3_yield numeric,
  s18op numeric,
  s18op_1sd numeric,
  s18oc numeric,
  s18oc_1sd numeric,
  s13cc numeric,
  s13cc_1sd numeric,
  comments text,
  interpretation text
);

CREATE OR REPLACE FUNCTION ae_add_bioapatite (
  id_bioapatite numeric,
  fk_sample_id numeric,
  sub_name text,
  distance_from_cervix numeric,
  sr_conc numeric,
  sr87_sr86 numeric,
  sr87_sr86_2sd numeric,
  ag4_po3_yield numeric,
  s18op numeric,
  s18op_1sd numeric,
  s18oc numeric,
  s18oc_1sd numeric,
  s13cc numeric,
  s13cc_1sd numeric,
  comments text,
  interpretation text
)
RETURNS numeric as
$$
DECLARE
  _r record;
  _q text;
BEGIN

  IF id_bioapatite IS NULL
  THEN
    _q := format('INSERT INTO bioapatite (
        fk_sample_id,
        sub_name,
        distance_from_cervix,
        sr_conc,
        sr87_sr86,
        sr87_sr86_2sd,
        ag4_po3_yield,
        s18op,
        s18op_1sd,
        s18oc,
        s18oc_1sd,
        s13cc,
        s13cc_1sd,
        comments,
        interpretation
      ) VALUES (
        %s, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L
      ) RETURNING id_bioapatite',
      fk_sample_id,
      sub_name,
      distance_from_cervix,
      sr_conc,
      sr87_sr86,
      sr87_sr86_2sd,
      ag4_po3_yield,
      s18op,
      s18op_1sd,
      s18oc,
      s18oc_1sd,
      s13cc,
      s13cc_1sd,
      comments,
      interpretation
    );
  ELSE
    _q := format('UPDATE bioapatite SET fk_sample_id = %s,
        sub_name = %L,
        distance_from_cervix = %L,
        sr_conc = %L,
        sr87_sr86 = %L,
        sr87_sr86_2sd = %L,
        ag4_po3_yield = %L,
        s18op = %L,
        s18op_1sd = %L,
        s18oc = %L,
        s18oc_1sd = %L,
        s13cc = %L,
        s13cc_1sd = %L,
        comments = %L,
        interpretation = %L
      WHERE id_bioapatite = %s 
      RETURNING *',
      fk_sample_id,
      sub_name,
      distance_from_cervix,
      sr_conc,
      sr87_sr86,
      sr87_sr86_2sd,
      ag4_po3_yield,
      s18op,
      s18op_1sd,
      s18oc,
      s18oc_1sd,
      s13cc,
      s13cc_1sd,
      comments,
      interpretation,
      id_bioapatite
    );
  END IF;
  EXECUTE _q INTO _r;

  RETURN id_bioapatite;

END;
$$ LANGUAGE plpgsql;

