# WIEN2k Docker stack

This repository contains a basic Docker stack for creating an image that allows you to quickly compile and run WIEN2k.
Additionally, it sets up an AiiDA environment that installs the WIEN2k plugin and common workflow interface. 

## Usage

The image can be built with:

```
docker build -t wien2k-ubuntu:latest .
```

Afterwards, you can run the image using:

```
docker run -d wien2k-ubuntu
```

## WIEN2`k` compilation instructions

Since WIEN2k is not open source, you must first obtain the source code via a valid license, see:

http://susi.theochem.tuwien.ac.at/order/index.html

Once you have the license, download the source code from the WIEN2k website.

### Copy `WIEN2k` into the Docker container

The following instructions will assume you have obtained the source for WIEN2k v23.2, gathered in the `WIEN2k_23.2.tar` tarball.
First, copy the tarball containing the WIEN2k source code in the container:

```
docker cp WIEN2k_23.2.tar <CONTAINER_ID>:/home/aiida/src/WIEN2k
```

Where the `<CONTAINER_ID>` can be found using `docker container ls -a`:

```
❯ docker container ls -a
CONTAINER ID   IMAGE           COMMAND                  CREATED          STATUS         PORTS     NAMES
dd657cf473e5   wien2k-ubuntu   "/usr/local/bin/star…"   22 minutes ago   Up 6 minutes             dazzling_gagarin
```

Inside the running container, go to the `/home/aiida/src/WIEN2k` directory and 

1. Expand the tarball:
    ```
    tar -xvf WIEN2k_23.2.tar
    ```
2. `gunzip` the packed files:
    ```
    gunzip *.gz
    ```
3. Final expand and linking via:
    ```
    ./expand_lapw
    ```
    Specify `y` in the prompt

You can now start the compilation process of WIEN2k.
Run `./siteconfig_lapw` to get started!

```
   ***********************************************************************
   *                                WIEN2k                               *
   *                          site configuration                         *
   ***********************************************************************

   This is the first time that you install WIEN2k on this computer.
   If you interrupt the "first installation", you can come back using -first
   Please follow the subsequent steps to set up WIEN2k.


It seems you do not have the intel fortran compiler in your path.
You need a f90 compiler for the installation of WIEN2k and:
a) you have another f90 compiler installed and in your path. Continue ...
b) you have ifort installed, but it is not in your path.
   STOP  and  put two lines like:
   source /opt/intel/oneapi/setvars.sh (use the /path_where_compiler_is_installed)
   older versions of ifort have commands like  fortvars.(c)sh intel64|ia32 and mklvars{em64t|32}.(c)sh)
   into your .bashrc | .cshrc startup file.
c) STOP and install ifort+mkl for your platform (or an alternate compiler)

continue or stop (c/s)
```

Type `c` and press enter.
Wait a bit and press enter again.

```
   **************************************************************************
   *                            Specify a system                            *
   **************************************************************************

   Current system is: unknown

     LI   Linux (Intel ifort compiler (12.0 or later)+mkl+intelmpi))
     LS   Linux+SLURM-batchsystem (Intel ifort (12.0 or later)+mkl+intelmpi)
     LG   Linux (gfortran + gcc (version 6 or higher) + OpenBlas)

     M    show more, not updated older options (not recommended)
```

Type `LG` and press enter.
Wait a bit and press enter again.

```
   ***********************************************************************
   *                          Specify compilers                          *
   ***********************************************************************
     Recommended setting for f90 compiler: gfortran
     Current selection (for current default just press ENTER):   gfortran

     Your compiler: 
```

Type `gfortran` and press enter.

```
     Changing Compiler to gfortran
     Recommended setting for C compiler: gcc
     Current selection (default):   cc

     Your compiler: 
```

Type `gcc` and press enter.

