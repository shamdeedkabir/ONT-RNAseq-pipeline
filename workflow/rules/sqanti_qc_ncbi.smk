rule sqanti_qc_ncbi:
    input:
        isoquant_gtf = os.path.join(config["out_dir"], "resources", "isoquant_out", "USDA_RNA_seq", "USDA_RNA_seq.extended_annotation.gtf"),
        ncbi_gtf = os.path.join(config["ref_dir"], "genomic.gtf"),
        ncbi_fasta = os.path.join(config["ref_dir"], "GCF_016699485.2_bGalGal1.mat.broiler.GRCg7b_genomic.fna")
    output:
        os.path.join(config["out_dir"], "resources" ,"sqanti3_out", "sqanti3_qc_on_ncbi", "sqanti_qc_on_ncbi_classification.txt"),
        os.path.join(config["out_dir"], "resources", "sqanti3_out", "sqanti3_qc_on_ncbi", "sqanti_qc_on_ncbi_corrected.cds.gff3"),
        os.path.join(config["out_dir"], "resources", "sqanti3_out", "sqanti3_qc_on_ncbi", "sqanti_qc_on_ncbi_corrected.faa"),
        os.path.join(config["out_dir"], "resources", "sqanti3_out", "sqanti3_qc_on_ncbi", "sqanti_qc_on_ncbi_corrected.fasta"),
        os.path.join(config["out_dir"], "resources", "sqanti3_out", "sqanti3_qc_on_ncbi", "sqanti_qc_on_ncbi_corrected.genePred"),
        os.path.join(config["out_dir"], "resources", "sqanti3_out", "sqanti3_qc_on_ncbi", "sqanti_qc_on_ncbi_corrected.gtf"),
        os.path.join(config["out_dir"], "resources", "sqanti3_out", "sqanti3_qc_on_ncbi", "sqanti_qc_on_ncbi_junctions.txt"),
        os.path.join(config["out_dir"], "resources", "sqanti3_out", "sqanti3_qc_on_ncbi", "sqanti_qc_on_ncbi_SQANTI3_report.html")
    log:
        os.path.join(config["out_dir"], "logs", "resources", "sqanti_qc_ncbi.log")
    params:
        sqanti_out_dir = os.path.join(config["out_dir"], "resources", "sqanti3_out", "sqanti3_qc_on_ncbi", "sqanti_qc_on_ncbi")
    conda:
        "../envs/SQANTI3.conda_env.yml"
    shell:
        """
        (
            echo "++++++++++++++++++++++++++++ total threads: {resources[cpus_per_task]}"
            echo "======== SQANTI3 version:"
            
            # rm -rf {params[sqanti_out_dir]}
            # mkdir -p {params[sqanti_out_dir]}
            # cd {params[sqanti_out_dir]}

            python workflow/tools/sqanti3/sqanti3_qc.py \
                --isoforms {input[isoquant_gtf]} \
                --refGTF {input[ncbi_gtf]} \
                --refFasta {input[ncbi_fasta]} \
                -t {resources[cpus_per_task]} \
                -o . \
                -d {params[sqanti_out_dir]} \
                --include_ORF \
                --saturation

        ) > {log} 2>&1
        """
        