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
    "qualifiedAssociation":{
        "@embed": "@never",
        "@omitDefault": true
    },
    "wasStartedBy":{
        "@embed": "@never",
        "@omitDefault": true
    },
    "boorder":{
        "@embed": "@never",
        "@omitDefault": true
    },
    "boormeester":{
        "@embed": "@never",
        "@omitDefault": true
    },

}
const frame_observation = {
    "@context": context,
    "@type": ["sosa:Observation"],

}
const frame_actuation = {
    "@context": context,
    "@type": ["sosa:Actuation"],
    "hasFeatureOfInterest": {
        "@embed": "@always",
        "@omitDefault": true,
        "hasProperty": {
            "@embed": "@always",
            "@omitDefault": true,
            "isActedOnBy": {
                "@embed": "@never",
                "@omitDefault": true
            }
        },
        "hasSample": {
            "@embed": "@never",
            "@omitDefault": true
        },
    },
    "actsOnProperty": {
        "@embed": "@always",
        "@omitDefault": true,
        "isActedOnBy": {
            "@embed": "@never",
            "@omitDefault": true
        },
        "isPropertyOf": {
            "@embed": "@always",
            "@omitDefault": true,
            "hasSample": {
                "@embed": "@never",
                "@omitDefault": true
            }
        }
    },

}

const frame_boorgat = {
    "@context": context,
    "@type": ["grondboringbeno:Boorgat"],
    "hasProperty": {
        "@embed": "@always",
        "@omitDefault": true,
        "isActedOnBy": {
            "@embed": "@always",
            "@omitDefault": true,
        },

    },
    "hasSample": {
        "@embed": "@always",
        "@omitDefault": true
    },

}

const frame_bijlage = {
    "@context": context,
    "@type": ["grondboringbeno:Bijlage"],

    "about": {
        "@embed": "@always",
        "@omitDefault": true,
        "actuations": {
            "@embed": "@never",
            "@omitDefault": true
        },
        "samplings":{
            "@embed": "@never",
            "@omitDefault": true
        },
        "qualifiedAssociation":{
            "@embed": "@never",
            "@omitDefault": true
        }

    }
}

const frame_sampling = {
    "@context": context,
    "@type": ["sosa:Sampling"],
    "hasFeatureOfInterest": {
        "@embed": "@always",
        "@omitDefault": true,
        "hasProperty": {
            "@embed": "@always",
            "@omitDefault": true,
            "isActedOnBy": {
                "@embed": "@never",
                "@omitDefault": true
            }
        },
        "hasSample": {
            "@embed": "@never",
            "@omitDefault": true
        },
    }

}

const sortLines = str => Array.from(new Set(str.split(/\r?\n/))).sort().join('\n'); // To sort the dump of the reasoner for turtle pretty printing. Easier than using the Sink or Store.

async function rdf_to_jsonld(nt, frame) {
    let rdf = await sortLines(nt);
    console.log("rdf to jsonld");
    let my_json = await jsonld.fromRDF(rdf);
    console.log("Extract ... as a tree using a frame.");
    return await jsonld.frame(my_json, frame);
}

