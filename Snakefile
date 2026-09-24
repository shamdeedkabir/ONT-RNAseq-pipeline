# # Usage
# # snakemake --profile profiles/slurm --use-conda
# # OPTIONAL:
# #   --rerun-trigger mtime: this uses modification time to determine whether to run rules

# import os

# configfile: "config/config.yaml"

# IN_DIR = config["in_dir"]
# OUT_DIR= config["out_dir"]

# # wildcard_constraints:
# #     run     = r"[^/]+",
# #     barcode = r"barcode\d+"

# # def discover_run_barcode_pairs(in_dir):
# #     """Scan in_dir for run folders, and within each, barcode folders."""
# #     runs = sorted(
# #         d for d in os.listdir(in_dir)
# #         if os.path.isdir(os.path.join(in_dir, d))
# #     )

# #     pairs = []
# #     for run in runs:
# #         run_path = os.path.join(in_dir, run, "fastq_pass")
# #         barcodes = sorted(
# #             d for d in os.listdir(run_path)
# #             if os.path.isdir(os.path.join(run_path, d)) and d.startswith("barcode")
# #         )
# #         pairs.extend((run, bc) for bc in barcodes)
# #     return pairs

# # RUN_BARCODE_PAIRS = discover_run_barcode_pairs(IN_DIR)
# # RUNS_LIST     = [p[0] for p in RUN_BARCODE_PAIRS]
# # BARCODES_LIST = [p[1] for p in RUN_BARCODE_PAIRS]


# rule all:
#     input:
#         os.path.join(config["out_dir"], "resources", "qc_filtered_samples.tsv"), 
#         os.path.join(config["out_dir"], "resources", "qc_filtered_samples.yaml")


# # rule all:
#     # input:
#         ### PRE-ALIGNMENT (REQUIRED)
#         # expand(os.path.join(OUT_DIR, "{run}", "a0-concat-fastq", "{barcode}_concatenated.fastq.gz"),
#         #        zip, run=RUNS_LIST, barcode=BARCODES_LIST),
#         # expand(os.path.join(OUT_DIR, "{run}", "a1-nanostat-raw-reads", "{barcode}_raw_read_nanostat.txt"),
#         #        zip, run=RUNS_LIST, barcode=BARCODES_LIST),
#         # expand(os.path.join(OUT_DIR, "{run}", "b0-pychopper-trimmed", "{barcode}_pychopper_trimmed.fastq.gz"),
#         #        zip, run=RUNS_LIST, barcode=BARCODES_LIST),
       
#        ### TRANSCRIPTOME ALIGNMENT
#        #  expand(os.path.join(OUT_DIR, "{run}", "c0i-transcriptome-alignments", "{barcode}_minimap2_transcriptome_aligned.bam"),
#        #         zip, run=RUNS_LIST, barcode=BARCODES_LIST),
#        #  expand(os.path.join(OUT_DIR, "{run}", "c1i-flagstat-transcriptome-alignments", "{barcode}_flagstat_transcriptome_alignment.txt"),
#        #         zip, run=RUNS_LIST, barcode=BARCODES_LIST),
#        #  expand(os.path.join(OUT_DIR, "{run}", "d0i-oarfish-transcriptome-aligned", "{barcode}_oarfish_quant_transcriptome_aligned.quant"),
#        #         zip, run=RUNS_LIST, barcode=BARCODES_LIST),
        
#         ### GENOME ALIGNMENT
#         # os.path.join(OUT_DIR, "resources", "genomic.bed"),
#         # os.path.join(OUT_DIR, "resources", "genomic.bed"),
#         # os.path.join(OUT_DIR, "resources", "GCF_016699485.2_bGalGal1.mat.broiler.GRCg7b_genomic.mmi"),
#         # expand(os.path.join(OUT_DIR, "{run}", "c0ii-genome-alignments", "{barcode}_minimap2_genome_aligned_sorted.bam"),
#         #        zip, run=RUNS_LIST, barcode=BARCODES_LIST),
#         # expand(os.path.join(OUT_DIR, "{run}", "c1ii-flagstat-genome-alignments", "{barcode}_flagstat_genome_alignment.txt"),
#         #        zip, run=RUNS_LIST, barcode=BARCODES_LIST),
        
#         ### SAMPLE QC
#         # os.path.join(OUT_DIR, "resources", "nanostat_pychopper_flagstatGenomic_read_qc.tsv"),
#         # os.path.join(config["out_dir"], "resources", "qc_filtered_samples.tsv"), 
#         # os.path.join(config["out_dir"], "resources", "qc_filtered_samples.yaml")

#         ### ISOQUANT




# # include: "workflow/rules/cat_reads.smk"
# # include: "workflow/rules/nanostat_raw_reads.smk"
# # include: "workflow/rules/pychopper_trim.smk"

# # include: "workflow/rules/align_to_transcriptome.smk"
# # include: "workflow/rules/oarfish_quant_transcriptome_aligned.smk"
# # include: "workflow/rules/flagstat_transcriptome_alignment.smk"

# # include: "workflow/rules/make_minimap2_junc_bed_file.smk"
# # include: "workflow/rules/make_minimap2_mmi_file.smk"
# # include: "workflow/rules/align_to_genome.smk"
# # include: "workflow/rules/flagstat_genome_alignment.smk"

