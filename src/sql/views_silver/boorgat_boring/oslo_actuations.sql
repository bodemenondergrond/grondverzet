-- s_bodemenondergrond.oslo_actuations source

CREATE OR REPLACE VIEW s_bodemenondergrond.oslo_actuations
AS WITH act AS (
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
 SELECT (('act:boorgat'::text || lip.permkey) || '-'::text) || act.n_act AS "@id",
    'sosa:Actuation'::text AS "@type",
    'obs_prop:diepte_boorgat'::text || lip.permkey AS "actsOnProperty",
    'boorgat:boorgat'::text || lip.permkey AS "hasFeatureOfInterest",
    (('result:boorgat'::text || lip.permkey) || '-act-'::text) || act.n_act AS "hasResult",
    (('boor:boring'::text || lip.permkey) || '-'::text) || act.n_act AS "madeByActuator",
    tb.datum_aanvang AS "resultTime",
    'cl-brm:'::text || lb.beschrijving AS "usedProcedure"
   FROM act
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = act.dov_boring_id AND lip.type = 'BORING'::text
     JOIN b_bodemenondergrond.lut_boormethode lb ON lb.code = act.uitvoeringsmethode
     JOIN b_bodemenondergrond.tbl_boring tb ON tb.dov_boring_id = act.dov_boring_id;