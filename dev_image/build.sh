#!/usr/bin/env bash

cd $(dirname $0)
docker build -t "apolloauto/apollo:dev-x86_64-voice" .
