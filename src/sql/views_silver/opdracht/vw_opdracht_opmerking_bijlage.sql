-- View: s_bodemenondergrond.vw_bijlage_opdracht

-- DROP VIEW s_bodemenondergrond.vw_bijlage_opdracht;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_bijlage_opdracht
 AS
 SELECT 'bl:opdracht'::text || lip.permkey AS "@id",
    'dossier:Stukonderdeel'::text AS "@type",
    'Bijlage bij opdracht '::text || o.naam AS "dcterms:title",
    b.title AS "rdfs:label",
    'agent:actor'::text || b.auteurs AS "dcterms:creator",
    'opdracht:'::text || lip.permkey AS "dcterms:isPartOf",
        CASE
            WHEN b.datum IS NOT NULL THEN b.datum
            WHEN b.jaar IS NOT NULL THEN to_date(b.jaar::text, 'YYYY'::text)::timestamp without time zone
            ELSE NULL::timestamp without time zone
        END AS "dcterms:created"
   FROM b_bodemenondergrond.tbl_bijlage b
     JOIN b_bodemenondergrond.lnk_bijlage lb ON b.id = lb.bijlage_id AND lb.type = 'OPDRACHT'::text
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = lb.object_id AND lip.type = 'OPDRACHT'::text AND lip.state = 'A'::text
     JOIN b_bodemenondergrond.tbl_opdracht o ON lip.id = o.opdracht_id;

ALTER TABLE s_bodemenondergrond.vw_bijlage_opdracht
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_opmerkingen_opdracht

-- DROP VIEW s_bodemenondergrond.vw_opmerkingen_opdracht;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_opmerkingen_opdracht
 AS
 SELECT (('opm:opdracht'::text || lip.permkey) || '-'::text) || row_number() OVER (PARTITION BY too.opdracht_id ORDER BY too.opmerking_opdracht_id) AS "@id",
    'dossier:Stukonderdeel'::text AS "@type",
    'Opmerking bij opdracht '::text || o.naam AS "dcterms:title",
    too.opmerking AS "dcterms:description",
    'agent:actor'::text || ta.actor_id AS "dcterms:creator",
    'opdracht:'::text || lip.permkey AS "dcterms:isPartOf",
    too.datum AS "dcterms:created"
   FROM b_bodemenondergrond.tbl_opmerking_opdracht too
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON too.opdracht_id = lip.id AND lip.type = 'OPDRACHT'::text AND lip.state = 'A'::text
     JOIN b_bodemenondergrond.tbl_opdracht o ON too.opdracht_id = o.opdracht_id
     JOIN b_bodemenondergrond.tbl_actor ta ON ta.actor_id = too.invoerder_id;

ALTER TABLE s_bodemenondergrond.vw_opmerkingen_opdracht
    OWNER TO postgres;

