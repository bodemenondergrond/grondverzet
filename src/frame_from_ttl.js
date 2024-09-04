import path from "path";
import fs from "fs";
import {RoxiReasoner} from "roxi-js";
import { glob } from 'glob';
import N3 from 'n3';

import {
    prefixes,
    frame_grondboring,
    frame_observation,
    frame_actuation,
    frame_sampling,
    frame_bijlage,
    frame_boorgat,
    frame_association,
    frame_agent,
    frame_sample,
    frame_procedure,
    frame_list,
    frame_observableProperty,
    frame_geometry,
    rdf_to_jsonld,
    sortLines,
    frame_opmerking
} from './utils/variables.js';

const dir = path.join(process.cwd(), 'src/source/')
const rules = path.join(process.cwd(), 'n3/')
const reasoner = RoxiReasoner.new();
const ttl_files = await glob('*.ttl', {
    cwd: dir
})
ttl_files.forEach(file => {
    reasoner.add_abox(fs.readFileSync(path.join(dir, file), 'utf8').toString());
})
let nt = await reasoner.get_abox_dump()
//console.log(reasoner.get_abox_dump())
fs.writeFileSync('src/result/grondboring-ssn-sosa-prov.jsonld', JSON.stringify(await rdf_to_jsonld(nt, frame_grondboring), null, 4));
fs.writeFileSync('src/result/observation-ssn-sosa-prov.jsonld', JSON.stringify(await rdf_to_jsonld(nt, frame_observation), null, 4));
fs.writeFileSync('src/result/actuation-ssn-sosa-prov.jsonld', JSON.stringify(await rdf_to_jsonld(nt, frame_actuation), null, 4));
fs.writeFileSync('src/result/sampling-ssn-sosa-prov.jsonld', JSON.stringify(await rdf_to_jsonld(nt, frame_sampling), null, 4));
fs.writeFileSync('src/result/bijlage-ssn-sosa-prov.jsonld', JSON.stringify(await rdf_to_jsonld(nt, frame_bijlage), null, 4));
fs.writeFileSync('src/result/boorgat-ssn-sosa-prov.jsonld', JSON.stringify(await rdf_to_jsonld(nt, frame_boorgat), null, 4));
fs.writeFileSync('src/result/association-ssn-sosa-prov.jsonld', JSON.stringify(await rdf_to_jsonld(nt, frame_association), null, 4));
fs.writeFileSync('src/result/agent-ssn-sosa-prov.jsonld', JSON.stringify(await rdf_to_jsonld(nt, frame_agent), null, 4));
fs.writeFileSync('src/result/sample-ssn-sosa-prov.jsonld', JSON.stringify(await rdf_to_jsonld(nt, frame_sample), null, 4));
fs.writeFileSync('src/result/procedure-ssn-sosa-prov.jsonld', JSON.stringify(await rdf_to_jsonld(nt, frame_procedure), null, 4));
fs.writeFileSync('src/result/list-ssn-sosa-prov.jsonld', JSON.stringify(await rdf_to_jsonld(nt, frame_list), null, 4));
fs.writeFileSync('src/result/observable-property-ssn-sosa-prov.jsonld', JSON.stringify(await rdf_to_jsonld(nt, frame_observableProperty), null, 4));
fs.writeFileSync('src/result/geometry-ssn-sosa-prov.jsonld', JSON.stringify(await rdf_to_jsonld(nt, frame_geometry), null, 4));
fs.writeFileSync('src/result/opmerking-ssn-sosa-prov.jsonld', JSON.stringify(await rdf_to_jsonld(nt, frame_opmerking), null, 4));


const n3_files = await glob('*.n3', {
    cwd: rules
})
n3_files.forEach(file => {
    reasoner.add_rules(fs.readFileSync(path.join(rules, file), 'utf8').toString());
})
reasoner.materialize();
let nt_all = await sortLines(reasoner.get_abox_dump())
const ttl_writer = new N3.Writer({ format: 'text/turtle' , prefixes: Object.assign({},prefixes ) });
const parser = new N3.Parser();
parser.parse(
    nt_all,
    (error, quad) => {
        if (quad)
            ttl_writer.addQuad(quad);
        else
            ttl_writer.end((error, result) => fs.writeFileSync('result/inferred/grondboring-ssn-sosa-prov.ttl', result));
    });

