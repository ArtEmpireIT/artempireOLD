DROP FUNCTION IF EXISTS ae_add_collagen (
  id_collagen numeric,
  fk_sample_id numeric,
  sub_name text,
  distance_from_cervix numeric,
  collagen_yield numeric,
  cp numeric,
  cp_1sd numeric,
  np numeric,
  np_1sd numeric,
  atomic_cn_ratio numeric,
  s13_ccoll numeric,
  s13_ccoll_1sd numeric,
  s15_ncoll numeric,
  s15_ncoll_1sd numeric,
  quality_criteria text,
  quality_comment text,
  interpretation text,
  comments text
);

CREATE OR REPLACE FUNCTION ae_add_collagen (
  id_collagen numeric,
  fk_sample_id numeric,
  sub_name text,
  distance_from_cervix numeric,
  collagen_yield numeric,
  cp numeric,
  cp_1sd numeric,
  np numeric,
  np_1sd numeric,
  atomic_cn_ratio numeric,
  s13_ccoll numeric,
  s13_ccoll_1sd numeric,
  s15_ncoll numeric,
  s15_ncoll_1sd numeric,
  quality_criteria text,
  quality_comment text,
  interpretation text,
  comments text
)
RETURNS numeric as
$$
DECLARE
  _r record;
  _q text;
BEGIN

  IF id_collagen IS NULL
  THEN
    _q := format('INSERT INTO collagen (
        fk_sample_id,
        sub_name,
        distance_from_cervix,
        collagen_yield,
        cp,
        cp_1sd,
        np,
        np_1sd,
        atomic_cn_ratio,
        s13_ccoll,
        s13_ccoll_1sd,
        s15_ncoll,
        s15_ncoll_1sd,
        quality_criteria,
        quality_comment,
        comments,
        interpretation
      ) VALUES (
        %s, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L
      ) RETURNING id_collagen',
      fk_sample_id,
      sub_name,
      distance_from_cervix,
      collagen_yield,
      cp,
      cp_1sd,
      np,
      np_1sd,
      atomic_cn_ratio,
      s13_ccoll,
      s13_ccoll_1sd,
      s15_ncoll,
      s15_ncoll_1sd,
      quality_criteria,
      quality_comment,
      comments,
      interpretation
    );
  ELSE
    _q := format('UPDATE collagen SET fk_sample_id = %s,
        sub_name = %L,
        distance_from_cervix = %L,
        collagen_yield = %L,
        cp = %L,
        cp_1sd = %L,
        np = %L,
        np_1sd = %L,
        atomic_cn_ratio = %L,
        s13_ccoll = %L,
        s13_ccoll_1sd = %L,
        s15_ncoll = %L,
        s15_ncoll_1sd = %L,
        quality_criteria = %L,
        quality_comment = %L,
        comments = %L,
        interpretation = %L
      WHERE id_collagen = %s 
      RETURNING *',
      fk_sample_id,
      sub_name,
      distance_from_cervix,
      collagen_yield,
      cp,
      cp_1sd,
      np,
      np_1sd,
      atomic_cn_ratio,
      s13_ccoll,
      s13_ccoll_1sd,
      s15_ncoll,
      s15_ncoll_1sd,
      quality_criteria,
      quality_comment,
      comments,
      interpretation,
      id_collagen
    );
  END IF;
  EXECUTE _q INTO _r;

  RETURN id_collagen;

END;
$$ LANGUAGE plpgsql;

