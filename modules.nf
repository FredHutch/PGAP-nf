process preprocessFASTA {

    container "quay.io/fhcrc-microbiome/integrate-metagenomic-assemblies:v0.5"
    cpus 1
    memory "2 GB"
    
    input:
    tuple path(fasta), path(yaml)

    output:
    tuple path("${fasta}"), path("${yaml}")

    script:
    template "preprocessFASTA.py"

}

process run_PGAP {

    container "ncbi/pgap:${params.pgap_version}"
    cpus 16
    memory "30 GB"
    publishDir "${params.output_folder}/"
    errorStrategy 'retry'
    maxRetries 2

    input:
    tuple file(fasta), file(yaml)
    file reference_tarball

    output:
    file "${fasta}.fna.gz"
    file "${fasta}.faa.gz"
    file "${fasta}.gbk.gz"
    file "${fasta}.gff.gz"
    file "${fasta}.sqn.gz"

    script:
    template "run_PGAP.sh"
}