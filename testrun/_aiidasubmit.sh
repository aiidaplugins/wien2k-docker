#!/bin/bash
exec > _scheduler-stdout.txt
exec 2> _scheduler-stderr.txt


 

export WIENROOT=/home/aiida/src/WIEN2k
cd case


'/home/aiida/src/WIEN2k/run123_lapw' '-i' '100' '-cc' '0.000001' '-ec' '0.000001' '-red' '3' '-numk' '-1 0.0317506' '-numk2' '-1 0.023812976204734406' '-noprec' '2' '-fermits' '0.0045' '-nokshift'  > 'run123_lapw.log' 

 
