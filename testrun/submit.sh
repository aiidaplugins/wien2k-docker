#!/bin/bash

echo '🚀 Running WIEN2k test'
cd /home/aiida/testrun/case
/home/aiida/src/WIEN2k/run123_lapw -i 100 -cc 0.01 -ec 0.01 -red 3 -numk 0 2 2 2 -noprec 0 -nokshift 2>stderr.log | tee run123_lapw.log
