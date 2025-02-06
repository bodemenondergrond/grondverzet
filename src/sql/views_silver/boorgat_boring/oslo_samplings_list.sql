-- s_bodemenondergrond.oslo_samplings_list source

CREATE OR REPLACE VIEW s_bodemenondergrond.oslo_samplings_list
AS WITH counter AS (
         SELECT tm.parent_permkey,
            count(tm.id) AS count
           FROM b_bodemenondergrond.tbl_monster tm
          GROUP BY tm.parent_permkey
        ), samples AS (
         SELECT tm.id,
            tm.parent_permkey,
            row_number() OVER (PARTITION BY tm.parent_permkey ORDER BY tm.id) AS rn
           FROM b_bodemenondergrond.tbl_monster tm
          WHERE tm.parent_permkey IS NOT NULL
        )
 SELECT (('list:boorgat'::text || samples.parent_permkey) || '-sam-'::text) || samples.rn AS "@id",
    'rdf:List'::text AS "@type",
    (('sam:boorgat'::text || samples.parent_permkey) || '-'::text) || samples.rn AS first,
        CASE
            WHEN samples.rn < counter.count THEN (('list:'::text || samples.parent_permkey) || '-sam-'::text) || (samples.rn + 1)
            ELSE NULL::text
        END AS rest
   FROM samples
     JOIN counter ON counter.parent_permkey = samples.parent_permkey;