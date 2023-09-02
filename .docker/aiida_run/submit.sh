#!/bin/bash

echo '🚀 Running WIEN2k AiiDA test'
aiida-common-workflows launch relax -r none -S Si -p moderate wien2k
verdi run /home/aiida/aiida_run/mv_testrun.py
