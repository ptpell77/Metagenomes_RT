# Run fastp on all input fastq files from sample sheet:
rule runFastp:
    input:
        read1in = join(config["fastqdir"], "{sample}_R1_001.fastq.gz"),
        read2in = join(config["fastqdir"], "{sample}_R2_001.fastq.gz")
    output:
        read1out = join(config["fastp_out"], "{sample}_R1_001.fastq.gz"),
        read2out = join(config["fastp_out"], "{sample}_R2_001.fastq.gz")
    shell:
        """
        fastp -i {input.read1in} -I {input.read2in} -o {output.read1out} -O {output.read2out}
        """

# Build a blastdb from the CAZy db:
rule buildDB:
    input:
        database = config["DB"]
    params:
        DBname = join(config["DBdir"], config["DBname"])
    output:
        DBout = join(config["DBdir"], config["DBname"] + ".dmnd")
    shell:
        """
        diamond makedb --in {input.database} -d {params.DBname}
        """

# Run diamond on all the pre-processed fastq files:
rule runDiamond:
    input:
        read1in = join(config["fastp_out"], "{sample}_R1_001.fastq.gz"),
        read2in = join(config["fastp_out"], "{sample}_R2_001.fastq.gz"),
        # dbfile = config["DBname"] # "{input.DBname}.dmnd"
    params:
        DBfile = join(config["DBdir"], config["DBname"])
    output:
        read1out = join(config["diamond_out"], "{sample}_R1.tsv"),
        read2out = join(config["diamond_out"], "{sample}_R2.tsv")
    shell:
        """
        diamond blastx -q {input.read1in} -d {params.DBfile} -b 0.5 -o {output.read1out}
        diamond blastx -q {input.read2in} -d {params.DBfile} -b 0.5 -o {output.read2out}
        """ # Run fastp on all input fastq files from sample sheet:

# Merge the individual outputs from reads:
rule mergeTSV:
    input:
        # expand(join(config["diamond_out"], "{sample}_R1.tsv"), sample=sampleNames), # <-- we'll include these as inputs, but not actually call them in the shell script, so this only happends when they're done,
        expand(join(config["diamond_out"], "{sample}_R2.tsv"), sample = sampleNames) 
	# expand(join(config["diamond_out"], "{sample}_R2.tsv"), sample = sampleNames)
    params:
        Outdir = config["diamond_out"]
    output:
        join(config["diamond_out"], "merged_CAZy_outputs.csv")
    shell:
        """
        python3 /analysis_dir/config/mergeDiamondOutputs.py {params.Outdir}
        """
