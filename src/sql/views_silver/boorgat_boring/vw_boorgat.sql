-- View: s_bodemenondergrond.vw_boorgat

-- DROP VIEW s_bodemenondergrond.vw_boorgat;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_boorgat
 AS
 WITH tm AS (
         SELECT tm_1.partition_key,
            tm_1.id,
            tm_1.identificatie,
            tm_1.monster_key,
            tm_1.datum_monstername,
            tm_1.tijdstip_monstername,
            tm_1.monstername_door,
            tm_1.organisatiecode,
            tm_1.status,
            tm_1.lastupdate,
            tm_1.techniek,
            tm_1.condities,
            tm_1.parent_permkey,
            tm_1.parent_type,
            tm_1.dieptevan,
            tm_1.dieptetot,
            tm_1.monstersamenstelling,
            tm_1.materiaalklasse,
            tm_1.bemonsteringsinstrument,
            tm_1.bemonsteringsprocedure,
            tm_1.monstertype,
            tm_1.opvolging,
            lip_1.partition_key,
            lip_1.id,
            lip_1.permkey,
            lip_1.type,
            lip_1.state,
            row_number() OVER (PARTITION BY tm_1.parent_permkey ORDER BY tm_1.id) AS rn
           FROM b_bodemenondergrond.tbl_monster tm_1
             JOIN b_bodemenondergrond.lnk_id_permkey lip_1 ON lip_1.id = tm_1.id AND lip_1.type = 'MONSTER'::text
        )
 SELECT 'boorgat:boorgat'::text || lip.permkey AS "@id",
    'grondboringbeno:Boorgat'::text AS "@type",
    'geometrie:boorgat'::text || lip.permkey AS "hasGeometry",
    array_agg('result:sam'::text || tm.permkey) AS "hasSample",
    'obs_prop:diepte_boorgat'::text || lip.permkey AS "hasProperty"
   FROM b_bodemenondergrond.tbl_boring tb
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = tb.dov_boring_id AND lip.type = 'BORING'::text
     LEFT JOIN tm tm(partition_key, id, identificatie, monster_key, datum_monstername, tijdstip_monstername, monstername_door, organisatiecode, status, lastupdate, techniek, condities, parent_permkey, parent_type, dieptevan, dieptetot, monstersamenstelling, materiaalklasse, bemonsteringsinstrument, bemonsteringsprocedure, monstertype, opvolging, partition_key_1, id_1, permkey, type, state, rn) ON tm.parent_permkey = lip.permkey
  GROUP BY lip.permkey;

ALTER TABLE s_bodemenondergrond.vw_boorgat
    OWNER TO postgres;

-- View: s_bodemenondergrond.vw_boorgatmeting

-- DROP VIEW s_bodemenondergrond.vw_boorgatmeting;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_boorgatmeting
 AS
 SELECT 'obs:bgm'::text || permkey AS "@id",
    'sosa:Observation'::text AS "@type",
    'result:obsbgm'::text || permkey AS "sosa:hasResult",
    'cl-opt:meting_van_het_boorgat'::text AS "sosa:usedProcedure",
    aanvang::timestamp without time zone AS "sosa:resultTime",
    'obs_prop:bgm'::text || permkey AS "sosa:observedProperty",
    'agent:agentonbekend'::text AS "grondboringbeno:opdrachtgever",
    'result:dieptebgm'::text || permkey AS "grondboringbeno:diepteboorgatmeting",
    'agent:agent'::text || logcomp AS "sosa:madeBySensor",
    'boorgat:boorgat'::text || permkey_boring AS "sosa:hasFeatureOfInterest"
   FROM s_bodemenondergrond.vw_boorgatmetingen vb;

ALTER TABLE s_bodemenondergrond.vw_boorgatmeting
    OWNER TO postgres;

