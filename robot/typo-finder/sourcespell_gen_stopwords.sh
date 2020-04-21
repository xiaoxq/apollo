#!/usr/bin/env bash

DIR=$( cd $( dirname "${BASH_SOURCE[0]}" ); pwd )
cd "$DIR/../.."

bash $DIR/sourcespell_no_stopwords.sh modules 2>&1 | grep -v '^Checking' | awk '{print $7}' | \
egrep '^.{5,99}$' | sort -i | uniq -i > $DIR/new_sourcespell_stopwords

meld $DIR/new_sourcespell_stopwords $DIR/sourcespell_stopwords
