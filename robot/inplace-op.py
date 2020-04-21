#!/usr/bin/env python

import sys

f = sys.argv[1]
with open(f, 'r') as fin:
    lines = fin.readlines()

OPS = {'+', '-', '*', '/', '|', '&', '&&', '||'}

changed = False
for i in range(len(lines)):
    line = lines[i]
    parts = line.split(' ', 4)
    # a = a [+-*/]
    if len(parts) < 4 or parts[0] != parts[2] or parts[1] != '=' or parts[3] not in OPS:
        continue
    print (line)
    a = parts[0]
    op = parts[3]
    new_line = line.replace('{} = {} {}'.format(a, a, op), '{} {}='.format(a, op), 1)
    if new_line != line:
        changed = True
        lines[i] = new_line

if changed:
    with open(f, 'w') as fout:
        fout.writelines(lines)
