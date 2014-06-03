#!/usr/bin/python

import fileinput
import string
from nltk import FreqDist
from nltk.tokenize import RegexpTokenizer

replace_punctuation = string.maketrans(string.punctuation, ' '*len(string.punctuation))
cleaned_input = ""
for line in fileinput.input():
    line=line.strip()
    line=line.translate(replace_punctuation)
    cleaned_input += line + " "

tokenizer = RegexpTokenizer(r'\w+')
freq = FreqDist(tokenizer.tokenize(cleaned_input))
for k in freq.keys()[:50]:
    print "%s\t%s" % (k, freq[k]) 

