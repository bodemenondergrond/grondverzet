-- View: s_bodemenondergrond.vw_cal_gecodeerd_asstring

-- DROP VIEW s_bodemenondergrond.vw_cal_gecodeerd_asstring;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_cal_gecodeerd_asstring
 AS
 SELECT id,
    interpretatie_id,
    van,
    tot,
    lithologische_beschrijving
   FROM b_bodemenondergrond.cal_gecodeerd_asstring;

ALTER TABLE s_bodemenondergrond.vw_cal_gecodeerd_asstring
    OWNER TO datawarehouse_ddl;

GRANT ALL ON TABLE s_bodemenondergrond.vw_cal_gecodeerd_asstring TO datawarehouse_ddl;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE s_bodemenondergrond.vw_cal_gecodeerd_asstring TO datawarehouse_dml;
GRANT SELECT ON TABLE s_bodemenondergrond.vw_cal_gecodeerd_asstring TO datawarehouse_ro;

-- View: s_bodemenondergrond.vw_cal_lnk_monster

-- DROP VIEW s_bodemenondergrond.vw_cal_lnk_monster;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_cal_lnk_monster
 AS
 SELECT bodemsite_id,
    bodemsite_pk,
    bodemlocatie_id,
    bodemlocatie_pk,
    diepteinterval_id,
    diepteinterval_pk,
    monster_id,
    monster_pk,
    parenttype
   FROM b_bodemenondergrond.cal_lnk_monster;

ALTER TABLE s_bodemenondergrond.vw_cal_lnk_monster
    OWNER TO datawarehouse_ddl;

GRANT ALL ON TABLE s_bodemenondergrond.vw_cal_lnk_monster TO datawarehouse_ddl;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE s_bodemenondergrond.vw_cal_lnk_monster TO datawarehouse_dml;
GRANT SELECT ON TABLE s_bodemenondergrond.vw_cal_lnk_monster TO datawarehouse_ro;

-- View: s_bodemenondergrond.vw_cal_lnk_observatie

-- DROP VIEW s_bodemenondergrond.vw_cal_lnk_observatie;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_cal_lnk_observatie
 AS
 SELECT bodemsite_id,
    bodemsite_pk,
    bodemlocatie_id,
    bodemlocatie_pk,
    diepteinterval_id,
    diepteinterval_pk,
    monster_id,
    monster_pk,
    observatie_id,
    observatie_pk,
    parenttype,
    origin
   FROM b_bodemenondergrond.cal_lnk_observatie;

ALTER TABLE s_bodemenondergrond.vw_cal_lnk_observatie
    OWNER TO datawarehouse_ddl;

GRANT ALL ON TABLE s_bodemenondergrond.vw_cal_lnk_observatie TO datawarehouse_ddl;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE s_bodemenondergrond.vw_cal_lnk_observatie TO datawarehouse_dml;
GRANT SELECT ON TABLE s_bodemenondergrond.vw_cal_lnk_observatie TO datawarehouse_ro;

-- View: s_bodemenondergrond.vw_cal_proefsamenvatting

-- DROP VIEW s_bodemenondergrond.vw_cal_proefsamenvatting;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_cal_proefsamenvatting
 AS
 SELECT id,
    korrelverdeling,
    onderkenning,
    mechanische_proeven,
    steenkoolanalyse,
    chemische_analyse,
    laboproeven
   FROM b_bodemenondergrond.cal_proefsamenvatting;

ALTER TABLE s_bodemenondergrond.vw_cal_proefsamenvatting
    OWNER TO datawarehouse_ddl;

GRANT ALL ON TABLE s_bodemenondergrond.vw_cal_proefsamenvatting TO datawarehouse_ddl;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE s_bodemenondergrond.vw_cal_proefsamenvatting TO datawarehouse_dml;
GRANT SELECT ON TABLE s_bodemenondergrond.vw_cal_proefsamenvatting TO datawarehouse_ro;

-- View: s_bodemenondergrond.vw_cal_zoekcalculatedobservatie

-- DROP VIEW s_bodemenondergrond.vw_cal_zoekcalculatedobservatie;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_cal_zoekcalculatedobservatie
 AS
 SELECT id,
    vloeigrens,
    uitrolgrens,
    ip
   FROM b_bodemenondergrond.cal_zoekcalculatedobservatie;

ALTER TABLE s_bodemenondergrond.vw_cal_zoekcalculatedobservatie
    OWNER TO datawarehouse_ddl;

GRANT ALL ON TABLE s_bodemenondergrond.vw_cal_zoekcalculatedobservatie TO datawarehouse_ddl;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE s_bodemenondergrond.vw_cal_zoekcalculatedobservatie TO datawarehouse_dml;
GRANT SELECT ON TABLE s_bodemenondergrond.vw_cal_zoekcalculatedobservatie TO datawarehouse_ro;

