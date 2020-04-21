#!/usr/bin/env bash

iconv -f utf-8 -t ascii//TRANSLIT "$1" > /tmp/ascii_converted
mv /tmp/ascii_converted "$1"
