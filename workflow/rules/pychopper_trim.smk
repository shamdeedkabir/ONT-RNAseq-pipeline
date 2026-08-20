rule pychopper_trim:
    input:
        os.path.join(config["out_dir"], "{run}", "a0-concat-fastq", "{barcode}_concatenated.fastq.gz")
    output:
        os.path.join(config["out_dir"], "{run}", "b0-pychopper-trimmed", "{barcode}_pychopper_trimmed.fastq.gz")
    log:
        os.path.join(config["out_dir"], "logs", "{run}", "b0-pychopper-trimmed", "{barcode}.log")
    conda:
        "../envs/pychopper.yaml"
    params:
        report_file = os.path.join(config["out_dir"], "{run}", "b0-pychopper-trimmed", "{barcode}_pychopper_report.pdf"),
        unclassified_fastq = os.path.join(config["out_dir"], "{run}", "b0-pychopper-trimmed", "{barcode}_pychopper_unclassified.fastq"),
        rescued_fastq = os.path.join(config["out_dir"], "{run}", "b0-pychopper-trimmed", "{barcode}_pychopper_rescued.fastq"),
        stat_file = os.path.join(config["out_dir"], "{run}", "b0-pychopper-trimmed", "{barcode}_pychopper_stats.tsv")
    shell:
        """
        (
            pychopper \
                -k PCB114 \
                -r {params[report_file]} \
                -u {params[unclassified_fastq]} \
                -w {params[rescued_fastq]} \
                -S {params[stat_file]} \
                -t {resources[pychopper_threads]} \
                {input} \
                - | pigz -p {resources[pigz_threads]} > {output} 
            
            echo "======= PROCESS COMPLETED (pychopper): {wildcards.run}--{wildcards.barcode}"
        ) > {log} 2>&1
        """