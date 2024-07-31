#!\bin\bash
  sparql.bat --results=TTL --data=..\result\grondboring-ssn-sosa-prov.jsonld --query model.rq  > \tmp\model.ttl
  rdf2dot  \tmp\model.ttl | dot -Tpng > model_grondboring.png

  sparql.bat --results=TTL --data=..\result\observation-ssn-sosa-prov.jsonld --query model.rq  > \tmp\model.ttl
  rdf2dot  \tmp\model.ttl | dot -Tpng > model_observation.png

  sparql.bat --results=TTL --data=..\result\actuation-ssn-sosa-prov.jsonld --query model.rq  > \tmp\model.ttl
  rdf2dot  \tmp\model.ttl | dot -Tpng > model_actuation.png

  sparql.bat --results=TTL --data=..\result\sampling-ssn-sosa-prov.jsonld --query model.rq  > \tmp\model.ttl
  rdf2dot  \tmp\model.ttl | dot -Tpng > model_sampling.png

  sparql.bat --results=TTL --data=..\result\bijlage-ssn-sosa-prov.jsonld --query model.rq  > \tmp\model.ttl
  rdf2dot  \tmp\model.ttl | dot -Tpng > model_bijlage.png

  sparql.bat --results=TTL --data=..\result\boorgat-ssn-sosa-prov.jsonld --query model.rq  > \tmp\model.ttl
  rdf2dot  \tmp\model.ttl | dot -Tpng > model_boorgat.png

  sparql.bat --results=TTL --data=..\result\inferred\grondboring-ssn-sosa-prov.ttl --query model.rq  > \tmp\model.ttl
  rdf2dot  \tmp\model.ttl | dot -Tpng > model_grondboring_inferred.png

  sparql.bat --results=TTL --data=..\source\20240729\boring1956-117549.ttl --query model.rq  > \tmp\model.ttl
  rdf2dot  \tmp\model.ttl | dot -Tpng > ..\source\20240729\boring1956-117549.png

  sparql.bat --results=TTL --data=..\source\20240729\boring2005-011108.ttl --query model.rq  > \tmp\model.ttl
  rdf2dot  \tmp\model.ttl | dot -Tpng > ..\source\20240729\boring2005-011108.png
