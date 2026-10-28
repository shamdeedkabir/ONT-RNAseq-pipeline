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

FASTQ_EXTS = (".fastq", ".fastq.gz", ".fq", ".fq.gz")

def discover_run_barcode_pairs(in_dir, out_dir):
    """Collect (run, barcode) samples from two places, skipping anything missing:
      1. raw reads:          {in_dir}/hatch*/fastq_pass/barcode*/  (only if they still have FASTQs)
      2. concatenated reads: {out_dir}/hatch*/a0-concat-fastq/barcode*_concatenated.fastq.gz
    so the workflow still parses after raw FASTQs have been deleted."""
    pairs = set()

    if os.path.isdir(in_dir):
        for run in os.listdir(in_dir):
            fq_pass = os.path.join(in_dir, run, "fastq_pass")
            if not (run.startswith("hatch") and os.path.isdir(fq_pass)):
                continue
            for bc in os.listdir(fq_pass):
                bc_dir = os.path.join(fq_pass, bc)
                if (bc.startswith("barcode") and os.path.isdir(bc_dir)
                        and any(f.endswith(FASTQ_EXTS) for f in os.listdir(bc_dir))):
                    pairs.add((run, bc))

    if os.path.isdir(out_dir):
        for run in os.listdir(out_dir):
            cat_dir = os.path.join(out_dir, run, "a0-concat-fastq")
            if run.startswith("hatch") and os.path.isdir(cat_dir):
                for f in os.listdir(cat_dir):
                    if f.endswith("_concatenated.fastq.gz"):
                        pairs.add((run, f.split("_")[0]))

    return sorted(pairs)

RUN_BARCODE_PAIRS = discover_run_barcode_pairs(IN_DIR, OUT_DIR)
RUNS_LIST     = [p[0] for p in RUN_BARCODE_PAIRS]
BARCODES_LIST = [p[1] for p in RUN_BARCODE_PAIRS]


