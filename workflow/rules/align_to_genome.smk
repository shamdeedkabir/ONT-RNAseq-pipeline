# arguments obtained from IsoQuant to meet IsoQuants default alignment preference: 
#    https://github.com/ablab/IsoQuant/blob/master/isoquant_lib/utils/read_mapper.py

# ====== description of minimap2 arguments used here =======
# {params[mmi_file]}:    # indexed .mmi file of the refseq .fna file (saves a few minutes for minimap2)
# -uf                    # pychopper reoriented the reads to single strand
# --secondary=yes        # isoquant's arg although deprecated/legacy in minimap2
# -Y                     # soft clipping enabled as done by isoquant
# --MD \                 # output MD tag as done by isoquant


rule align_to_genome:
    input:
        input_fastq = os.path.join(config["out_dir"], "{run}", "b0-pychopper-trimmed", "{barcode}_pychopper_trimmed.fastq.gz"),
        mmi_file = os.path.join(config["out_dir"], "resources", "GCF_016699485.2_bGalGal1.mat.broiler.GRCg7b_genomic.mmi"),
        bed_file = os.path.join(config["out_dir"], "resources", "genomic.bed")
    output:
        os.path.join(config["out_dir"], "{run}", "c0ii-genome-alignments", "{barcode}_minimap2_genome_aligned_sorted.bam")
    log:
        os.path.join(config["out_dir"], "logs", "{run}", "c0ii-genome-alignments", "{barcode}.log")

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
                {input[mmi_file]} \
                {input[input_fastq]} \
                -a -x splice \
                -uf \
                --secondary=yes \
                -Y \
                --MD \
                -t {resources[minimap2_threads]} \
                --junc-bed {input[bed_file]} | \
            samtools \
                sort \
                -@ {resources[samtools_threads]} \
                -m 4G \
                -o {output}

            echo "======= alignment complete - indexing sorted bam file"

            samtools \
                index \
                -@ {resources[cpus_per_task]} \
                {output}
            
            echo "======= PROCESS COMPLETED (minimap2 genome alignment): {wildcards.run}--{wildcards.barcode}"
        ) > {log} 2>&1
        """