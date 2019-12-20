#!/bin/bash

set -e

NXF_VER=19.10.0 nextflow \
    run \
    ../main.nf \
    --sample_sheet sample_sheet.csv \
    --output_folder ./
