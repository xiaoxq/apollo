#!/usr/bin/env bash
#   sourcespell.sh </some/dir>

TARGET_DIR=$1

# Check tools.
if ! [ -x "$(command -v sourcespell)" ]; then
  echo "Installing sourcespell..."
  sudo pip install sourcespell
fi

DIR=$( cd $( dirname "${BASH_SOURCE[0]}" ); pwd )
sourcespell --directory "${TARGET_DIR}" \
    --ignore-patterns \
        '*.conf' \
        '*.crt' \
        '*.pb.txt' \
        '*.seg' \
        '*.key' \
        '*.json' \
        '*_cn.md' \
        '*BUILD' \
        '*/frontend/dist/*' \
        '*/frontend/src/fonts/*' \
        '*/ssl_keys/*' \
        '*yarn.lock' \
    --excluded-words ${DIR}/sourcespell_stopwords 2>&1 | \
grep -v ^Checking | tee -a result.txt
cat result.txt | awk '{print $7}' | egrep '^.{5,99}$' | /home/aaron/work/toolkit/count.py | sort -n

# Fix typos
FROM=Unrelevent
TO=Irrelevant
grep -r ${FROM} modules | awk -F: '{print $1}' | uniq | xargs -L 1 sed -i "s|${FROM}|${TO}|g"
