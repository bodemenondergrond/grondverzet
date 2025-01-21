-- View: s_bodemenondergrond.vw_opdracht

-- DROP VIEW s_bodemenondergrond.vw_opdracht;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_opdracht
 AS
 WITH observaties AS (
         SELECT array_agg(('location:'::text || a.text) || lip_1.permkey) AS beschrijft,
            a.opdracht_id
           FROM b_bodemenondergrond.lnk_id_permkey lip_1
             JOIN ( SELECT 'interp'::text AS text,
                    lnk_opdracht_interpretatie.interpretatie_id AS id,
                    lnk_opdracht_interpretatie.opdracht_id,
                    'INTERPRETATIE'::text AS type
                   FROM b_bodemenondergrond.lnk_opdracht_interpretatie
                UNION
                 SELECT 'boring'::text AS text,
                    lnk_boring_opdracht.dov_boring_id AS id,
                    lnk_boring_opdracht.opdracht_id,
                    'BORING'::text AS type
                   FROM b_bodemenondergrond.lnk_boring_opdracht
                UNION
                 SELECT 'filter'::text AS text,
                    lnk_filter_opdracht.filter_id AS id,
                    lnk_filter_opdracht.opdracht_id,
                    'FILTER'::text AS type
                   FROM b_bodemenondergrond.lnk_filter_opdracht
                UNION
                 SELECT 'bodemlocatie'::text AS text,
                    lnk_bodemlocatie_opdracht.bodemlocatie AS id,
                    lnk_bodemlocatie_opdracht.opdracht,
                    'BODEMLOCATIE'::text AS type
                   FROM b_bodemenondergrond.lnk_bodemlocatie_opdracht
                UNION
                 SELECT 'bodemsite'::text AS text,
                    lnk_bodemsite_opdracht.bodemsite AS id,
                    lnk_bodemsite_opdracht.opdracht,
                    'BODEMSITE'::text AS type
                   FROM b_bodemenondergrond.lnk_bodemsite_opdracht
                UNION
                 SELECT 'gwlocatie'::text AS text,
                    lnk_gwlocatie_opdracht.gwlocatie_id AS id,
                    lnk_gwlocatie_opdracht.opdracht_id,
                    'GWLOCATIE'::text AS type
                   FROM b_bodemenondergrond.lnk_gwlocatie_opdracht
                UNION
                 SELECT 'monster'::text AS text,
                    lnk_monster_opdracht.monster_id AS id,
                    lnk_monster_opdracht.opdracht_id,
                    'MONSTER'::text AS type
                   FROM b_bodemenondergrond.lnk_monster_opdracht
                UNION
                 SELECT 'observatie'::text AS text,
                    lnk_observatie_opdracht.observatie AS id,
                    lnk_observatie_opdracht.opdracht,
                    'OBSERVATIE'::text AS type
                   FROM b_bodemenondergrond.lnk_observatie_opdracht
                UNION
                 SELECT 'interp'::text AS text,
                    lnk_opdracht_interpretatie.interpretatie_id AS id,
                    lnk_opdracht_interpretatie.opdracht_id,
                    'INTERPRETATIE'::text AS type
                   FROM b_bodemenondergrond.lnk_opdracht_interpretatie
                UNION
                 SELECT 'sondering'::text AS text,
                    lnk_sondering_opdracht.id,
                    lnk_sondering_opdracht.opdracht_id,
                    'SONDERING'::text AS type
                   FROM b_bodemenondergrond.lnk_sondering_opdracht
                UNION
                 SELECT 'voorafmelding'::text AS text,
                    lnk_voorafmelding_opdracht.voorafmelding_id AS id,
                    lnk_voorafmelding_opdracht.opdracht_id,
                    'VOORAFMELDING'::text AS type
                   FROM b_bodemenondergrond.lnk_voorafmelding_opdracht) a ON a.id = lip_1.id AND lip_1.type = a.type AND lip_1.state = 'A'::text
          GROUP BY a.opdracht_id
        ), aard AS (
         SELECT array_agg('cl-dlb:'::text || lo.beschrijving) AS aard,
            loa.opdracht_id
           FROM b_bodemenondergrond.lnk_opdracht_aard loa
             JOIN b_bodemenondergrond.lut_opdrachtaard lo ON loa.aard_id = lo.code
          GROUP BY loa.opdracht_id
        ), gekop_opdr AS (
         SELECT array_agg('opdracht:'::text || lip_1.permkey) AS gekop_opdr,
            lgo_1.opdracht_id
           FROM b_bodemenondergrond.lnk_gekoppelde_opdracht lgo_1
             LEFT JOIN b_bodemenondergrond.lnk_id_permkey lip_1 ON lip_1.id = lgo_1.gekoppelde_id AND lip_1.type = 'OPDRACHT'::text
          GROUP BY lgo_1.opdracht_id
        )
 SELECT 'opdracht:'::text || lip.permkey AS "@id",
    'dossier:Stuk'::text AS "@type",
    array_remove(ARRAY[
        CASE
            WHEN tdl.organisatie_id IS NOT NULL THEN 'agent:organisatie'::text || tdl.organisatie_id
            ELSE NULL::text
        END,
        CASE
            WHEN tog.organisatie_id IS NOT NULL THEN 'agent:organisatie'::text || tog.organisatie_id
            ELSE NULL::text
        END,
        CASE
            WHEN org.organisatie_id IS NOT NULL THEN 'agent:organisatie'::text || org.organisatie_id
            ELSE NULL::text
        END,
        CASE
            WHEN ton.organisatie_id IS NOT NULL THEN 'agent:organisatie'::text || ton.organisatie_id
            ELSE NULL::text
        END], NULL::text) AS "prov:wasAttributedTo",
    array_remove(ARRAY[
        CASE
            WHEN tdl.organisatie_id IS NOT NULL AND lip.permkey IS NOT NULL THEN (('attribution:agent'::text || tdl.organisatie_id) || '_opdracht'::text) || lip.permkey
            ELSE NULL::text
        END,
        CASE
            WHEN ton.organisatie_id IS NOT NULL AND lip.permkey IS NOT NULL THEN (('attribution:agent'::text || ton.organisatie_id) || '_opdracht'::text) || lip.permkey
            ELSE NULL::text
        END,
        CASE
            WHEN org.organisatie_id IS NOT NULL AND lip.permkey IS NOT NULL THEN (('attribution:agent'::text || org.organisatie_id) || '_opdracht'::text) || lip.permkey
            ELSE NULL::text
        END,
        CASE
            WHEN ton.organisatie_id IS NOT NULL AND lip.permkey IS NOT NULL THEN (('attribution:agent'::text || ton.organisatie_id) || '_opdracht'::text) || lip.permkey
            ELSE NULL::text
        END], NULL::text) AS "prov:qualifiedAttribution",
    ( SELECT a.aard
           FROM aard a
          WHERE a.opdracht_id = o.opdracht_id) AS "dcterms:subject",
    ( SELECT go.gekop_opdr
           FROM gekop_opdr go
          WHERE go.opdracht_id = o.opdracht_id) AS "dcterms:relation",
    'cl-opdrorigine:'::text || oo.beschrijving AS "dcterms:type",
    o.omschrijving AS "prov:value",
    o.omschrijving AS "rdfs:label",
    ( SELECT obs.beschrijft
           FROM observaties obs
          WHERE obs.opdracht_id = o.opdracht_id) AS "dossier:beschrijft",
    'id:opdracht'::text || lip.permkey AS "adms:identifier",
    'Opdracht '::text || o.naam AS "dcterms:title"
   FROM b_bodemenondergrond.tbl_opdracht o
     LEFT JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = o.opdracht_id AND lip.type = 'OPDRACHT'::text AND lip.state = 'A'::text
     LEFT JOIN b_bodemenondergrond.lut_opdrachtorigine oo ON o.origine = oo.code
     LEFT JOIN b_bodemenondergrond.tbl_opdrachtgever tog ON o.opdrachtgever_id = tog.opdrachtgever_id AND tog.organisatie_id IS NOT NULL
     LEFT JOIN b_bodemenondergrond.tbl_opdrachtnemer ton ON o.opdrachtnemer_id = ton.opdrachtnemer_id AND ton.organisatie_id IS NOT NULL
     LEFT JOIN b_bodemenondergrond.tbl_dataleverancier tdl ON o.dataleverancier_id = tdl.dataleverancier_id AND tdl.organisatie_id IS NOT NULL
     LEFT JOIN b_bodemenondergrond.tbl_organisatie org ON o.partner = org.kbonummer
     LEFT JOIN b_bodemenondergrond.lnk_gekoppelde_opdracht lgo ON o.opdracht_id = lgo.opdracht_id
     LEFT JOIN b_bodemenondergrond.lnk_id_permkey lip2 ON lip2.id = lgo.gekoppelde_id AND lip2.type = 'OPDRACHT'::text AND lip2.state = 'A'::text;