# # include: "workflow/rules/compile_qc.smk"
# include: "workflow/rules/qc_filter_samples.smk"

# include: "workflow/rules/isoquant_joint_discovery.smk"














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

def discover_run_barcode_pairs(out_dir):
    """Scan in_dir for run folders, and within each, barcode folders."""
    runs = sorted(
        d for d in os.listdir(out_dir)
        if os.path.isdir(os.path.join(out_dir, d)) and d.startswith("hatch")
    )

    pairs = []
    for run in runs:
        run_path = os.path.join(out_dir, run, "c0ii-genome-alignments")
        if os.path.exists(run_path):
            barcodes = sorted(
                f.split("_")[0]
                for f in os.listdir(run_path)
                if f.endswith(".bam") and os.path.isfile(os.path.join(run_path, f))
            )
            pairs.extend((run, bc) for bc in barcodes)
    return pairs

RUN_BARCODE_PAIRS = discover_run_barcode_pairs(OUT_DIR)
RUNS_LIST     = [p[0] for p in RUN_BARCODE_PAIRS]
BARCODES_LIST = [p[1] for p in RUN_BARCODE_PAIRS]


rule all:
    input:
        os.path.join(config["out_dir"], "resources", "qc_filtered_samples.tsv"), 
        os.path.join(config["out_dir"], "resources", "qc_filtered_samples.yaml"),
        directory(os.path.join(config["out_dir"], "resources", "isoquant_out")),
        
        
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


# rule all:
    # input:
        ### PRE-ALIGNMENT (REQUIRED)
        # expand(os.path.join(OUT_DIR, "{run}", "a0-concat-fastq", "{barcode}_concatenated.fastq.gz"),
        #        zip, run=RUNS_LIST, barcode=BARCODES_LIST),
        # expand(os.path.join(OUT_DIR, "{run}", "a1-nanostat-raw-reads", "{barcode}_raw_read_nanostat.txt"),
        #        zip, run=RUNS_LIST, barcode=BARCODES_LIST),
        # expand(os.path.join(OUT_DIR, "{run}", "b0-pychopper-trimmed", "{barcode}_pychopper_trimmed.fastq.gz"),
        #        zip, run=RUNS_LIST, barcode=BARCODES_LIST),
       
       ### TRANSCRIPTOME ALIGNMENT
       #  expand(os.path.join(OUT_DIR, "{run}", "c0i-transcriptome-alignments", "{barcode}_minimap2_transcriptome_aligned.bam"),
       #         zip, run=RUNS_LIST, barcode=BARCODES_LIST),
       #  expand(os.path.join(OUT_DIR, "{run}", "c1i-flagstat-transcriptome-alignments", "{barcode}_flagstat_transcriptome_alignment.txt"),
       #         zip, run=RUNS_LIST, barcode=BARCODES_LIST),
       #  expand(os.path.join(OUT_DIR, "{run}", "d0i-oarfish-transcriptome-aligned", "{barcode}_oarfish_quant_transcriptome_aligned.quant"),
       #         zip, run=RUNS_LIST, barcode=BARCODES_LIST),
        
        ### GENOME ALIGNMENT
        # os.path.join(OUT_DIR, "resources", "genomic.bed"),
        # os.path.join(OUT_DIR, "resources", "genomic.bed"),
        # os.path.join(OUT_DIR, "resources", "GCF_016699485.2_bGalGal1.mat.broiler.GRCg7b_genomic.mmi"),
        # expand(os.path.join(OUT_DIR, "{run}", "c0ii-genome-alignments", "{barcode}_minimap2_genome_aligned_sorted.bam"),
        #        zip, run=RUNS_LIST, barcode=BARCODES_LIST),
        # expand(os.path.join(OUT_DIR, "{run}", "c1ii-flagstat-genome-alignments", "{barcode}_flagstat_genome_alignment.txt"),
        #        zip, run=RUNS_LIST, barcode=BARCODES_LIST),
        
        ### SAMPLE QC
        # os.path.join(OUT_DIR, "resources", "nanostat_pychopper_flagstatGenomic_read_qc.tsv"),
        # os.path.join(config["out_dir"], "resources", "qc_filtered_samples.tsv"), 
        # os.path.join(config["out_dir"], "resources", "qc_filtered_samples.yaml")

        ### ISOQUANT
        



# include: "workflow/rules/cat_reads.smk"
# include: "workflow/rules/nanostat_raw_reads.smk"
# include: "workflow/rules/pychopper_trim.smk"

# include: "workflow/rules/align_to_transcriptome.smk"
# include: "workflow/rules/oarfish_quant_transcriptome_aligned.smk"
# include: "workflow/rules/flagstat_transcriptome_alignment.smk"

# include: "workflow/rules/make_minimap2_junc_bed_file.smk"
# include: "workflow/rules/make_minimap2_mmi_file.smk"
# include: "workflow/rules/align_to_genome.smk"
# include: "workflow/rules/flagstat_genome_alignment.smk"

# include: "workflow/rules/compile_qc.smk"
include: "workflow/rules/qc_filter_samples.smk"

include: "workflow/rules/isoquant_joint_discovery.smk"

include: "workflow/rules/sqanti_qc_ncbi.smk"
include: "workflow/rules/sqanti_filter.smk"
include: "workflow/rules/sqanti_qc_filtered_ncbi_on_gega.smk"