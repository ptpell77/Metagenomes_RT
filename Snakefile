from os.path import join
import pandas as pd

# This will
configfile: "config/config.yaml"

# Inport a list of the files to be processed, based on the samplesheet specified in the config file:
df = pd.read_table(config['samplesheet'])
sampleNames = df['sample name'].tolist()



rule all:
    input:
        expand(join(config["fastp_out"], "{sample}_R1_001.fastq.gz"), sample = sampleNames), # <-- run fastp on everything
        expand(join(config["DBdir"], config["DBname"]+".dmnd")), # <-- Build the DB
        expand(join(config["diamond_out"], "{sample}_R2.tsv"), sample = sampleNames), # <-- run diamond on all read pairs
	expand(join(config["diamond_out"], "merged_CAZy_outputs.csv"))

include: "./config/snakemake_rules.smk"
# # Import list of sample names and metadata.
# # Columns "filename" and "sample" are required for processing.
# # Column "filename" should be in the format "16S-[WELL]L[0:7]", i.e. "16S-A12-L2"
# # There should be no underscores in the file or the sample name.
# # Also include a "group" column. All samples in each group will be processed as a single phyloseq.
# # If all samples from a run are part of the same experiment, then list them as part of the same group.
# df=pd.read_table(config['samplesheet'], header=)
# df['group'] = df['group'].fillna("blank")
# df['fullfilename']=df['filename'] + "_" + df['sample']
# df['trimfilename']=df['group'] + "/R1/" + df['fullfilename']
# groups=(df['group'].unique()).tolist()
# groupList=(df['group'].tolist())
# demuxedfiles=df['filename'].tolist()
# biosamples=df['sample'].tolist()
# fullfilenames=df['fullfilename'].tolist()
# trimfilenames=df['trimfilename'].tolist()
# def sampleToFile(s):
#     return df.query('sample == s')['filename'].tolist()[0]
# def fileToSample(file):
#     return df.query('filename == file')['sample'].tolist()[0]

# Import indices for demultiplexing.
# dfindices=pd.read_table(config['indices'], header=0)
# phases=dfindices['phase'].tolist()

# Import list of FASTQ paths and shortened filenames.
# This file needs to be generated for each sequencing run.
# It includes columns read1, read2, and file.
# read1 lists the full path to the file for read 1.
# read2 lists the full path to the file for read 2.
# file lists the 16S name and indices used for each sample, i.e. 16S-A-A7.
# dffastq=pd.read_table(config['fastqlist'], header=0)
# dffastq.columns=["read1","read2","file"]
# Generate a list of sample files.
# files=list(set(dffastq['file'].tolist()))

# rule all:
#     input:
       # expand(join(config["outdir"], "inputCheck_log.txt")),
       # expand(join(config["outdir"], "demux/{sample}-R1.fastq.gz"), sample=files),
       # expand(join(config["outdir"], "demux/R1/{sample}-L{phase}.fastq.gz"), sample=files, phase=phases),
       # expand(join(config["trimdir"], "{group}/R1/{fullfilename}_executed_trim_reads.txt"), zip, group=groupList,fullfilename=fullfilenames),
       # expand("".join([config["trimdir"],"/{group}/summary.txt"]), group=groups),
       # expand("".join([config["trimdir"],"/{group}/lowReadsSummary.txt"]), group=groups),
       # expand("workflow/out/{group}/DADA2_output/seqtab_all.rds", group=groups),
       #  expand("workflow/out/{group}/DADA2_output/dsvs_msa.tree", group=groups),
       #  expand("workflow/out/{group}/DADA2_output/L6_summary.txt", group=groups)

# include: "workflow/rules/processRawReads.smk"
