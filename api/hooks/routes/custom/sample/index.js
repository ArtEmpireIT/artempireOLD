'use strict';
const express = require('express');
const router = express.Router();
const db = require('../../../../config/db');
const {bodyParse, parseJWT} = require('../../../../utils/middlewares');

const queryResponse = (req, res, query) => {
  return db.query(query)
  .then(data => {
    res.status(200).send(data[0]);
  })
  .catch(error => {
    console.log(error);
    res.status(500).send([error]);
  });
}

router.get('/materials', (req, res) => {
  const query = 'SELECT * FROM material_sample;';
  queryResponse(req, res, query);
})

router.get('/:id/bioapatite', (req, res) => {
  const id = req.params.id;
  if(isNaN(parseInt(id, 10))) {
    res.status(400).json({
      ok: false,
      error: 'Invalid parameter. id must be a number'
    });
    return;
  }
  const query = `
    SELECT * FROM bioapatite
    WHERE fk_sample_id = ${id}
  `;
  queryResponse(req, res, query);
})

router.post('/:id/bioapatite', bodyParse, (req, res) => {
  const id = req.params.id;
  if(isNaN(parseInt(id, 10))) {
    res.status(400).json({
      ok: false,
      error: 'Invalid parameter. id must be a number'
    });
    return;
  }

  const query = `SELECT ae_add_bioapatite(
    ${req.body.id_bioapatite},
    ${req.body.fk_sample_id},
    ${req.body.sub_name},
    ${req.body.distance_from_cervix},
    ${req.body.sr_conc},
    ${req.body.sr87_sr86},
    ${req.body.sr87_sr86_2sd},
    ${req.body.ag4_po3_yield},
    ${req.body.s18op},
    ${req.body.s18op_1sd},
    ${req.body.s18oc},
    ${req.body.s18oc_1sd},
    ${req.body.s13cc},
    ${req.body.s13cc_1sd},
    ${req.body.comments},
    ${req.body.interpretation}
  )`;

  db.query(query)
  .then(data => {
    res.status(200).send(data[0] && data[0][0]);
  })
  .catch(error => {
    console.log(error);
    res.status(500).send([error]);
  });
})

router.delete('/:id_sample/bioapatite/:id', (req, res) => {
  const id = req.params.id;
  if(isNaN(parseInt(id, 10))) {
    res.status(400).json({
      ok: false,
      error: 'Invalid parameter. id must be a number'
    });
    return;
  }

  const query = `DELETE FROM bioapatite WHERE id_bioapatite = ${id}`;
  queryResponse(req, res, query);
})

router.get('/:id/collagens', (req, res) => {
  const id = req.params.id;
  if(isNaN(parseInt(id, 10))) {
    res.status(400).json({
      ok: false,
      error: 'Invalid parameter. id must be a number'
    });
    return;
  }
  const query = `
    SELECT * FROM collagen
    WHERE fk_sample_id = ${id}
  `;
  queryResponse(req, res, query);
})

router.post('/:id/collagen', bodyParse, (req, res) => {
  const id = req.params.id;
  if(isNaN(parseInt(id, 10))) {
    res.status(400).json({
      ok: false,
      error: 'Invalid parameter. id must be a number'
    });
    return;
  }

  const query = `SELECT ae_add_collagen(
    ${req.body.id_collagen},
    ${req.body.fk_sample_id},
    ${req.body.sub_name},
    ${req.body.distance_from_cervix},
    ${req.body.collagen_yield},
    ${req.body.cp},
    ${req.body.cp_1sd},
    ${req.body.np},
    ${req.body.np_1sd},
    ${req.body.atomic_cn_ratio},
    ${req.body.s13_ccoll},
    ${req.body.s13_ccoll_1sd},
    ${req.body.s15_ncoll},
    ${req.body.s15_ncoll_1sd},
    ${req.body.quality_criteria},
    ${req.body.quality_comment},
    ${req.body.interpretation},
    ${req.body.comments}
  )`;

  db.query(query)
  .then(data => {
    res.status(200).send(data[0] && data[0][0]);
  })
  .catch(error => {
    console.log(error);
    res.status(500).send([error]);
  });
})

