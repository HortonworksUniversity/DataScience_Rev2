#! /usr/bin/env python
import sys
from math import fabs
from org.apache.pig.scripting import Pig

k = 4
tolerance = 0.01

MAX_SCORE = 4
MIN_SCORE = 0
MAX_ITERATION = 100

# initial centroid, equally divide the space
initial_centroids = ""
last_centroids = [None] * k
for i in range(k):
    last_centroids[i] = MIN_SCORE + float(i)/k*(MAX_SCORE-MIN_SCORE)
    initial_centroids = initial_centroids + str(last_centroids[i])
    if i!=k-1:
        initial_centroids = initial_centroids + ":"

P = Pig.compile("""register 'centroid.py' using jython as centroid; 
                   raw = load 'student.txt' as (name:chararray, age:int, gpa:double);
                   centroided = foreach raw generate gpa, centroid.get_closest_centroid(gpa, '$centroids') as centroid;
                   grouped = group centroided by centroid parallel 2;
                   result = foreach grouped generate group, AVG(centroided.gpa);
                   store result into 'kmoutput';
                """)

converged = False
iter_num = 0
while iter_num<MAX_ITERATION:
    Q = P.bind({'centroids':initial_centroids})
    results = Q.runSingle()
    if results.isSuccessful() == "FAILED":
        raise "Pig job failed"
    iter = results.result("result").iterator()
    centroids = [None] * k
    distance_move = 0
    # get new centroid of this iteration, caculate the moving distance with last iteration
    for i in range(k):
        tuple = iter.next()
        centroids[i] = float(str(tuple.get(1)))
        distance_move = distance_move + fabs(last_centroids[i]-centroids[i])
    distance_move = distance_move / k;
    Pig.compile("fs -rm -R kmoutput").bind().runSingle()
    print("iteration " + str(iter_num))
    print("average distance moved: " + str(distance_move))
    if distance_move<tolerance:
        sys.stdout.write("k-means converged at centroids: [")
        sys.stdout.write(",".join(str(v) for v in centroids))
        sys.stdout.write("]\n")
        converged = True
        break
    last_centroids = centroids[:]
    initial_centroids = ""
    for i in range(k):
        initial_centroids = initial_centroids + str(last_centroids[i])
        if i!=k-1:
            initial_centroids = initial_centroids + ":"
    iter_num += 1

if not converged:
    print("no convergence after " + str(iter_num) + " iterations")
    sys.stdout.write("last centroids: [")
    sys.stdout.write(",".join(str(v) for v in last_centroids))
    sys.stdout.write("]\n")
