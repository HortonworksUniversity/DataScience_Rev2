#! /usr/lib/spark/bin/pyspark

from pyspark import SparkContext
from pyspark import SparkConf
from pyspark.mllib.clustering import KMeans
from numpy import array
from math import sqrt
import os

#Run locally - uncomment out the 2 lines below 
#os.environ['SPARK_YARN_MODE'] = "false"
#sc = SparkContext("local", "KMeans")
#Run on YARN (uncomment line below)
sc = SparkContext("yarn-client", "KMeans")

# Load and parse the data
data = sc.textFile("hdfs://namenode:8020/user/root/kmeans_data.txt")
parsedData = data.map(lambda line: array([float(x) for x in line.split(' ')]))

# Build the model (cluster the data)
clusters = KMeans.train(parsedData, 2, maxIterations=10,
        runs=30, initializationMode="random")
print "Cluster centers = %s" % clusters.centers

# Evaluate clustering by computing Within Set Sum of Squared Errors
def error(point):
    center = clusters.centers[clusters.predict(point)]
    return sqrt(sum([x**2 for x in (point - center)]))

WSSSE = parsedData.map(lambda point: error(point)).reduce(lambda x, y: x + y)
print("Within Set Sum of Squared Error = " + str(WSSSE))
