-- s_bodemenondergrond.oslo_sampling_monsterbehandeling source

CREATE OR REPLACE VIEW s_bodemenondergrond.oslo_sampling_monsterbehandeling
AS SELECT (('sam:sam'::text || lip.permkey) || '-'::text) || row_number() OVER (PARTITION BY tmb1.monster ORDER BY tmb1.id) AS "@id",
    'sosa:Sampling'::text AS "@type",
    'ag:'::text || tu.organisatie_id AS "MadeBySampler",
        CASE
            WHEN tmb1.waarde_bool IS TRUE THEN 'cl-behwaarde:'::text || s_bodemenondergrond.clean(lb.beschrijving::character varying)::text
            ELSE 'cl-behwaarde:'::text || s_bodemenondergrond.clean(lbk.beschrijving::character varying)::text
        END AS "usedProcedure",
    'result:deltasam'::text || lip.permkey AS "hasResult",
    COALESCE(tmb1.datum::timestamp without time zone, tmb2.datum::timestamp without time zone, tm.datum_monstername) AS "resultTime",
    'result:sam'::text || lip.permkey AS "hasFeatureOfInterest"
   FROM b_bodemenondergrond.tbl_monster_behandeling tmb1
     LEFT JOIN b_bodemenondergrond.lut_behandeling_keuze lbk ON lbk.code = tmb1.waarde_keuze
     JOIN b_bodemenondergrond.lut_behandeling lb ON lb.code = tmb1.behandeling
     JOIN b_bodemenondergrond.tbl_monster tm ON tm.id = tmb1.monster
     JOIN b_bodemenondergrond.lnk_id_permkey lip ON lip.id = tm.id AND lip.type = 'MONSTER'::text
     LEFT JOIN b_bodemenondergrond.tbl_monster_behandeling tmb2 ON tmb1.monster = tmb2.monster AND tmb2.behandeling = 'M_MVD'::text
     LEFT JOIN b_bodemenondergrond.tbl_uitvoerder tu ON tu.uitvoerder_id = COALESCE(tmb1.waarde_uitvoerder, tmb2.waarde_uitvoerder, tm.monstername_door)
  WHERE tmb1.behandeling <> 'M_MVD'::text AND NOT s_bodemenondergrond.clean(lbk.beschrijving::character varying)::text ~ 'not implemented'::text AND NOT s_bodemenondergrond.clean(lb.beschrijving::character varying)::text ~ 'not implemented'::text;