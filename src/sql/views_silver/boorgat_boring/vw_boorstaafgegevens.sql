-- View: s_bodemenondergrond.vw_boorstaatgegevens_consistentie_observation

-- DROP VIEW s_bodemenondergrond.vw_boorstaatgegevens_consistentie_observation;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_boorstaatgegevens_consistentie_observation
 AS
 WITH opdr AS (
         SELECT lip_1.permkey,
            linkopd.dov_boring_id
           FROM b_bodemenondergrond.lnk_id_permkey lip_1
             JOIN b_bodemenondergrond.lnk_boring_opdracht linkopd ON linkopd.opdracht_id = lip_1.id AND lip_1.type = 'OPDRACHT'::text AND lip_1.state = 'A'::text
        )
 SELECT DISTINCT 'observation:cons'::text || lip.permkey AS "@id",
    'sosa:Observation'::text AS "@type",
    'Consistentie boorgat '::text || lip.permkey AS "rdfs:label",
    'location:boorgat'::text || lip.permkey AS "prov:atLocation",
    'slice:cons'::text || lip.permkey AS "hasResult",
    tb.datum_aanvang AS "resultTime",
    'prop:consistentie'::text AS "observedProperty",
    'cl-bpt:bepalen_consistentie_boorgat'::text AS "usedProcedure",
    COALESCE(array_agg('opdracht:'::text || opdr.permkey), NULL::text[]) AS "prov:wasStartedBy",
    'agent:organisatie'::text || tu.organisatie_id AS "madeBySensor",
    'boorgat:boorgat'::text || lip.permkey AS "hasFeatureOfInterest"
   FROM b_bodemenondergrond.tbl_boring tb
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON tb.dov_boring_id = lip.id AND lip.type = 'BORING'::text AND lip.state = 'A'::text
     JOIN ( SELECT DISTINCT tc_1.boring_id
           FROM b_bodemenondergrond.tbl_consistentie tc_1) tc ON tb.dov_boring_id = tc.boring_id
     LEFT JOIN opdr ON opdr.dov_boring_id = tb.dov_boring_id
     LEFT JOIN b_bodemenondergrond.tbl_uitvoerder tu ON tu.uitvoerder_id = tb.uitvoerder
  GROUP BY lip.permkey, tb.datum_aanvang, tu.organisatie_id;

ALTER TABLE s_bodemenondergrond.vw_boorstaatgegevens_consistentie_observation
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_boorstaatgegevens_consistentie_slice

-- DROP VIEW s_bodemenondergrond.vw_boorstaatgegevens_consistentie_slice;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_boorstaatgegevens_consistentie_slice
 AS
 WITH r AS (
         SELECT lip.permkey,
            row_number() OVER (PARTITION BY tc.boring_id ORDER BY tc.diepte_van) AS rn
           FROM b_bodemenondergrond.tbl_consistentie tc
             JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = tc.boring_id AND lip.type = 'BORING'::text AND lip.state = 'A'::text
        )
 SELECT 'slice:cons'::text || permkey AS "@id",
    'qb:Slice'::text AS "@type",
    'Slice consistentie boorgat '::text || permkey AS "rdfs:label",
    'slicekey:sliceBydepth'::text AS "qb:sliceStructure",
    'prop:consistentie'::text AS "bodemenondergrond:eigenschap",
    'boorgat:boorgat'::text || permkey AS "bodemenondergrond:onderwerp",
    array_agg((('observation:cons'::text || permkey) || '-'::text) || rn) AS "qb:observation"
   FROM r
  GROUP BY permkey;

ALTER TABLE s_bodemenondergrond.vw_boorstaatgegevens_consistentie_slice
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_boorstaatgegevens_consistentie_slice_observation_values

