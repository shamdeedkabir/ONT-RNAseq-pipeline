rule compile_oarfish_quant:
    input:
        expand(os.path.join(OUT_DIR, "{run}", "d0i-oarfish-transcriptome-aligned", "{barcode}_oarfish_quant_transcriptome_aligned.quant"),
               zip, run=RUNS_LIST, barcode=BARCODES_LIST)
    output:
        os.path.join(config["out_dir"], "resources", "oarfish_compiled_quant.tsv")
    log:
        os.path.join(config["out_dir"], "logs", "resources", "compile_oarfish_quant.log")
    conda:
        "../envs/pandas.yaml"
    shell:
        """
        (
            echo "compiling oarfish quantifications for all samples into one file ..."

            python ./workflow/scripts/parse_oarfish_quant.py \
                --base_dir {config[out_dir]} \
                -o {output}
        ) > {log} 2>&1
        """