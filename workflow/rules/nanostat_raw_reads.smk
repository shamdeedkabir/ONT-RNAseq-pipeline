rule nanostat_raw_reads:
    input:
        os.path.join(config["out_dir"], "{run}", "a0-concat-fastq", "{barcode}_concatenated.fastq.gz")
    output:
        os.path.join(config["out_dir"], "{run}", "a1-nanostat-raw-reads", "{barcode}_raw_read_nanostat.txt")
    log:
        os.path.join(config["out_dir"], "logs", "{run}", "a1-nanostat-raw-reads", "{barcode}.log")
    conda:
        "../envs/nanostat.yaml"
    shell:
        """
        (
            echo "++++++++++++++++++++++++++++ nanostat threads: {resources[samtools_threads]}"
            
            NanoStat \
                --fastq {config[out_dir]}/{wildcards.run}/a0-concat-fastq/{wildcards.barcode}_concatenated.fastq.gz \
                --outdir {config[out_dir]}/{wildcards.run}/a1-nanostat-raw-reads \
                -n {wildcards.barcode}_raw_read_nanostat.txt \
                --threads {resources[cpus_per_task]}

                echo "PROCESS COMPLETED (nanostat): {wildcards.run}--{wildcards.barcode}"
        ) > {log} 2>&1
        """