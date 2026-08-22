import glob
import os

rule cat_reads:
    # input:
    #     lambda wildcards: sorted(
    #         p
    #         for p in glob.glob(os.path.join(config["in_dir"], wildcards.run, "fastq_pass", wildcards.barcode, "*"))
    #         if p.endswith(".fastq") or p.endswith(".fastq.gz") or p.endswith(".fq") or p.endswith(".fq.gz")
    #     )
    input:
        lambda wildcards: sorted(
            p
            for p in glob.glob(os.path.join(config["in_dir"], wildcards.run, "fastq_pass", wildcards.barcode, "*"))
            if p.endswith((".fastq", ".fastq.gz", ".fq", ".fq.gz"))
            and os.path.exists(os.path.realpath(p))   # <- filters dangling symlinks
        )
    output:
        os.path.join(config["out_dir"], "{run}", "a0-concat-fastq", "{barcode}_concatenated.fastq.gz")
    log:
        os.path.join(config["out_dir"], "logs", "{run}", "a0-concat-fastq", "{barcode}.log")
    conda:
        "../envs/fastcat.yaml"
    shell:
        """
        echo "++++++++++++++++++++++++++++ Fastcat Threads: {resources[cpus_per_task]}" >> {log}

        (fastcat fastq {config[in_dir]}/{wildcards.run}/fastq_pass/{wildcards.barcode} \
            -o {config[out_dir]}/{wildcards.run}/a0-concat-fastq/{wildcards.barcode}_fastqc \
            | bgzip -@ {resources[cpus_per_task]} > {output}) 2> {log}

        echo "PROCESSING COMPLETED (fastcat): {wildcards.run}--{wildcards.barcode}" >> {log}         
        """