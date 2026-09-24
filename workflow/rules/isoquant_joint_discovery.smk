rule isoquant_joint_discovery:
    input:
        yaml_samples = os.path.join(config["out_dir"], "resources", "qc_filtered_samples.yaml"),
        reference_fasta = os.path.join(config["ref_dir"], "GCF_016699485.2_bGalGal1.mat.broiler.GRCg7b_genomic.fna"),
        reference_gtf = os.path.join(config["ref_dir"], "genomic.gtf")
    output:
        directory(os.path.join(config["out_dir"], "resources", "isoquant_out")),
        os.path.join(config["out_dir"], "resources", "isoquant_out", "USDA_RNA_seq", "USDA_RNA_seq.extended_annotation.gtf")
    log:
        os.path.join(config["out_dir"], "logs", "resources", "isoquant_joint_discovery.log")
    conda:
        "../envs/isoquant.yaml"
    shell:
        """
        (
            echo "++++++++++++++++++++++++++++ total threads: {resources[cpus_per_task]}"
            echo "======== isoquant version:"
            isoquant --version

            isoquant \
                --reference {input[reference_fasta]} \
                --genedb {input[reference_gtf]} \
                --complete_genedb \
                --stranded forward \
                --fl_data \
                --report_novel_unspliced true \
                --model_construction_strategy sensitive_ont \
                --polya_requirement always \
                --max_coverage_normal_chr 1000000 \
                -t {resources[cpus_per_task]} \
                --yaml {input[yaml_samples]} \
                --data_type nanopore \
                -o {output}

            echo "======= PROCESS COMPLETED (isoquant isoform discovery)!!!"
        ) > {log} 2>&1
        """