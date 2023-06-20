#!/usr/bin/env nextflow

// Using DSL-2
nextflow.enable.dsl=2

include {
    preprocessFASTA;
    run_PGAP
} from './modules'

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

workflow {

    // Print the help message
    if (params.help){
        helpMessage();
        exit 0
    }

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
        .from(
            file(
                params.sample_sheet,
                checkIfExists: true
            )
        )
        .splitCsv(header:true)
        .map { it -> [
            file(it["fasta"], checkIfExists: true), 
            file(it["yaml"], checkIfExists: true)
        ]}
        | preprocessFASTA

    // Point to the reference files
    reference_tarball = file(
        "https://s3.amazonaws.com/pgap/input-${params.pgap_version}.tgz"
    )

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

    // Run PGAP
    run_PGAP(
        preprocessFASTA.out,
        reference_tarball
    )

}