#!/usr/bin/env python

import fileinput
import string

from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.cluster import KMeans
from scipy.misc import factorial

#Pandas depends on matplotlib - set up a temp dir for config 
import os
import tempfile
os.environ['MPLCONFIGDIR'] = tempfile.mkdtemp()
from pandas import DataFrame

def run_kmeans(dataset, max_iterations=100, num_clusters=10, num_seeds=10):
    vectorizer = TfidfVectorizer(stop_words='english', use_idf=True)
    feature_vectors = vectorizer.fit_transform(dataset["content"])
    km = KMeans(n_clusters=num_clusters, init='k-means++', 
                         max_iter=max_iterations, n_init=num_seeds, verbose=0)
    clusters = km.fit_predict(feature_vectors)
    result = DataFrame(dataset, columns = ["topic", "article_id"])
    result["cluster_id"] = clusters
    return result

        
replace_punctuation = string.maketrans(string.punctuation, ' '*len(string.punctuation))
current_topic = ""
dataset = []
for line in fileinput.input():
    line = line.strip()
    fields = line.split('\t')
    content = fields[2].translate(replace_punctuation)
    if not current_topic:
        current_topic = fields[0]
    elif current_topic != fields[0]:
        clusters = run_kmeans(DataFrame(dataset))
        print(DataFrame.to_string(clusters, header = False, index = False))
        current_topic = fields[0]
        dataset[:] = []
    dataset.append({"topic": fields[0], "article_id": fields[1], 
                    "content": content})
clusters = run_kmeans(DataFrame(dataset))
print(DataFrame.to_string(clusters, header = False, index = False))