rule all:
    input:
        # Main BODY
        ### PRE-ALIGNMENT (REQUIRED)
        expand(os.path.join(OUT_DIR, "{run}", "a0-concat-fastq", "{barcode}_concatenated.fastq.gz"),
               zip, run=RUNS_LIST, barcode=BARCODES_LIST),
        expand(os.path.join(OUT_DIR, "{run}", "a1-nanostat-raw-reads", "{barcode}_raw_read_nanostat.txt"),
               zip, run=RUNS_LIST, barcode=BARCODES_LIST),
        expand(os.path.join(OUT_DIR, "{run}", "b0-pychopper-trimmed", "{barcode}_pychopper_trimmed.fastq.gz"),
               zip, run=RUNS_LIST, barcode=BARCODES_LIST),

        ### GENOME ALIGNMENT
        os.path.join(OUT_DIR, "resources", "genomic.bed"),
        os.path.join(OUT_DIR, "resources", "GCF_016699485.2_bGalGal1.mat.broiler.GRCg7b_genomic.mmi"),
        expand(os.path.join(OUT_DIR, "{run}", "c0ii-genome-alignments", "{barcode}_minimap2_genome_aligned_sorted.bam"),
               zip, run=RUNS_LIST, barcode=BARCODES_LIST),
        expand(os.path.join(OUT_DIR, "{run}", "c1ii-flagstat-genome-alignments", "{barcode}_flagstat_genome_alignment.txt"),
               zip, run=RUNS_LIST, barcode=BARCODES_LIST),
        
        os.path.join(config["out_dir"], "resources", "qc_filtered_samples.tsv"), 
        os.path.join(config["out_dir"], "resources", "qc_filtered_samples.yaml"),
        os.path.join(config["out_dir"], "resources", "isoquant_out"),
        
        sqanti_qc_ncbi_outs = [
            os.path.join(config["out_dir"], "resources" ,"sqanti3_out", "sqanti3_qc_on_ncbi", "sqanti_qc_on_ncbi_classification.txt"),
            os.path.join(config["out_dir"], "resources", "sqanti3_out", "sqanti3_qc_on_ncbi", "sqanti_qc_on_ncbi_corrected.cds.gff3"),
            os.path.join(config["out_dir"], "resources", "sqanti3_out", "sqanti3_qc_on_ncbi", "sqanti_qc_on_ncbi_corrected.faa"),
            os.path.join(config["out_dir"], "resources", "sqanti3_out", "sqanti3_qc_on_ncbi", "sqanti_qc_on_ncbi_corrected.fasta"),
            os.path.join(config["out_dir"], "resources", "sqanti3_out", "sqanti3_qc_on_ncbi", "sqanti_qc_on_ncbi_corrected.genePred"),
            os.path.join(config["out_dir"], "resources", "sqanti3_out", "sqanti3_qc_on_ncbi", "sqanti_qc_on_ncbi_corrected.gtf"),
            os.path.join(config["out_dir"], "resources", "sqanti3_out", "sqanti3_qc_on_ncbi", "sqanti_qc_on_ncbi_junctions.txt"),
            os.path.join(config["out_dir"], "resources", "sqanti3_out", "sqanti3_qc_on_ncbi", "sqanti_qc_on_ncbi_SQANTI3_report.html")
        ],
        sqanti_filter = [
            os.path.join(config["out_dir"], "resources", "sqanti3_out", "sqanti3_filter", "sqanti_qc_on_ncbi_classification_N_samples.txt"),
            os.path.join(config["out_dir"], "resources", "sqanti3_out", "sqanti3_filter", "sqanti_results", "sqanti_qc_filtered.filtered.gtf")
        ],
        sqanti_qc_gega_outs = [
            os.path.join(config["out_dir"], "resources", "sqanti3_out", "sqanti_qc_on_gega", "sqanti_qc_on_filtered_ncbi_against_gega_SQANTI3_report.html")
        ],

        gffread_extended_transcriptome = os.path.join(config["out_dir"], "resources", "sqanti3_out", "sqanti_extended_transcriptome.fa"),

        transcriptome_align = expand(os.path.join(OUT_DIR, "{run}", "c0i-transcriptome-alignments", "{barcode}_minimap2_transcriptome_aligned.bam"),
               zip, run=RUNS_LIST, barcode=BARCODES_LIST),
        flagstat_transcriptome_align = expand(os.path.join(OUT_DIR, "{run}", "c1i-flagstat-transcriptome-alignments", "{barcode}_flagstat_transcriptome_alignment.txt"),
               zip, run=RUNS_LIST, barcode=BARCODES_LIST),
        oarfish_quant = expand(os.path.join(OUT_DIR, "{run}", "d0i-oarfish-transcriptome-aligned", "{barcode}_oarfish_quant_transcriptome_aligned.quant"),
               zip, run=RUNS_LIST, barcode=BARCODES_LIST),

        oarfish_compilation = os.path.join(config["out_dir"], "resources", "oarfish_compiled_quant.tsv"),


### PRE-ALIGNMENT
include: "workflow/rules/cat_reads.smk"
include: "workflow/rules/nanostat_raw_reads.smk"
include: "workflow/rules/pychopper_trim.smk"

### GENOME ALIGNMENT
include: "workflow/rules/make_minimap2_junc_bed_file.smk"
include: "workflow/rules/make_minimap2_mmi_file.smk"
include: "workflow/rules/align_to_genome.smk"
include: "workflow/rules/flagstat_genome_alignment.smk"

### SAMPLE QC
include: "workflow/rules/compile_qc.smk"
include: "workflow/rules/qc_filter_samples.smk"

### ISOFORM DISCOVERY + SQANTI3
include: "workflow/rules/isoquant_joint_discovery.smk"
include: "workflow/rules/sqanti_qc_ncbi.smk"
include: "workflow/rules/sqanti_filter.smk"
include: "workflow/rules/sqanti_qc_filtered_ncbi_on_gega.smk"
include: "workflow/rules/gffread_build_extended_transcriptome.smk"

### TRANSCRIPTOME ALIGNMENT + QUANT
include: "workflow/rules/align_to_transcriptome.smk"
include: "workflow/rules/flagstat_transcriptome_alignment.smk"
include: "workflow/rules/oarfish_quant_transcriptome_aligned.smk"
include: "workflow/rules/compile_oarfish_quant.smk"
