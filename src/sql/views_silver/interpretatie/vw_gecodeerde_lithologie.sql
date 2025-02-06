-- View: s_bodemenondergrond.vw_gecodeerde_lithologie_group_observations

-- DROP VIEW s_bodemenondergrond.vw_gecodeerde_lithologie_group_observations;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_gecodeerde_lithologie_group_observations
 AS
 WITH extras AS (
         SELECT tgl.gecodeerd_lithologisch_id,
            array_remove(array_agg(DISTINCT 'cl-tektoniek:'::text || tt.kenmerk), NULL::text) AS "bodemenondergrond:tektoniek",
            array_remove(array_agg(DISTINCT 'cl-ader:'::text || ta.kenmerk), NULL::text) AS "bodemenondergrond:ader",
            array_remove(array_agg(DISTINCT 'cl-fossielaard:'::text || tf.fossielaard), NULL::text) AS "bodemenondergrond:fossielaard",
            array_remove(array_agg(DISTINCT 'cl-fossieltype:'::text || tf.fossieltype), NULL::text) AS "bodemenondergrond:fossieltype",
            array_remove(array_agg(DISTINCT 'cl-seckenm:'::text || tsk.kenmerk), NULL::text) AS "bodemenondergrond:seckenm",
            array_remove(array_agg(DISTINCT 'cl-sedstruct:'::text || tss.kenmerk), NULL::text) AS "bodemenondergrond:sedstruct",
            array_remove(array_agg(DISTINCT 'cl-kleur:'::text || tgl.kleur), NULL::text) AS "bodemenondergrond:kleur"
           FROM b_bodemenondergrond.tbl_gecodeerd_lithologisch tgl
             LEFT JOIN b_bodemenondergrond.tbl_tektoniek tt ON tgl.gecodeerd_lithologisch_id = tt.gecodeerd_lithologisch_id
             LEFT JOIN b_bodemenondergrond.tbl_ader ta ON tgl.gecodeerd_lithologisch_id = ta.gecodeerd_lithologisch_id
             LEFT JOIN b_bodemenondergrond.tbl_fossiel tf ON tgl.gecodeerd_lithologisch_id = tf.gecodeerd_lithologisch_id
             LEFT JOIN b_bodemenondergrond.tbl_secundair_kenmerk tsk ON tgl.gecodeerd_lithologisch_id = tsk.gecodeerd_lithologisch_id
             LEFT JOIN b_bodemenondergrond.tbl_sedimentaire_structuur tss ON tgl.gecodeerd_lithologisch_id = tss.gecodeerd_lithologisch_id
          GROUP BY tgl.gecodeerd_lithologisch_id
         HAVING count(tt.kenmerk) >= 1 OR count(ta.kenmerk) >= 1 OR count(tf.fossielaard) >= 1 OR count(tf.fossieltype) >= 1 OR count(tsk.kenmerk) >= 1 OR count(tss.kenmerk) >= 1 OR count(tgl.kleur) >= 1
        ), r AS (
         SELECT lip.permkey,
            row_number() OVER (PARTITION BY lip.permkey ORDER BY tlb.van) AS rn,
            array_remove(ARRAY['cl-lithonaam:'::text || tlb.hoofdbenaming_1::text, 'cl-lithonaam:'::text || tlb.hoofdbenaming_2::text], NULL::text) AS "bodemenondergrond:hoofdnaam",
            array_remove(ARRAY[
                CASE
                    WHEN tlb.plaatselijk_1 = 'P'::bpchar THEN 'cl-lithonaam:P'::text || tlb.bijbenaming_1::text
                    ELSE 'cl-lithonaam:P'::text || tlb.bijbenaming_1::text
                END,
                CASE
                    WHEN tlb.plaatselijk_2 = 'P'::bpchar THEN 'cl-lithonaam:P'::text || tlb.bijbenaming_2::text
                    ELSE 'cl-lithonaam:P'::text || tlb.bijbenaming_2::text
                END,
                CASE
                    WHEN tlb.plaatselijk_3 = 'P'::bpchar THEN 'cl-lithonaam:P'::text || tlb.bijbenaming_3::text
                    ELSE 'cl-lithonaam:P'::text || tlb.bijbenaming_3::text
                END], NULL::text) AS "bodemenondergrond:bijnaam",
            extras.gecodeerd_lithologisch_id,
            extras."bodemenondergrond:tektoniek",
            extras."bodemenondergrond:ader",
            extras."bodemenondergrond:fossielaard",
            extras."bodemenondergrond:fossieltype",
            extras."bodemenondergrond:seckenm",
            extras."bodemenondergrond:sedstruct",
            extras."bodemenondergrond:kleur"
           FROM b_bodemenondergrond.tbl_interpretatie ti
             JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = ti.interpretatie_id AND lip.type = 'INTERPRETATIE'::text AND lip.state = 'A'::text
             JOIN b_bodemenondergrond.tbl_gecodeerd_lithologisch tlb ON tlb.interpretatie_id = ti.interpretatie_id
             JOIN extras ON extras.gecodeerd_lithologisch_id = tlb.gecodeerd_lithologisch_id
        )
 SELECT (('observation:interp'::text || permkey) || '-'::text) || rn AS "@id",
    'qb:Observation'::text AS "@type",
    'dataset:gecodeerdeLithologie'::text AS "qb:dataSet",
    'cl-interpretatie:gecodeerdeLithologie'::text AS "dcterms:type",
    ((('quantityvalue:interp'::text || permkey) || '-'::text) || rn) || '-van'::text AS "bodemenondergrond:diepteVan",
    ((('quantityvalue:interp'::text || permkey) || '-'::text) || rn) || '-tot'::text AS "bodemenondergrond:diepteTot",
    "bodemenondergrond:hoofdnaam",
    "bodemenondergrond:bijnaam",
    "bodemenondergrond:kleur",
    "bodemenondergrond:ader",
    "bodemenondergrond:fossielaard",
    "bodemenondergrond:fossieltype",
    "bodemenondergrond:seckenm",
    "bodemenondergrond:sedstruct",
    "bodemenondergrond:tektoniek"
   FROM r;

