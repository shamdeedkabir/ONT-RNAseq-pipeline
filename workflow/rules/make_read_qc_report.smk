rule make_read_qc_report:
    input:
        os.path.join(config["out_dir"], "{run}", "b0-pychopper-trimmed", "{barcode}_pychopper_trimmed.fastq.gz"),
        os.path.join(config["out_dir"], "{run}", "a1-nanostat-raw-reads", "{barcode}_raw_read_nanostat.txt")
    output:
        os.path.join(config["out_dir"], "summary", "nanostat_pychopper_read_qc.tsv")
    log:
        os.path.join(config["out_dir"], "logs", "summary", "make_read_qc_report.log")
    conda:
        "../envs/pandas.yaml"
    shell:
        """
        (
            ./workflow/scripts/parse_qc_data.py \
                -i {config[out_dir]} \
                -o {config[outdir]}/summary
        ) > {log} 2>&1
        """