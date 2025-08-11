# Use a base Ubuntu image
FROM ubuntu:22.04


# Update package lists and install necessary dependencies
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    wget \
    xorg-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    gfortran \
    libreadline-dev \
    libbz2-dev \
    liblzma-dev \
    libpcre2-dev \
    libharfbuzz-dev \
    libfreetype6-dev \
    libfribidi-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    libgc-dev \
    python3-pip \
    less \
    grep \
    cmake \
    vim 

WORKDIR /tmp/

# Copying the demux repo and sample data
# COPY ./16s-demux /16s-demux
# COPY ./fastq_data /fastq_data
# RUN mkdir /analysis_dir/snakemake_things
# COPY ./snakemake_things/* /analysis_dir/snakemake_things/


RUN mkdir /analysis_dir/
COPY ./requirements.txt ./requirements.txt
RUN mkdir /analysis_dir/fastq_data/
COPY ./test_data/*.fastq.gz /analysis_dir/fastq_data/
RUN mkdir /analysis_dir/outputs/
RUN mkdir /analysis_dir/outputs/fastp/
RUN mkdir /analysis_dir/outputs/diamond/
RUN mkdir /analysis_dir/config/
RUN mkdir /analysis_dir/database/
COPY ./snakemake_things/Snakefile /analysis_dir/
COPY ./snakemake_things/snakemake_rules.smk /analysis_dir/config/
COPY ./snakemake_things/config.yaml /analysis_dir/config/




# Install Python requirements & Snakemake
RUN pip3 install -r ./requirements.txt 

# Download CAZydb:
WORKDIR /analysis_dir/database/
RUN wget https://bcb.unl.edu/dbCAN2/download/Databases/CAZyDB.07262023.fa

WORKDIR /bin/

# Install fastp 
RUN wget http://opengene.org/fastp/fastp
RUN chmod a+x ./fastp

# install diamond
RUN cd /bin/
RUN wget http://github.com/bbuchfink/diamond/archive/v2.0.4.tar.gz
RUN tar xzf v2.0.4.tar.gz
RUN mkdir /bin/diamond-2.0.4/bin
RUN cmake /bin/diamond-2.0.4/
RUN make -j4
RUN make install

# WORKDIR /16s-demux
WORKDIR /analysis_dir/
