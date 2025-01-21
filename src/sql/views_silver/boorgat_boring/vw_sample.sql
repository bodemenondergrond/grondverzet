-- View: s_bodemenondergrond.vw_bijlage_sample

-- DROP VIEW s_bodemenondergrond.vw_bijlage_sample;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_bijlage_sample
 AS
 WITH bl AS (
         SELECT lip.permkey,
            tb.title,
            row_number() OVER (PARTITION BY tm.parent_permkey ORDER BY tm.id) AS rn,
                CASE
                    WHEN tb.datum IS NOT NULL THEN tb.datum
                    ELSE to_date(tb.jaar::character varying::text, 'YYYY'::text)::timestamp without time zone
                END AS date,
            tb.auteurs
           FROM b_bodemenondergrond.tbl_bijlage tb
             JOIN b_bodemenondergrond.lnk_bijlage lb ON tb.id = lb.bijlage_id
             JOIN b_bodemenondergrond.tbl_monster tm ON tm.id = lb.object_id AND lb.type = 'MONSTER'::text
             JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = tm.id AND lip.type = 'MONSTER'::text AND lip.state = 'A'::text
        )
 SELECT (('bl:sam'::text || permkey) || '-'::text) || rn AS "@id",
    'grondboringbeno:Bijlage'::text AS "@type",
    'agent:actor'::text || auteurs AS "dcterms:creator",
    date,
    title AS "rdfs:label"
   FROM bl;

ALTER TABLE s_bodemenondergrond.vw_bijlage_sample
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_dates_sample_opslag

-- DROP VIEW s_bodemenondergrond.vw_dates_sample_opslag;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_dates_sample_opslag
 AS
 SELECT 'datum:start-sam'::text || lip.permkey AS "@id",
    'time:Instant'::text AS "@type",
    to2.beschikbaar_vanaf::timestamp without time zone AS "inXSDDateTimeStamp"
   FROM b_bodemenondergrond.tbl_opslaglocatie to2
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = to2.grondmonster_id AND lip.type = 'MONSTER'::text AND lip.state = 'A'::text
UNION
 SELECT 'datum:end-sam'::text || lip.permkey AS "@id",
    'time:Instant'::text AS "@type",
    to2.beschikbaar_tot::timestamp without time zone AS "inXSDDateTimeStamp"
   FROM b_bodemenondergrond.tbl_opslaglocatie to2
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = to2.grondmonster_id AND lip.type = 'MONSTER'::text AND lip.state = 'A'::text;

ALTER TABLE s_bodemenondergrond.vw_dates_sample_opslag
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_sample

-- DROP VIEW s_bodemenondergrond.vw_sample;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_sample
 AS
 WITH sample_number AS (
         SELECT tm_1.id,
            row_number() OVER (PARTITION BY tm_1.parent_permkey ORDER BY tm_1.id) AS rn
           FROM b_bodemenondergrond.tbl_monster tm_1
          WHERE tm_1.parent_permkey IS NOT NULL
        )
 SELECT 'result:sam'::text || lip.permkey AS "@id",
    'sosa:Sample'::text AS "@type",
    jsonb_build_object('@id', (('sam:'::text || tm.parent_permkey) || '-'::text) || sample_number.rn) AS "sosa:isResultOf",
    'boorgat:boorgat'::text || tm.parent_permkey AS "isSampleOf",
    ('result:sam'::text || lip.permkey) || '-van'::text AS "grondboringbeno:sampleDiepteVan",
    ('result:sam'::text || lip.permkey) || '-tot'::text AS "grondboringbeno:sampleDiepteTot"
   FROM b_bodemenondergrond.tbl_monster tm
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = tm.id AND lip.type = 'MONSTER'::text AND lip.state = 'A'::text
     JOIN sample_number ON sample_number.id = tm.id;

ALTER TABLE s_bodemenondergrond.vw_sample
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_sampling_monsterbehandeling

