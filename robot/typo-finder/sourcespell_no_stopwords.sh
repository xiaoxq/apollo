#!/usr/bin/env bash
# Usage:
#   sourcespell.sh </some/dir>

TARGET_DIR=$1

# Check tools.
if ! [ -x "$(command -v sourcespell)" ]; then
  echo "Installing sourcespell..."
  sudo pip install sourcespell
fi

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
