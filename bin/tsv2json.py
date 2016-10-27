#!python

import json
import sys

if len(sys.argv) != 2:
    sys.stderr.write('Usage: tsv2json.py <tsv file>\n')
    sys.stderr.write('Convert a tsv file to a json file with each line as a json record\n')
    sys.exit(-1)

infile = sys.argv[1]
lines = [ x.strip().split('\t') for x in open(infile) ]
header = lines[0]
for line in lines[1:]:
    obj = { x: y for x, y in zip(header, line) }
    print json.dumps(obj)
