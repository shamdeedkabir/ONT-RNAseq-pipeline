rule make_minimap2_junc_bed_file:
    input:
        os.path.join(config["ref_dir"], "genomic.gtf")
    output:
        os.path.join(config["out_dir"], "resources", "genomic.bed")
    log:
        os.path.join(config["out_dir"], "logs", "resources", "make_minimap2_junc_bed_file.log")
    conda:
        "../envs/minimap2.yaml"
    shell:
        """
        (
            paftools.js \
                gff2bed {input} \
                > {output}

        echo "======= PROCESS COMPLETED (minimap2 junc-bed file)"
        ) > {log} 2>&1
        """