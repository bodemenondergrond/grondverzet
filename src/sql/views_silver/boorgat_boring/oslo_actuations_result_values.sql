-- s_bodemenondergrond.oslo_actuations_results_values source

CREATE OR REPLACE VIEW s_bodemenondergrond.oslo_actuations_results_values
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
 SELECT ((((('result:boorgat'::text || lip.permkey) || '-act'::text) || lip.permkey) || '-'::text) || act.n_act) || '-post'::text AS "@id",
    'grondboringbeno:Diepte'::text AS "@type",
    'qudt-unit:M'::text AS "unitMeasure",
    ''::text || act.tot AS value
   FROM act
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = act.dov_boring_id AND lip.type = 'BORING'::text
UNION ALL
 SELECT ((((('result:boorgat'::text || lip.permkey) || '-act'::text) || lip.permkey) || '-'::text) || act.n_act) || '-pre'::text AS "@id",
    'grondboringbeno:Diepte'::text AS "@type",
    'qudt-unit:M'::text AS "unitMeasure",
    ''::text || act.van AS value
   FROM act
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = act.dov_boring_id AND lip.type = 'BORING'::text;