-- DROP VIEW s_bodemenondergrond.vw_boorstaatgegevens_consistentie_slice_observation_values;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_boorstaatgegevens_consistentie_slice_observation_values
 AS
 WITH r AS (
         SELECT tc.id,
            row_number() OVER (PARTITION BY tc.boring_id ORDER BY tc.diepte_van) AS rn
           FROM b_bodemenondergrond.tbl_consistentie tc
        )
 SELECT ((('quantityvalue:cons'::text || lip.permkey) || '-'::text) || r.rn) || '-van'::text AS "@id",
    'qudt:QuantityValue'::text AS "@type",
    tc.diepte_van AS "qudt:value",
    'qudt-unit:M'::text AS "qudt:unit"
   FROM b_bodemenondergrond.tbl_consistentie tc
     JOIN r ON r.id = tc.id
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = tc.boring_id AND lip.type = 'BORING'::text AND lip.state = 'A'::text
UNION
 SELECT ((('quantityvalue:cons'::text || lip.permkey) || '-'::text) || r.rn) || '-tot'::text AS "@id",
    'qudt:QuantityValue'::text AS "@type",
    tc.diepte_tot AS "qudt:value",
    'qudt-unit:M'::text AS "qudt:unit"
   FROM b_bodemenondergrond.tbl_consistentie tc
     JOIN r ON r.id = tc.id
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = tc.boring_id AND lip.type = 'BORING'::text AND lip.state = 'A'::text;

ALTER TABLE s_bodemenondergrond.vw_boorstaatgegevens_consistentie_slice_observation_values
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_boorstaatgegevens_consistentie_slice_observations

-- DROP VIEW s_bodemenondergrond.vw_boorstaatgegevens_consistentie_slice_observations;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_boorstaatgegevens_consistentie_slice_observations
 AS
 WITH r AS (
         SELECT tc_1.id,
            row_number() OVER (PARTITION BY tc_1.boring_id ORDER BY tc_1.diepte_van) AS rn
           FROM b_bodemenondergrond.tbl_consistentie tc_1
        )
 SELECT (('observation:cons'::text || lip.permkey) || '-'::text) || r.rn AS "@id",
    'qb:Observation'::text AS "@type",
    'dataset:cube_results'::text AS "qb:dataSet",
    ((('quantityvalue:cons'::text || lip.permkey) || '-'::text) || r.rn) || '-van'::text AS "bodemenondergrond:diepteVan",
    ((('quantityvalue:cons'::text || lip.permkey) || '-'::text) || r.rn) || '-tot'::text AS "bodemenondergrond:diepteTot",
    'cl-cons:'::text || tc.consistentie AS "bodemenondergrond:beoordeling"
   FROM b_bodemenondergrond.tbl_consistentie tc
     JOIN r ON r.id = tc.id
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = tc.boring_id AND lip.type = 'BORING'::text AND lip.state = 'A'::text;

ALTER TABLE s_bodemenondergrond.vw_boorstaatgegevens_consistentie_slice_observations
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_boorstaatgegevens_kleur_observation

-- DROP VIEW s_bodemenondergrond.vw_boorstaatgegevens_kleur_observation;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_boorstaatgegevens_kleur_observation
 AS
 WITH opdr AS (
         SELECT perm.permkey,
            linkopd.dov_boring_id
           FROM b_bodemenondergrond.lnk_id_permkey perm
             JOIN b_bodemenondergrond.lnk_boring_opdracht linkopd ON linkopd.opdracht_id = perm.id AND perm.type = 'OPDRACHT'::text
        )
 SELECT DISTINCT 'observation:kleur'::text || lip.permkey AS "@id",
    'sosa:Observation'::text AS "@type",
    'Kleur boorgat '::text || lip.permkey AS "rdfs:label",
    'location:boorgat'::text || lip.permkey AS "prov:atLocation",
    'slice:kleur'::text || lip.permkey AS "hasResult",
    tb.datum_aanvang AS "resultTime",
    'prop:kleur'::text AS "observedProperty",
    'cl-bpt:bepalen_kleur_boorgat'::text AS "usedProcedure",
    array_agg('opdracht:'::text || opdr.permkey) AS "prov:wasStartedBy",
    'agent:organisatie'::text || tu.organisatie_id AS "madeBySensor",
    'boorgat:boorgat'::text || lip.permkey AS "hasFeatureOfInterest"
   FROM b_bodemenondergrond.tbl_boring tb
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON tb.dov_boring_id = lip.id AND lip.type = 'BORING'::text AND lip.state = 'A'::text
     JOIN ( SELECT DISTINCT ti_1.boring_id
           FROM b_bodemenondergrond.tbl_insitukleur ti_1) ti ON tb.dov_boring_id = ti.boring_id
     LEFT JOIN opdr ON opdr.dov_boring_id = tb.dov_boring_id
     LEFT JOIN b_bodemenondergrond.tbl_uitvoerder tu ON tu.uitvoerder_id = tb.uitvoerder
  GROUP BY lip.permkey, tu.organisatie_id, tb.datum_aanvang;

