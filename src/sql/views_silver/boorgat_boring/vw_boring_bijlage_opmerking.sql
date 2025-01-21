-- View: s_bodemenondergrond.vw_bijlage_boring

-- DROP VIEW s_bodemenondergrond.vw_bijlage_boring;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_bijlage_boring
 AS
 SELECT (('bl:boring'::text || lip.permkey) || '-'::text) || row_number() OVER (PARTITION BY lip.permkey ORDER BY tb.id) AS "@id",
    'grondboringbeno:Bijlage'::text AS "@type",
    'boring:'::text || lip.permkey AS about,
        CASE
            WHEN tb.datum IS NOT NULL THEN tb.datum
            WHEN tb.jaar IS NOT NULL THEN to_date(tb.jaar::text, 'YYYY'::text)::timestamp without time zone
            ELSE NULL::timestamp without time zone
        END AS date,
    'agent:actor'::text || tb.auteurs AS "dcterms:creator"
   FROM b_bodemenondergrond.tbl_bijlage tb
     JOIN b_bodemenondergrond.lnk_bijlage lb ON tb.id = lb.bijlage_id
     JOIN b_bodemenondergrond.tbl_boring tb2 ON tb2.dov_boring_id = lb.object_id AND lb.type = 'BORING'::text
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = tb2.dov_boring_id AND lip.type = 'BORING'::text AND lip.state = 'A'::text;

ALTER TABLE s_bodemenondergrond.vw_bijlage_boring
    OWNER TO postgres;

