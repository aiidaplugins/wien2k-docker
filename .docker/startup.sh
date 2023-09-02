#!/bin/bash
source /home/aiida/bashrc_noninteractive.sh

sudo service postgresql start
sudo service rabbitmq-server start

psql -l > /dev/null 2>&1 || {
    echo ' ⭐️ Setting up the `aiida` postgres role...'
    sudo -u postgres createuser aiida
    sudo -u postgres psql -U postgres -c "ALTER USER aiida WITH PASSWORD 'database';" 1>/dev/null 
}
psql -d w2k > /dev/null 2>&1 || {
    echo ' ✨ Creating the `w2k` database...'
    sudo -u postgres createdb -O aiida w2k
}

source /home/aiida/.aiida_venvs/w2k/bin/activate 2>/dev/null

verdi profile show > /dev/null 2>&1 || {
    verdi setup -n --config /home/aiida/project/w2k/setup/profile/dev.yaml
    verdi config set warnings.rabbitmq_version False
}

verdi computer show localhost > /dev/null 2>&1 || {
    verdi computer setup -n --config /home/aiida/project/w2k/setup/computer/localhost.yaml
    verdi computer configure local localhost -n --safe-interval 0
}

verdi code show run123_lapw > /dev/null 2>&1 || {
    verdi code setup -n --config /home/aiida/project/w2k/setup/code/run123_lapw.yaml
}

exec "$@"