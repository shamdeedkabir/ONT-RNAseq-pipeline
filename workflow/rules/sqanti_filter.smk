rule sqanti_filter:
    input:
        os.path.join(config["out_dir"], "resources", "sqanti3_out", "sqanti3_qc_on_ncbi", "sqanti_qc_on_ncbi_classification.txt")
    output:
        sqanti_extended_classification = os.path.join(config["out_dir"], "resources", "sqanti3_out", "sqanti3_filter", "sqanti_qc_on_ncbi_classification_N_samples.txt"),
        filtered_gtf = os.path.join(config["out_dir"], "resources", "sqanti3_out", "sqanti3_filter", "sqanti_results", "sqanti_qc_filtered.filtered.gtf")
    log:
        os.path.join(config["out_dir"], "logs", "resources", "sqanti_filter.log")
    params:
        isoquant_tx_counts = os.path.join(config["out_dir"], "resources", "isoquant_out", "USDA_RNA_seq", "USDA_RNA_seq.discovered_transcript_grouped_file_name_counts.linear.tsv"),
        isoquant_extended_gtf = os.path.join(config["out_dir"], "resources", "isoquant_out", "USDA_RNA_seq", "USDA_RNA_seq.extended_annotation.gtf"),
        tx_N_counts = os.path.join(config["out_dir"], "resources", "sqanti3_out", "sqanti3_filter", "isoquant_tx_N_counts.txt"),
        source_labels = os.path.join(config["out_dir"], "resources", "sqanti3_out", "sqanti3_filter", "gtf_source_labels.txt"),
        sqanti_corrected_gtf = os.path.join(config["out_dir"], "resources", "sqanti3_out", "sqanti3_qc_on_ncbi", "sqanti_qc_on_ncbi_corrected.gtf"),
        out_dir = os.path.join(config["out_dir"], "resources", "sqanti3_out", "sqanti3_filter", "sqanti_results"),
        json_filter = "workflow/aux/classification_rule.json"
    conda:
        "../envs/SQANTI3.conda_env.yml"
    shell:
        """
        (
            echo "++++++++++++++++++++++++++++ total threads: {resources[cpus_per_task]}"
            echo "======== SQANTI3 version:"

            chmod +x workflow/scripts/aggregate_isoquant_N_samples.sh

            workflow/scripts/aggregate_isoquant_N_samples.sh \
                --transcript-counts {params[isoquant_tx_counts]} \
                --isoquant-gtf {params[isoquant_extended_gtf]} \
                --classification {input} \
                --output-ncounts {params[tx_N_counts]} \
                --output-source-labels {params[source_labels]} \
                --output-classification {output[sqanti_extended_classification]}

            
            echo "running SQANTI3 custom filter..."

            python workflow/tools/sqanti3/sqanti3_filter.py \
                rules \
                --sqanti_class {output[sqanti_extended_classification]} \
                --filter_gtf {params[sqanti_corrected_gtf]} \
                -d {params[out_dir]} \
                -o sqanti_qc_filtered \
                -c {resources[cpus_per_task]} \
                --json_filter {params[json_filter]}

        ) > {log} 2>&1
        """