router.delete('/collagen/:id', (req, res) => {
  const id = req.params.id;
  if(isNaN(parseInt(id, 10))) {
    res.status(400).json({
      ok: false,
      error: 'Invalid parameter. id must be a number'
    });
    return;
  }

  const query = `DELETE FROM collagen WHERE id_collagen = ${id}`;
  queryResponse(req, res, query);
})

router.get('/', parseJWT, (req, res) => {
  // const { access_archeology } = (req.user || {});
  const secretQuery = req.user ? '' : 'AND COALESCE(s.confidencial, FALSE) = FALSE ';
  const query = `
    SELECT s.name as name,
      s.id_muestra as id,
      r.variable as remain_variable,
      r.nombre as remain_name_spanish,
      r.traduccion as remain_name_english,
      ir.fk_especie_nombre as especies_spanish,
      esp.english as especies_english,
      e.id_entierro as excavation_id,
      e.nomenclatura_sitio as excavation_papv,
      e.lugar as excavation_place,
      ia.id_individuo_arqueologico as indiv_arqueo_id,
      ia.unid_estratigrafica as indiv_arqueo_name
    FROM sample s
    JOIN individuo_resto ir ON s.fk_individuo_resto_id = ir.id_individuo_resto
    LEFT JOIN especie esp ON ir.fk_especie_nombre = esp.nombre
    JOIN resto r ON ir.fk_resto_variable = r.variable
    JOIN individuo_arqueologico ia ON ir.fk_individuo_arqueologico_id = ia.id_individuo_arqueologico
    JOIN entierro e ON e.id_entierro = ia.fk_entierro
    WHERE type='${req.query.type}' ${secretQuery}
  `;
  queryResponse(req, res, query);
})

router.get('/:id', (req, res) => {
  const id = req.params.id;
  if(isNaN(parseInt(id, 10))) {
    res.status(400).json({
      ok: false,
      error: 'Invalid parameter. id must be a number'
    });
    return;
  }
  const query = `
    SELECT s.*,
      r.nombre as remain_name_spanish,
      r.traduccion as remain_name_english,
      ir.fk_especie_nombre as especies_spanish,
      esp.english as especies_english,
      e.id_entierro as excavation_id,
      e.nomenclatura_sitio as excavation_papv,
      e.lugar as excavation_place,
      ia.id_individuo_arqueologico as indiv_arqueo_id,
      ia.unid_estratigrafica as indiv_arqueo_name,
      sm.fk_material_sample_material as material,
      to_json(rc) as radiocarbon
    FROM sample s
    JOIN individuo_resto ir ON s.fk_individuo_resto_id = ir.id_individuo_resto
    LEFT JOIN especie esp ON ir.fk_especie_nombre = esp.nombre
    JOIN resto r ON ir.fk_resto_variable = r.variable
    JOIN individuo_arqueologico ia ON ir.fk_individuo_arqueologico_id = ia.id_individuo_arqueologico
    LEFT JOIN radiocarbon_dating rc ON ia.fk_radiocarbon_dating_id = rc.id_radiocarbon_dating
    LEFT JOIN sample_rel_material_sample sm ON sm.fk_sample_id = s.id_muestra
    JOIN entierro e ON e.id_entierro = ia.fk_entierro
    WHERE s.id_muestra = ${id};
  `;
  db.query(query)
  .then(data => {
    res.status(200).send(data[0] && data[0][0]);
  })
  .catch(error => {
    console.log(error);
    res.status(500).send([error]);
  });
})

router.post('/:id', bodyParse, (req, res) => {
  const query = `SELECT ae_add_sample(
    ${req.body.id_muestra},
    ${req.body.name},
    ${req.body.ma_number},
    ${req.body.date},
    ${req.body.surface},
    ${req.body.overall_preservation},
    ${req.body.recorder},
    ${req.body.crown_height},
    ${req.body.tooth_abrasion},
    ${req.body.state},
    ${req.body.color},
    ${req.body.consistency},
    ${req.body.microcracks},
    ${req.body.sediment_particles},
    ${req.body.comments},

    ${req.body.fk_individuo_resto_id},
    ${req.body.material},
    '${JSON.stringify(req.body.radiocarbon).replace(/\$string\$/g, '').replace(/'/g, '')}',
    ${req.body.indiv_arqueo_id},
    ${Boolean(req.body.confidencial)}
  )`;
  db.query(query)
  .then(data => {
    res.status(200).send(data[0] && data[0][0]);
  })
  .catch(error => {
    console.log(error);
    res.status(500).send([error]);
  });
})