```
   ***********************************************************************
   *                 Specify compiler and linker options                 *
   ***********************************************************************

PLEASE NOTE: Best performance can be obtained with processor specific options.
Very important for speed-up is an optimized BLAS (like mkl, OpenBlas, essl, ..)
instead of the simple "-lblas_lapw"

For more info see  http://www.wien2k.at/reg_user/faq

searching ...

for performance reasons make sure you use  gcc 6.x version (or later).

find: '/usr/lib64': No such file or directory
You have the following OpenBlas libraries in /opt /usr/lib or /usr/lib64
and must select one of them in the R_LIBS:

/usr/lib/aarch64-linux-gnu/libopenblas64.so.0
/usr/lib/aarch64-linux-gnu/libopenblas64.a
/usr/lib/aarch64-linux-gnu/openblas64-openmp/libopenblas64.so.0
/usr/lib/aarch64-linux-gnu/openblas64-openmp/libopenblas64.a
/usr/lib/aarch64-linux-gnu/openblas64-openmp/libopenblas64p-r0.3.20.so
/usr/lib/aarch64-linux-gnu/openblas64-openmp/libopenblas64p-r0.3.20.a
/usr/lib/aarch64-linux-gnu/openblas64-openmp/libopenblas64.so
/usr/lib/aarch64-linux-gnu/libopenblas64.so
find: '/usr/lib64': No such file or directory

ATTENTION:
You do not have valid suffixes for the linker (.so or .a).
Please take care to not use -lopenblas, but specify the full path
and the fullname of your library, e.g. use:
/your/openblas/library/path/libopenblas.so.0

Hit Enter to continue
```

Nothing to do here yet, we'll come back and specify the openblas libraries later.

```
   **********************************************************************
   *                       Specify LIBXC settings                       *
   **********************************************************************
    echo "The current wien2k version supports an interface to libxc-5.1.2"
    echo "If you have libxc-5.0.0 you must copy manually in SRC_lapw0"
    echo "libxc.F_libxc5.0 libxc_mod.F_libxc5.0 and inputpars.F_libxc5.0"
    echo "to their default names."

 Would you like to use LIBXC (needed ONLY for self-consistent gKS mGGA calculations, for the stress tensor and experts who want to play with different DFT options. It must have been installed before)? (y,N):

```

Type `y` and press enter.

```
 To abort the LIBXC setup enter 'x' at any point!

 Do you want to automatically search for LIBXC installations? (Y,n):
```

Type `n` and press enter.

```
 Please enter the root-directory of your LIBXC-installation!:
```

Copy-paste `/home/aiida/src/libxc-6.2.2` and press enter.

```
 Please enter the lib-directory of your LIBXC-installation (usually lib or lib64)!:
```

Type `lib` and press enter.

```
   ********************************************************************
   *                          LIBXC Summary                           *
   ********************************************************************


 Your LIBXC options are:    -DLIBXC -I/home/aiida/src/libxc-6.2.2/include/
 Your LIBXC libraries are:  -L/home/aiida/src/libxc-6.2.2/lib// -lxcf03 -lxc

 NOTE that we assumed the names of the necessary libraries to be:
    xc     and
    xcf03  (Fortran interface).

 If in your LIBXC version those libraries have different names, please
 change LIBXC_LIBNAME and LIBXC_FORTRAN manually to the correct ones!

     Press RETURN to continue
```

All good!
Press enter.

```
   *********************************************************************
   *                       Specify FFTW settings                       *
   *********************************************************************

 We need a FFTW3 library, which must be installed on your system !
 To abort the FFTW setup enter 'x' at any point!

 Do you want to automatically search for FFTW installations? (Y,n):
```

Type `n` and press enter.

```
 Your present FFTW choice is: FFTW3

 Present FFTW root directory is:
 Please specify the path of your FFTW installation (like /opt/fftw3/) or accept present choice (enter):
```

Copy-paste `/home/aiida/src/fftw-3.3.10` and press enter.

```
 The present target architecture of your FFTW library is: lib64
 Please specify the target achitecture of your FFTW library (e.g. lib64) or accept present choice (enter):
```

Type `lib` and press enter.

```
 The present name of your FFTW library: fftw3
 Please specify the name of your FFTW library or accept present choice (enter):
```

Press enter.

```
  ********************************************************************
  *                           FFTW Summary                           *
  ********************************************************************


  No OMP parallel version of your FFTW library could be found. Installing
  it would improve the performance of some programs (lapw0, lapw2, 3ddens).

  Your FFTW_OPT are:   -DFFTW3 -I/home/aiida/src/fftw-3.3.10/include
  Your FFTW_LIBS are:  -L/home/aiida/src/fftw-3.3.10/lib -lfftw3

  These options derive from your chosen settings:

  FFTWROOT:            /home/aiida/src/fftw-3.3.10/
  FFTW_VERSION:        FFTW3
  FFTW_LIB:            lib
  FFTW_LIBNAME:        fftw3
  Is this correct? (Y,n):
```

Type `Y` and press enter.
Now you'll wind up in the "Compiler and linker options" menu:

