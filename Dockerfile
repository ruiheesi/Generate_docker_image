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

ENV PATH="/root/miniconda3/bin:${PATH}"
ARG PATH="/root/miniconda3/bin:${PATH}"

RUN apt-get update && apt-get install -y wget && rm -rf /var/lib/apt/lists/*

RUN wget\
    https://repo.anaconda.com/miniconda/Miniconda3-py37_4.8.2-Linux-x86_64.sh \
    && mkdir /root/.conda \
    && bash Miniconda3-py37_4.8.2-Linux-x86_64.sh  -b \
    && rm -f Miniconda3-py37_4.8.2-Linux-x86_64.sh

RUN conda --version && \
    conda config --append channels defaults && \
    conda config --append channels anaconda && \
    conda config --append channels bioconda && \
    conda config --append channels conda-forge && \
    conda config --append channels bu_cnio && \
    conda config --append channels esgf && \
    conda install -c conda-forge mamba


COPY environment.yml .

RUN conda init bash && \
    mamba env update -f r_conda_environment.yml && \
    mamba env update -f r_conda_environment.yml && \
    mamba env update -f r_conda_environment.yml

RUN echo "source activate single-cell-test-Rbase" > ~/.bashrc && \
    echo "TMPDIR=/mnt" > /root/.Renviron
    
ENV PATH /opt/conda/envs/env/bin:$PATH

RUN chmod -R ugo+rx /opt && \
    chmod -R ugo+rx /tmp
    

CMD ["bash"]




