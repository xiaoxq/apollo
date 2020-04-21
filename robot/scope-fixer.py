#!/usr/bin/env python

import sys

f = sys.argv[1]
with open(f, 'r') as fin:
    lines = fin.readlines()

for i in range(len(lines)):
    line = lines[i]
    striped = line.strip()
    if not striped.endswith(';'):
        continue
    if not (striped.startswith('if (') or striped.startswith('for (') or striped.startswith('while (')):
        continue

    right_bracket = None
    open_bracket = 0
    for j in range(len(line)):
        if line[j] == '(':
            open_bracket += 1
        elif line[j] == ')':
            open_bracket -= 1
            if open_bracket == 0:
                right_bracket = j
                break
    if right_bracket is None:
        continue

    lines[i] = '%s) { %s }' % (line[:right_bracket], line[right_bracket + 2:-1])

with open(f, 'w') as fout:
    fout.writelines(lines)
