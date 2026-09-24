rule gffread_build_extended_transcriptome:
    input:
        filtered_gtf = os.path.join(config["out_dir"], "resources", "sqanti3_out", "sqanti3_filter", "sqanti_results", "sqanti_qc_filtered.filtered.gtf")
    output:
        os.path.join(config["out_dir"], "resources", "sqanti3_out", "sqanti_extended_transcriptome.fa")
    log:
        os.path.join(config["out_dir"], "logs", "resources", "gffread_build_extended_transcriptome.log")
    params:
        ncbi_fasta = os.path.join(config["ref_dir"], "GCF_016699485.2_bGalGal1.mat.broiler.GRCg7b_genomic.fna")
    conda:
        "../envs/gffread.yaml"
    shell:
        """
        (
            echo "++++++++++++++++++++++++++++ total threads: {resources[cpus_per_task]}"
            echo "======== gffread version:" 
            gffread -v

            gffread \
                {input[filtered_gtf]} \
                -g {params[ncbi_fasta]} \
                -w {output}
            
            echo "file extended transcriptome file written to: {output}"
        
        ) > {log} 2>&1
        """