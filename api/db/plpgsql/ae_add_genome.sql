DROP FUNCTION IF EXISTS ae_add_genome (
  id_wholegenome numeric,
  fk_sample_id numeric,
  successful text,
  overall_snps numeric,
  closes_pop text,
  overall_error numeric,
  contamination numeric,
  ctot_rate numeric,
  gtoa_rate numeric,
  ancest_origin text,
  reference_genome text,
  seq_strategy text,
  libraries_seq numeric,
  raw_reads numeric,
  mapped_reads numeric,
  duplicate numeric,
  molecular_sex text,
  gc_content numeric,
  whole_coverage numeric,
  mean_read_depth numeric,
  average_length numeric,
  updated_on text,
  comments text,
  interpretation text
);

CREATE OR REPLACE FUNCTION ae_add_genome (
  id_wholegenome numeric,
  fk_sample_id numeric,
  successful text,
  overall_snps numeric,
  closes_pop text,
  overall_error numeric,
  contamination numeric,
  ctot_rate numeric,
  gtoa_rate numeric,
  ancest_origin text,
  reference_genome text,
  seq_strategy text,
  libraries_seq numeric,
  raw_reads numeric,
  mapped_reads numeric,
  duplicate numeric,
  molecular_sex text,
  gc_content numeric,
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

  IF id_wholegenome IS NULL
  THEN
    _q := format('INSERT INTO wholegenome (
      fk_sample_id,
      successful,
      overall_snps,
      closes_pop,
      overall_error,
      contamination,
      ctot_rate,
      gtoa_rate,
      ancest_origin,
      reference_genome,
      seq_strategy,
      libraries_seq,
      raw_reads,
      mapped_reads,
      duplicate,
      molecular_sex,
      gc_content,
      whole_coverage,
      mean_read_depth,
      average_length,
      updated_on,
      comments,
      interpretation
      ) VALUES (
        %s, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L, %L,
        %L::date, %L, %L
      ) RETURNING id_wholegenome',
      fk_sample_id,
      successful,
      overall_snps,
      closes_pop,
      overall_error,
      contamination,
      ctot_rate,
      gtoa_rate,
      ancest_origin,
      reference_genome,
      seq_strategy,
      libraries_seq,
      raw_reads,
      mapped_reads,
      duplicate,
      molecular_sex,
      gc_content,
      whole_coverage,
      mean_read_depth,
      average_length,
      updated_on,
      comments,
      interpretation
    );
  ELSE
    _q := format('UPDATE wholegenome SET
      fk_sample_id = %s,
      successful = %L,
      overall_snps = %L,
      closes_pop = %L,
      overall_error = %L,
      contamination = %L,
      ctot_rate = %L,
      gtoa_rate = %L,
      ancest_origin = %L,
      reference_genome = %L,
      seq_strategy = %L,
      libraries_seq = %L,
      raw_reads = %L,
      mapped_reads = %L,
      duplicate = %L,
      molecular_sex = %L,
      gc_content = %L,
      whole_coverage = %L,
      mean_read_depth = %L,
      average_length = %L,
      updated_on = %L::date,
      comments = %L,
      interpretation = %L
      WHERE id_wholegenome = %s
      RETURNING *',
      fk_sample_id,
      successful,
      overall_snps,
      closes_pop,
      overall_error,
      contamination,
      ctot_rate,
      gtoa_rate,
      ancest_origin,
      reference_genome,
      seq_strategy,
      libraries_seq,
      raw_reads,
      mapped_reads,
      duplicate,
      molecular_sex,
      gc_content,
      whole_coverage,
      mean_read_depth,
      average_length,
      updated_on,
      comments,
      interpretation,
      id_wholegenome
    );
  END IF;
  EXECUTE _q INTO _r;

  RETURN _r.id_wholegenome;

END;
$$ LANGUAGE plpgsql;