ALTER TABLE s_bodemenondergrond.vw_boorstaatgegevens_kleur_observation
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_boorstaatgegevens_kleur_slice

-- DROP VIEW s_bodemenondergrond.vw_boorstaatgegevens_kleur_slice;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_boorstaatgegevens_kleur_slice
 AS
 WITH r AS (
         SELECT lip.permkey,
            row_number() OVER (PARTITION BY ti.boring_id ORDER BY ti.diepte_van) AS rn
           FROM b_bodemenondergrond.tbl_insitukleur ti
             JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = ti.boring_id AND lip.type = 'BORING'::text AND lip.state = 'A'::text
        )
 SELECT 'slice:kleur'::text || permkey AS "@id",
    'qb:Slice'::text AS "@type",
    'Slice kleur boorgat '::text || permkey AS "rdfs:label",
    'slicekey:sliceBydepth'::text AS "qb:sliceStructure",
    'prop:kleur'::text AS "bodemenondergrond:eigenschap",
    'boorgat:boorgat'::text || permkey AS "bodemenondergrond:onderwerp",
    array_agg((('observation:kleur'::text || permkey) || '-'::text) || rn) AS "qb:observation"
   FROM r
  GROUP BY permkey;

ALTER TABLE s_bodemenondergrond.vw_boorstaatgegevens_kleur_slice
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_boorstaatgegevens_kleur_slice_observation_values

-- DROP VIEW s_bodemenondergrond.vw_boorstaatgegevens_kleur_slice_observation_values;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_boorstaatgegevens_kleur_slice_observation_values
 AS
 WITH r AS (
         SELECT ti.id,
            row_number() OVER (PARTITION BY ti.boring_id ORDER BY ti.diepte_van) AS rn
           FROM b_bodemenondergrond.tbl_insitukleur ti
        )
 SELECT ((('quantityvalue:kleur'::text || lip.permkey) || '-'::text) || r.rn) || '-van'::text AS "@id",
    'qudt:QuantityValue'::text AS "@type",
    ti.diepte_van AS "qudt:value",
    'qudt-unit:M'::text AS "qudt:unit"
   FROM b_bodemenondergrond.tbl_insitukleur ti
     JOIN r ON r.id = ti.id
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = ti.boring_id AND lip.type = 'BORING'::text AND lip.state = 'A'::text
UNION
 SELECT ((('quantityvalue:kleur'::text || lip.permkey) || '-'::text) || r.rn) || '-tot'::text AS "@id",
    'qudt:QuantityValue'::text AS "@type",
    ti.diepte_tot AS "qudt:value",
    'qudt-unit:M'::text AS "qudt:unit"
   FROM b_bodemenondergrond.tbl_insitukleur ti
     JOIN r ON r.id = ti.id
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = ti.boring_id AND lip.type = 'BORING'::text AND lip.state = 'A'::text;

ALTER TABLE s_bodemenondergrond.vw_boorstaatgegevens_kleur_slice_observation_values
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_boorstaatgegevens_kleur_slice_observations

-- DROP VIEW s_bodemenondergrond.vw_boorstaatgegevens_kleur_slice_observations;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_boorstaatgegevens_kleur_slice_observations
 AS
 WITH r AS (
         SELECT ti_1.id,
            row_number() OVER (PARTITION BY ti_1.boring_id ORDER BY ti_1.diepte_van) AS rn
           FROM b_bodemenondergrond.tbl_insitukleur ti_1
        )
 SELECT (('observation:kleur'::text || lip.permkey) || '-'::text) || r.rn AS "@id",
    'qb:Observation'::text AS "@type",
    'dataset:cube_results'::text AS "qb:dataSet",
    ((('quantityvalue:kleur'::text || lip.permkey) || '-'::text) || r.rn) || '-van'::text AS "bodemenondergrond:diepteVan",
    ((('quantityvalue:kleur'::text || lip.permkey) || '-'::text) || r.rn) || '-tot'::text AS "bodemenondergrond:diepteTot",
    'cl-kleur:'::text || ti.kleur AS "bodemenondergrond:beoordeling"
   FROM b_bodemenondergrond.tbl_insitukleur ti
     JOIN r ON r.id = ti.id
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = ti.boring_id AND lip.type = 'BORING'::text AND lip.state = 'A'::text;

