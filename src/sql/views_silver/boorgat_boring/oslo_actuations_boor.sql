-- s_bodemenondergrond.oslo_actuations_boor source

CREATE OR REPLACE VIEW s_bodemenondergrond.oslo_actuations_boor
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
 SELECT (('boor:boring'::text || lip.permkey) || '-'::text) || act.n_act AS "@id",
    'grondboringen:Boor'::text AS "@type",
    'cl-brm:'::text || s_bodemenondergrond.to_camelcase(lb.beschrijving) AS implements,
    (('boordiameter:boring'::text || lip.permkey) || '-'::text) || act.n_act AS "hasProperty"
   FROM act
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = act.dov_boring_id AND lip.type = 'BORING'::text
     JOIN b_bodemenondergrond.lut_boormethode lb ON lb.code = act.uitvoeringsmethode;