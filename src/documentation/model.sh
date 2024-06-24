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