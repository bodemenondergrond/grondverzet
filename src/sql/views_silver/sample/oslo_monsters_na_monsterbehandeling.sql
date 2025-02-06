-- s_bodemenondergrond.oslo_monsters_na_monsterbehandeling source

CREATE OR REPLACE VIEW s_bodemenondergrond.oslo_monsters_na_monsterbehandeling
AS WITH monster_ids AS (
         SELECT tmb_1.id,
            row_number() OVER (PARTITION BY tmb_1.monster) AS rn
           FROM b_bodemenondergrond.tbl_monster_behandeling tmb_1
          WHERE tmb_1.behandeling <> 'M_MVD'::text
        )
 SELECT 'result:deltasam'::text || lip.permkey AS "@id",
    'Sosa:Sample'::text AS "@type",
    array_agg((('act:sam'::text || lip.permkey) || '-'::text) || monster_ids.rn) AS "isResultOf",
    'boorgat:boorgat'::text || tm.parent_permkey AS "isSampleOf"
   FROM b_bodemenondergrond.tbl_monster_behandeling tmb
     JOIN b_bodemenondergrond.tbl_monster tm ON tm.id = tmb.monster
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = tm.id AND lip.type = 'MONSTER'::text
     JOIN monster_ids ON monster_ids.id = tmb.id
  GROUP BY lip.permkey, tm.parent_permkey, tm.parent_type
 HAVING tm.parent_type = 'BORING'::text;