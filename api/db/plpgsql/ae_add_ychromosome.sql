DROP FUNCTION IF EXISTS ae_add_ychromosome (
  id_ychromosome numeric,
  fk_sample_id numeric,
  successful text,
  snps_hit numeric,
  class_method text,
  haplogroup text,
  superhaplo text,
  haplo_ancest_origin text,
  possible_pat_relat text,
  seq_strategy text,
  libraries_seq numeric,
  raw_reads numeric,
  mapped_reads numeric,
  whole_coverage numeric,
  mean_read_depth numeric,
  average_length numeric,
  updated_on text,
  comments text,
  interpretation text
);

CREATE OR REPLACE FUNCTION ae_add_ychromosome (
  id_ychromosome numeric,
  fk_sample_id numeric,
  successful text,
  snps_hit numeric,
  class_method text,
  haplogroup text,
  superhaplo text,
  haplo_ancest_origin text,
  possible_pat_relat text,
  seq_strategy text,
  libraries_seq numeric,
  raw_reads numeric,
  mapped_reads numeric,
  whole_coverage numeric,
  mean_read_depth numeric,
  average_length numeric,
  updated_on text,
  comments text,
  interpretation text
)
RETURNS numeric as
$$
DECLARE
  _r record;
  _q text;
BEGIN

  IF id_ychromosome IS NULL
  THEN
    _q := format('INSERT INTO ychromosome (
      fk_sample_id,
      successful,
      snps_hit,
      class_method,
      haplogroup,
      superhaplo,
      haplo_ancest_origin,
      possible_pat_relat,
      seq_strategy,
      libraries_seq,
      raw_reads,
      mapped_reads,
      whole_coverage,
      mean_read_depth,
      average_length,
      updated_on,
      comments,
      interpretation
      ) VALUES (
        %s, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L,
        %L::date, %L, %L
      ) RETURNING id_ychromosome',
      fk_sample_id,
      successful,
      snps_hit,
      class_method,
      haplogroup,
      superhaplo,
      haplo_ancest_origin,
      possible_pat_relat,
      seq_strategy,
      libraries_seq,
      raw_reads,
      mapped_reads,
      whole_coverage,
      mean_read_depth,
      average_length,
      updated_on,
      comments,
      interpretation
    );
  ELSE
    _q := format('UPDATE ychromosome SET
      fk_sample_id = %s,
      successful = %L,
      snps_hit = %L,
      class_method = %L,
      haplogroup = %L,
      superhaplo = %L,
      haplo_ancest_origin = %L,
      possible_pat_relat = %L,
      seq_strategy = %L,
      libraries_seq = %L,
      raw_reads = %L,
      mapped_reads = %L,
      whole_coverage = %L,
      mean_read_depth = %L,
      average_length = %L,
      updated_on = %L::date,
      comments = %L,
      interpretation = %L
      WHERE id_ychromosome = %s
      RETURNING *',
      fk_sample_id,
      successful,
      snps_hit,
      class_method,
      haplogroup,
      superhaplo,
      haplo_ancest_origin,
      possible_pat_relat,
      seq_strategy,
      libraries_seq,
      raw_reads,
      mapped_reads,
      whole_coverage,
      mean_read_depth,
      average_length,
      updated_on,
      comments,
      interpretation,
      id_ychromosome
    );
  END IF;
  EXECUTE _q INTO _r;

  RETURN _r.id_ychromosome;

END;
$$ LANGUAGE plpgsql;
