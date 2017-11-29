# script variables
VAGRANT_HOME="/home/vagrant"
DOWNLOAD="Yes"

SPARK_LNK="https://d3kbcqa49mib13.cloudfront.net/spark-2.2.0-bin-hadoop2.7.tgz"
SPARK_ARCH="$(echo "$SPARK_LNK" | rev | cut -d/ -f1 | rev)"
SPARK=${SPARK_ARCH/.tgz/""}

SBT_LNK="https://github.com/sbt/sbt/releases/download/v1.0.1/sbt-1.0.1.tgz"
SBT_ARCH="$(echo "$SBT_LNK" | rev | cut -d/ -f1 | rev)"
SBT=${SBT_ARCH/.tgz/""}

HADOOP_LNK="http://apache.crihan.fr/dist/hadoop/common/hadoop-2.7.4/hadoop-2.7.4.tar.gz"
HADOOP_ARCH="$(echo "$HADOOP_LNK" | rev | cut -d/ -f1 | rev)"
HADOOP=${HADOOP_ARCH/.tar.gz/""}

# update
sudo apt-get -y update

# install vim
sudo apt-get install -y vim htop r-base

# install jdk8
sudo apt-get install -y software-properties-common python-software-properties
sudo add-apt-repository -y ppa:openjdk-r/ppa
sudo apt-get update
sudo apt-get install -y openjdk-8-jdk

# SPARK DOWNLOAD
#-------------------------------------------------------------------------------
# get spark and unzip
if [ $DOWNLOAD = "Yes" ]
then
	sudo wget $SPARK_LNK
else
	sudo cp /vagrant/resources/$SPARK_ARCH $VAGRANT_HOME
fi
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

# SBT DOWNLOAD
#-------------------------------------------------------------------------------
# get sbt and unzip
if [ $DOWNLOAD = "Yes" ]
then
	sudo wget $SBT_LNK
else
	sudo cp /vagrant/resources/$SBT_ARCH $VAGRANT_HOME
fi
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

# HADOOP DOWNLOAD
#-------------------------------------------------------------------------------
# get hadoop and unzip
if [ $DOWNLOAD = "Yes" ]
then
	sudo wget $HADOOP_LNK
else
	sudo cp /vagrant/resources/$HADOOP_ARCH $VAGRANT_HOME
fi
sudo tar -xzf $HADOOP_ARCH
sudo rm -rf $HADOOP_ARCH
sudo ln -s $HADOOP hadoop

# fix permission
sudo chown -R vagrant $HADOOP
sudo chgrp -R vagrant $HADOOP
sudo chown -R vagrant hadoop
sudo chgrp -R vagrant hadoop

cat >> $VAGRANT_HOME/.bashrc <<- EOF

# hadoop
export HADOOP_HOME="$VAGRANT_HOME/$HADOOP/"
export PATH=\$PATH:\$HADOOP_HOME/bin

EOF

# SPARK CONF
#-------------------------------------------------------------------------------
# log settings
sudo cp /vagrant/resources/spark/log4j.properties $VAGRANT_HOME/spark/conf
sudo chown -R vagrant:vagrant $VAGRANT_HOME/spark/conf/log4j.properties

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

# HADOOP CONF
#-------------------------------------------------------------------------------
#core-site
#sudo sed 's/master/192\.168\.100\.101/g' /vagrant/resources/hadoop/core-site.xml\
#	> $VAGRANT_HOME/hadoop/etc/hadoop/core-site.xml
sudo cp /vagrant/resources/hadoop/core-site.xml $VAGRANT_HOME/hadoop/etc/hadoop/
sudo chown -R vagrant:vagrant $VAGRANT_HOME/hadoop/etc/hadoop/core-site.xml

# hdfs-site
sudo cp /vagrant/resources/hadoop/hdfs-site.xml $VAGRANT_HOME/hadoop/etc/hadoop/
sudo chown -R vagrant:vagrant $VAGRANT_HOME/hadoop/etc/hadoop/hdfs-site.xml

#mapred-site
sudo cp /vagrant/resources/hadoop/mapred-site.xml $VAGRANT_HOME/hadoop/etc/hadoop/
sudo chown -R vagrant:vagrant $VAGRANT_HOME/hadoop/etc/hadoop/mapred-site.xml

#yarn-site
sudo cp /vagrant/resources/hadoop/yarn-site.xml $VAGRANT_HOME/hadoop/etc/hadoop/
sudo chown -R vagrant:vagrant $VAGRANT_HOME/hadoop/etc/hadoop/yarn-site.xml

#yarn-default
sudo cp /vagrant/resources/hadoop/yarn-default.xml $VAGRANT_HOME/hadoop/etc/hadoop/
sudo chown -R vagrant:vagrant $VAGRANT_HOME/hadoop/etc/hadoop/yarn-default.xml