ALTER TABLE s_bodemenondergrond.vw_boorstaatgegevens_kleur_slice_observations
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_boorstaatgegevens_observable_properties

-- DROP VIEW s_bodemenondergrond.vw_boorstaatgegevens_observable_properties;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_boorstaatgegevens_observable_properties
 AS
 SELECT t."@id",
    'sosa:ObservableProperty'::text AS "@type",
    array_agg('boorgat:boorgat'::text || lip.permkey) AS "ssn:isPropertyOf"
   FROM b_bodemenondergrond.lnk_id_permkey lip
     JOIN ( SELECT DISTINCT 'prop:consistentie'::text AS "@id",
            tc.boring_id
           FROM b_bodemenondergrond.tbl_consistentie tc
        UNION ALL
         SELECT DISTINCT 'prop:vochtgehalte'::text AS "@id",
            tv.boring_id
           FROM b_bodemenondergrond.tbl_vochtgehalte tv
        UNION ALL
         SELECT DISTINCT 'prop:kleur'::text AS "@id",
            ti.boring_id
           FROM b_bodemenondergrond.tbl_insitukleur ti) t ON t.boring_id = lip.id AND lip.type = 'BORING'::text AND lip.state = 'A'::text
  GROUP BY t."@id";

ALTER TABLE s_bodemenondergrond.vw_boorstaatgegevens_observable_properties
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_boorstaatgegevens_vocht_observation

-- DROP VIEW s_bodemenondergrond.vw_boorstaatgegevens_vocht_observation;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_boorstaatgegevens_vocht_observation
 AS
 WITH opdr AS (
         SELECT lip_1.permkey,
            linkopd.dov_boring_id
           FROM b_bodemenondergrond.lnk_id_permkey lip_1
             JOIN b_bodemenondergrond.lnk_boring_opdracht linkopd ON linkopd.opdracht_id = lip_1.id AND lip_1.type = 'OPDRACHT'::text AND lip_1.state = 'A'::text
        )
 SELECT DISTINCT 'observation:vocht'::text || lip.permkey AS "@id",
    'sosa:Observation'::text AS "@type",
    'Vochtgehalte boorgat '::text || lip.permkey AS "rdfs:label",
    'location:boorgat'::text || lip.permkey AS "prov:atLocation",
    'slice:vocht'::text || lip.permkey AS "hasResult",
    tb.datum_aanvang AS "resultTime",
    'prop:vochtgehalte'::text AS "observedProperty",
    'cl-bpt:bepalen_vochtgehalte_boorgat'::text AS "usedProcedure",
    array_agg('opdracht:'::text || opdr.permkey) AS "prov:wasStartedBy",
    'agent:organisatie'::text || tu.organisatie_id AS "madeBySensor",
    'boorgat:boorgat'::text || lip.permkey AS "hasFeatureOfInterest"
   FROM b_bodemenondergrond.tbl_boring tb
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON tb.dov_boring_id = lip.id AND lip.type = 'BORING'::text AND lip.state = 'A'::text
     JOIN ( SELECT DISTINCT tv_1.boring_id
           FROM b_bodemenondergrond.tbl_vochtgehalte tv_1) tv ON tb.dov_boring_id = tv.boring_id
     LEFT JOIN opdr ON opdr.dov_boring_id = tb.dov_boring_id
     LEFT JOIN b_bodemenondergrond.tbl_uitvoerder tu ON tu.uitvoerder_id = tb.uitvoerder
  GROUP BY lip.permkey, tu.organisatie_id, tb.datum_aanvang;

ALTER TABLE s_bodemenondergrond.vw_boorstaatgegevens_vocht_observation
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_boorstaatgegevens_vocht_slice

