#! /usr/bin/env python

import string
from email.utils import parseaddr

for_split = [',', '\n', '\t', '\'', '.', '\"', '!', '?', '-', '~', '[', ']', 
        '=', '(', ')', '\"', ':', ';', '{', '}', '<', '>']
ignored = ['Re:', 'the', 'and', 'i', 'to', 'of', 'a', 'in', 'was', 'that', 'had',
        'he', 'you', 'his','my', 'it', 'as', 'with', 'her', 'for', 'on']

@outputSchema("y:bag{t:tuple(word:chararray, wordcount:int)}")
def getTop5Words(bag):
    result = []
    i = 0
    wordcount = {}
    for record in bag:
        doc = record[0]
        for ch in for_split:
            doc = string.replace(doc, ch, ' ')
        for word in [w.lower() for w in string.split(doc)]:
            if word not in wordcount:
                wordcount[word] = 1
            else:
                wordcount[word] += 1
    for word in sorted(wordcount, key=wordcount.get, reverse=True):
        if not word in ignored and i < 5 and wordcount[word] > 1:
            tup = (word, wordcount[word])
            result.append(tup)
            i = i + 1
    return result

@outputSchema("fromEmail:chararray")
def getFromEmail(fromEmail):
    return parseaddr(fromEmail)[1]
