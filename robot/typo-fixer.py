#!/usr/bin/env python3

TYPOS = {
    ".arrange(": ".arange(",  # Fix back.
    "kee_clear": "keep_clear",
    "Upont": "Upon",
}

import sys

for typo, fix in TYPOS.items():
    print (f'sed -i "s/{typo}/{fix}/g" "{sys.argv[1]}"')