router.post('/adn/:id', bodyParse, (req, res) => {
  const query = `SELECT ae_add_adn_sample(
    ${req.body.id_muestra},
    ${req.body.name},
    ${req.body.unipv_number},
    ${req.body.date},
    ${req.body.successful},
    ${req.body.surface},
    ${req.body.overall_preservation},
    ${req.body.recorder},
    ${req.body.powder_weigth},
    ${req.body.extraction_method},
    ${req.body.concentration},
    ${req.body.ratio},
    ${req.body.volume},
    ${req.body.residual_volume},
    ${req.body.extraction_place},
    ${req.body.storage_loc},
    ${req.body.people_cont},
    ${req.body.library_ava},
    ${req.body.comments},
    ${req.body.fk_individuo_resto_id},
    ${Boolean(req.body.confidencial)}
  )`;
  db.query(query)
  .then(data => {
    res.status(200).send(data[0] && data[0][0]);
  })
  .catch(error => {
    console.log(error);
    res.status(500).send([error]);
  });
})

router.delete('/:id', (req, res) => {
  const id = req.params.id;
  if(isNaN(parseInt(id, 10))) {
    res.status(400).json({
      ok: false,
      error: 'Invalid parameter: id must be a number'
    });
    return;
  }
  const query = `DELETE FROM sample WHERE id_muestra = ${id}`;
  queryResponse(req, res, query);
})

router.get('/:id/mtdna', (req, res) => {
  const id = req.params.id;
  if(isNaN(parseInt(id, 10))) {
    res.status(400).json({
      ok: false,
      error: 'Invalid parameter. id must be a number'
    });
    return;
  }
  const query = `
    SELECT * FROM mtdna
    WHERE fk_sample_id = ${id} ORDER BY id_mtdna
  `;
  queryResponse(req, res, query);
})

router.post('/:id/mtdna', bodyParse, (req, res) => {
  const id = req.params.id;
  if(isNaN(parseInt(id, 10))) {
    res.status(400).json({
      ok: false,
      error: 'Invalid parameter. id must be a number'
    });
    return;
  }

  const query = `SELECT ae_add_mtdna(
    ${req.body.id_mtdna},
    ${req.body.fk_sample_id},
    ${req.body.successful},
    ${req.body.haplo_vs_rcrs},
    ${req.body.seq_range},
    ${req.body.class_method},
    ${req.body.haplogroup},
    ${req.body.overall_rank},
    ${req.body.superhaplo},
    ${req.body.haplo_ancest_origin},
    ${req.body.expect_not_fd_polys},
    ${req.body.private_polys},
    ${req.body.heteroplasmies},
    ${req.body.alter_haplo},
    ${req.body.fasta},
    ${req.body.bam_file},
    ${req.body.vcf_file},
    ${req.body.possible_mat_relat},
    ${req.body.seq_strategy},
    ${req.body.libraries_seq},
    ${req.body.raw_reads},
    ${req.body.mapped_reads},
    ${req.body.whole_coverage},
    ${req.body.mean_read_depth},
    ${req.body.fraction},
    ${req.body.average_length},
    ${req.body.contamination},
    ${req.body.updated_on},
    ${req.body.comments},
    ${req.body.interpretation}
  )`;

  db.query(query)
  .then(data => {
    res.status(200).send(data[0] && data[0][0]);
  })
  .catch(error => {
    console.log(error);
    res.status(500).send([error]);
  });
})

router.delete('/mtdna/:id', (req, res) => {
  const id = req.params.id;
  if(isNaN(parseInt(id, 10))) {
    res.status(400).json({
      ok: false,
      error: 'Invalid parameter. id must be a number'
    });
    return;
  }

  const query = `DELETE FROM mtdna WHERE id_mtdna = ${id}`;
  queryResponse(req, res, query);
})

