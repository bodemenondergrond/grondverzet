CREATE OR REPLACE VIEW s_bodemenondergrond.oslo_grondboring
AS WITH opdr AS (
         SELECT perm.permkey,
            linkopd.dov_boring_id
           FROM b_bodemenondergrond.lnk_id_permkey perm
             JOIN b_bodemenondergrond.lnk_boring_opdracht linkopd ON linkopd.opdracht_id = perm.id AND perm.type = 'OPDRACHT'::text
        )
 SELECT 'boring:'::text || lip.permkey AS "@id",
    'grondboringbeno:Grondboring'::text AS "@type",
    'id:boring'::text || lip.permkey AS identifier,
    ARRAY[(('ass:'::text || to2.organisatie_id) || '-'::text) || lip.permkey, (('ass:'::text || td.organisatie_id) || '-'::text) || lip.permkey, (('ass:'::text || tu.organisatie_id) || '-'::text) || lip.permkey, (('ass:a'::text || ta.actor_id) || '-'::text) || lip.permkey] AS "qualifiedAssociation",
    tb.datum_aanvang AS "resultTime",
    ('list:boorgat'::text || lip.permkey) || '-act1'::text AS actuations,
    array_agg('opdracht:'::text || opdr.permkey) AS "wasStartedBy",
    'ag:'::text || to2.organisatie_id AS opdrachtgever,
    ('list:boorgat'::text || lip.permkey) || '-sam1'::text AS samplings,
    'agent:organisatie'::text || td.organisatie_id AS dataleverancier,
    'agent:organisatie'::text || tu.organisatie_id AS boorder,
    'agent:organisatie'::text || ta.actor_id AS boormeester
   FROM b_bodemenondergrond.tbl_boring tb
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = tb.dov_boring_id AND lip.type = 'BORING'::text
     LEFT JOIN opdr ON tb.dov_boring_id = opdr.dov_boring_id
     LEFT JOIN b_bodemenondergrond.tbl_opdrachtgever to2 ON to2.opdrachtgever_id = tb.opdrachtgever
     LEFT JOIN b_bodemenondergrond.tbl_dataleverancier td ON td.dataleverancier_id = tb.dataleverancier
     LEFT JOIN b_bodemenondergrond.tbl_uitvoerder tu ON tu.uitvoerder_id = tb.uitvoerder
     LEFT JOIN b_bodemenondergrond.tbl_actor ta ON ta.actor_id = tb.boormeester
  GROUP BY lip.permkey, tb.datum_aanvang, to2.organisatie_id, td.organisatie_id, tu.organisatie_id, ta.actor_id;