```
 ***********************************************************************
 *                     Compiler and linker options                     *
 ***********************************************************************


 Recommended options for system linuxgfortran are:
      OpenMP switch:           -fopenmp
      Compiler options:        -ffree-form -O2 -ftree-vectorize -march=native -ffree-line-length-none -ffpe-summary=none
      Linker Flags:            $(FOPT) -L../SRC_lib
      Preprocessor flags:      '-DParallel'
      R_LIB (LAPACK+BLAS):     /usr/lib64/libopenblas_openmp.so.0 -lpthread

 Current settings:
  M   OpenMP switch:           -fopenmp
  O   Compiler options:        -ffree-form -O2 -ftree-vectorize -march=native -ffree-line-length-none -ffpe-summary=none
  L   Linker Flags:            $(FOPT) -L../SRC_lib
  P   Preprocessor flags       '-DParallel'
  R   R_LIBS (LAPACK+BLAS):    /usr/lib64/libopenblas_openmp.so.0 -lpthread
  F   FFTW options:            -DFFTW3 -I/home/aiida/src/fftw-3.3.10/include
      FFTW-LIBS:               -L/home/aiida/src/fftw-3.3.10/lib -lfftw3
  X   LIBX options:            -DLIBXC -I/home/aiida/src/libxc-6.2.2/include
      LIBXC-LIBS:              -L/home/aiida/src/libxc-6.2.2/lib/ -lxcf03 -lxc

  S   Save and Quit

      To change an item select option.
Selection:
```

Since we couldn't specify it before, we'll go back and set the `R_LIBS`.
Type `R` and press enter.
The prompt will ask for the "Real libraries":

```
Selection: R
     Real libraries=
```

Copy paste 

`/usr/lib/aarch64-linux-gnu/openblas64-openmp/libopenblas64.so.0 -lpthread`

and press enter.
Next, press `S` to save and quit and press enter.

```
   ***********************************************************************
   *                     Configure parallel execution                    *
   ***********************************************************************

   These options are stored in WIEN2k_parallel_options of your WIENROOT.
   You can change them later manually or with siteconfig.

   If you have only ONE multi-core node (ONE shared memory system) it is normally
   better to start jobs in the background rather than using remote commands.
   If you select a shared memory system WIEN will by default not use remote
   shell commands (USE_REMOTE and MPI_REMOTE = 0 in WIEN2k_parallel_options) and
   set the default granularity to 1.

   You still can override this default granularity in your .machines file.

   You may also set a specific TASKSET command to bind your executables to a
   specific core on multicore machines.

  If you have A SINGLE shared memory parallel computers answer next question with Y
  If you have A CLUSTER OF shared memory parallel computers answer next question with N
  Shared Memory Architecture? (y/N):
```

Type `y` and press enter.

```
  Do you know/need a command to bind your jobs to specific nodes?
  (like taskset -c). Enter N / your_specific_command:
```

Type `N` and press enter.

```
   ***********************************************************************
   *                      (Re-)Dimension parameters                      *
   ***********************************************************************

WIEN2k uses dynamical allocation of most arrays according to the requirements of
your example. However, to avoid that the programs grow larger than the memory of
your computer, there are two limiting parameters, NMATMAX (the maximum matrix
size) and NUME (number of eigenvalues), which should be set corresponding to your
hardware.

A matrix of 20000x20000 requires 4 (8) Gb of memory for a single lapw1 (using 10
(20) bytes for real (complex) numbers to account for overheads).

Thus set NMATMAX to  sqrt(MEMORY/10)  (MEMORY in Bytes)!

NMATMAX=20000 ==>   4GB (real) (==> cells with about 50-150 atoms/unitcell)
    ==> for lapw1c:    NMATMAX will be reduced internally to NMATMAX/sqrt2
    ==> for lapw1_mpi: NMATMAX will be increased internally to NMATMAX*sqrt(NP)

NUME determines the number of states to output. As a rule of thumb one can estimate
100 basis functions per atom in the cell and 10 occupied states per atom, so set

NUME=NMATMAX/10!

The present values are:
      PARAMETER          (NMATMAX=   29000)
      PARAMETER          (NUME=   6000)

    Change parameters in:

    1   lapw1/2  (e.g. NMATMAX, NUME, RESTRICT_OUTPUT)
    A   all programs (usually not necessary)

    Q   to quit

     Selection:
```

Type `Q` and press enter.

```

   ***********************************************************************
   *                      Compile/Recompile programs                     *
   ***********************************************************************

     A   Compile all programs (suggested)

     Q   Quit

     Selection:
```

