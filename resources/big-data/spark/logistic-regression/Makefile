all: clean clean-out run
run:	
	sbt compile
	time sbt run > res.stdout 2> res.stderr
clean-out:
	rm -rf ../../out/test_pred_logreg_spark
clean:
	sbt clean
	rm -rf res*
clean-project:
	sbt clean
	rm -rf project target metastore_db derby.log spark-warehouse
	rm -rf res*
