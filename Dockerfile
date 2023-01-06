## Emacs, make this -*- mode: sh; -*-
FROM rocker/r-ubuntu:20.04
#FROM debian:testing

RUN chmod -R ugo+rx /root \
  && umask u=rwx,g=rwx,o=rx	

## Configure default locale, see https://github.com/rocker-org/rocker/issues/19
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& locale-gen en_US.utf8 \
	&& /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8


RUN pwd

RUN apt-get update && apt-get install -y wget && rm -rf /var/lib/apt/lists/*

RUN wget\
    https://repo.anaconda.com/miniconda/Miniconda3-py37_4.12.0-Linux-x86_64.sh \
    && mkdir /root/.conda \
    && bash Miniconda3-py37_4.12.0-Linux-x86_64.sh  -b \
    && rm -f Miniconda3-py37_4.12.0-Linux-x86_64.sh

ENV PATH="/root/miniconda3/bin:${PATH}"
ARG PATH="/root/miniconda3/bin:${PATH}"

RUN conda --version && \
    conda config --append channels anaconda && \
    conda config --append channels bioconda && \
    conda config --append channels conda-forge && \
    conda config --append channels bu_cnio && \
    conda config --append channels esgf && \
    conda install -c conda-forge mamba

COPY pinned_r_conda_environment.yml .
COPY r_conda_environment.yml .
COPY lib_conda_environment.yml .
COPY biocond_conda_environment.yml .

RUN conda init bash && \
    mamba env create -n bulk_rna_seq && \
    mamba env update -n bulk_rna_seq -f lib_conda_environment.yml

RUN mamba env update -n bulk_rna_seq -f r_conda_environment.yml

RUN mamba env update -n bulk_rna_seq -f pinned_r_conda_environment.yml

RUN mamba env update -n bulk_rna_seq -f biocond_conda_environment.yml
    
RUN wget https://github.com/CCBR/l2p/blob/master/r-l2p-0.0_13-r35_0.tar.bz2?raw=true -O /tmp/r-l2p-0.0_13-r35_0.tar.bz2
RUN mamba install /tmp/r-l2p-0.0_13-r35_0.tar.bz2
RUN wget https://github.com/CCBR/l2p/blob/master/r-l2psupp-0.0_13-r35_0.tar.bz2?raw=true -O /tmp/r-l2psupp-0.0_13-r35_0.tar.bz2
RUN mamba install /tmp/r-l2psupp-0.0_13-r35_0.tar.bz2

RUN echo "source activate single-cell-test-Rbase" > ~/.bashrc && \
    echo "TMPDIR=/mnt" > /root/.Renviron
    
ENV PATH /opt/conda/envs/env/bin:$PATH

RUN chmod -R ugo+rx /opt && \
    chmod -R ugo+rx /tmp
    

CMD ["bash"]


