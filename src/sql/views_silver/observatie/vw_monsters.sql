-- View: s_bodemenondergrond.vw_moment_sample_opslag

-- DROP VIEW s_bodemenondergrond.vw_moment_sample_opslag;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_moment_sample_opslag
 AS
 SELECT ('moment:sam'::text || lip.permkey) || '-opslag'::text AS "@id",
    'time:Interval'::text AS "@type",
    'datum:start-sam'::text || lip.permkey AS "hasBeginning",
    'datum:end-sam'::text || lip.permkey AS "hasEnd"
   FROM b_bodemenondergrond.tbl_opslaglocatie to2
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = to2.grondmonster_id AND lip.type = 'MONSTER'::text AND lip.state = 'A'::text;

ALTER TABLE s_bodemenondergrond.vw_moment_sample_opslag
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_monster_depths

-- DROP VIEW s_bodemenondergrond.vw_monster_depths;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_monster_depths
 AS
 SELECT ('result:sam'::text || lip.permkey) || '-van'::text AS "@id",
    'grondboringbeno:Diepte'::text AS "@type",
    tm.dieptevan AS value,
    'qudt-unit:M'::text AS "unitMeasure"
   FROM b_bodemenondergrond.tbl_monster tm
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = tm.id AND lip.type = 'MONSTER'::text AND lip.state = 'A'::text
UNION
 SELECT ('result:sam'::text || lip.permkey) || '-tot'::text AS "@id",
    'grondboringbeno:Diepte'::text AS "@type",
    tm.dieptetot AS value,
    'qudt-unit:M'::text AS "unitMeasure"
   FROM b_bodemenondergrond.tbl_monster tm
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = tm.id AND lip.type = 'MONSTER'::text AND lip.state = 'A'::text;

ALTER TABLE s_bodemenondergrond.vw_monster_depths
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_monster_namen

-- DROP VIEW s_bodemenondergrond.vw_monster_namen;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_monster_namen
 AS
 SELECT ('id:sam'::text || lip.permkey) || '-1'::text AS "@id",
    'adms:Identifier'::text AS "@type",
    tm.identificatie AS "skos:notation",
    'agent:organisatie'::text || tu.organisatie_id AS "dcterms:source"
   FROM b_bodemenondergrond.tbl_monster tm
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = tm.id AND lip.type = 'MONSTER'::text AND lip.state = 'A'::text
     LEFT JOIN b_bodemenondergrond.tbl_uitvoerder tu ON tu.uitvoerder_id = tm.monstername_door
UNION
 SELECT (('id:sam'::text || lip.permkey) || '-'::text) || (1 + row_number() OVER (PARTITION BY tm.id ORDER BY tlab.alternatieve_benaming_id)) AS "@id",
    'adms:Identifier'::text AS "@type",
    tm.identificatie AS "skos:notation",
    'agent:organisatie'::text || tu.organisatie_id AS "dcterms:source"
   FROM b_bodemenondergrond.tbl_laboproeven_alternatieve_benaming tlab
     JOIN b_bodemenondergrond.tbl_monster tm ON tm.id = tlab.grondmonster_id
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = tm.id AND lip.type = 'MONSTER'::text AND lip.state = 'A'::text
     LEFT JOIN b_bodemenondergrond.tbl_uitvoerder tu ON tu.uitvoerder_id = tm.monstername_door;

ALTER TABLE s_bodemenondergrond.vw_monster_namen
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_monsters_na_monsterbehandeling

-- DROP VIEW s_bodemenondergrond.vw_monsters_na_monsterbehandeling;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_monsters_na_monsterbehandeling
 AS
 WITH monster_ids AS (
         SELECT tmb_1.id,
            row_number() OVER (PARTITION BY tmb_1.monster) AS rn
           FROM b_bodemenondergrond.tbl_monster_behandeling tmb_1
          WHERE tmb_1.behandeling <> 'M_MVD'::text
        )
 SELECT 'result:deltasam'::text || lip.permkey AS "@id",
    'Sosa:Sample'::text AS "@type",
    jsonb_agg((('act:sam'::text || lip.permkey) || '-'::text) || monster_ids.rn) AS "isResultOf",
    'boorgat:boorgat'::text || tm.parent_permkey AS "isSampleOf"
   FROM b_bodemenondergrond.tbl_monster_behandeling tmb
     JOIN b_bodemenondergrond.tbl_monster tm ON tm.id = tmb.monster
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = tm.id AND lip.type = 'MONSTER'::text AND lip.state = 'A'::text
     JOIN monster_ids ON monster_ids.id = tmb.id
  GROUP BY lip.permkey, tm.parent_permkey;

ALTER TABLE s_bodemenondergrond.vw_monsters_na_monsterbehandeling
    OWNER TO postgres;

