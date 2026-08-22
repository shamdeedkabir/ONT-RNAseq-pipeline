rule flagstat_transcriptome_alignment:
    input:
        os.path.join(config["out_dir"], "{run}", "c0i-transcriptome-alignments", "{barcode}_minimap2_transcriptome_aligned.bam")
    output:
        os.path.join(config["out_dir"], "{run}", "c1i-flagstat-transcriptome-alignments", "{barcode}_flagstat_transcriptome_alignment.txt")
    log:
        os.path.join(config["out_dir"], "logs", "{run}", "c1i-flagstat-transcriptome-alignments", "{barcode}.log")
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