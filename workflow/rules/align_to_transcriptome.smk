rule align_to_transcriptome:
    input:
        os.path.join(config["out_dir"], "{run}", "b0-pychopper-trimmed", "{barcode}_pychopper_trimmed.fastq.gz")
    output:
        os.path.join(config["out_dir"], "{run}", "c0i-transcriptome-alignments", "{barcode}_minimap2_transcriptome_aligned.bam")
    log:
        os.path.join(config["out_dir"], "logs", "{run}", "c0i-aligned-to-transcriptome", "{barcode}.log")
    conda:
        "../envs/minimap2.yaml"
    shell:
        """
        (
            echo "======== minimap2 version:"
            minimap2 --version
        
            echo "======== samtools version:"
            samtools --version

            echo "======== Total Threads: {resources[cpus_per_task]}"
            echo "======== Total Threads: {resources[minimap2_threads]}"
            echo "======== Total Threads: {resources[samtools_threads]}"

            minimap2 \
                -ax map-ont \
                -N 100 \
                --eqx \
                -t {resources[minimap2_threads]} \
                "{config[ref_dir]}/rna.fna" \
                {input} | \
            samtools \
                view \
                -@ {resources[samtools_threads]} \
                -b \
                -o {output}
        
        echo "======= PROCESS COMPLETED (minimap2 transcriptome alignment): {wildcards.run}--{wildcards.barcode}"
        ) > {log} 2>&1
        """