ALTER TABLE s_bodemenondergrond.vw_gecodeerde_lithologie_group_observations
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_gecodeerde_lithologie_group_observations_values

-- DROP VIEW s_bodemenondergrond.vw_gecodeerde_lithologie_group_observations_values;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_gecodeerde_lithologie_group_observations_values
 AS
 WITH r AS (
         SELECT lip.permkey,
            row_number() OVER (PARTITION BY lip.permkey ORDER BY tlb.van) AS rn,
            tlb.van,
            tlb.tot
           FROM b_bodemenondergrond.tbl_interpretatie ti
             JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = ti.interpretatie_id AND lip.type = 'INTERPRETATIE'::text AND lip.state = 'A'::text
             JOIN b_bodemenondergrond.tbl_gecodeerd_lithologisch tlb ON tlb.interpretatie_id = ti.interpretatie_id
        )
 SELECT ((('quantityvalue:interp'::text || r.permkey) || '-'::text) || r.rn) || '-van'::text AS "@id",
    'qudt:QuantityValue'::text AS "@type",
    r.van AS "qudt:value",
    'qudt-unit:M'::text AS "qudt:unit"
   FROM r
UNION ALL
 SELECT ((('quantityvalue:interp'::text || r.permkey) || '-'::text) || r.rn) || '-tot'::text AS "@id",
    'qudt:QuantityValue'::text AS "@type",
    r.tot AS "qudt:value",
    'qudt-unit:M'::text AS "qudt:unit"
   FROM r;

ALTER TABLE s_bodemenondergrond.vw_gecodeerde_lithologie_group_observations_values
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_gecodeerde_lithologie_observation

