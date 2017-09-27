# vagrant-apache-spark-ubuntu-standalone-cluster

## Introduction
Vagrant project to spin up a cluster of n nodes, Ubuntu 12.04 LTS 64-bit virtual machines with Apache Spark 2.2.0 (pre-built for Apache Hadoop 2.7).
Example of a 5-node cluster:
- node-1 : Spark Master (192.168.100.101)
- node-2 : Spark Slave (192.168.100.102)
- node-3 : Spark Slave (192.168.100.103)
- node-4 : Spark Slave (192.168.100.104)
- node-5 : Spark Slave (192.168.100.105)

## Prerequisites
- Vagrant 1.7 or higher.
- VirtualBox 4.3.2 or higher.

## Getting Started
1. Download and install VirtualBox.
2. Download and install Vagrant.
3. Git clone this project, and change directory into this project directory.
5. `vagrant up` to create the VM.
6. `vagrant ssh node-1` to get into your Spark master node.
7. `/home/vagrant/spark/sbin/start-all.sh` to start Spark master and all slave nodes.
8. Point your browser at `http://192.168.100.101:8080/` to visualize the Spark UI.
9. `vagrant halt` to turn off the cluster, `vagrant up` to turn it on again and `vagrant destroy` if you want to destroy and get rid it.

## Note
To avoid downloading vagrant box many times, one can manually download the box at [precise64 box](https://files.hashicorp.com/precise64.box) and put it in `box/precise64.box`. Same for [spark](https://d3kbcqa49mib13.cloudfront.net/spark-2.2.0-bin-hadoop2.7.tgz) and `resources/spark-2.2.0-bin-hadoop2.7.tgz` (in which case you have to modify `scripts/bootstrap.sh` to copy spark from `/vagrant/resources` to VM instead of using `wget`).