router.get('/:id/ychromosome', (req, res) => {
  const id = req.params.id;
  if(isNaN(parseInt(id, 10))) {
    res.status(400).json({
      ok: false,
      error: 'Invalid parameter. id must be a number'
    });
    return;
  }
  const query = `
    SELECT * FROM ychromosome
    WHERE fk_sample_id = ${id} ORDER BY id_ychromosome
  `;
  queryResponse(req, res, query);
})

router.post('/:id/ychromosome', bodyParse, (req, res) => {
  const id = req.params.id;
  if(isNaN(parseInt(id, 10))) {
    res.status(400).json({
      ok: false,
      error: 'Invalid parameter. id must be a number'
    });
    return;
  }

  const query = `SELECT ae_add_ychromosome(
    ${req.body.id_ychromosome},
    ${req.body.fk_sample_id},
    ${req.body.successful},
    ${req.body.snps_hit},
    ${req.body.class_method},
    ${req.body.haplogroup},
    ${req.body.superhaplo},
    ${req.body.haplo_ancest_origin},
    ${req.body.possible_pat_relat},
    ${req.body.seq_strategy},
    ${req.body.libraries_seq},
    ${req.body.raw_reads},
    ${req.body.mapped_reads},
    ${req.body.whole_coverage},
    ${req.body.mean_read_depth},
    ${req.body.average_length},
    ${req.body.updated_on},
    ${req.body.comments},
    ${req.body.interpretation}
  )`;

  db.query(query)
  .then(data => {
    res.status(200).send(data[0] && data[0][0]);
  })
  .catch(error => {
    console.log(error);
    res.status(500).send([error]);
  });
})

router.delete('/ychromosome/:id', (req, res) => {
  const id = req.params.id;
  if(isNaN(parseInt(id, 10))) {
    res.status(400).json({
      ok: false,
      error: 'Invalid parameter. id must be a number'
    });
    return;
  }

  const query = `DELETE FROM ychromosome WHERE id_ychromosome = ${id}`;
  queryResponse(req, res, query);
})

router.get('/:id/genome', (req, res) => {
  const id = req.params.id;
  if(isNaN(parseInt(id, 10))) {
    res.status(400).json({
      ok: false,
      error: 'Invalid parameter. id must be a number'
    });
    return;
  }
  const query = `
    SELECT * FROM wholegenome
    WHERE fk_sample_id = ${id} ORDER BY id_wholegenome
  `;
  queryResponse(req, res, query);
})

router.post('/:id/genome', bodyParse, (req, res) => {
  const id = req.params.id;
  if(isNaN(parseInt(id, 10))) {
    res.status(400).json({
      ok: false,
      error: 'Invalid parameter. id must be a number'
    });
    return;
  }

  const query = `SELECT ae_add_genome(
    ${req.body.id_wholegenome},
    ${req.body.fk_sample_id},
    ${req.body.successful},
    ${req.body.overall_snps},
    ${req.body.closes_pop},
    ${req.body.overall_error},
    ${req.body.contamination},
    ${req.body.ctot_rate},
    ${req.body.gtoa_rate},
    ${req.body.ancest_origin},
    ${req.body.reference_genome},
    ${req.body.seq_strategy},
    ${req.body.libraries_seq},
    ${req.body.raw_reads},
    ${req.body.mapped_reads},
    ${req.body.duplicate},
    ${req.body.molecular_sex},
    ${req.body.gc_content},
    ${req.body.whole_coverage},
    ${req.body.mean_read_depth},
    ${req.body.average_length},
    ${req.body.updated_on},
    ${req.body.comments},
    ${req.body.interpretation}
  )`;

  db.query(query)
  .then(data => {
    res.status(200).send(data[0] && data[0][0]);
  })
  .catch(error => {
    console.log(error);
    res.status(500).send([error]);
  });
})

router.delete('/genome/:id', (req, res) => {
  const id = req.params.id;
  if(isNaN(parseInt(id, 10))) {
    res.status(400).json({
      ok: false,
      error: 'Invalid parameter. id must be a number'
    });
    return;
  }

  const query = `DELETE FROM wholegenome WHERE id_wholegenome = ${id}`;
  queryResponse(req, res, query);
})

module.exports = router;
