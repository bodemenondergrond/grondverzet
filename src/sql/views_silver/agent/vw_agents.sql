-- View: s_bodemenondergrond.vw_agents

-- DROP VIEW s_bodemenondergrond.vw_agents;

CREATE OR REPLACE VIEW s_bodemenondergrond.vw_agents
 AS
 WITH agents AS (
         SELECT DISTINCT 'agent:organisatie'::text || to2.organisatie_id AS "@id",
            NULL::text AS "actedOnBehalfOf"
           FROM b_bodemenondergrond.tbl_opdrachtgever to2
        UNION
         SELECT DISTINCT 'agent:organisatie'::text || td.organisatie_id AS "@id",
            'agent:organisatie'::text || to2.organisatie_id AS "actedOnBehalfOf"
           FROM b_bodemenondergrond.tbl_dataleverancier td
             LEFT JOIN b_bodemenondergrond.tbl_boring tb ON tb.dataleverancier = td.dataleverancier_id
             LEFT JOIN b_bodemenondergrond.tbl_opdrachtgever to2 ON to2.opdrachtgever_id = tb.opdrachtgever
        UNION
         SELECT DISTINCT 'agent:organisatie'::text || to3.organisatie_id AS "@id",
            'agent:organisatie'::text || to2.organisatie_id AS "actedOnBehalfOf"
           FROM b_bodemenondergrond.tbl_opdrachtnemer to3
             LEFT JOIN b_bodemenondergrond.tbl_boring tb ON tb.dataleverancier = to3.opdrachtnemer_id
             LEFT JOIN b_bodemenondergrond.tbl_opdrachtgever to2 ON to2.opdrachtgever_id = tb.opdrachtgever
        UNION
         SELECT DISTINCT 'agent:actor'::text || ta.actor_id AS "@id",
            'agent:organisatie'::text || to2.organisatie_id AS "actedOnBehalfOf"
           FROM b_bodemenondergrond.tbl_actor ta
             LEFT JOIN b_bodemenondergrond.tbl_boring tb ON ta.actor_id = tb.boormeester
             LEFT JOIN b_bodemenondergrond.tbl_opdrachtgever to2 ON to2.opdrachtgever_id = tb.opdrachtgever
        )
 SELECT "@id",
    'prov:Agent'::text AS "@type",
    jsonb_agg("actedOnBehalfOf") AS "actedOnBehalfOf"
   FROM agents
  GROUP BY "@id";

ALTER TABLE s_bodemenondergrond.vw_agents
    OWNER TO datawarehouse_ddl;

