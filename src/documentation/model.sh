#!/bin/bash
  sparql --results=TTL --data=../result/grondboring-ssn-sosa-prov.jsonld --query model.rq  > /tmp/model.ttl
  rdf2dot  /tmp/model.ttl | dot -Tpng > model_grondboring.png

  sparql --results=TTL --data=../result/observation-ssn-sosa-prov.jsonld --query model.rq  > /tmp/model.ttl
  rdf2dot  /tmp/model.ttl | dot -Tpng > model_observation.png

  sparql --results=TTL --data=../result/actuation-ssn-sosa-prov.jsonld --query model.rq  > /tmp/model.ttl
  rdf2dot  /tmp/model.ttl | dot -Tpng > model_actuation.png

  sparql --results=TTL --data=../result/sampling-ssn-sosa-prov.jsonld --query model.rq  > /tmp/model.ttl
  rdf2dot  /tmp/model.ttl | dot -Tpng > model_sampling.png

  sparql --results=TTL --data=../result/bijlage-ssn-sosa-prov.jsonld --query model.rq  > /tmp/model.ttl
  rdf2dot  /tmp/model.ttl | dot -Tpng > model_bijlage.png

  sparql --results=TTL --data=../result/boorgat-ssn-sosa-prov.jsonld --query model.rq  > /tmp/model.ttl
  rdf2dot  /tmp/model.ttl | dot -Tpng > model_boorgat.png

  sparql --results=TTL --data=../source/20240729/boring1956-117549.ttl --query model.rq  > /tmp/model.ttl
  rdf2dot  /tmp/model.ttl | dot -Tpng > ../source/20240729/boring1956-117549.png

  sparql --results=TTL --data=../source/20240729/boring2005-011108.ttl --query model.rq  > /tmp/model.ttl
  rdf2dot  /tmp/model.ttl | dot -Tpng > ../source/20240729/boring2005-011108.png

  sparql --results=TTL --data=../result/inferred/grondboring-ssn-sosa-prov.ttl --query model.rq  > /tmp/model.ttl
  rdf2dot  /tmp/model.ttl | dot -Tpng > model_grondboring_inferred.png

<<<<<<< HEAD
  sparql --results=TTL --data=../source/sample.ttl --query model.rq  > ./model.ttl
  rdf2dot  ./model.ttl | dot -Tpng > sample.png
=======
  sparql --results=TTL --data=../source/sample.ttl --query model.rq  > /tmp/model.ttl
  rdf2dot  /tmp/model.ttl | dot -Tpng > sample.png

  sparql --results=TTL --data=../source/observation.ttl --query model.rq  > /tmp/model.ttl
  rdf2dot  /tmp/model.ttl | dot -Tpng > observation.png

  sparql --results=TTL --data=../source/observation2.ttl --query model.rq  > /tmp/model.ttl
  rdf2dot  /tmp/model.ttl | dot -Tpng > observation2.png
>>>>>>> 54da18c1f93037d288056cadde6e533f01dfa7b0
