# WIEN2k Docker stack

This repository contains a basic Docker stack for creating an image that allows you to quickly compile and run WIEN2k.
Additionally, it sets up an AiiDA environment that installs the WIEN2k plugin and common workflow interface. 

The Docker stack was mainly set up for testing WIEN2k and its interface with the [AiiDA common workflows](https://github.com/aiidateam/aiida-common-workflows).

## Usage

### Downloading the WIEN2`k` source code

Since WIEN2k is not open source, you must first obtain the source code via a valid license, see:

http://susi.theochem.tuwien.ac.at/order/index.html

Once you have the license, download the `WIEN2k_23.2.tar` source code from the WIEN2k website.

> ❗️Important: The automated compilation of WIEN2k in this docker build _expects_ the `WIEN2k_23.2.tar` file to be in the root directory of this repository by default.

### WIEN2k container

The `wien2k` image can be built with a simple `make` command:

```
make wien2k
```

Afterwards, you can run and connect to a container based on this image using:

```
docker run -it wien2k /bin/bash
```

You can leave the container at any time using `exit`, which will stop the container.
To restart the container and connect to it afterwards, simply run:

```
docker start -ia `<CONTAINER_ID>` 
```

Where `<CONTAINER_ID>` will be returned by the `docker run` command, or can be obtained from:

```
docker container ls -a
```

### AiiDA-WIEN2k

In case you want to also run the AiiDA interface, you can build the full image using:

```
make aiida
```

And run it with a similar command as above, specifying the correct image tag:

```
docker run -it aiida-wien2k /bin/bash
```

### Testing

As the main purpose of this Docker stack is testing, you can easily do a test run from scratch for WIEN2k using the `wien2k` image with:

```
make test-wien2k
```

or do the full testrun via the common workflows using:

```
make test-aiida
```

Note that these targets will also execute the build targets mentioned above.
The outputs of the WIEN2k calculation will be in the `wien2k_run` or `aiida_run` directories, respectively.

Use `make clean` to remove the generated `run.log` and test directories.

### Using a different WIEN2k source

In case you want to use a difference WIEN2k source code than `WIEN2k_23.2.tar`, you can specify the path to the source tarball using the `WIEN2K_SOURCE` environment variable, for example:

```
make wien2k WIEN2K_SOURCE=<path/to/wien2k/tarball>
```

Where you have to replace `<path/to/wien2k/tarball>` with the (relative or absolute) path of the WIEN2k source tarball.