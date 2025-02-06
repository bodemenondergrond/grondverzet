-- View: s_bodemenondergrond.vw_geometrie

-- DROP VIEW s_bodemenondergrond.vw_geometrie;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_geometrie
 AS
 SELECT 'geometrie:boorgat'::text || lip.permkey AS "@id",
    'geosparql:Geometry'::text AS "@type",
    st_astext(st_transform(st_force2d(tp.locatie), 4326)) AS "asWKT"
   FROM b_bodemenondergrond.tbl_boring tb
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = tb.dov_boring_id AND lip.type = 'BORING'::text
     JOIN b_bodemenondergrond.tbl_puntlocatie tp ON tb.boringpositie = tp.id;

ALTER TABLE s_bodemenondergrond.vw_geometrie
    OWNER TO datawarehouse_ddl;