const prefixes = { "act": "https://data.bodemenondergrond.vlaanderen.be/id/actuation/",
    "adms": "http://www.w3.org/ns/adms#",
    "ag": "https://data.bodemenondergrond.vlaanderen.be/id/agent/",
    "ass": "https://data.bodemenondergrond.vlaanderen.be/id/association/",
    "bemprocedure": "https://data.bodemenondergrond.vlaanderen.be/id/bemonsteringsprocedure/",
    "boe": "https://data.vlaanderen.be/ns/bodem-en-ondergrond#",
    "bl": "https://data.bodemenondergrond.vlaanderen.be/id/bijlage/",
    "boorgat": "https://data.bodemenondergrond.vlaanderen.be/id/boorgat/",
    "boor": "https://data.bodemenondergrond.vlaanderen.be/id/boor/",
    "boormethodeinterval": "https://data.bodemenondergrond.vlaanderen.be/id/boormethodeinterval/",
    "boring": "https://data.bodemenondergrond.vlaanderen.be/id/boring/",
    "cl-bpt": "https://data.bodemenondergrond.vlaanderen.be/id/concept/bemonsteringsproceduretype/",
    "cl-brm": "https://data.bodemenondergrond.vlaanderen.be/id/concept/boormethode/",
    "cl-dlb": "https://data.bodemenondergrond.vlaanderen.be/id/concept/doelboring/",
    "cl-got": "https://data.bodemenondergrond.vlaanderen.be/id/concept/grondobjecttype/",
    "cl-idt": "https://data.bodemenondergrond.vlaanderen.be/id/concept/identificatortype/",
    "dcterms": "http://purl.org/dc/terms/",
    "geometrie": "https://data.bodemenondergrond.vlaanderen.be/id/geometrie/",
    "geosparql": "http://www.opengis.net/ont/geosparql#",
    "gmldov": "https://data.bodemenondergrond.vlaanderen.be/id/gml/",
    "gml": "http://www.opengis.net/ont/gml#",
    "grondboringbeno": "https://data.bodemenondergrond.vlaanderen.be/ns/grondboringen#",
    "grondboringen": "https://data.vlaanderen.be/ns/grondboringen#",
    "grondobject": "https://data.bodemenondergrond.vlaanderen.be/id/grondobject/",
    "hel": "https://data.bodemenondergrond.vlaanderen.be/id/helling/",
    "id": "https://data.bodemenondergrond.vlaanderen.be/id/identificator/",
    "incl": "https://data.bodemenondergrond.vlaanderen.be/id/inclinatie/",
    "list": "https://data.bodemenondergrond.vlaanderen.be/id/list/",
    "moment": "https://data.bodemenondergrond.vlaanderen.be/id/moment/",
    "obs": "https://data.bodemenondergrond.vlaanderen.be/id/observation/",
    "obs_prop": "https://data.bodemenondergrond.vlaanderen.be/id/property/",
    "opdracht": "https://data.bodemenondergrond.vlaanderen.be/id/opdracht/",
    "opm": "https://data.bodemenondergrond.vlaanderen.be/id/opmerking/",
    "prop": "https://data.bodemenondergrond.vlaanderen.be/id/concept/property/",
    "prov": "http://www.w3.org/ns/prov#",
    "qudt-schema": "https://qudt.org/schema/qudt/",
    "qudt-unit": "https://qudt.org/vocab/unit/",
    "rdf": "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
    "rdfs": "http://www.w3.org/2000/01/rdf-schema#",
    "result": "https://data.bodemenondergrond.vlaanderen.be/id/result/",
    "richting": "https://data.bodemenondergrond.vlaanderen.be/id/richting/",
    "rol": "https://data.bodemenondergrond.vlaanderen.be/id/concept/rol/",
    "sam": "https://data.bodemenondergrond.vlaanderen.be/id/sampling/",
    "schema": "https://schema.org/",
    "sdmx-attribute": "http://purl.org/linked-data/sdmx/2009/attribute#",
    "seb": "https://data.vlaanderen.be/ns/sensoren-en-bemonstering#",
    "skos": "http://www.w3.org/2004/02/skos/core#",
    "sosa": "http://www.w3.org/ns/sosa/",
    "sosa-om": "http://www.w3.org/ns/sosa/om#",
    "ssn": "http://www.w3.org/ns/ssn/",
    "time": "http://www.w3.org/2006/time#",
    "wettelijkkader": "https://data.bodemenondergrond.vlaanderen.be/id/wettelijkkader/",
    "xsd": "http://www.w3.org/2001/XMLSchema#"
}

export {
    prefixes,
    frame_grondboring,
    frame_observation,
    frame_actuation,
    frame_sampling,
    frame_bijlage,
    frame_boorgat,
    rdf_to_jsonld,
    sortLines
};