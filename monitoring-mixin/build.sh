#!/bin/bash

OUTPUT_DIR=build

rm -r ${OUTPUT_DIR} && mkdir -p ${OUTPUT_DIR}

jsonnet -J vendor main.jsonnet -m ${OUTPUT_DIR}