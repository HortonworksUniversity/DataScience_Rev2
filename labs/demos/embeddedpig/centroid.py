#! /usr/bin/env python
from java.lang import Double
from math import fabs

centroids = []
    
@outputSchema("closestCentroid:double")    
def get_closest_centroid(val, centroids_string):
    if not centroids:
        for centroid in centroids_string.split(":"):
            centroids.append(float(centroid))

    min_distance = Double.MAX_VALUE
    closest_centroid = 0
    for centroid in centroids:
        distance = fabs(centroid - float(val));
        if (distance < min_distance):
            min_distance = distance
            closest_centroid = centroid
    return closest_centroid
