# Use the official Ubuntu 22.04 base image
FROM wien2k

USER root

# Install the `software-properties-common` package to be able to add PPA's
RUN apt update && \
    apt upgrade -y && \
    apt install -y \
    software-properties-common

# Install Python and the required services
RUN add-apt-repository ppa:deadsnakes/ppa -y && \
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

# Switch to the `aiida` user
USER aiida

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

COPY --chown=aiida:aiida setup project/w2k/setup
COPY --chown=aiida:aiida aiida_run aiida_run

COPY startup.sh /usr/local/bin/startup_aiida.sh
RUN sudo chmod +x /usr/local/bin/startup_aiida.sh
ENTRYPOINT ["/usr/local/bin/startup_aiida.sh"]
