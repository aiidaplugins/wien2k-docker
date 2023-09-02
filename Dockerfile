# Use the official Ubuntu 22.04 base image
FROM ubuntu:22.04

# Set environment variables to prevent prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=linux

ARG wien2k_source=WIEN2k_23.2.tar

# Update Ubuntu and install some tools for all users
RUN apt update && \
    apt upgrade -y && \
    apt install -y \
    sudo \
    build-essential \
    software-properties-common \
    gfortran \
    curl \
    vim \
    git \
    wget \
    csh \
    tcsh \
    bc \
    libopenblas-dev && \
    add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update && apt-get install -y \
    python3-pip \
    python3.9-dev \
    python3.9-venv \
    python3.9-distutils \
    postgresql \
    postgresql-server-dev-all \
    postgresql-client \
    rabbitmq-server && \
    rm -rf /var/lib/apt/lists/*

# Create the `aiida` user; make him a sudoer that can execute sudo commands without a password
RUN useradd -ms /bin/bash aiida && \
    echo "aiida:aiida" | chpasswd && \
    adduser aiida sudo && \
    echo 'aiida ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    echo '' >> /home/aiida/.bashrc

USER aiida

# Custom compilation of FFTW
WORKDIR /home/aiida/src
RUN wget https://www.fftw.org/fftw-3.3.10.tar.gz && \
    tar -zxvf fftw-3.3.10.tar.gz && \
    rm fftw-3.3.10.tar.gz && \
    cd fftw-3.3.10 && \
    ./configure FCC=gfortran CC=gcc && \
    make && sudo make install

# WIEN2k compilation
WORKDIR /home/aiida/src/WIEN2k

COPY --chown=aiida:aiida ${wien2k_source} .
COPY --chown=aiida:aiida .docker/expand_lapw_inputs .
COPY --chown=aiida:aiida .docker/siteconfig_lapw_inputs .
COPY --chown=aiida:aiida .docker/userconfig_lapw_inputs .

RUN tar -xvf ${wien2k_source} \
    && gunzip *.gz \
    && chmod +x ./expand_lapw \
    && ./expand_lapw < expand_lapw_inputs \
    && ./siteconfig_lapw < siteconfig_lapw_inputs \
    && ./userconfig_lapw < userconfig_lapw_inputs 

RUN mkdir /home/aiida/scratch

# Install `pipx`, install `aiida-project` and create the AiiDA environment
RUN python3.9 -m pip install --user pipx && \
    echo '' >> $HOME/.bashrc && \
    echo 'export PATH=$PATH:/home/aiida/.local/bin' >> $HOME/.bashrc && \
    export PATH=$PATH:/home/aiida/.local/bin && \
    pipx ensurepath && \
    pipx install aiida-project && \
    aiida-project init --shell bash && \
    aiida-project create w2k \
    --core-version 1.6.9 \
    --python 3.9

# Git clone the latest `develop` branch for `aiida-common-workflows` and install it
WORKDIR /home/aiida/project/w2k/git

RUN git clone https://github.com/aiidateam/aiida-common-workflows.git && \
    /home/aiida/.aiida_venvs/w2k/bin/pip install -e aiida-common-workflows && \
    /home/aiida/.aiida_venvs/w2k/bin/reentry scan

WORKDIR /home/aiida

COPY --chown=aiida:aiida .docker/bashrc_noninteractive.sh bashrc_noninteractive.sh
COPY --chown=aiida:aiida .docker/setup project/w2k/setup
COPY --chown=aiida:aiida .docker/aiida_run aiida_run
COPY --chown=aiida:aiida .docker/manual_run manual_run

COPY .docker/startup.sh /usr/local/bin/startup.sh
RUN sudo chmod +x /usr/local/bin/startup.sh
ENTRYPOINT ["/usr/local/bin/startup.sh"]
