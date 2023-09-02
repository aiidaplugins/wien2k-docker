# Commands to source for non-interactive shells

# added by WIEN2k: BEGIN
# --------------------------------------------------------
alias lsi="ls -aslp *.in*"
alias lso="ls -aslp *.output*"
alias lsd="ls -aslp *.def"
alias lsc="ls -aslp *.clm*"
alias lss="ls -aslp *.scf* */*scf"
alias lse="ls -aslp *.error"
alias LS="ls -alsp |grep /"
alias pslapw="ps -ef |grep "lapw""
alias cdw="cd /home/aiida/WIEN2k"
if [ "$OMP_NUM_THREADS" = "" ]; then export OMP_NUM_THREADS=1; fi
#export LD_LIBRARY_PATH=.....
export EDITOR="vim"
export SCRATCH=/home/aiida/scratch
if [ "$WIENROOT" = "" ]; then export WIENROOT=/home/aiida/src/WIEN2k; fi
export W2WEB_CASE_BASEDIR=/home/aiida/WIEN2k
export STRUCTEDIT_PATH=$WIENROOT/SRC_structeditor/bin
export PDFREADER=evince
export PATH=$WIENROOT:$STRUCTEDIT_PATH:$WIENROOT/SRC_IRelast/script-elastic:$PATH:.
export OCTAVE_EXEC_PATH=${PATH}::
export OCTAVE_PATH=${STRUCTEDIT_PATH}::

ulimit -s unlimited
alias octave="octave -p $OCTAVE_PATH"
# --------------------------------------------------------
