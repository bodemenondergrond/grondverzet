-- View: s_bodemenondergrond.vw_fictief_monster_voor_observatiebehandeling

-- DROP VIEW s_bodemenondergrond.vw_fictief_monster_voor_observatiebehandeling;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_fictief_monster_voor_observatiebehandeling
 AS
 SELECT DISTINCT ('result:sam'::text || lipm.permkey) || '-bis'::text AS "@id",
    'sosa:Sample'::text AS "@type",
    'result:sam'::text || lipm.permkey AS "prov:wasDerivedFrom",
    'boorgat:boorgat'::text || tm.parent_permkey AS "isSampleOf"
   FROM b_bodemenondergrond.tbl_observatie_behandeling tob
     JOIN b_bodemenondergrond.tbl_observatie to2 ON tob.observatie = to2.id
     JOIN b_bodemenondergrond.lnk_id_permkey lipm ON lipm.permkey = to2.parent_permkey AND to2.parent_type = lipm.type AND lipm.state = 'A'::text
     JOIN b_bodemenondergrond.tbl_monster tm ON tm.id = lipm.id;

ALTER TABLE s_bodemenondergrond.vw_fictief_monster_voor_observatiebehandeling
    OWNER TO postgres;

