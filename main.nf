#!/usr/bin/env nextflow

// Function which prints help message text
def helpMessage() {
    log.info"""
    Usage:

    netflow run FredHutch/PGAP-nf <args>

    Required Arguments:
        --sample_sheet        # Comma-separated table with `fasta` and `yaml` columns
        --output_folder       # Folder to place output files

    """.stripIndent()
}

// Print the help message
params.help = false
if (params.help){
    helpMessage();
    exit 0
}

// Default values for flags
params.sample_sheet = false
params.output_folder = false
params.pgap_version = "2019-11-25.build4172"

if (!params.sample_sheet){
    log.info"""Please specify --sample_sheet."""
    exit 0
}
if (!params.output_folder){
    log.info"""Please specify --output_folder."""
    exit 0
}

// Set up a channel with the fasta and yaml paths

Channel
    .from(file(params.sample_sheet))
    .splitCsv(header:true)
    .map { it -> [file(it["fasta"]), file(it["yaml"])]}
    .set { sample_sheet_ch }

// Point to the reference files
reference_tarball = file("https://s3.amazonaws.com/pgap/input-${params.pgap_version}.tgz")

// Make sure that the reference file exists
if (!reference_tarball.exists()){
    log.info"""
Problem, https://s3.amazonaws.com/pgap/input-${params.pgap_version}.tgz does not exist.

This is probably because the specified PGAP version is not valid (currently using ${params.pgap_version}).

To figure out the latest version to use, go to https://github.com/ncbi/pgap/releases

You can specify which PGAP version to use with the --pgap_version flag.
"""
    exit 0
}

process run_PGAP {

    container "ncbi/pgap:${params.pgap_version}"
    cpus 16
    memory "30 GB"
    publishDir "${params.output_folder}/"

    input:
    tuple file(fasta), file(yaml) from sample_sheet_ch
    file reference_tarball

    output:
    file "${fasta}.fna"
    file "${fasta}.faa"
    file "${fasta}.gbk"
    file "${fasta}.gff"
    file "${fasta}.sqn"

    """
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
    /pgap/pgap.cwl \
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

done

    """

}