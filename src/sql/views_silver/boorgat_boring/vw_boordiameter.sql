-- View: s_bodemenondergrond.vw_boordiameter

-- DROP VIEW s_bodemenondergrond.vw_boordiameter;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_boordiameter
 AS
 WITH diameterintervallen AS (
         SELECT tbd.dov_boring_id,
            tbd.van,
            tbd.tot,
            tbd.boordiameter,
            lip.permkey,
            row_number() OVER (PARTITION BY tbd.dov_boring_id ORDER BY tbd.van) AS nr
           FROM b_bodemenondergrond.tbl_boor_detail tbd
             JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = tbd.dov_boring_id AND lip.type = 'BORING'::text AND lip.state = 'A'::text
          WHERE tbd.boordiameter IS NOT NULL
        )
 SELECT dov_boring_id,
    json_build_object('@type', 'Boorgatdiameter', '@id', ('bnboorgat:boorgat'::text || permkey) || '-boordiameter'::text, 'Boorgatdiameter.diameter', array_agg(s_bodemenondergrond.fn_boorgatdiameterinterval(permkey, nr::numeric, van, tot, boordiameter::numeric))) AS "Boorgat.boordiameter"
   FROM diameterintervallen
  GROUP BY dov_boring_id, permkey;

ALTER TABLE s_bodemenondergrond.vw_boordiameter
    OWNER TO datawarehouse_ddl;

