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
To build the Singularity image, move the zip file 'XXX' located in XXX onto the cluster, where Singularity/Apptainer should already be installed. The command:

`singularity build {IMAGENAME.sif} DEFFILENAME`

will start the build process, but make be killed due to high resource demands, so you can use the snakemake script XXX to launch the build by running:

`sbatch BUILDSCRIPT.sh`. This should take roughly 1 HOUR? to run. If completed successfully, you should see a message along the lines of 'XXX', and the file XXX.sif should be added to the current working directory.

In order to move the CAZy database locally, you will need to do one more step, once. Run the command:

`singularity run IMAGENAME.sif`.

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

