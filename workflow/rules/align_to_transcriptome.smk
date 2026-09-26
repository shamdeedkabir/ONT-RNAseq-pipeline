rule align_to_transcriptome:
    input:
        os.path.join(config["out_dir"], "{run}", "b0-pychopper-trimmed", "{barcode}_pychopper_trimmed.fastq.gz")
    output:
        os.path.join(config["out_dir"], "{run}", "c0i-transcriptome-alignments", "{barcode}_minimap2_transcriptome_aligned.bam")
    log:
        os.path.join(config["out_dir"], "logs", "{run}", "c0i-aligned-to-transcriptome", "{barcode}.log")
    params:
        gffread_extended_transcriptome = os.path.join(config["out_dir"], "resources", "sqanti3_out", "sqanti_extended_transcriptome.fa"),
    conda:
        "../envs/minimap2.yaml"
    shell:
        """
        (
            echo "++++++++++++++++++++++++++++ total threads: {resources[cpus_per_task]}"
            echo "++++++++++++++++++++++++++++ minimap2 threads: {resources[minimap2_threads]}"
            echo "++++++++++++++++++++++++++++ samtools threads: {resources[samtools_threads]}"

            echo "======== minimap2 version:"
            minimap2 --version
        
            echo "======== samtools version:"
            samtools --version

            minimap2 \
                -ax map-ont \
                -N 100 \
                --eqx \
                -t {resources[minimap2_threads]} \
                {params[gffread_extended_transcriptome]} \
                {input} | \
            samtools \
                view \
                -@ {resources[samtools_threads]} \
                -b \
                -o {output}
        
        echo "======= PROCESS COMPLETED (minimap2 transcriptome alignment): {wildcards.run}--{wildcards.barcode}"
        ) > {log} 2>&1
        """