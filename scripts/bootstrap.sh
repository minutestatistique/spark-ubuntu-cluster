# script variables
VAGRANT_HOME="/home/vagrant"

SPARK_LNK="https://d3kbcqa49mib13.cloudfront.net/spark-2.2.0-bin-hadoop2.7.tgz"
SPARK_ARCH="$(echo "$SPARK_LNK" | rev | cut -d/ -f1 | rev)"
SPARK=${SPARK_ARCH/.tgz/""}

SBT_LNK="https://github.com/sbt/sbt/releases/download/v1.0.1/sbt-1.0.1.tgz"
SBT_ARCH="$(echo "$SBT_LNK" | rev | cut -d/ -f1 | rev)"
SBT=${SBT_ARCH/.tgz/""}

# update
sudo apt-get -y update

# install vim
sudo apt-get install -y vim htop r-base

# install jdk8
sudo apt-get install -y software-properties-common python-software-properties
sudo add-apt-repository -y ppa:openjdk-r/ppa
sudo apt-get update
sudo apt-get install -y openjdk-8-jdk

# get spark and unzip
sudo wget $SPARK_LNK
sudo tar -xzf $SPARK_ARCH
sudo rm -rf $SPARK_ARCH
sudo ln -s $SPARK spark

# fix permission
sudo chown -R vagrant $SPARK
sudo chgrp -R vagrant $SPARK
sudo chown -R vagrant spark
sudo chgrp -R vagrant spark

cat >> $VAGRANT_HOME/.bashrc <<- EOF

# spark
export SPARK_HOME="$VAGRANT_HOME/$SPARK/"
export PATH=\$PATH:\$SPARK_HOME/bin

EOF

# get sbt and unzip
sudo wget $SBT_LNK
sudo tar -xzf $SBT_ARCH
sudo rm -rf $SBT_ARCH

# fix permission
sudo chown -R vagrant sbt
sudo chgrp -R vagrant sbt

cat >> $VAGRANT_HOME/.bashrc <<- EOF

# sbt
export SBT_HOME="$VAGRANT_HOME/sbt/"
export PATH=\$PATH:\$SBT_HOME/bin

EOF

# log settings
sudo cp /vagrant/resources/log4j.properties spark/conf

sudo chown -R vagrant:vagrant spark/conf/log4j.properties

# spark environment
echo "#!/usr/bin/env bash
SPARK_MASTER_HOST=${3}1
SPARK_LOCAL_IP=${3}${1}
" > $VAGRANT_HOME/spark/conf/spark-env.sh

sudo chown -R vagrant:vagrant $VAGRANT_HOME/spark/conf/spark-env.sh

# slaves file
rm -rf $VAGRANT_HOME/spark/conf/slaves
for i in `seq 2 $2`;
do
	echo "${3}${i}" >> $VAGRANT_HOME/spark/conf/slaves
done

sudo chown -R vagrant:vagrant $VAGRANT_HOME/spark/conf/slaves


# copy ssh config
cp /vagrant/resources/config $VAGRANT_HOME/.ssh
sudo chown -R vagrant:vagrant $VAGRANT_HOME/.ssh/config

# passwordless ssh to slaves
# private key is only required in master
if [ $1 -eq "1" ]; then
	cp /vagrant/resources/id_dsa $VAGRANT_HOME/.ssh
	sudo chown vagrant:vagrant $VAGRANT_HOME/.ssh/id_dsa
	sudo chmod 600 $VAGRANT_HOME/.ssh/id_dsa
fi
# public key on all slaves
cat /vagrant/resources/id_dsa.pub >> $VAGRANT_HOME/.ssh/authorized_keys


echo "set nocompatible" > $VAGRANT_HOME/.vimrc
sudo chown vagrant:vagrant $VAGRANT_HOME/.vimrc

