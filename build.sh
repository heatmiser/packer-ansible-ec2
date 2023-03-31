#!/bin/bash

packer build -machine-readable packer-build.json | tee build_artifact-$(date +%Y-%m-%d.%H%M).txt