-- DROP VIEW s_bodemenondergrond.vw_gecodeerde_lithologie_observation;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_gecodeerde_lithologie_observation
 AS
 WITH relevant_int AS (
         SELECT DISTINCT ti_1.interpretatie_id,
            lip.permkey AS relkey
           FROM b_bodemenondergrond.tbl_interpretatie ti_1
             JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = ti_1.interpretatie_id AND lip.state = 'A'::text AND lip.type = 'INTERPRETATIE'::text
             JOIN b_bodemenondergrond.tbl_gecodeerd_lithologisch tlb ON tlb.interpretatie_id = ti_1.interpretatie_id
        ), ti AS (
         SELECT DISTINCT relevant_int.relkey,
            ti_1.geldigvan AS "prov:startedAtTime",
            ti_1.geldigtot AS "prov:endedAtTime",
            ti_1.datum AS "sosa:resultTime",
            'agent:agent'::text || ti_1.partner AS "bodemenondergrond:databeheerder",
            'agent:agent'::text || td.organisatie_id AS "bodemenondergrond:dataleverancier",
            'cl-betr:'::text || ti_1.betrouwbaarheid AS "ssn-system:qualityOfObservation"
           FROM b_bodemenondergrond.tbl_interpretatie ti_1
             JOIN relevant_int ON relevant_int.interpretatie_id = ti_1.interpretatie_id
             JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = ti_1.interpretatie_id AND lip.state = 'A'::text AND lip.type = 'INTERPRETATIE'::text
             LEFT JOIN b_bodemenondergrond.tbl_dataleverancier td ON td.dataleverancier_id = ti_1.dataleverancier
        ), opdrachten AS (
         SELECT DISTINCT relevant_int.relkey,
            array_agg('opdracht:'::text || lip.permkey) AS "prov:wasStartedBy"
           FROM b_bodemenondergrond.tbl_opdracht to2
             JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = to2.opdracht_id AND lip.type = 'OPDRACHT'::text AND lip.state = 'A'::text
             JOIN b_bodemenondergrond.lnk_opdracht_interpretatie loi ON loi.opdracht_id = to2.opdracht_id
             JOIN relevant_int ON relevant_int.interpretatie_id = loi.interpretatie_id
          GROUP BY relevant_int.relkey
        ), boring AS (
         SELECT DISTINCT relevant_int.relkey,
            lipb.permkey
           FROM b_bodemenondergrond.tbl_boring tb
             JOIN b_bodemenondergrond.lnk_id_permkey lipb ON lipb.id = tb.dov_boring_id AND lipb.type = 'BORING'::text AND lipb.state = 'A'::text
             JOIN b_bodemenondergrond.lnk_boring_interpretatie lbi ON tb.dov_boring_id = lbi.dov_boring_id
             JOIN relevant_int ON relevant_int.interpretatie_id = lbi.interpretatie_id
        ), auteurs AS (
         SELECT DISTINCT relevant_int.relkey,
            array_agg('agent:actor'::text || ta.actor_id) AS "sosa:madeBySensor"
           FROM b_bodemenondergrond.lnk_interpretatie_auteur lia
             JOIN b_bodemenondergrond.tbl_actor ta ON ta.actor_id = lia.actor_id
             JOIN relevant_int ON relevant_int.interpretatie_id = lia.interpretatie_id
          GROUP BY relevant_int.relkey
        )
 SELECT DISTINCT 'interp:'::text || ti.relkey AS "@id",
    'sosa:Observation'::text AS "@type",
    'cl-interpretatie:gecodeerdeLithologie'::text AS "dcterms:type",
    '"Gecodeerde lithologie op locatie van boorgat '::text || boring.permkey AS "rdfs:label",
    ti."sosa:resultTime",
    ti."prov:startedAtTime",
    ti."prov:endedAtTime",
    'observationgroup:interp'::text || ti.relkey AS "sosa:hasResult",
    'location:boorgat'::text || boring.permkey AS "sosa:hasFeatureOfInterest",
    'location:boorgat'::text || boring.permkey AS "prov:atLocation",
    ti."bodemenondergrond:dataleverancier",
    ti."bodemenondergrond:databeheerder",
    opdrachten."prov:wasStartedBy",
    auteurs."sosa:madeBySensor",
    ti."ssn-system:qualityOfObservation"
   FROM ti
     JOIN boring ON boring.relkey = ti.relkey
     LEFT JOIN opdrachten ON opdrachten.relkey = ti.relkey
     LEFT JOIN auteurs ON auteurs.relkey = ti.relkey;

ALTER TABLE s_bodemenondergrond.vw_gecodeerde_lithologie_observation
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_gecodeerde_lithologie_observation_group

