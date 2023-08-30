#!/bin/bash
sudo service postgresql start

psql -l 2>/dev/null || {
    echo ' ⭐️ Setting up the `aiida` postgres role...'
    sudo -u postgres createuser aiida
    sudo -u postgres psql -U postgres -c "ALTER USER aiida WITH PASSWORD 'database';" 1>/dev/null 
}
psql -d w2k 2>/dev/null || {
    echo ' ✨ Creating the `w2k` database...'
    sudo -u postgres createdb -O aiida w2k
}

sudo service rabbitmq-server start

# echo 'consumer_timeout = 36000000000 # 10,000 hours in milliseconds' | \
#     sudo tee -a /etc/rabbitmq/rabbitmq-env.conf 1>/dev/null

source /home/aiida/.aiida_venvs/w2k/bin/activate 2>/dev/null

reentry scan

verdi profile show 2>/dev/null || {
    verdi setup -n --config /home/aiida/project/w2k/setup/profile/dev.yaml
    verdi config set warnings.rabbitmq_version False
}

verdi computer show localhost 2>/dev/null || {
    verdi computer setup -n --config /home/aiida/project/w2k/setup/computer/localhost.yaml
    verdi computer configure local localhost -n --safe-interval 0
}

verdi code show run123_lapw 2>/dev/null || {
    verdi code setup -n --config /home/aiida/project/w2k/setup/code/run123_lapw.yaml
}

# Add the required environment variable for WIEN2k
export SCRATCH=/home/aiida/scratch
if [ "$WIENROOT" = "" ]; then export WIENROOT=/home/aiida/src/WIEN2k; fi
export STRUCTEDIT_PATH=$WIENROOT/SRC_structeditor/bin
export PATH=$WIENROOT:$STRUCTEDIT_PATH:$WIENROOT/SRC_IRelast/script-elastic:$PATH:.

ulimit -s unlimited
alias octave="octave -p $OCTAVE_PATH"

# Do the test run!
aiida-common-workflows launch relax -r none -S Si -p moderate wien2k

verdi run /home/aiida/mv_testrun.py

exec "$@"