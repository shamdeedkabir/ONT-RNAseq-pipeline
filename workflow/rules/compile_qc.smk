rule compile_qc:
    input:
        expand(os.path.join(OUT_DIR, "{run}", "c1ii-flagstat-genome-alignments", "{barcode}_flagstat_genome_alignment.txt"),
               zip, run=RUNS_LIST, barcode=BARCODES_LIST)
    output:
        os.path.join(config["out_dir"], "resources", "nanostat_pychopper_flagstatGenomic_read_qc.tsv")
    log:
        os.path.join(config["out_dir"], "logs", "resources", "compile_qc.smk")
    conda:
        "../envs/minimap2.yaml"
    params:
        output_location = os.path.join(config["out_dir"], "resources")
    shell:
        """
        (
            ./workflow/scripts/parse_qc_data.py \
                -i {config[out_dir]} \
                -o {params[output_location]}
        )
        """