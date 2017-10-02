import org.apache.spark.ml.linalg.DenseVector
import org.apache.spark.sql.functions.udf
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.DataFrame
import org.apache.spark.ml.classification.{BinaryLogisticRegressionSummary, LogisticRegression}

object LogReg {
	def main(args: Array[String]) {
		val spark = SparkSession
		.builder()
		.master("spark://192.168.100.101:7077")
		.appName("Logistic Regression example")
		.getOrCreate()

		//spark.conf.set("spark.executor.memory", "1g")

		// For implicit conversions like converting RDDs to DataFrames
		import spark.implicits._

		// Load training data
		val train = spark.read.format("libsvm").load("../../data/train_disc.libsvm")
		val test = spark.read.format("libsvm").load("../../data/test_disc.libsvm")

		val lr = new LogisticRegression()
		.setMaxIter(10)
		.setRegParam(0.3)
		.setElasticNetParam(0.8)

		// Fit the model
		val logregModel = lr.fit(train)

		// Print the coefficients and intercept for logistic regression
		println(s"Coefficients: ${logregModel.coefficients} Intercept: ${logregModel.intercept}")

		// Extract the summary from the returned LogisticRegressionModel instance trained in the earlier
		// example
		val trainSummary = logregModel.summary

		// Obtain the objective per iteration.
		val objectiveHistory = trainSummary.objectiveHistory
		println("objectiveHistory:")
		objectiveHistory.foreach(loss => println(loss))

		// Predict on test data
		val predictions = logregModel.transform(test)
		// Output predictions
		val tailValue = udf((arr: DenseVector) => arr.apply(1))
		predictions
		.withColumn("prob", tailValue(predictions("probability")))
		.select($"prediction", $"prob")
		.write
		.option("header", "true")
		.csv("../../out/test_pred_logreg_spark")

		spark.stop()
	}
}
