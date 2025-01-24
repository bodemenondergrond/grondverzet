-- s_bodemenondergrond.oslo_samplings source

CREATE OR REPLACE VIEW s_bodemenondergrond.oslo_samplings
AS WITH samples AS (
         SELECT tm_1.id,
            lip.permkey,
            row_number() OVER (PARTITION BY tm_1.parent_permkey ORDER BY tm_1.id) AS rn
           FROM b_bodemenondergrond.tbl_monster tm_1
             JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = tm_1.id AND lip.type = 'MONSTER'::text
        )
 SELECT (('sam:'::text || tm.parent_permkey) || '-'::text) || samples.rn AS "@id",
    'sosa:Sampling'::text AS "@type",
    'boorgat:boorgat'::text || tm.parent_permkey AS "hasFeatureOfInterest",
    'result:sam'::text || samples.permkey AS "hasResult",
    (('boor:boring'::text || tm.parent_permkey) || '-'::text) || samples.rn AS "madeBySampler",
    tm.datum_monstername AS "resultTime",
    tm.bemonsteringsprocedure AS "usedProcedure"
   FROM b_bodemenondergrond.tbl_monster tm
     JOIN samples ON tm.id = samples.id
  WHERE tm.parent_permkey IS NOT NULL;