# hadoop environment
sudo sed -i 's/\${JAVA_HOME}/\/usr\/lib\/jvm\/java-8-openjdk-amd64/g' $VAGRANT_HOME/hadoop/etc/hadoop/hadoop-env.sh
sudo chown -R vagrant:vagrant $VAGRANT_HOME/hadoop/etc/hadoop/hadoop-env.sh

# masters file
rm -rf $VAGRANT_HOME/hadoop/etc/hadoop/masters
#echo "${3}1" >> $VAGRANT_HOME/hadoop/etc/hadoop/masters
echo "hadoop-master" >> $VAGRANT_HOME/hadoop/etc/hadoop/masters
sudo chown -R vagrant:vagrant hadoop/etc/hadoop/masters

# slaves file
rm -rf $VAGRANT_HOME/hadoop/etc/hadoop/slaves

echo "hadoop-master" > $VAGRANT_HOME/hadoop/etc/hadoop/slaves
for i in `seq 2 $2`;
do
	echo "hadoop-slave-$(($i-1))" >> $VAGRANT_HOME/hadoop/etc/hadoop/slaves
done

sudo chown -R vagrant:vagrant $VAGRANT_HOME/hadoop/etc/hadoop/slaves

# TODO re-organize
mkdir -p $VAGRANT_HOME/hadoop_work/hdfs/datanode $VAGRANT_HOME/hadoop_work/yarn/local\
	$VAGRANT_HOME/hadoop_work/yarn/log\
	$VAGRANT_HOME/hadoop_work/hdfs/namenode $VAGRANT_HOME/hadoop_work/hdfs/namesecondary

# NETWORK CONF
#-------------------------------------------------------------------------------
sudo mv /etc/hosts /etc/hosts_bk
echo "127.0.0.1 localhost" > hosts
echo "${3}1 hadoop-master" >> hosts
	for i in `seq 2 $2`;
do
	echo "${3}${i} hadoop-slave-$(($i-1))" >> hosts
done
sudo mv hosts /etc/hosts

# CLEAR DATANODE AFTER FAILURE 
#-------------------------------------------------------------------------------
sudo cp /vagrant/resources/hadoop/clear_datanode.sh $VAGRANT_HOME/
sudo chmod a+x vagrant:vagrant $VAGRANT_HOME/clear_datanode.sh

# FORMAT NAMENODE AFTER FAILURE
# ------------------------------------------------------------------------------
sudo cp /vagrant/resources/hadoop/clear_namenode.sh $VAGRANT_HOME/
sudo chmod a+x vagrant:vagrant $VAGRANT_HOME/clear_namenode.sh

# SSH CONF
#-------------------------------------------------------------------------------
# copy ssh config
cp /vagrant/resources/ssh/config $VAGRANT_HOME/.ssh
sudo chown -R vagrant:vagrant $VAGRANT_HOME/.ssh/config

# passwordless ssh to slaves
# private key is only required in master
if [ $1 -eq "1" ]; then
	cp /vagrant/resources/ssh/id_dsa $VAGRANT_HOME/.ssh
	sudo chown vagrant:vagrant $VAGRANT_HOME/.ssh/id_dsa
	sudo chmod 600 $VAGRANT_HOME/.ssh/id_dsa
fi
# public key on all slaves
cat /vagrant/resources/ssh/id_dsa.pub >> $VAGRANT_HOME/.ssh/authorized_keys

# GENERAL CONF
#-------------------------------------------------------------------------------
echo "set nocompatible" > $VAGRANT_HOME/.vimrc
sudo chown vagrant:vagrant $VAGRANT_HOME/.vimrc

# BASH CONF
#-------------------------------------------------------------------------------
echo "# hadoop
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH=\$PATH:\$JAVA_HOME/bin
export HADOOP_HOME=$VAGRANT_HOME/hadoop
export PATH=\$PATH:\$HADOOP_HOME/bin
export PATH=\$PATH:\$HADOOP_HOME/sbin
export HADOOP_MAPRED_HOME=\$HADOOP_HOME
export HADOOP_COMMON_HOME=\$HADOOP_HOME
export HADOOP_HDFS_HOME=\$HADOOP_HOME
export YARN_HOME=\$HADOOP_HOME
export HADOOP_CONF_DIR=\$HADOOP_HOME/etc/hadoop
export YARN_CONF_DIR==\$HADOOP_HOME/etc/hadoop
export HADOOP_COMMON_LIB_NATIVE_DIR=\$HADOOP_HOME/lib/native
export HADOOP_OPTS=\"-Djava.library.path=\$HADOOP_HOME/lib\"
export CLASSPATH=\$CLASSPATH:$VAGRANT_HOME/hadoop/lib/*:.
export HADOOP_OPTS=\"\$HADOOP_OPTS -Djava.security.egd=file:/dev/../dev/urandom\"
" >> $VAGRANT_HOME/.bashrc
source $VAGRANT_HOME/.bashrc
