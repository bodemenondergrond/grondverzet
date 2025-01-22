-- View: s_bodemenondergrond.vw_identificators

-- DROP VIEW s_bodemenondergrond.vw_identificators;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_identificators
 AS
 WITH identificators AS (
         SELECT tb.dov_boring_id,
            lip.permkey,
            tb.uniek_dov_id AS ident,
            'cl-idt:boornummer'::text AS ident_type
           FROM b_bodemenondergrond.tbl_boring tb
             JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = tb.dov_boring_id AND lip.type = 'BORING'::text AND lip.state = 'A'::text
        UNION
         SELECT tab.dov_boring_id,
            lip.permkey,
            tab.naam AS ident,
            'cl-idt:KBIN-'::text || labt.naam AS ident_type
           FROM b_bodemenondergrond.tbl_alternatieve_benaming tab
             JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = tab.dov_boring_id AND lip.type = 'BORING'::text AND lip.state = 'A'::text
             JOIN b_bodemenondergrond.lut_alternatieve_benaming_type labt ON labt.alternatieve_benaming_type_id = tab.type
        ), numbered_identificators AS (
         SELECT identificators.dov_boring_id,
            identificators.permkey,
            identificators.ident,
            identificators.ident_type,
            row_number() OVER (PARTITION BY identificators.dov_boring_id) AS nr
           FROM identificators
        )
 SELECT dov_boring_id,
    array_agg(s_bodemenondergrond.fn_identificator(permkey, ident, ident_type, nr::numeric)) AS identificators
   FROM numbered_identificators
  GROUP BY dov_boring_id;

ALTER TABLE s_bodemenondergrond.vw_identificators
    OWNER TO datawarehouse_ddl;

