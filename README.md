# D2PC

This repository includes code implementing of D2PC, Carousel, OCC-Store(OCC+2PC), and 2PL-Store(2PC+2PC). Both approaches support geo-distributed transaction processing.

The code is based on TAPIR, the SOSP 2015 paper, ["Building Consistent Transactions with
Inconsistent Replication."](http://dl.acm.org/authorize?N93281).

The repo is structured as follows:

- /lib - the transport library for communication between nodes. This
  includes UDP based network communcation as well as the ability to
  simulate network conditions on a local machine, including packet
  delays and reorderings.

- /replication - replication library for the distributed stores
  - /lr - implementation of leader based replication protocol
  - /commit - implementation of co-coordinators

- /store - partitioned/sharded distributed store
  - /common - common data structures, backing stores and interfaces for all of stores
  - /strongstore - implementation of both an OCC-based and locking-based 2PC transactional
  storage system, designed to work with LR

## Compiling & Running
You can compile all of the D2PC executables by running make in the root directory

D2PC depends on protobufs, libevent and openssl, so you will need the following development libraries:
- libprotobuf-dev
- libevent-openssl
- libevent-pthreads
- libevent-dev
- libssl-dev
- protobuf-compiler

# Deployment

## Environment
We run our code on Ubuntu20.04.

```
sudo apt install -y libprotobuf-dev libevent-dev libssl-dev protobuf-compiler libevent-dev openssl libssl-dev

git clone https://github.com/shenweihai1/D2PC.git

# 1. install protobuf
cd ~
wget https://github.com/protocolbuffers/protobuf/releases/download/v3.13.0/protobuf-all-3.13.0.tar.gz
tar -zxvf protobuf-all-3.13.0.tar.gz
cd protobuf-3.13.0/
./configure --prefix=/usr/local/protobuf
make -j$(nproc) 
make -j$(nproc) install

# 2. install libevent
cd ~
wget https://github.com/libevent/libevent/releases/download/release-2.1.8-stable/libevent-2.1.8-stable.tar.gz
tar -xzvf libevent-2.1.8-stable.tar.gz
cd libevent-2.1.8-stable
./configure --prefix=/usr/local/libevent
make -j$(nproc) 
make -j$(nproc) install

# 3. install googletest
cd ~
wget -O googletest-release-1.8.1.tar.gz https://github.com/google/googletest/archive/refs/tags/release-1.8.1.tar.gz 
tar -xzvf googletest-release-1.8.1.tar.gz
cd googletest-release-1.8.1
cmake ./
make -j$(nproc) 
make -j$(nproc) install


# 4. Compile D2PC
cd D2PC
```

## Compile
```
cd D2PC
make
```

## Run
```
1. cd D2PC/store/tools/
2. modify config files.
    for example, if there are 3 shards, there should be shard0.config, shard1.config, shard2.config, in each file, configure the replicas of this shard.
    An additional configuration for co-coordinators is needed, named shard.coor.config.
3. run key_generator.py to generate keys
4. modify run-test.sh
    set tpcmode as 'parallel'
    set mode as 'occ'
    set store as 'strongstore'
    set client as 'retwisClient'
    set keypath as the location of generated keys.

    you can configure others as you need, including:
    shard number: nshards
    replica number per shard: nreplica
    clients number: nclient
    run time: rtime
5. ./run-test.sh
```

