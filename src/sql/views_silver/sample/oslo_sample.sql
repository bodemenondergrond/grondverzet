-- s_bodemenondergrond.oslo_sample source

CREATE OR REPLACE VIEW s_bodemenondergrond.oslo_sample
AS WITH sample_number AS (
         SELECT tm_1.id,
            row_number() OVER (PARTITION BY tm_1.parent_permkey ORDER BY tm_1.id) AS rn
           FROM b_bodemenondergrond.tbl_monster tm_1
          WHERE tm_1.parent_permkey IS NOT NULL
        )
 SELECT 'result:sam'::text || lip.permkey AS "@id",
    'sosa:Sample'::text AS "@type",
    (('sam:boorgat'::text || tm.parent_permkey) || '-'::text) || sample_number.rn AS "sosa:isResultOf",
    'boorgat:boorgat'::text || tm.parent_permkey AS "isSampleOf",
        CASE
            WHEN tm.dieptevan IS NOT NULL THEN ('result:sam'::text || lip.permkey) || '-van'::text
            ELSE NULL::text
        END AS "grondboringbeno:sampleDiepteVan",
        CASE
            WHEN tm.dieptetot IS NOT NULL THEN ('result:sam'::text || lip.permkey) || '-tot'::text
            ELSE NULL::text
        END AS "grondboringbeno:sampleDiepteTot"
   FROM b_bodemenondergrond.tbl_monster tm
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = tm.id AND lip.type = 'MONSTER'::text
     JOIN sample_number ON sample_number.id = tm.id;