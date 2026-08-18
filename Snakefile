# Usage
# snakemake --profile profiles/slurm --use-conda
# OPTIONAL:
#   --rerun-trigger mtime: this uses modification time to determine whether to run rules

import os

configfile: "config/config.yaml"

IN_DIR = config["in_dir"]
OUT_DIR = config["out_dir"]

# Expected barcode folders: barcode01 ... barcode24
BARCODES = [f"barcode{idx:02d}" for idx in range(1, 25)]

wildcard_constraints:
    barcode = r"barcode\d+"

# Keep the same folder layout under the output directory while concatenating reads
# Example output: {out_dir}/barcode01/reads.fastq.gz
rule all:
    input:
        expand(os.path.join(OUT_DIR, "a0-concat-fastq", "{barcode}_concatenated.fastq.gz"), barcode=BARCODES),
        expand(os.path.join(OUT_DIR, "a1-nanostat-raw-reads", "{barcode}_raw_read_nanostat.txt"), barcode=BARCODES),
        expand(os.path.join(OUT_DIR, "b0-pychopper-trimmed", "{barcode}_pychopper_trimmed.fastq.gz"), barcode=BARCODES),
        expand(os.path.join(OUT_DIR, "c0i-transcriptome-alignments", "{barcode}_minimap2_transcriptome_aligned.bam"), barcode=BARCODES),
        expand(os.path.join(OUT_DIR, "d0i-oarfish-transcriptome-aligned", "{barcode}_oarfish_quant_transcriptome_aligned.quant"), barcode=BARCODES),

# Include the rule definitions from the separate Snakefile module.
include: "workflow/rules/cat_reads.smk"
include: "workflow/rules/nanostat_raw_reads.smk"
include: "workflow/rules/pychopper_trim.smk"
include: "workflow/rules/align_to_transcriptome.smk"
include: "workflow/rules/oarfish_quant_transcriptome_aligned.smk"

# Optional: a helper rule can be added here if you want to expose the final target
# in a more general way, but the main workflow entry point is the included rule file.