Type `A` and press enter.
Wait for the compilation to complete, this can take a while.
Once it's done, you should see no compile errors, simply press enter to move to the next step.

```
   **************************************************************************
   *                                Perl Path                               *
   **************************************************************************

   Specify the path of the perl program.

   The default is:          /usr/bin/perl

   The current path is:     /usr/bin/perl

   Please enter the full path of the perl program:
```

Here the default is fine.
Press enter twice.


```
   **************************************************************************
   *                                Temp Path                               *
   **************************************************************************

   Specify the path to a directory, where temporary files can be stored.

   The default is:          /tmp

   The current path is:     /tmp

 Please enter the full path to your temporary directory:
```

Unless you want to change it, press enter.

And we're done!

```
    ***********************************************************************
    *                                WIEN 2k                              *
    *                          site configuration                         *
    ***********************************************************************

   Please check in SRC_*/compile.msg if any serious errors were encountered
   during compilation. In case of errors fix the compiler options, check the
   system configuation, and rerun ./siteconfig_lapw.

   If no errors occured, your WIEN2k site is now configured.

   The options you specified during this procedure (compilers, flags, paths)
   are saved in files in your WIENROOT directory (WIEN2k_MPI, WIEN2k_OPTIONS,
   WIEN2k_SYSTEM, and WIEN2k_COMPILER). You can modify them there directly,
   however, in that case, you have to use siteconfig again to accordingly
   adapt the Makefiles (just enter the corresponding menu and save changes).

   To setup the environment for WIEN users, each user should execute:
   /home/aiida/src/WIEN2k/userconfig_lapw !


   We wish you GOOD LUCK with your calculations.

   Your friendly WIEN2k Team
```

Well, at least with the compilation.
Now run `/home/aiida/src/WIEN2k/userconfig_lapw`.

```
   *********************************************************"
   *                        WIEN 2k                        *"
   *                  user configuration                   *"
   *********************************************************"
     Last configuration: Tue Aug 29 06:47:23 UTC 2023
                      Wien Version: WIEN2k_23.2 (Release 9/3/2022)
                      System: linuxgfortran

     Setting up user: aiida
     Home directory:  /home/aiida
     Shell:           bash

     Specify your prefered editor (default is emacs):
     editor shall be:
```

Choose your favorite editor and press enter, then `Y`.

```
     Specify your prefered DATA directory, where your cases should be
     stored (for  /home/aiida/WIEN2k, just enter RETURN key):
     DATA directory:
```

Unless you want to change it, press enter, then `Y`. 

```
     Specify your prefered scratch directory, where big case.vector files
     can be stored (Recommended is a local directory (maybe /scratch), not a
     NFS directory. For your working directory, just enter RETURN key):
     scratch directory:
```

Type `/home/aiida/scratch` and press enter, then `Y`.

```
     Specify your program to read pdf files (default is okular)
     (on some Linux systems use xpdf, evince, pdfstudio, ...):evince

     Set PDFREADER to  evince (Y/n)
```

Not sure what to pick here.
I just typed `evince` and then enter, then `Y`.

```
WIEN2k can use OpenMP parallelization on multicore computers.
For details please read the "Parallelization section" of the Usersguide.
Your present computer has  cores, but more than 4 (8) cores is useless.
How many cores do you want to use by default (4):1

     Set OMP_NUM_THREADS to  1 (Y/n) Y
```

As shown above, I selected `1` core and then `Y`.

```


!!!  The following lines will be added to your .bashrc file if you continue !!!
     A copy of your current .bashrc will be saved under  .bashrc.savelapw !

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
```

Type `Y` and press enter.

```
     If you want to use k-point parallel execution on a non-shared memory
     system, you must be able to login without specifying a password.
     When using   rsh  you should modify your .rhosts file, if you are
     using   ssh  you must generate (ssh-keygen) and transfer your  "public keys".

     Edit .rhosts file now? (y/N)
```

Type `N` and press enter.

```   *********************************************************
   *                        WIEN 2k                        *
   *                  user configuration                   *
   *********************************************************


   Your user environment for WIEN users is now configured.

   You have to restart your shell before the changes come
   into effect (execute: . ~/.bashrc).

   Start "w2web", define "user/password" and select a port. Then point
   your web-browser to the proper address:PORT.

   We wish you GOOD LUCK with your calculations.
   Your WIEN2k Team
```

And we're done!

## TODO: Common workflows instructions

```
aiida-common-workflows launch relax -r none -S Al -p moderate wien2k
```