-- DROP VIEW s_bodemenondergrond.vw_sampling_monsterbehandeling;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_sampling_monsterbehandeling
 AS
 SELECT (('sam:sam'::text || lip.permkey) || '-'::text) || row_number() OVER (PARTITION BY tmb1.monster ORDER BY tmb1.id) AS "@id",
    'sosa:Sampling'::text AS "@type",
    'agent:organisatie'::text || tu.organisatie_id AS "MadeBySampler",
        CASE
            WHEN tmb1.waarde_bool IS TRUE THEN 'cl-behwaarde:'::text || s_bodemenondergrond.clean(lb.beschrijving::character varying)::text
            ELSE 'cl-behwaarde:'::text || s_bodemenondergrond.clean(lbk.beschrijving::character varying)::text
        END AS "usedProcedure",
    'result:deltasam'::text || lip.permkey AS "hasResult",
    COALESCE(tmb1.datum::timestamp without time zone, tmb2.datum::timestamp without time zone, tm.datum_monstername) AS "resultTime",
    'result:sam'::text || lip.permkey AS "hasFeatureOfInterest"
   FROM b_bodemenondergrond.tbl_monster_behandeling tmb1
     LEFT JOIN b_bodemenondergrond.lut_behandeling_keuze lbk ON lbk.code = tmb1.waarde_keuze
     JOIN b_bodemenondergrond.lut_behandeling lb ON lb.code = tmb1.behandeling
     JOIN b_bodemenondergrond.tbl_monster tm ON tm.id = tmb1.monster
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = tm.id AND lip.type = 'MONSTER'::text AND lip.state = 'A'::text
     LEFT JOIN b_bodemenondergrond.tbl_monster_behandeling tmb2 ON tmb1.monster = tmb2.monster AND tmb2.behandeling = 'M_MVD'::text
     LEFT JOIN b_bodemenondergrond.tbl_uitvoerder tu ON tu.uitvoerder_id = COALESCE(tmb1.waarde_uitvoerder, tmb2.waarde_uitvoerder, tm.monstername_door)
  WHERE tmb1.behandeling <> 'M_MVD'::text AND NOT s_bodemenondergrond.clean(lbk.beschrijving::character varying)::text ~ 'not implemented'::text AND NOT s_bodemenondergrond.clean(lb.beschrijving::character varying)::text ~ 'not implemented'::text;

ALTER TABLE s_bodemenondergrond.vw_sampling_monsterbehandeling
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_sampling_observatiebehandeling

-- DROP VIEW s_bodemenondergrond.vw_sampling_observatiebehandeling;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_sampling_observatiebehandeling
 AS
 WITH obs_ids AS (
         SELECT tob_1.id,
            row_number() OVER (PARTITION BY tob_1.observatie ORDER BY tob_1.id) AS rn
           FROM b_bodemenondergrond.tbl_observatie_behandeling tob_1
             JOIN b_bodemenondergrond.lut_behandeling lb_1 ON lb_1.code = tob_1.behandeling AND lb_1.parenttype = 'OBSERVATIE'::text
          WHERE lb_1.type <> 'B'::text OR tob_1.waarde_bool IS TRUE
        )
 SELECT (((('sam:sam'::text || to2.parent_permkey) || '-obs'::text) || lip.permkey) || '-'::text) || obs_ids.rn AS "@id",
    'sosa:Sampling'::text AS "@type",
    'agent:organisatie'::text || tu.organisatie_id AS "madeBySampler",
        CASE
            WHEN lb.type = 'B'::text THEN 'cl-behwaarde:'::text || s_bodemenondergrond.clean(lb.beschrijving::character varying)::text
            ELSE 'cl-behwaarde:'::text || s_bodemenondergrond.clean(lbk.beschrijving::character varying)::text
        END AS "usedProcedure",
    (('result:deltasam'::text || to2.parent_permkey) || '-obs'::text) || lip.permkey AS "hasResult",
    COALESCE(to2.fenomeentijd, to2.invoerdatum)::timestamp without time zone AS "resultTime",
    ('result:sam'::text || to2.parent_permkey) || '-bis'::text AS "hasFeatureOfInterest"
   FROM b_bodemenondergrond.tbl_observatie_behandeling tob
     JOIN b_bodemenondergrond.tbl_observatie to2 ON tob.observatie = to2.id
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = to2.id AND lip.type = 'OBSERVATIE'::text AND lip.state = 'A'::text
     JOIN obs_ids ON obs_ids.id = tob.id
     LEFT JOIN b_bodemenondergrond.tbl_uitvoerder tu ON tu.uitvoerder_id = to2.uitvoerder
     JOIN b_bodemenondergrond.lut_behandeling lb ON lb.code = tob.behandeling AND lb.parenttype = 'OBSERVATIE'::text AND lip.state = 'A'::text
     LEFT JOIN b_bodemenondergrond.lut_behandeling_keuze lbk ON lbk.code = tob.waarde_keuze
  WHERE NOT s_bodemenondergrond.clean(lb.beschrijving::character varying)::text ~ 'not implemented'::text AND NOT (s_bodemenondergrond.clean(lbk.beschrijving::character varying)::text ~ 'not implemented'::text AND lb.type <> 'B'::text);

