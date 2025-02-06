-- s_bodemenondergrond.oslo_sampling_observatiebehandeling source

CREATE OR REPLACE VIEW s_bodemenondergrond.oslo_sampling_observatiebehandeling
AS WITH obs_ids AS (
         SELECT tob_1.id,
            row_number() OVER (PARTITION BY tob_1.observatie ORDER BY tob_1.id) AS rn
           FROM b_bodemenondergrond.tbl_observatie_behandeling tob_1
             JOIN b_bodemenondergrond.lut_behandeling lb_1 ON lb_1.code = tob_1.behandeling AND lb_1.parenttype = 'OBSERVATIE'::text
          WHERE lb_1.type <> 'B'::text OR tob_1.waarde_bool IS TRUE
        )
 SELECT (((('sam:sam'::text || to2.parent_permkey) || '-obs'::text) || lip.permkey) || '-'::text) || obs_ids.rn AS "@id",
    'sosa:Sampling'::text AS "@type",
    'ag:organisatie'::text || tu.organisatie_id AS "madeBySampler",
        CASE
            WHEN lb.type = 'B'::text THEN 'cl-behwaarde:'::text || s_bodemenondergrond.clean(lb.beschrijving::character varying)::text
            ELSE 'cl-behwaarde:'::text || s_bodemenondergrond.clean(lbk.beschrijving::character varying)::text
        END AS "usedProcedure",
    (('result:deltasam'::text || to2.parent_permkey) || '-obs'::text) || lip.permkey AS "hasResult",
    COALESCE(to2.fenomeentijd, to2.invoerdatum)::timestamp without time zone AS "resultTime",
    ('result:sam'::text || to2.parent_permkey) || '-bis'::text AS "hasFeatureOfInterest"
   FROM b_bodemenondergrond.tbl_observatie_behandeling tob
     JOIN b_bodemenondergrond.tbl_observatie to2 ON tob.observatie = to2.id
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = to2.id AND lip.type = 'OBSERVATIE'::text
     JOIN obs_ids ON obs_ids.id = tob.id
     LEFT JOIN b_bodemenondergrond.tbl_uitvoerder tu ON tu.uitvoerder_id = to2.uitvoerder
     JOIN b_bodemenondergrond.lut_behandeling lb ON lb.code = tob.behandeling AND lb.parenttype = 'OBSERVATIE'::text
     LEFT JOIN b_bodemenondergrond.lut_behandeling_keuze lbk ON lbk.code = tob.waarde_keuze
  WHERE NOT s_bodemenondergrond.clean(lb.beschrijving::character varying)::text ~ 'not implemented'::text AND NOT (s_bodemenondergrond.clean(lbk.beschrijving::character varying)::text ~ 'not implemented'::text AND lb.type <> 'B'::text);