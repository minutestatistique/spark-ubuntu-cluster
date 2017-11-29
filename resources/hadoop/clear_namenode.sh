rm -Rf /usr/local/hadoop/tmp
cd $HADOOP_HOME/hdfs
rm -r datanode/
rm -r namenode/
$HADOOP_HOME/bin/hdfs namenode -format
