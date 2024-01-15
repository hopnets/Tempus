# Tempus: Probabilistic Network Latency Verification

This repository provides the instructions and files required to run the experiments in our paper. 
We used Julia to implement Tempus and ran our experiments on Ubuntu machines (version: 18.04) so all the commands in this repository are for Ubuntu.
To run the experiments, you should follow the following steps:

* [Step 1: Installing Julia](#step-1-installing-dependencies) (~ 10 minutes)
* [Step 2: Cloning the repository](#step-3-cloning-the-repository) (~ 5 minutes)
* [Step 3: Installing the dependencies](#step-1-installing-dependencies) (~ 5 minutes)
* [Step 4: Running the experiments](#step-1-installing-dependencies) (This step can take from a few hours to a few days depending on the experiments that you run)


## Step 1: Installing Julia

For our experiments, we use Julia version 1.7.3. To install it, run the following commands:

```
wget https://julialang-s3.julialang.org/bin/linux/x64/1.7/julia-1.7.3-linux-x86_64.tar.gz
tar zxvf julia-1.7.3-linux-x86_64.tar.gz
```
For the next line, we are assuming that you have extracted Julia in $HOME. If this is not true, replace $HOME with the path you have extracted the Julia files to.

```
echo "export PATH=$HOME/julia-1.7.3/bin:\$PATH" >> ~/.bashrc
source ~/.bashrc
```

To verify that Julia is installed, run ```julia --version```. Expected output:

```
julia version 1.7.3
```

## Step 2: Cloning the repository

To clone the repository, run the following script:

```
git clone https://github.com/hopnets/Tempus.git
```

## Step 3: Installing the dependencies

We provide a shell script (```install_pkg.sh```) for installing the dependencies. To run the script, please execute the following command:

```
bash install_pkg.sh
```

