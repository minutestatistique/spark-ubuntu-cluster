import org.apache.spark.ml.linalg.DenseVector
import org.apache.spark.sql.functions.udf
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.DataFrame
import org.apache.spark.ml.regression.{LinearRegressionSummary, LinearRegression}

object LMReg {
	def main(args: Array[String]) {
		val spark = SparkSession
		.builder()
		.master("spark://192.168.100.101:7077")
		.appName("Linear Regression example")
		.getOrCreate()

		//spark.conf.set("spark.executor.memory", "1g")

		// For implicit conversions like converting RDDs to DataFrames
		import spark.implicits._

		// Load training data
		val train = spark.read.format("libsvm").load("../../data/train_cont.libsvm")
		val test = spark.read.format("libsvm").load("../../data/test_cont.libsvm")

		val lr = new LinearRegression()
		.setMaxIter(10)
		.setRegParam(0.3)
		.setElasticNetParam(0.8)

		// Fit the model
		val logregModel = lr.fit(train)

		// Print the coefficients and intercept for logistic regression
		println(s"Coefficients: ${logregModel.coefficients} Intercept: ${logregModel.intercept}")

		// Extract the summary from the returned LinearRegressionModel instance trained in the earlier
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
		.select($"prediction")
		.write
		.option("header", "true")
		.csv("../../out/test_pred_lm_spark")

		spark.stop()
	}
}