-- DROP VIEW s_bodemenondergrond.vw_boorstaatgegevens_vocht_slice;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_boorstaatgegevens_vocht_slice
 AS
 WITH r AS (
         SELECT lip.permkey,
            row_number() OVER (PARTITION BY tv.boring_id ORDER BY tv.diepte_van) AS rn
           FROM b_bodemenondergrond.tbl_vochtgehalte tv
             JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = tv.boring_id AND lip.type = 'BORING'::text AND lip.state = 'A'::text
        )
 SELECT 'slice:vocht'::text || permkey AS "@id",
    'qb:Slice'::text AS "@type",
    'Slice vochtgehalte boorgat '::text || permkey AS "rdfs:label",
    'slicekey:sliceBydepth'::text AS "qb:sliceStructure",
    'prop:vochtgehalte'::text AS "bodemenondergrond:eigenschap",
    'boorgat:boorgat'::text || permkey AS "bodemenondergrond:onderwerp",
    array_agg((('observation:vocht'::text || permkey) || '-'::text) || rn) AS "qb:observation"
   FROM r
  GROUP BY permkey;

ALTER TABLE s_bodemenondergrond.vw_boorstaatgegevens_vocht_slice
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_boorstaatgegevens_vocht_slice_observation_values

-- DROP VIEW s_bodemenondergrond.vw_boorstaatgegevens_vocht_slice_observation_values;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_boorstaatgegevens_vocht_slice_observation_values
 AS
 WITH r AS (
         SELECT tv.id,
            row_number() OVER (PARTITION BY tv.boring_id ORDER BY tv.diepte_van) AS rn
           FROM b_bodemenondergrond.tbl_vochtgehalte tv
        )
 SELECT ((('quantityvalue:vocht'::text || lip.permkey) || '-'::text) || r.rn) || '-van'::text AS "@id",
    'qudt:QuantityValue'::text AS "@type",
    tv.diepte_van AS "qudt:value",
    'qudt-unit:M'::text AS "qudt:unit"
   FROM b_bodemenondergrond.tbl_vochtgehalte tv
     JOIN r ON r.id = tv.id
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = tv.boring_id AND lip.type = 'BORING'::text AND lip.state = 'A'::text
UNION
 SELECT ((('quantityvalue:vocht'::text || lip.permkey) || '-'::text) || r.rn) || '-tot'::text AS "@id",
    'qudt:QuantityValue'::text AS "@type",
    tv.diepte_tot AS "qudt:value",
    'qudt-unit:M'::text AS "qudt:unit"
   FROM b_bodemenondergrond.tbl_vochtgehalte tv
     JOIN r ON r.id = tv.id
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = tv.boring_id AND lip.type = 'BORING'::text AND lip.state = 'A'::text;

ALTER TABLE s_bodemenondergrond.vw_boorstaatgegevens_vocht_slice_observation_values
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_boorstaatgegevens_vocht_slice_observations

-- DROP VIEW s_bodemenondergrond.vw_boorstaatgegevens_vocht_slice_observations;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_boorstaatgegevens_vocht_slice_observations
 AS
 WITH r AS (
         SELECT tv_1.id,
            row_number() OVER (PARTITION BY tv_1.boring_id ORDER BY tv_1.diepte_van) AS rn
           FROM b_bodemenondergrond.tbl_vochtgehalte tv_1
        )
 SELECT (('observation:vocht'::text || lip.permkey) || '-'::text) || r.rn AS "@id",
    'qb:Observation'::text AS "@type",
    'dataset:cube_results'::text AS "qb:dataSet",
    ((('quantityvalue:vocht'::text || lip.permkey) || '-'::text) || r.rn) || '-van'::text AS "bodemenondergrond:diepteVan",
    ((('quantityvalue:vocht'::text || lip.permkey) || '-'::text) || r.rn) || '-tot'::text AS "bodemenondergrond:diepteTot",
    'cl-vocht:'::text || tv.vochtgehalte AS "bodemenondergrond:beoordeling"
   FROM b_bodemenondergrond.tbl_vochtgehalte tv
     JOIN r ON r.id = tv.id
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = tv.boring_id AND lip.type = 'BORING'::text AND lip.state = 'A'::text;

ALTER TABLE s_bodemenondergrond.vw_boorstaatgegevens_vocht_slice_observations
    OWNER TO postgres;

