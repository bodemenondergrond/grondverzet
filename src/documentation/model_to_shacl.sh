#!/bin/bash

  sparql --results=TTL --data=../result/inferred/grondboring-ssn-sosa-prov.ttl --query model_to_shacl.rq  > ../source/shacl/grondboring-ap-constraints.ttl
  #rdf2dot  /tmp/model.ttl | dot -Tpng > model_grondboring_inferred.png
  shacl v --shapes ../source/shacl/grondboring-ap-constraints.ttl  --data ../result/inferred/grondboring-ssn-sosa-prov.ttl > ../result/inferred/shacl_result.ttl
  shacl v --shapes ../source/shacl/grondboring-ap-constraints.ttl  --data ../source/20240906/bodemenondergrond.ttl > ../source/20240906/shacl_result.ttl
  #shacl v --shapes ../source/shacl/grondboring-ap-constraints.ttl  --data ../result/inferred/grondboring-ssn-sosa-prov.ttl > ../result/inferred/shacl_result.ttl
