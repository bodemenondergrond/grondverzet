-- View: s_bodemenondergrond.vw_association

-- DROP VIEW s_bodemenondergrond.vw_association;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_association
 AS
 SELECT (('ass:'::text || to2.organisatie_id) || '-'::text) || lip.permkey AS "@id",
    'prov:Association'::text AS "@type",
    'ag:'::text || to2.organisatie_id AS agent,
    'cl-dlb:'::text || clean_string(ld.omschrijving::character varying)::text AS "hadPlan",
    'rol:opdrachtgever'::text AS "hadRole"
   FROM b_bodemenondergrond.tbl_opdrachtgever to2
     JOIN b_bodemenondergrond.tbl_boring tb ON tb.opdrachtgever = to2.opdrachtgever_id
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = tb.dov_boring_id AND lip.type = 'BORING'::text
     LEFT JOIN b_bodemenondergrond.lut_doel ld ON ld.doel_id = tb.doel
UNION
 SELECT (('ass:'::text || to2.organisatie_id) || '-'::text) || lip.permkey AS "@id",
    'prov:Association'::text AS "@type",
    'ag:'::text || to2.organisatie_id AS agent,
        CASE
            WHEN (tb.wettelijk_type = ANY (ARRAY['niet_ingedeeld'::text, NULL::text])) AND tb.erkenning IS NULL AND tb.voorafmelding IS NULL THEN 'wettelijkkader:'::text || lip.permkey
            ELSE NULL::text
        END AS "hadPlan",
    'rol:boorder'::text AS "hadRole"
   FROM b_bodemenondergrond.tbl_opdrachtnemer to2
     JOIN b_bodemenondergrond.tbl_boring tb ON tb.uitvoerder = to2.opdrachtnemer_id
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = tb.dov_boring_id AND lip.type = 'BORING'::text
UNION
 SELECT (('ass:'::text || td.organisatie_id) || '-'::text) || lip.permkey AS "@id",
    'prov:Association'::text AS "@type",
    'ag:'::text || td.organisatie_id AS agent,
    NULL::text AS "hadPlan",
    'rol:dataleverancier'::text AS "hadRole"
   FROM b_bodemenondergrond.tbl_dataleverancier td
     JOIN b_bodemenondergrond.tbl_boring tb ON tb.dataleverancier = td.dataleverancier_id
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = tb.dov_boring_id AND lip.type = 'BORING'::text
UNION
 SELECT (('ass:a'::text || ta.actor_id) || '-'::text) || lip.permkey AS "@id",
    'prov:Association'::text AS "@type",
    'ag:a'::text || ta.actor_id AS agent,
    NULL::text AS "hadPlan",
    'rol:boormeester'::text AS "hadRole"
   FROM b_bodemenondergrond.tbl_actor ta
     JOIN b_bodemenondergrond.tbl_boring tb ON tb.boormeester = ta.actor_id
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = tb.dov_boring_id AND lip.type = 'BORING'::text;

ALTER TABLE s_bodemenondergrond.vw_association
    OWNER TO datawarehouse_ddl;

