#! /usr/bin/python3

import json
import pandas as pd
import requests
from requests.adapters import HTTPAdapter, Retry

def db_lookup(session, url, key):
    response = session.get(url)
    response = json.loads(response.content)
    return response.get(key)

def OrthoDB_lookup(session, cmd, query):
    url = ("https://v10-1.orthodb.org/" + cmd +
            "?id=" + query)
    record = db_lookup(session, url, "data")
    return record

def NCBIGene_lookup(session, gene_id, orthologs=False):
    url = ("https://api.ncbi.nlm.nih.gov/datasets/v2/gene/id/" +
            gene_id)
    if orthologs:
        url = url + "/orthologs"
    record = db_lookup(session, url, "reports")
    return record

def get_gene_id(session, BUSCO_id, species):
    orthologs = OrthoDB_lookup(session, "orthologs", BUSCO_id)
    species_list = [orthologs[s].get("organism").get("name")
            for s,_ in enumerate(orthologs)]
    if species not in species_list:
        return None
    idx = species_list.index(species)
    ortholog_id = (orthologs[idx].get("genes")[0]
            .get("gene_id").get("param"))
    record = OrthoDB_lookup(session, "ogdetails", ortholog_id)
    gene_id = record.get("entrez")[0].get("id")
    return gene_id

def search_human_orthologs(session, BUSCO_id, species):
    gene_id = get_gene_id(session, BUSCO_id, "Homo sapiens")
    orthologs =  NCBIGene_lookup(session, gene_id, orthologs=True)
    species_list =  [orthologs[s].get("gene").get("taxname")
            for s,_ in enumerate(orthologs)]
    if species not in species_list:
        species = "Homo sapiens"
    idx = species_list.index(species)
    NCBI_record = orthologs[idx]
    return NCBI_record, species

def parse_NCBI_record(NCBI_record, value):
    value = NCBI_record.get(value)
    if isinstance(value, list):
        value = value[0]
    return value

def identify_BUSCO_gene(session, BUSCO_id, species):
    gene_id = get_gene_id(session, BUSCO_id, species)
    try:
        NCBI_record =  NCBIGene_lookup(session, gene_id)[0]
    except:
        NCBI_record = {'warning': 'no match'}
    if NCBI_record.get("warning") is not None:
        NCBI_record, species = search_human_orthologs(session,
                BUSCO_id, species)
    NCBI_record = NCBI_record.get("gene")
    gene_id = parse_NCBI_record(NCBI_record, "gene_id")
    gene_symbol = parse_NCBI_record(NCBI_record, "symbol")
    ensembl_id = parse_NCBI_record(NCBI_record,
            "ensembl_gene_ids")
    return [BUSCO_id, gene_id, gene_symbol, ensembl_id, species]

def main(id_file, species, outfile):
    with open(id_file, "r") as f:
        BUSCO_ids = [line.rstrip() for line in f]

    s = requests.Session()
    retries = Retry(total=5, backoff_factor=0.1, status_forcelist=[500])
    s.mount('https://', HTTPAdapter(max_retries=retries))

    output = []
    for b in BUSCO_ids:
        gene = identify_BUSCO_gene(s, b, species)
        output.append(gene)

    output = pd.DataFrame(output,
            columns = ["BUSCO", "GeneID", "GeneSymbol",
                "Ensembl_ID", "species"])
    output.to_csv(outfile, index=False)

if __name__ == "__main__":

    from argparse import ArgumentParser

    parser = ArgumentParser()
    parser.add_argument("-i", "--id_file", required=True)
    parser.add_argument("-s", "--species", required=True)
    parser.add_argument("-o", "--outfile", required=True)
    args = parser.parse_args()

    main(args.id_file, args.species, args.outfile)
