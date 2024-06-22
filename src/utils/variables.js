'use strict';

import fs from "fs";
import jsonld from "jsonld";

const context = JSON.parse(fs.readFileSync('source/context.json', 'utf8'));
const frame_grondboring = {
    "@context": context,
    "@type": ["grondboringen:Grondboring"],
    "member": {
        "@type": "skos:Concept",
        "@embed": "@never",
        "@omitDefault": true
    },
}
const frame_observation = {
    "@context": context,
    "@type": ["sosa:Observation"],

}

const sortLines = str => Array.from(new Set(str.split(/\r?\n/))).sort().join('\n'); // To sort the dump of the reasoner for turtle pretty printing. Easier than using the Sink or Store.

async function rdf_to_jsonld(nt, frame) {
    let rdf = await sortLines(nt);
    console.log("rdf to jsonld");
    let my_json = await jsonld.fromRDF(rdf);
    console.log("Extract ... as a tree using a frame.");
    return await jsonld.frame(my_json, frame);
}



export {
    frame_grondboring,
    frame_observation,
    rdf_to_jsonld
};