# Usage
# snakemake --profile profiles/slurm --use-conda
# OPTIONAL:
#   --rerun-trigger mtime: this uses modification time to determine whether to run rules

import os

configfile: "config/config.yaml"

IN_DIR = config["in_dir"]
OUT_DIR= config["out_dir"]

wildcard_constraints:
    run     = r"[^/]+",
    barcode = r"barcode\d+"

def discover_run_barcode_pairs(in_dir):
    """Scan in_dir for run folders, and within each, barcode folders."""
    runs = sorted(
        d for d in os.listdir(in_dir)
        if os.path.isdir(os.path.join(in_dir, d))
    )

    pairs = []
    for run in runs:
        run_path = os.path.join(in_dir, run)
        barcodes = sorted(
            d for d in os.listdir(run_path)
            if os.path.isdir(os.path.join(run_path, d)) and d.startswith("barcode")
        )
        pairs.extend((run, bc) for bc in barcodes)
    return pairs

RUN_BARCODE_PAIRS = discover_run_barcode_pairs(IN_DIR)
RUNS_LIST     = [p[0] for p in RUN_BARCODE_PAIRS]
BARCODES_LIST = [p[1] for p in RUN_BARCODE_PAIRS]

rule all:
    input:
        expand(os.path.join(OUT_DIR, "{run}", "a0-concat-fastq", "{barcode}_concatenated.fastq.gz"),
               zip, run=RUNS_LIST, barcode=BARCODES_LIST),
        expand(os.path.join(OUT_DIR, "{run}", "a1-nanostat-raw-reads", "{barcode}_raw_read_nanostat.txt"),
               zip, run=RUNS_LIST, barcode=BARCODES_LIST),
        expand(os.path.join(OUT_DIR, "{run}", "b0-pychopper-trimmed", "{barcode}_pychopper_trimmed.fastq.gz"),
               zip, run=RUNS_LIST, barcode=BARCODES_LIST),
        expand(os.path.join(OUT_DIR, "{run}", "c0i-transcriptome-alignments", "{barcode}_minimap2_transcriptome_aligned.bam"),
               zip, run=RUNS_LIST, barcode=BARCODES_LIST),
        expand(os.path.join(OUT_DIR, "{run}", "d0i-oarfish-transcriptome-aligned", "{barcode}_oarfish_quant_transcriptome_aligned.quant"),
               zip, run=RUNS_LIST, barcode=BARCODES_LIST),
        os.path.join(OUT_DIR, "resources", "genomic.bed"),
        os.path.join(OUT_DIR, "resources", "genomic.bed"),
        os.path.join(OUT_DIR, "resources", "GCF_016699485.2_bGalGal1.mat.broiler.GRCg7b_genomic.mmi"),
        expand(os.path.join(OUT_DIR, "{run}", "c0ii-genome-alignments", "{barcode}_minimap2_genome_aligned_sorted.bam"),
               zip, run=RUNS_LIST, barcode=BARCODES_LIST),

include: "workflow/rules/cat_reads.smk"
include: "workflow/rules/nanostat_raw_reads.smk"
include: "workflow/rules/pychopper_trim.smk"
include: "workflow/rules/align_to_transcriptome.smk"
include: "workflow/rules/oarfish_quant_transcriptome_aligned.smk"
include: "workflow/rules/make_minimap2_junc_bed_file.smk"
include: "workflow/rules/make_minimap2_mmi_file.smk"
include: "workflow/rules/align_to_genome.smk"
