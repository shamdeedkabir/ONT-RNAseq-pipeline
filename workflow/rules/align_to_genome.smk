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
        os.path.join(config["out_dir"], "{run}", "b0-pychopper-trimmed", "{barcode}_pychopper_trimmed.fastq.gz")
    output:
        os.path.join(config["out_dir"], "{run}", "c0ii-genome-alignments", "{barcode}_minimap2_genome_aligned.fastq.gz")
    log:
        os.path.join(config["out_dir"], "logs", "{run}", "c0ii-genome-alignments", "{barcode}.log")
    params:
        mmi_file = os.path.join(config["out_dir"], "resources", "GCF_016699485.2_bGalGal1.mat.broiler.GRCg7b_genomic.mmi")
        bed_file = os.path.join(config["out_dir"], "resources", "genomic.bed")

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
                {params[mmi_file]} \    # indexed .mmi file of the refseq .fna file (saves a few minutes for minimap2)
                {input} \
                -a -x splice \
                -uf \
                --secondary=yes \
                -Y \
                --MD \
                -t {resources[minimap2_threads]} \
                --junc-bed {params[bed_file]}     

        echo "======= PROCESS COMPLETED (minimap2 genome alignment): {wildcards.run}--{wildcards.barcode}"
        )
        """