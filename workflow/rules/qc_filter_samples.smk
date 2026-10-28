rule qc_filter_samples:
    input:
        os.path.join(config["out_dir"], "resources", "nanostat_pychopper_flagstatGenomic_read_qc.tsv")
    output:
        os.path.join(config["out_dir"], "resources", "qc_filtered_samples.tsv"),
        os.path.join(config["out_dir"], "resources", "qc_filtered_samples.yaml")
    log:
        os.path.join(config["out_dir"], "logs", "resources", "qc_filter_samples.log")
    conda:
        "../envs/minimap2.yaml"
    params:
        output_location = os.path.join(config["out_dir"], "resources"),
        nanostat_num_reads = 4000000,
        nanostat_len_n50 = 1100,
        pychopper_primers_found_pct = 80,
        pychopper_strand_bias_range = 0.05,
        genome_flagstat_mapped_pct = 95

    shell:
        """
        (
            echo "creating qc_filtered_samples.yaml and qc_filtered_samples.yaml ..."

            python ./workflow/scripts/filter_qc.py \
                -i {input} \
                -s {config[out_dir]} \
                -o {params[output_location]} \
                -r {params[nanostat_num_reads]} \
                -l {params[nanostat_len_n50]} \
                -p {params[pychopper_primers_found_pct]} \
                -b {params[pychopper_strand_bias_range]} \
                -m {params[genome_flagstat_mapped_pct]}
        ) > {log} 2>&1
        """