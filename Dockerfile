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
    build-essential \
    gfortran \
    curl \
    vim \
    git \
    wget \
    csh \
    tcsh \
    bc \
    libopenblas-dev

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

WORKDIR /home/aiida

COPY --chown=aiida:aiida .docker/bashrc_noninteractive.sh bashrc_noninteractive.sh
COPY --chown=aiida:aiida .docker/testrun testrun

COPY .docker/startup.sh /usr/local/bin/startup.sh
RUN sudo chmod +x /usr/local/bin/startup.sh
ENTRYPOINT ["/usr/local/bin/startup.sh"]
