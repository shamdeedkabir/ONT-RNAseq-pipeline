rule oarfish_quant_transcriptome_aligned:
    input:
        os.path.join(config["out_dir"], "{run}", "c0i-transcriptome-alignments", "{barcode}_minimap2_transcriptome_aligned.bam")
    output:
        os.path.join(config["out_dir"], "{run}", "d0i-oarfish-transcriptome-aligned", "{barcode}_oarfish_quant_transcriptome_aligned.quant")
    log:
        os.path.join(config["out_dir"], "logs", "{run}", "d0i-oarfish-transcriptome-aligned", "{barcode}.log")
    conda:
        "../envs/oarfish.yaml"
    shell:
        """
        (
            echo "++++++++++++++++++++++++++++ oarfish threads: {resources[oarfish_threads]}"

            echo "========== oarfish version:"
            oarfish --version

            oarfish \
                -j {resources[oarfish_threads]} \
                -a {input} \
                -o "{config[out_dir]}/{wildcards.run}/d0i-oarfish-transcriptome-aligned/{wildcards.barcode}_oarfish_quant_transcriptome_aligned" \
                --filter-group no-filters \
                --model-coverage

            echo "======= PROCESS COMPLETED (oarfish on transcriptome aligned): {wildcards.run}--{wildcards.barcode}"
        ) > {log} 2>&1
        """