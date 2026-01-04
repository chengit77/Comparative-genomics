## Howler-specific structural variant discovery and annotation
The identification of howler-specific structural variants (SVs) was carried out in the following three steps. All files for step 1 are stored in the `smartiesv-pairwise` directory. All files for step 2 are stored in the `howler-sv-detecting-annotation` directory. All files for step 3 are stored in the `sv-alignment` directory.
### 1. Genome-wide pairwise comparisons using smartie-sv
Currently, there are multiple approaches for structural variant (SV) detection, such as presence–absence variation (PAV)–based methods and read-based callers like Sniffles. Because our data consist of **contig-level** genome assemblies, we adopted a traditional read-mapping–based approach, *smartie-sv*, for SV detection.

To run smartie-sv on the example data:
1. Edit the `run_martie_sv_example.sh` to specify where the `smartie-sv` folder is.
2. Run `run_smartie_sv_example.sh` by typing `bash run_smartie_sv_example.sh`. This script controls a pipeline of jobs and submit them to SLURM correctly. It is important that you **DO NOT SUBMIT THIS SCRIPT TO SLURM - it will fail if you do!!**

Insread of a `slurm` file, the log information will be stored in the file `./smartie-sv/pipeline/log`.

To check if the pipeline is done running you can either:
1. Look for the words "Complete log" in the last line of the log file: `smartie-sv/pipeline/log`.
2. Type `ps -aef | grep YOUR CLUSTER ID | grep smartie | wc -l`: "2" means it's still runing and "1" means it's done.

### 2. Identification of howler-specific SVs and their annotation
This section including removing duplicate SVs from the `smartie-sv output` in the step 1, identifying SVs shared across all howler species, and annotating these SVs bashed on human gene coordinates.

To run those scripts, you will need to change the paths specified in the two main scripts: `01_call_shared_variants.sh` and `02_overlap_with_human_genes.sh`. These scripts call other scripts from the subdirectories `./scripts/identify_variants`, but you should NOT need to change those subscripts.

### 3. Multi-species sequence alignment and visualization of SV-associated genes
**Loss of SV signal and false positive calls** are challenges faced by researchers worldwide in this field. Here, we used the alignment algorithm [PRANK](http://wasabiapp.org/software/prank/) to perform multi-species sequence alignment of SV-associated genes.
To minimize false positives and signal loss during alignment, we first aligned the sequences of six howler monkey species, then aligned the sequences of six other primate species, and finally merged the two groups of sequences for a combined alignment.
Visualization are performed using [Jalview](https://www.jalview.org/).

Here are the instructions for the scripts:
- `align_and_visualize_SV.py` is a python script that does both alignment and visualization.
- `config.yaml` specifies where the input files are, how big the window is around the gene, and gives shorter names to the samples.
- `jalview_settings.txt` is used by `jalview` to control the colors and figure dimensions.

This command will loop over all the genes in the list:
```bash
python align_and_visualize_SV.py
```
This command will run the script on one gene:
```bash
python align_and_visualization_SV.py --gene BRCA1
```
