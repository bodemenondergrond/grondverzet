-- View: s_bodemenondergrond.vw_num_results_from_observations

-- DROP VIEW s_bodemenondergrond.vw_num_results_from_observations;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_num_results_from_observations
 AS
 SELECT 'result:obs'::text || lip.permkey AS "@id",
    'sosa:Result'::text AS "@type",
    'obs:'::text || lip.permkey AS "isResultOf",
    to2.meetwaarde_num AS "rdf:value",
    ''::text AS "sdmx-attribute:unitMeasure"
   FROM b_bodemenondergrond.tbl_observatie to2
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = to2.id AND lip.type = 'OBSERVATIE'::text AND lip.state = 'A'::text
     JOIN b_bodemenondergrond.lut_parameter lp ON lp.id = to2.parameter
  WHERE to2.parent_permkey IS NOT NULL AND to2.meetwaarde_num IS NOT NULL;

ALTER TABLE s_bodemenondergrond.vw_num_results_from_observations
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_obs_prop_from_observations

-- DROP VIEW s_bodemenondergrond.vw_obs_prop_from_observations;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_obs_prop_from_observations
 AS
 SELECT 'obs_prop:obs'::text || lip.permkey AS "@id",
    'sosa:ObservableProperty'::text AS "@type",
    'cl-par:'::text || lower(lp.korte_naam) AS "dcterms:subject",
    'result:sam'::text || to2.parent_permkey AS "ssn:isPropertyOf"
   FROM b_bodemenondergrond.tbl_observatie to2
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = to2.id AND lip.type = 'OBSERVATIE'::text AND lip.state = 'A'::text
     JOIN b_bodemenondergrond.lut_parameter lp ON lp.id = to2.parameter
  WHERE to2.parent_permkey IS NOT NULL;

ALTER TABLE s_bodemenondergrond.vw_obs_prop_from_observations
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_obs_prop_geometrie

-- DROP VIEW s_bodemenondergrond.vw_obs_prop_geometrie;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_obs_prop_geometrie
 AS
 SELECT 'obs_prop:geometrie_boorgat'::text || lip.permkey AS "@id",
    'sosa:ObservableProperty'::text AS "@type",
    'prop:geometrie'::text AS subject,
    'boorgat:boorgat'::text || lip.permkey AS "isPropertyOf"
   FROM b_bodemenondergrond.tbl_boring tb
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = tb.dov_boring_id AND lip.type = 'BORING'::text AND lip.state = 'A'::text;

ALTER TABLE s_bodemenondergrond.vw_obs_prop_geometrie
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_observation

-- DROP VIEW s_bodemenondergrond.vw_observation;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_observation
 AS
 WITH obs_beh AS (
         SELECT DISTINCT tob.observatie
           FROM b_bodemenondergrond.tbl_observatie_behandeling tob
        ), monster_beh AS (
         SELECT DISTINCT perm.permkey
           FROM b_bodemenondergrond.tbl_monster_behandeling tmb
             JOIN b_bodemenondergrond.lnk_id_permkey perm ON perm.id = tmb.id AND perm.type = 'MONSTER'::text AND perm.state = 'A'::text
          WHERE tmb.behandeling <> 'M_MVD'::text
        )
 SELECT 'obs:'::text || lip.permkey AS "@id",
    'sosa:Observation'::text AS "@type",
    'result:obs'::text || lip.permkey AS "hasResult",
    'cl-opt:'::text || to2.analysemethode AS "usedProcedure",
    COALESCE(to2.datum_analyse, to2.fenomeentijd) AS "resultTime",
    COALESCE(to2.fenomeentijd, to2.datum_analyse) AS "phenomenonTime",
    'agent:organisatie'::text || tu.organisatie_id AS "madeBySensor",
        CASE
            WHEN obs_beh.observatie IS NOT NULL THEN (('result:deltasam'::text || to2.parent_permkey) || '-obs'::text) || lip.permkey
            WHEN monster_beh.permkey IS NOT NULL THEN 'result:deltasam'::text || to2.parent_permkey
            ELSE 'result:sam'::text || to2.parent_permkey
        END AS "hasFeatureOfInterest",
    'her:obs2022-6907912'::text AS "prov:atLocation"
   FROM b_bodemenondergrond.tbl_observatie to2
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON to2.id = lip.id AND lip.type = 'OBSERVATIE'::text AND lip.state = 'A'::text
     LEFT JOIN obs_beh ON obs_beh.observatie = to2.id
     LEFT JOIN monster_beh ON monster_beh.permkey = to2.parent_permkey
     LEFT JOIN b_bodemenondergrond.tbl_uitvoerder tu ON to2.uitvoerder = tu.uitvoerder_id
  WHERE to2.parent_permkey IS NOT NULL;

