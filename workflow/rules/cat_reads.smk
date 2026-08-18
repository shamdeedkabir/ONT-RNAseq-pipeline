import glob
import os

rule cat_reads:
    input:
        lambda wildcards: sorted(
            p
            for p in glob.glob(os.path.join(config["in_dir"], wildcards.barcode, "*"))
            if p.endswith(".fastq") or p.endswith(".fastq.gz") or p.endswith(".fq") or p.endswith(".fq.gz")
        )
    output:
        os.path.join(config["out_dir"], "a0-concat-fastq", "{barcode}_concatenated.fastq.gz")
    log:
        "logs/a0-concat-fastq/{barcode}.log"
    conda:
        "../envs/fastcat.yaml"
    shell:
        """
        mkdir -p {config[out_dir]}/a0-concat-fastq logs/a0-concat-fastq
        rm -rf {config[out_dir]}/a0-concat-fastq/{wildcards.barcode}_fastqc

        (fastcat fastq {config[in_dir]}/{wildcards.barcode} \
            -o {config[out_dir]}/a0-concat-fastq/{wildcards.barcode}_fastqc \
            | bgzip -@ {resources[cpus_per_task]} > {output}) 2> {log}

        echo "PROCESSING COMPLETED (fastcat): {wildcards.barcode}" >> {log}         
        """