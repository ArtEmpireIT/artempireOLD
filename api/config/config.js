'use strict';

const cfg = {
  port: process.env.PORT || 9000,
  pguser: process.env.PGUSER || 'postgres',
  pgpass: process.env.PGPASS || 'postgres',
  pghost: process.env.PGHOST || 'postgis',
  pgname: process.env.PGNAME || 'artempire',
  pgport: process.env.PGPORT || 5432,
  apiversion: 'v1',
  uploads: process.env.UPLOADS || '/uploads',
  secret: process.env.SECRET || 'ae_jwt_default_shecret'
}
cfg.pgstring = 'postgres://' + cfg.pguser + ':' + cfg.pgpass + '@' + cfg.pghost + ':' + cfg.pgport + '/' + cfg.pgname;

module.exports = cfg;