ALTER TABLE s_bodemenondergrond.vw_observation
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_observation_sample_materiaalklasse

-- DROP VIEW s_bodemenondergrond.vw_observation_sample_materiaalklasse;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_observation_sample_materiaalklasse
 AS
 SELECT ('obs:sam'::text || lip.permkey) || '-materiaalklasse'::text AS "@id",
    'sosa:Observation'::text AS "@type",
    tm.materiaalklasse AS "hasResult",
    COALESCE(tm.datum_monstername, tb.datum_aanvang) AS "resultTime",
    'obs_prop:materiaalklasse-sam'::text || lip.permkey AS "observedProperty",
    'agent:organisatie'::text || tu.organisatie_id AS "madeBySensor",
    'cl-bpt:bepaling_materiaalklasse'::text AS "usedProcedure",
    'opdracht:'::text || lip2.permkey AS "prov:wasStartedBy",
    'result:sam'::text || lip.permkey AS "hasFeatureOfInterest"
   FROM b_bodemenondergrond.tbl_monster tm
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = tm.id AND lip.type = 'MONSTER'::text AND lip.state = 'A'::text
     JOIN b_bodemenondergrond.lnk_monster_opdracht lmo ON lmo.monster_id = tm.id
     JOIN b_bodemenondergrond.tbl_opdracht to2 ON lmo.opdracht_id = to2.opdracht_id
     JOIN b_bodemenondergrond.lnk_id_permkey lip2 ON lip2.id = to2.opdracht_id AND lip2.type = 'OPDRACHT'::text AND lip.state = 'A'::text
     JOIN b_bodemenondergrond.lnk_id_permkey lip3 ON lip3.permkey = tm.parent_permkey AND lip3.type = 'BORING'::text AND tm.parent_type = 'BORING'::text AND lip.state = 'A'::text
     JOIN b_bodemenondergrond.tbl_boring tb ON tb.dov_boring_id = lip3.id
     LEFT JOIN b_bodemenondergrond.tbl_uitvoerder tu ON COALESCE(tm.monstername_door, tb.uitvoerder) = tu.uitvoerder_id;

ALTER TABLE s_bodemenondergrond.vw_observation_sample_materiaalklasse
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_observation_sample_monstersamenstelling

-- DROP VIEW s_bodemenondergrond.vw_observation_sample_monstersamenstelling;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_observation_sample_monstersamenstelling
 AS
 SELECT ('obs:sam'::text || lip.permkey) || '-monstersamenstelling'::text AS "@id",
    'sosa:Observation'::text AS "@type",
    lower(tm.monstersamenstelling) AS "hasSimpleResult",
    'obs_prop:monstersamenstelling-sam'::text || lip.permkey AS "observedProperty",
    'agent:organisatie'::text || tu.organisatie_id AS "madeBySensor",
    'result:sam'::text || lip.permkey AS "hasFeatureOfInterest"
   FROM b_bodemenondergrond.tbl_monster tm
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = tm.id AND lip.type = 'MONSTER'::text AND lip.state = 'A'::text
     JOIN b_bodemenondergrond.lnk_monster_opdracht lmo ON lmo.monster_id = tm.id
     JOIN b_bodemenondergrond.tbl_opdracht to2 ON lmo.opdracht_id = to2.opdracht_id
     JOIN b_bodemenondergrond.lnk_id_permkey lip2 ON lip2.id = to2.opdracht_id AND lip2.type = 'OPDRACHT'::text AND lip.state = 'A'::text
     JOIN b_bodemenondergrond.lnk_id_permkey lip3 ON lip3.permkey = tm.parent_permkey AND lip3.type = 'BORING'::text AND tm.parent_type = 'BORING'::text AND lip.state = 'A'::text
     JOIN b_bodemenondergrond.tbl_boring tb ON tb.dov_boring_id = lip3.id
     LEFT JOIN b_bodemenondergrond.tbl_uitvoerder tu ON COALESCE(tm.monstername_door, tb.uitvoerder) = tu.uitvoerder_id;

ALTER TABLE s_bodemenondergrond.vw_observation_sample_monstersamenstelling
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_observation_sample_monstertype

