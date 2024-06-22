#!/bin/bash
  sparql --results=TTL --data=../source/grondboring-ssn-sosa-prov.ttl --query model.rq  > model.ttl
  rdf2dot  model.ttl | dot -Tpng > model.png
  rdf2dot  model.ttl  > model.dot
#/home/gehau/Downloads/grondboringen/20240612/grondboring-ssn-sosa-prov.ttl