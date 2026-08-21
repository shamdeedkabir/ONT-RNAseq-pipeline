# Creation of this file saves a few minutes for each of the minimap2 genome alignment run
# The relevant arguments for minimap2 for creating mmi file was obtained from IsoQuant's method:
#    https://github.com/ablab/IsoQuant/blob/master/isoquant_lib/utils/read_mapper.py 


rule make_minimap2_mmi_file:
    input:
        os.path.join(config["ref_dir"], "GCF_016699485.2_bGalGal1.mat.broiler.GRCg7b_genomic.fna")
    output:
        os.path.join(config["out_dir"], "resources", "GCF_016699485.2_bGalGal1.mat.broiler.GRCg7b_genomic.mmi")
    log:
        os.path.join(config["out_dir"], "logs", "resources", "make_minimap2_mmi_file.log")
    conda:
        "../envs/minimap2.yaml"
    shell:
        """
        (
            echo "======== minimap2 version:"
            minimap2 --version
            
            minimap2 \
                -t {resources[cpus_per_task]} \
                -k 14 \
                -w 5 \
                -d {output} \
                {input}
                
            echo "======= PROCESS COMPLETED (minimap2 mmi file)"
        ) > {log} 2>&1
        """