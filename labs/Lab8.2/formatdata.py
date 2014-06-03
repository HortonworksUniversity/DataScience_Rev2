#! /usr/bin/env python

import string
import avro.schema
import tarfile
import os
import re
import argparse
import dateutil.parser as parser
from avro.datafile import DataFileWriter
from avro.io import DatumWriter
from email.utils import parseaddr

_HEADER_RE = re.compile(r'(\S+):\s*(.*$)')
_DATE_SUFFIX_RE = re.compile(r'(.+)\s*$')

def strip_extract_newsgroup_header(text):
    before, _blankline, after = text.partition('\n\n')
    header_text = before.splitlines(True)
    header = {}
    
    # Only extract the Date, Newsgroups, Lines, Subject, and Distribution headers
    for line in header_text:
        m = _HEADER_RE.match(line)
        if not m:
            continue
        key = m.group(1)
        if key and key == "Date":
            header[key] = parser.parse(re.sub(_DATE_SUFFIX_RE, "", m.group(2))).isoformat()
        elif key and key == "Newsgroups":
            header[key] = m.group(2).split(",")
        elif key and key == "Lines":
            header[key] = int(m.group(2))
        elif key and key in ["Subject", "Distribution"]:
            header[key] = filter(lambda x: x in string.printable, m.group(2))
        elif key and key == "From":
            #Filter out any non-printable characters from string data, and parse the sender address
            header[key] = parseaddr(filter(lambda x: x in string.printable, m.group(2)))[1]
    
        if ("Distribution" not in header):
            header["Distribution"] = "NA"
        if ("Subject" not in header):
            header["Subject"] = "NA"
        if ("Lines" not in header):
            header["Lines"] = -1
                     
    return (header, after)


_QUOTE_RE = re.compile(r'(writes in|writes:|wrote:|says:|said:'
                       r'|^In article|^Quoted from|^\||^>)')

def strip_newsgroup_quoting(text):
    good_lines = [line for line in text.split('\n')
                  if not _QUOTE_RE.search(line)]
    return '\n'.join(good_lines)

def strip_newsgroup_footer(text):
    lines = text.strip().split('\n')
    for line_num in range(len(lines) - 1, -1, -1):
        line = lines[line_num]
        if line.strip().strip('-') == '':
            break

    if line_num > 0:
        return '\n'.join(lines[:line_num])
    else:
        return text


argparser = argparse.ArgumentParser(description = 'Convert and merge raw newsgroup data into a single Avro datafile.')
argparser.add_argument('-topic', dest = 'topic', help = 'the newsgroup topic to process', default = "")
args = argparser.parse_args()

#Each newsgroup article (message) will become a record in the output Avro data file,
#containing the header fields shown below, as well as an
#unstructured Content field containing the body text
_AVRO_SCHEMA = u"""{"namespace": "hortonworks.newsgroup",
 "type": "record",
 "name": "Message",
 "fields": [
     {"name": "articleId", "type": "int"},
     {"name": "date", "type": "string"},
     {"name": "from", "type": "string"},
     {"name": "newsgroups", "type": "string"},
     {"name": "subject", "type": ["string", "null"]},
     {"name": "lines", "type": ["int", "null"]},
     {"name": "distribution", "type": ["string", "null"]},
     {"name": "content", "type": ["string", "null"]}
 ]
}"""
_AVRO_FILE_NAME = "newsgroups.avro"

schema = avro.schema.parse(_AVRO_SCHEMA)
writer = DataFileWriter(open(_AVRO_FILE_NAME, "w"), DatumWriter(), schema)

tar = tarfile.open(u"newsgroups.tgz", 'r:gz')
print r'.*' + re.escape(args.topic) + '/(\d+)$'
_FILENAME_RE = re.compile(r'.*' + re.escape(args.topic) + '/(\d+)$')

#Walk through the newgroup files, parsing each file and writing into the target Avro datafile
for tar_info in tar:
    # We only want to process newsgroup articles, which have numeric file names. Ignore anything else
    if not _FILENAME_RE.match(tar_info.name):
        continue
    file = tar.extractfile(tar_info)
    print "Processing article %s" % (tar_info.name)

    #For the content, we want to strip out header, footer, 
    #quoted content from previous messages, 
    #and any non-printable characters.
    #We will retain a subset of header fields in the final output
    data = file.read()
    (header, data) = strip_extract_newsgroup_header(data)
    data = strip_newsgroup_quoting(data)
    data = strip_newsgroup_footer(data)
    #Filter out non-printable characters from the content
    data = filter(lambda x: x in string.printable, data)
            
    #Write header and content fields to the Avro data file for the current message
    writer.append({"articleId": int(_FILENAME_RE.match(tar_info.name).group(1)), "date": header["Date"], 
                    "newsgroups": ",".join(header["Newsgroups"]), "from": header["From"],
                    "subject": header["Subject"], "lines": header["Lines"], 
                    "distribution": header["Distribution"], "content": data})
    file.close()
writer.close()
print "Successfully created %s" % _AVRO_FILE_NAME