-- DROP VIEW s_bodemenondergrond.vw_observation_sample_monstertype;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_observation_sample_monstertype
 AS
 SELECT ('obs:sam'::text || lip.permkey) || '-monstertype'::text AS "@id",
    'sosa:Observation'::text AS "@type",
    tm.monstertype AS "hasResult",
    COALESCE(tm.datum_monstername, tb.datum_aanvang) AS "resultTime",
    'obs_prop:monstertype-sam'::text || lip.permkey AS "observedProperty",
    'agent:organisatie'::text || tu.organisatie_id AS "madeBySensor",
    'cl-bpt:bepaling_monstertype '::text AS "usedProcedure",
    'opdracht:'::text || lip2.permkey AS "prov:wasStartedBy",
    'result:sam'::text || lip.permkey AS "hasFeatureOfInterest"
   FROM b_bodemenondergrond.tbl_monster tm
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = tm.id AND lip.type = 'MONSTER'::text AND lip.state = 'A'::text
     JOIN b_bodemenondergrond.lnk_monster_opdracht lmo ON lmo.monster_id = tm.id
     JOIN b_bodemenondergrond.tbl_opdracht to2 ON lmo.opdracht_id = to2.opdracht_id
     JOIN b_bodemenondergrond.lnk_id_permkey lip2 ON lip2.id = to2.opdracht_id AND lip2.type = 'OPDRACHT'::text AND lip.state = 'A'::text
     JOIN b_bodemenondergrond.lnk_id_permkey lip3 ON lip3.permkey = tm.parent_permkey AND lip3.type = 'BORING'::text AND tm.parent_type = 'BORING'::text AND lip.state = 'A'::text
     JOIN b_bodemenondergrond.tbl_boring tb ON tb.dov_boring_id = lip3.id
     LEFT JOIN b_bodemenondergrond.tbl_uitvoerder tu ON COALESCE(tm.monstername_door, tb.uitvoerder) = tu.uitvoerder_id;

ALTER TABLE s_bodemenondergrond.vw_observation_sample_monstertype
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_observation_sample_opslag

-- DROP VIEW s_bodemenondergrond.vw_observation_sample_opslag;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_observation_sample_opslag
 AS
 SELECT ('obs:sam'::text || lip.permkey) || '-opslaglocatie'::text AS "@id",
    'sosa:Observation'::text AS "@type",
    'cl-loc:'::text || lo2.beschrijving AS "hasResult",
    to2.beschikbaar_vanaf::timestamp without time zone AS "resultTime",
    ('moment:sam'::text || lip.permkey) || '-opslag'::text AS "phenomenonTime",
    'obs_prop:opslag-sam'::text || lip.permkey AS "observedProperty",
    'agent:actor'::text || to2.partner AS "madeBySensor",
    'result:sam'::text || lip.permkey AS "hasFeatureOfInterest"
   FROM b_bodemenondergrond.tbl_opslaglocatie to2
     JOIN b_bodemenondergrond.lut_opslaglocatie lo2 ON to2.opslaglocatie = lo2.code
     JOIN b_bodemenondergrond.tbl_monster tm ON tm.id = to2.grondmonster_id
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = tm.id AND lip.type = 'MONSTER'::text AND lip.state = 'A'::text;

ALTER TABLE s_bodemenondergrond.vw_observation_sample_opslag
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_procedures_from_observations

-- DROP VIEW s_bodemenondergrond.vw_procedures_from_observations;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_procedures_from_observations
 AS
 SELECT 'cl-opt:'::text || code AS "@id",
    'sosa:Procedure'::text AS "@type",
    beschrijving AS "skos:notation"
   FROM b_bodemenondergrond.lut_analysemethode la;

ALTER TABLE s_bodemenondergrond.vw_procedures_from_observations
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_text_results_from_observations

-- DROP VIEW s_bodemenondergrond.vw_text_results_from_observations;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_text_results_from_observations
 AS
 SELECT 'result:obs'::text || lip.permkey AS "@id",
    'sosa:Result'::text AS "@type",
    'obs:'::text || lip.permkey AS "isResultOf",
    s_bodemenondergrond.parametertocodelijst(to2.parameter::character varying)::text || to2.meetwaarde_txt AS "rdf:value"
   FROM b_bodemenondergrond.tbl_observatie to2
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = to2.id AND lip.type = 'OBSERVATIE'::text AND lip.state = 'A'::text
     JOIN b_bodemenondergrond.lut_parameter lp ON lp.id = to2.parameter
  WHERE to2.parent_permkey IS NOT NULL AND to2.meetwaarde_num IS NULL;

ALTER TABLE s_bodemenondergrond.vw_text_results_from_observations
    OWNER TO postgres;

