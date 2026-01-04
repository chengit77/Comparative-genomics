## Identification of genes under positive selection
We used a widely accepted approach [PAML codeml](https://github.com/abacus-gene/paml) to identify genes under positive selection, which consisted of the following two steps. All files used for **calculating dN/dS** in step 1 are located in `dNdS-codeml`. All files used for **likelihood ratio tests (LRTs)** in step 2 are located in `LRT`.

### 1. Detection of genes under positive selection
a. File format conversion

To convert fasta to codon, you need to modify the `DNA fasta directory`, `Protein fasta directory`, and `Output directories` in `fasta_to_codon.sh` and run
```bash
bash fasta_to_codon.sh
```
Because the FASTA files may differ among individuals, the script `fasta_to_codon.sh` can be modified as needed, including whether to invoke the three auxiliary scripts `FASTAtoPHYL.pl`, `one_line_fasta.pl`, `pal2nal.pl`. The key requirement is to ensure that the final output is a codon alignment format accepted by `PAML codeml`.

b. Calculate dn/ds ratios under branch model

To calculate the dN/dS ratios under the null model and branch model, you need to modify the path in `codeml_M0.sh`, `codeml_M0_ctl_file.sh`, `codeml_M0_branch.sh`, `codeml_M0_branch_ctl_file.sh`, ensure that `tree.treefile` is provided, and run the following command to generate ctl file for each gene:

```bash
bash codeml_M0_ctl_file.sh
bash codeml_M0_branch_ctl_file.sh
```

Then, run the following command to calculate dn/ds for each gene under null and branch model:

```bash
bash codeml_M0.sh
bash codeml_M0_branch.sh
```

c. Calculate dn/ds ratios under branch-site model

To calculate the dN/dS ratios under the null model and branch-site model, you need to modify the path in `codeml_M2anull_branchsite.sh`, `codeml_M2null_branchsite_ctl_file.sh`, `codeml_M2a_branchsite.sh`, `codeml_M2_branchsite_ctl_file.sh`, ensure that `tree.treefile` is provided, and run the following command to generate ctl file for each gene:

```bash
bash codeml_M2null_branchsite_ctl_file.sh
bash codeml_M2_branchsite_ctl_file.sh
```

Then, run the following command to calculate dn/ds for each gene under null and branch model:

```bash
bash codeml_M2anull_branchsite.sh
bash codeml_M2a_branchsite.sh
```

### 2. LRT
To perform the likelihood ratio test (LRT), you need to modify the paths `DIR` in `codeml_branch.sh`, `codeml_M2.sh` and run our custom Python pipeline `codeml_branch.py`, `codeml_M2.py` to extract parameters from the Step 1 output files, including `dN`, `dS`, `ω`, `np`, and `lnL`:

```bash
python codeml_branch_dNdS.py --directory $DIR --genes genelist.txt --outfile output.txt
python codeml_M2.py --directory $DIR --genes genelist.txt --outfile output_M2.txt
```

Finally, you may import the `output.txt` and `output_M2.txt` into R or Python to perform LRT calculations.

### Additional notes
If you are using **BUSCO single-copy orthologs** as genes, you will need to convert BUSCO IDS to gene names. Here, we provide a custom Python pipeline in `BUSCO-to-NCBI` to perform this conversion in batch:

Specifiy an input file (list of BUSCO groups to look up), target species, and the name for the output file.

```bash
python3 convert_BUSCO_to_NCBI.py --id_file busco.txt --species "Callithrix jacchus" --outfile gene_ids.txt
```

Note: the species name has to be in quotes. And it needs to be run in an enviroment with pandas.

If there are several issues with finding the information you want, for example: (1) gene ids are missing from OrthoDB v10.1 for some marmoset orthologs, (2) some marmoset gene ids have been updated in the NCBI Gene database to new numbers, (3) not all marmoset orthologs have an ENSEMBL id, and (4) some marmoset orthologs are not annotated at all.

To get around all of that, the script tries a few different ways of searching:
1. First, we try to use the marmoset gene id from OrthoDB to search NCBI Gene
2. If we can't use the marmoset gene id, we search NCBI using the human gene id from OrthoDB
Then we search NCBI for the marmoset ortholog of that gene
3. If we still can't find the marmoset ortholog, we return the human gene
