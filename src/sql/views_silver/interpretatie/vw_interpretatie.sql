-- View: s_bodemenondergrond.vw_interpretatie_bijlage

-- DROP VIEW s_bodemenondergrond.vw_interpretatie_bijlage;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_interpretatie_bijlage
 AS
 SELECT (('bl:interp'::text || lip.permkey) || '-'::text) || row_number() OVER (PARTITION BY lip.permkey ORDER BY tb.id) AS "@id",
    'bodemenondergrond:Bijlage'::text AS "@type",
    tb.title AS "rdfs:label",
    'agent:actor'::text || tb.auteurs AS "dcterms:creator",
    'interp:'::text || lip.permkey AS "schema:about",
    tb.datum AS "dcterms:date"
   FROM b_bodemenondergrond.tbl_bijlage tb
     JOIN b_bodemenondergrond.lnk_bijlage lb ON tb.id = lb.bijlage_id
     JOIN b_bodemenondergrond.tbl_interpretatie ti ON ti.interpretatie_id = lb.object_id
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = ti.interpretatie_id AND lip.type = 'INTERPRETATIE'::text AND lip.state = 'A'::text
  WHERE lb.type = 'INTERPRETATIE'::text;

ALTER TABLE s_bodemenondergrond.vw_interpretatie_bijlage
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_interpretatie_componentspecification

-- DROP VIEW s_bodemenondergrond.vw_interpretatie_componentspecification;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_interpretatie_componentspecification
 AS
 SELECT DISTINCT "@id",
    "@type",
    "qb:componentAttachment",
    "qb:dimension",
    "qb:measure",
    "rdfs:label"
   FROM s_bodemenondergrond.tbl_interpretatie_componentspecification;

ALTER TABLE s_bodemenondergrond.vw_interpretatie_componentspecification
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_interpretatie_concepts

-- DROP VIEW s_bodemenondergrond.vw_interpretatie_concepts;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_interpretatie_concepts
 AS
 SELECT DISTINCT "@id",
    "@type",
    "rdfs:label"
   FROM s_bodemenondergrond.tbl_interpretatie_concepts;

ALTER TABLE s_bodemenondergrond.vw_interpretatie_concepts
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_interpretatie_datasets

-- DROP VIEW s_bodemenondergrond.vw_interpretatie_datasets;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_interpretatie_datasets
 AS
 SELECT DISTINCT 'dataset:cube_results'::text AS "@id",
    'qb:DataSet'::text AS "@type",
    '"kubus resultaten"@nl'::text AS "rdfs:label",
    '"Dataset van resultaten"@nl'::text AS "rdfs:comment",
    'dsd:cube_results'::text AS "qb:structure",
    array_agg(('slice:'::text || t.table_name) || lip.permkey) AS "qb:slice"
   FROM b_bodemenondergrond.lnk_id_permkey lip
     JOIN ( SELECT DISTINCT 'cons'::text AS table_name,
            tc.boring_id
           FROM b_bodemenondergrond.tbl_consistentie tc
        UNION ALL
         SELECT DISTINCT 'vocht'::text AS table_name,
            tv.boring_id
           FROM b_bodemenondergrond.tbl_vochtgehalte tv
        UNION ALL
         SELECT DISTINCT 'kleur'::text AS table_name,
            ti.boring_id
           FROM b_bodemenondergrond.tbl_insitukleur ti) t ON t.boring_id = lip.id AND lip.type = 'BORING'::text AND lip.state = 'A'::text
UNION
 SELECT tbl_interpretatie_datasets."@id",
    tbl_interpretatie_datasets."@type",
    tbl_interpretatie_datasets."rdfs:label",
    tbl_interpretatie_datasets."rdfs:comment",
    tbl_interpretatie_datasets."qb:structure",
    tbl_interpretatie_datasets."qb:slice"::text[] AS "qb:slice"
   FROM s_bodemenondergrond.tbl_interpretatie_datasets;

ALTER TABLE s_bodemenondergrond.vw_interpretatie_datasets
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_interpretatie_datastructuredefinition

-- DROP VIEW s_bodemenondergrond.vw_interpretatie_datastructuredefinition;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_interpretatie_datastructuredefinition
 AS
 SELECT DISTINCT "@id",
    "@type",
    string_to_array("qb:component"::text, ', '::text) AS string_to_array,
    "qb:sliceKey",
    "rdfs:comment"
   FROM s_bodemenondergrond.tbl_interpretatie_datastructuredefinition;

ALTER TABLE s_bodemenondergrond.vw_interpretatie_datastructuredefinition
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_interpretatie_opmerking

-- DROP VIEW s_bodemenondergrond.vw_interpretatie_opmerking;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_interpretatie_opmerking
 AS
 SELECT (('opm:interp'::text || lip.permkey) || '-'::text) || row_number() OVER (PARTITION BY lip.permkey ORDER BY toi.opmerking_interpretatie_id) AS "@id",
    'bodemenondergrond:Opmerking'::text AS "@type",
    toi.opmerking AS "dcterms:description",
    'agent:actor'::text || toi.invoerder_id AS "dcterms:creator",
    'interp:'::text || lip.permkey AS "schema:about",
    toi.datum AS "dcterms:date"
   FROM b_bodemenondergrond.tbl_opmerking_interpretatie toi
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = toi.interpretatie_id AND lip.type = 'INTERPRETATIE'::text AND lip.state = 'A'::text;

ALTER TABLE s_bodemenondergrond.vw_interpretatie_opmerking
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_interpretatie_slicekey

-- DROP VIEW s_bodemenondergrond.vw_interpretatie_slicekey;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_interpretatie_slicekey
 AS
 SELECT 'slicekey:sliceBydepth'::text AS "@id",
    'qb:SliceKey'::text AS "@type",
    'sliceByDepth SliceKey'::text AS "rdfs:label",
    'Slice door eigenschap (sosa:observedProperty) en onderwerp (sosa:hasFeatureOfInterest) vast te zetten'::text AS "rdfs:comment",
    ARRAY['bodemenondergrond:onderwerp'::text, 'bodemenondergrond:eigenschap'::text] AS "qb:componentProperty";

ALTER TABLE s_bodemenondergrond.vw_interpretatie_slicekey
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_interpretaties_properties

-- DROP VIEW s_bodemenondergrond.vw_interpretaties_properties;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_interpretaties_properties
 AS
 SELECT DISTINCT "@id",
    string_to_array("@type"::text, ','::text) AS string_to_array,
    "rdfs:range",
    "rdfs:label",
    "rdfs:subPropertyOf",
    "rdfs:comment"
   FROM s_bodemenondergrond.tbl_interpretatie_properties;

ALTER TABLE s_bodemenondergrond.vw_interpretaties_properties
    OWNER TO postgres;

