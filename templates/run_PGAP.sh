#!/bin/bash

set -euxo pipefail

# Decompress the supplemental_data
tar xzvf ${reference_tarball}

# Make sure that the expected folder exists
[[ -s input-${params.pgap_version} ]]

# usage: pgap.cwl [-h] [--blast_hits_cache_data BLAST_HITS_CACHE_DATA]
#                 [--blast_rules_db BLAST_RULES_DB] --fasta FASTA
#                 [--gc_assm_name GC_ASSM_NAME] [--ignore_all_errors]
#                 [--no_internet] --report_usage --submol SUBMOL
#                 [--supplemental_data SUPPLEMENTAL_DATA]
#                 [job_order]

# positional arguments:
#   job_order             Job input json file

# optional arguments:
#   -h, --help            show this help message and exit
#   --blast_hits_cache_data BLAST_HITS_CACHE_DATA
#   --blast_rules_db BLAST_RULES_DB
#   --fasta FASTA
#   --gc_assm_name GC_ASSM_NAME
#   --ignore_all_errors
#   --no_internet
#   --report_usage
#   --submol SUBMOL
#   --supplemental_data SUPPLEMENTAL_DATA

cwl-runner \
    \$(find / -name 'pgap.cwl') \
    --fasta ${fasta} \
    --submol ${yaml} \
    --supplemental_data input-${params.pgap_version} \
    --report_usage 2>&1 | tail -n 120
# I have to throw away all but the tail of the standard error for this process,
# because it can easily take up gigabytes of logfile

# Rename the input files
for suffix in fna faa gbk gff sqn; do

    echo "Checking to make sure that annot.\$suffix exists"
    [[ -s annot.\$suffix ]]

    echo "Renaming to ${fasta}.\$suffix"
    mv annot.\$suffix ${fasta}.\$suffix
    echo "Compressing ${fasta}.\$suffix"
    gzip ${fasta}.\$suffix

done