-- DROP VIEW s_bodemenondergrond.vw_gecodeerde_lithologie_observation_group;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_gecodeerde_lithologie_observation_group
 AS
 WITH relevant_int AS (
         SELECT DISTINCT ti.interpretatie_id,
            lip.permkey AS relkey
           FROM b_bodemenondergrond.tbl_interpretatie ti
             JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = ti.interpretatie_id AND lip.state = 'A'::text AND lip.type = 'INTERPRETATIE'::text
             JOIN b_bodemenondergrond.tbl_gecodeerd_lithologisch tlb ON tlb.interpretatie_id = ti.interpretatie_id
        ), observations AS (
         SELECT relevant_int.relkey,
            (('observation:interp'::text || relevant_int.relkey) || '-'::text) || row_number() OVER (PARTITION BY relevant_int.relkey ORDER BY tlb.van) AS obs
           FROM b_bodemenondergrond.tbl_interpretatie ti
             JOIN relevant_int ON relevant_int.interpretatie_id = ti.interpretatie_id
             JOIN b_bodemenondergrond.tbl_gecodeerd_lithologisch tlb ON tlb.interpretatie_id = ti.interpretatie_id
        ), boring AS (
         SELECT DISTINCT relevant_int.relkey,
            lipb.permkey
           FROM b_bodemenondergrond.tbl_boring tb
             JOIN b_bodemenondergrond.lnk_id_permkey lipb ON lipb.id = tb.dov_boring_id AND lipb.type = 'BORING'::text AND lipb.state = 'A'::text
             JOIN b_bodemenondergrond.lnk_boring_interpretatie lbi ON tb.dov_boring_id = lbi.dov_boring_id
             JOIN relevant_int ON relevant_int.interpretatie_id = lbi.interpretatie_id
        )
 SELECT 'observationgroup:interp'::text || observations.relkey AS "@id",
    'qb:ObservationGroup'::text AS "@type",
    '"Observation group gecodeerde lithologie op locatie van boorgat '::text || boring.permkey AS "rdfs:label",
    ('list:interp'::text || observations.relkey) || '-1'::text AS "bodemenondergrond:list",
    array_agg(observations.obs) AS "qb:observation"
   FROM observations
     JOIN boring ON observations.relkey = boring.relkey
  GROUP BY observations.relkey, boring.permkey;

ALTER TABLE s_bodemenondergrond.vw_gecodeerde_lithologie_observation_group
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_gecodeerde_lithologie_observation_list

-- DROP VIEW s_bodemenondergrond.vw_gecodeerde_lithologie_observation_list;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_gecodeerde_lithologie_observation_list
 AS
 WITH counter AS (
         SELECT lip.permkey,
            count(ti.interpretatie_id) AS c
           FROM b_bodemenondergrond.tbl_interpretatie ti
             JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = ti.interpretatie_id AND lip.type = 'INTERPRETATIE'::text AND lip.state = 'A'::text
             JOIN b_bodemenondergrond.tbl_gecodeerd_lithologisch tlb ON tlb.interpretatie_id = ti.interpretatie_id
          GROUP BY lip.permkey
        ), observations AS (
         SELECT lip.permkey,
            row_number() OVER (PARTITION BY lip.permkey ORDER BY tlb.van) AS rn
           FROM b_bodemenondergrond.tbl_interpretatie ti
             JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = ti.interpretatie_id AND lip.type = 'INTERPRETATIE'::text AND lip.state = 'A'::text
             JOIN b_bodemenondergrond.tbl_gecodeerd_lithologisch tlb ON tlb.interpretatie_id = ti.interpretatie_id
        )
 SELECT (('list:interp'::text || observations.permkey) || '-'::text) || observations.rn AS "@id",
    'rdf:List'::text AS "@type",
    (('observation:interp'::text || observations.permkey) || '-'::text) || observations.rn AS "rdf:fist",
        CASE
            WHEN observations.rn < counter.c THEN (('list:interp'::text || observations.permkey) || '-'::text) || (observations.rn + 1)
            ELSE 'rdf:nil'::text
        END AS "rdf:rest"
   FROM observations
     JOIN counter ON counter.permkey = observations.permkey;

ALTER TABLE s_bodemenondergrond.vw_gecodeerde_lithologie_observation_list
    OWNER TO postgres;