ALTER TABLE s_bodemenondergrond.vw_sampling_observatiebehandeling
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_samplings

-- DROP VIEW s_bodemenondergrond.vw_samplings;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_samplings
 AS
 WITH samples AS (
         SELECT tm_1.id,
            lip.permkey,
            row_number() OVER (PARTITION BY tm_1.parent_permkey ORDER BY tm_1.id) AS rn
           FROM b_bodemenondergrond.tbl_monster tm_1
             JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = tm_1.id AND lip.type = 'MONSTER'::text AND lip.state = 'A'::text
        )
 SELECT (('sam:sam:'::text || tm.parent_permkey) || '-'::text) || samples.rn AS "@id",
    'sosa:Sampling'::text AS "@type",
    'boorgat:boorgat'::text || tm.parent_permkey AS "hasFeatureOfInterest",
    'result:sam'::text || samples.permkey AS "hasResult",
    (('boor:boring'::text || tm.parent_permkey) || '-'::text) || samples.rn AS "madeBySampler",
    tm.datum_monstername AS "resultTime",
    tm.bemonsteringsprocedure AS "usedProcedure"
   FROM b_bodemenondergrond.tbl_monster tm
     JOIN samples ON tm.id = samples.id
  WHERE tm.parent_permkey IS NOT NULL;

ALTER TABLE s_bodemenondergrond.vw_samplings
    OWNER TO datawarehouse_ddl;

-- View: s_bodemenondergrond.vw_samplings_list

-- DROP VIEW s_bodemenondergrond.vw_samplings_list;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_samplings_list
 AS
 WITH counter AS (
         SELECT tm.parent_permkey,
            count(tm.id) AS count
           FROM b_bodemenondergrond.tbl_monster tm
          GROUP BY tm.parent_permkey
        ), samples AS (
         SELECT tm.id,
            tm.parent_permkey,
            row_number() OVER (PARTITION BY tm.parent_permkey ORDER BY tm.id) AS rn
           FROM b_bodemenondergrond.tbl_monster tm
          WHERE tm.parent_permkey IS NOT NULL
        )
 SELECT (('list:'::text || samples.parent_permkey) || '-sam'::text) || samples.rn AS "@id",
    'rdf:List'::text AS "@type",
    (('sam:'::text || samples.parent_permkey) || '-'::text) || samples.rn AS first,
        CASE
            WHEN samples.rn < counter.count THEN (('list:'::text || samples.parent_permkey) || '-sam'::text) || (samples.rn + 1)
            ELSE NULL::text
        END AS rest
   FROM samples
     JOIN counter ON counter.parent_permkey = samples.parent_permkey;

ALTER TABLE s_bodemenondergrond.vw_samplings_list
    OWNER TO datawarehouse_ddl;

