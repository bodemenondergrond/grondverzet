-- View: s_bodemenondergrond.vw_actuations

-- DROP VIEW s_bodemenondergrond.vw_actuations;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_actuations
 AS
 WITH act AS (
         SELECT tbd.partition_key,
            tbd.boor_detail_id,
            tbd.dov_boring_id,
            tbd.van,
            tbd.tot,
            tbd.uitvoeringsmethode,
            tbd.bekisting_nr,
            tbd.bekisting_dikte,
            tbd.bekisting_materiaal,
            tbd.boordiameter,
            row_number() OVER (PARTITION BY tbd.dov_boring_id ORDER BY tbd.van) AS n_act
           FROM b_bodemenondergrond.tbl_boor_detail tbd
        )
 SELECT (('act:'::text || lip.permkey) || '-'::text) || act.n_act AS "@id",
    'sosa:Actuation'::text AS "@type",
    'obs_prop:diepte_boorgat'::text || lip.permkey AS "actsOnProperty",
    'boorgat:boorgat'::text || lip.permkey AS "hasFeatureOfInterest",
    jsonb_build_object('@id', (((('result:boorgat'::text || lip.permkey) || '-act'::text) || lip.permkey) || '-'::text) || act.n_act, '@type', 'sosa:Result', 'postconditie', json_build_object('@id', ((((('result:boorgat'::text || lip.permkey) || '-act'::text) || lip.permkey) || '-'::text) || act.n_act) || '-post'::text, '@type', 'grondboringbeno:Diepte', 'unitMeasure', 'qudt-unit:M', 'value', ''::text || act.tot), 'preconditie', json_build_object('@id', ((((('result:boorgat'::text || lip.permkey) || '-act'::text) || lip.permkey) || '-'::text) || act.n_act) || '-pre'::text, '@type', 'grondboringbeno:Diepte', 'unitMeasure', 'qudt-unit:M', 'value', ''::text || act.van), 'about', 'boorgat:boorgat'::text || lip.permkey) AS "hasResult",
    json_build_object('@id', (('boor:boring'::text || lip.permkey) || '-'::text) || act.n_act, '@type', 'grondboringen:Boor', 'implements', 'cl-brm:'::text || lb.beschrijving, 'hasProperty', (('boordiamaer:boring'::text || lip.permkey) || '-'::text) || act.n_act) AS "madeByActuator",
    tb.datum_aanvang AS "resultTime",
    'cl-brm:'::text || lb.beschrijving AS "usedProcedure"
   FROM act
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = act.dov_boring_id AND lip.type = 'BORING'::text
     JOIN b_bodemenondergrond.lut_boormethode lb ON lb.code = act.uitvoeringsmethode
     JOIN b_bodemenondergrond.tbl_boring tb ON tb.dov_boring_id = act.dov_boring_id;

ALTER TABLE s_bodemenondergrond.vw_actuations
    OWNER TO datawarehouse_ddl;

-- View: s_bodemenondergrond.vw_actuations_list

-- DROP VIEW s_bodemenondergrond.vw_actuations_list;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_actuations_list
 AS
 WITH counter AS (
         SELECT tbd_1.dov_boring_id,
            count(tbd_1.boor_detail_id) AS count
           FROM b_bodemenondergrond.tbl_boor_detail tbd_1
          GROUP BY tbd_1.dov_boring_id
        ), tbd AS (
         SELECT tbd_1.partition_key,
            tbd_1.boor_detail_id,
            tbd_1.dov_boring_id,
            tbd_1.van,
            tbd_1.tot,
            tbd_1.uitvoeringsmethode,
            tbd_1.bekisting_nr,
            tbd_1.bekisting_dikte,
            tbd_1.bekisting_materiaal,
            tbd_1.boordiameter,
            row_number() OVER (PARTITION BY tbd_1.dov_boring_id ORDER BY tbd_1.van) AS rn
           FROM b_bodemenondergrond.tbl_boor_detail tbd_1
        )
 SELECT (('list:'::text || lip.permkey) || '-act'::text) || tbd.rn AS "@id",
    'rdf:List'::text AS "@type",
    (('act:'::text || lip.permkey) || '-'::text) || tbd.rn AS first,
        CASE
            WHEN tbd.rn < counter.count THEN (('list:'::text || lip.permkey) || '-act'::text) || (tbd.rn + 1)
            ELSE NULL::text
        END AS rest
   FROM tbd
     JOIN counter ON counter.dov_boring_id = tbd.dov_boring_id
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = tbd.dov_boring_id AND lip.type = 'BORING'::text;

ALTER TABLE s_bodemenondergrond.vw_actuations_list
    OWNER TO datawarehouse_ddl;