ALTER TABLE s_bodemenondergrond.vw_opdracht
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_opdracht_aard

-- DROP VIEW s_bodemenondergrond.vw_opdracht_aard;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_opdracht_aard
 AS
 SELECT 'cl-dlb:'::text || beschrijving AS "@id",
    'skos:Concept'::text AS "@type",
    beschrijving AS "rdfs:label"
   FROM b_bodemenondergrond.lut_opdrachtaard;

ALTER TABLE s_bodemenondergrond.vw_opdracht_aard
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_opdracht_id

-- DROP VIEW s_bodemenondergrond.vw_opdracht_id;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_opdracht_id
 AS
 SELECT 'id:'::text || lip.permkey AS "@id",
    'adms:Identifier'::text AS "@type",
    o.naam AS "skos:notation"
   FROM b_bodemenondergrond.tbl_opdracht o
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON o.opdracht_id = lip.id;

ALTER TABLE s_bodemenondergrond.vw_opdracht_id
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_opdracht_origine

-- DROP VIEW s_bodemenondergrond.vw_opdracht_origine;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_opdracht_origine
 AS
 SELECT 'cl-opdrorigine:'::text || beschrijving AS "@id",
    'skos:Concept'::text AS "@type",
    beschrijving AS "rdfs:label"
   FROM b_bodemenondergrond.lut_opdrachtorigine;

ALTER TABLE s_bodemenondergrond.vw_opdracht_origine
    OWNER TO postgres;


