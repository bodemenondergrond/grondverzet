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

