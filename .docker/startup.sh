#!/bin/bash
source /home/aiida/bashrc_noninteractive.sh

cd /home/aiida/testrun/case
/home/aiida/src/WIEN2k/run123_lapw -nokshift

exec "$@"