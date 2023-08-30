# Use the official Ubuntu 22.04 base image
FROM ubuntu:22.04

# Set environment variables to prevent prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=linux

# Update Ubuntu and install some tools for all users
RUN apt update && \
    apt upgrade -y && \
    apt install -y \
    sudo \
    curl \
    vim \
    git \
    wget \
    csh \
    tcsh \
    make \
    autoconf \
    libtool \
    gnuplot-x11 \
    libgd-dev \
    libglu1-mesa-dev \
    libtogl-dev \
    tcl-dev \
    tk-dev \
    libfftw3-dev \
    libxmu-dev \
    build-essential \
    software-properties-common \
    tk \
    gfortran \
    gcc \
    liblapack-dev \
    ghostscript \
    tcl-dev \
    libpng-dev \
    libvips \
    libtiff5 \ 
    gnuplot-x11 \   
    libxc-dev \
    libblas-dev \
    liblapack-dev \
    libopenblas64-openmp-dev \
    bc && \
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

# Custom compilation of LibXC
# RUN wget -O libxc-6.2.2.tar.gz http://www.tddft.org/programs/libxc/down.php?file=6.2.2/libxc-6.2.2.tar.gz && \
#     tar -zxvf libxc-6.2.2.tar.gz && \
#     cd libxc-6.2.2 && \
#     ./configure FC=gfortran CC=gcc --prefix=$HOME/src/libxc-6.2.2 && \
#     make && make install && \
#     rm /home/aiida/src/libxc-6.2.2.tar.gz

# Compile OpenBLAS
WORKDIR /home/aiida/src
RUN wget https://github.com/xianyi/OpenBLAS/releases/download/v0.3.23/OpenBLAS-0.3.23.tar.gz && \
    tar -xvf OpenBLAS-0.3.23.tar.gz && \
    cd OpenBLAS-0.3.23/ && \
    make FC=gfortran CC=gcc

# Custom compilation of FFTW
RUN wget https://www.fftw.org/fftw-3.3.10.tar.gz && \
    tar -zxvf fftw-3.3.10.tar.gz && \
    cd fftw-3.3.10 && \
    ./configure FCC=gfortran CC=gcc --prefix=/home/aiida/src/fftw-3.3.10 && \
    make && make install && \
    rm /home/aiida/src/fftw-3.3.10.tar.gz

# WIEN2k compilation
WORKDIR /home/aiida/src/WIEN2k

COPY --chown=aiida:aiida WIEN2k_23.2.tar .
COPY --chown=aiida:aiida .docker/expand_lapw_inputs .
COPY --chown=aiida:aiida .docker/siteconfig_lapw_inputs .
COPY --chown=aiida:aiida .docker/userconfig_lapw_inputs .

RUN tar -xvf WIEN2k_23.2.tar \
    && gunzip *.gz \
    && chmod +x ./expand_lapw \
    && ./expand_lapw < expand_lapw_inputs \
    && ./siteconfig_lapw < siteconfig_lapw_inputs \
    && ./userconfig_lapw < userconfig_lapw_inputs 

RUN mkdir /home/aiida/.ssh && \
    ssh-keyscan github.com >> ~/.ssh/known_hosts

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

WORKDIR /home/aiida/project/w2k/git

RUN git clone https://github.com/aiidateam/aiida-common-workflows.git && \
    /home/aiida/.aiida_venvs/w2k/bin/pip install -e aiida-common-workflows && \
    /home/aiida/.aiida_venvs/w2k/bin/reentry scan

WORKDIR /home/aiida

COPY --chown=aiida:aiida .docker/setup /home/aiida/project/w2k/setup
COPY --chown=aiida:aiida .docker/mv_testrun.py /home/aiida/mv_testrun.py
COPY --chown=aiida:aiida .docker/bashrc_additions.sh /home/aiida/bash_additions.sh
COPY --chown=aiida:aiida .docker/bashrc_noninteractive.sh /home/aiida/bashrc_noninteractive.sh
RUN cat /home/aiida/bash_additions.sh >> ~/.bashrc

COPY .docker/startup.sh /usr/local/bin/startup.sh
RUN sudo chmod +x /usr/local/bin/startup.sh
ENTRYPOINT ["/usr/local/bin/startup.sh"]
