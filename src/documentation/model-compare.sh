#!/bin/bash


  sparql --results=TTL --data=../result/inferred/grondboring-ssn-sosa-prov.ttl --query model.rq  > /tmp/model1.ttl
  rdf2dot  /tmp/model1.ttl | dot -Tpng > ../result/inferred/grondboring-ssn-sosa-prov.png

  sparql --results=TTL --data=../result/inferred/grondboring-ssn-sosa-prov-2.ttl --query model.rq  > /tmp/model2.ttl
  rdf2dot  /tmp/model2.ttl | dot -Tpng > ../result/inferred/grondboring-ssn-sosa-prov-2.png

  rdfdiff /tmp/model1.ttl /tmp/model2.ttl TURTLE TURTLE > ../result/inferred/grondboring-ssn-sosa-prov.diff