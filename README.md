# README
## Pipeline overview
This pipeline is containerized in both Docker and Singularity images for running locally/on compute clusters respectively. The pipeline itself is constructed using snakemake to organise the workflow, and the individual steps (described in 'snakemake_rules.smk') rely on the programs fastq and Diamond.

## Inputs
There are only three inputs that will vary between runs: the raw .fastq.gx files themselves, the config file ('config.yaml') and the samplesheet ('samplesheet.txt'). The raw reads can be stored anywhere on the served where the pipeline will be run for use in Singularity, and their locations will be specified within the samplesheet. 
The samplesheet should be a tab-delimited file named 'samplesheet.txt' (You can use another name for the sample sheet, but the name will need to be updated in the 'config.yaml' file). The samplesheet should have two columns named 'XXX' and 'XXX', with XXX containing the paths to the files, and XXX containing the file name, with the '_R1_001.fastq.gz' suffix dropped.

## Using Docker
### Building Docker image
You can find instructions on Docker installation here {https://docs.docker.com/engine/install/}. Once Docker is installed, open the Docker desktop application or run ‘systemctl start docker’ to launch the Docker Daemon. 
To build a docker image, download the Docker sip file (LOCATION) and unzip. Then run the following command from a terminal within the directory containing 'Dockerfile':

`docker build -t {IMAGE_NAME}:{VERSION} . `.

This will take soem time, as it has to download the full CAZy database, but should finish within TIME. If successful, you should see an output like the following:
`XXX
XXX
XXX`. 

You can launch a container in the image with the command:

`docker run -it {IMAGE_NAME}:{VERSION}`

The following files structure should be set up within the container:

XXX

### Test run in Docker
...

### Real run in Docker
To run the pipeline, enter into a conatiner (`docker run -it {IMAGE_NAME}:{VERSION}`). You can find the name of the container by running `docker container ls` in a separate terminal shell. Next transfer the input files into the container using the commang: `COMMANDS`.

You will need to move in two tests of files: the sample sheet, and the raw reads themselves. The sample sheet should be moved into the config, and the reads should go into the READ DIRECTIRY:
`docker co XXX`

`docker cp XXX`.

Once this is done, you can edit the config file to make sure all the paths are correct. DESCRIBE WHAT WILL NEED TO BE CHANGED!!!

Now you can initiate the run by running `snakemake --cores X` with `X` replaced by the number of cores you want to use.Before starting a real run, you can also use the command `snakemake -n` to do a 'dry run' which will show the steps to be completed without running anything. 

If the run is successful, you should see a message saying 'XXX' at the end. 

## Using Singularity/Apptainer
### Building Singularity image

To build the Singularity image, move the zip file 'singularity_things.zip' located in GoogleDrive(?) onto the cluster, where Singularity/Apptainer should already be installed. The command:

`singularity build testimage.sif singularity_def_file.txt`

will start the build process, but make be killed due to high resource demands, so you can use the snakemake script 'slurm_buildImage' to launch the build by running:

`sbatch slurm_buildImage.sh`. This should take roughly <15 minutes to run. If completed successfully, you should see a message along the lines of 'XXX', and the file XXX.sif should be added to the current working directory.

In order to move the CAZy database locally, you will need to do one more step, once. Run the command:

`singularity run testimage.sif`.

This will execute the instructions in the last '%run script' section of the definition file, which will download the CAZy DB into the /analysis_dir/database/ folder. Once this has been done, it doesn't need to be repeated. 

### Test run in Singularity
...

### Real run in Singularity
To run the analysis, make sure the samplesheet describes the paths is pointing to the correct locations relative to the CURRENT WORKIND DIRECTORY. Then, launch a container in the image by running:

`singularity shell {IMAGENAME.sif}`.

You should now be in the CURRENT WORKING DIRECTORY, and have access to all the same files you did outside of the container (and any changes you make to them will be saved, so be as careful as you would normally!). 
Check that the config file paths are correct, then launch a 'dry run' by running:

`snakemake -n`

in the directory contianing the Snakefile. If this goes smoothly, you can launch a full run using 'snakemake --cores X', with 'X' replaced by the number of cores to use. For short jobs, this should run as is, but for larger runs, use a slurm script to allocate time resources.
An example script is included in XXX. For a single test file ('XXX') with X cores, X memory, Sherlock took X long to run the full pipeline (X for fastp and X for DIAMOND).


## Unlocking:
If the directory is locked because slurm/something else kills a process, you can unlock it from analysis_dir, by running:

`singularity shell ../testimage.sif`

`snakemake --unlock`

`exit`

## Rerunning incomplete items:
If a job is killed unexpectedly, it may not have time to delete partially completed files. If this is the case, you may need to add the flag:
`--rerun-incomplete`
to the `snakemake` command when starting the next run so that these incomplete files are regenerated before moving on to the next step. 

## Slurm Resources:
To run this pipeline on Sherlock, you'll need to specify the resources needed. Assuming the typical file size is about 15 GB for each forward/reverse file (so 30 GB per sample), the following settings are recommended for each step:

#### fastp:
* threads: 8
* memory: 2 GB
* time: 20 min
Running fastp should take about 15 minutes per paired end read set. Increasing the number of cores will speed it up, but has limited returns beyond XXX. Likewise, increasing the memory beyond XXX will slightly improve timing, but running more steps in parallel is a more efficient way to speed up the analysis. 

#### diamond build db (for cazyDB):
* threads: 8 
* memory: 2 GB 
* time: 2 min 
Running the build DB step on Sherlock with 8 cores should take under 1 minute, and not exceed 2 GB of memory at any time point. 
  
#### diampond blastx:
* threads: XXX
* memory: XXX
* time: XXX
  

#### merge diamond outputs:
* threads: 1 
* memory: XXX
* time: XXX
This step relies on a simply python script that is not capable of multithreading, so providing more cores/threads won't speed anything up. This should take approximately XXX per set of paired end reads, so the time provided should be roughly XXX times the number of input pairs.

Default resource settings are specified at the top of the Snakefile. The default settings are: 
`resources:\
    mem_mb=4000 # default to 4 GB per job\
    time=1:00:00 # default to max 1 hour per job\
threads: 1 # default to 1 thread per job`

These will only be used when resources are specified directly in the rule, which shouldn't be the case for any rules, but protects against any issues with resource specification. 
  
