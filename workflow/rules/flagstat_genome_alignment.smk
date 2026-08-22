rule flagstat_genome_alignment:
    input:
        os.path.join(config["out_dir"], "{run}", "c0ii-genome-alignments", "{barcode}_minimap2_genome_aligned_sorted.bam")
    output:
        os.path.join(config["out_dir"], "{run}", "c1ii-flagstat-genome-alignments", "{barcode}_flagstat_genome_alignment.txt")
    log:
        os.path.join(config["out_dir"], "logs", "{run}", "c1ii-flagstat-genome-alignments", "{barcode}.log")
    conda:
        "../envs/minimap2.yaml" # this environment has samtools installed
    shell:
        """
        (
            echo "++++++++++++++++++++++++++++ samtools threads: {resources[samtools_threads]}"

            samtools \
                flagstat \
                -@ {resources[samtools_threads]} \
                {input} \
                > {output}
        ) > {log} 2>&1
        """