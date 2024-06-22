import path from "path";
import fs from "fs";
import {RoxiReasoner} from "roxi-js";
import { glob } from 'glob';

import {
    frame_grondboring,
    frame_observation,
    rdf_to_jsonld
} from './utils/variables.js';

const dir = path.join(process.cwd(), 'source/')
const reasoner = RoxiReasoner.new();
const ttl_files = await glob('*.ttl', {
    cwd: dir
})
ttl_files.forEach(file => {
    reasoner.add_abox(fs.readFileSync(path.join(dir, file), 'utf8').toString());
})
//console.log(reasoner.get_abox_dump())
fs.writeFileSync('result/grondboring-ssn-sosa-prov.jsonld', JSON.stringify(await rdf_to_jsonld(reasoner.get_abox_dump(), frame_grondboring), null, 4));
fs.writeFileSync('result/observation-ssn-sosa-prov.jsonld', JSON.stringify(await rdf_to_jsonld(reasoner.get_abox_dump(), frame_observation), null, 4));
