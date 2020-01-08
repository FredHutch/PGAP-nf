# Nextflow tool running the NCBI Prokaryotic Genome Annotation Pipeline

The goal of this tool is to run the NCBI Prokaryotic Genome Annotation Pipeline
on arbitrary sets of genomes using the Nextflow system for workflow management.


## Input Data

In order to run this tool, you will need to provide:

  1) Genome sequences in FASTA format (NOTE: files cannot be compressed in any way)
  2) Annotations for each genome in YAML format (example below)
  3) Sample sheet linking each genome FASTA with its corresponding annotation YAML


### Genome Annotation (YAML)

The format of the genome annotation YAML expected by PGAP is described here: 
(https://github.com/ncbi/pgap/wiki/Input-Files)[https://github.com/ncbi/pgap/wiki/Input-Files].


### Sample sheet

The sample sheet linking each genome FASTA with its corresponding annotation YAML
must be formatted as a CSV with two named columns, `fasta` and `yaml`. 

For example:

```
fasta,yaml
local_folder/genome1.fasta,local_folder/genome1.yaml
local_folder/genome2.fasta,local_folder/genome2.yaml
```

The path to the FASTA and YAML can be a relative path, an absolute path, or even
the URL of a file which can be accessed via FTP, HTTP, or any other common file protocol.


## Setting up Nextflow

In order to run the tool, you first need to install and configure Nextflow. Take a look
at the [Nextflow documentation](http://nextflow.io/) for help with this. Some instructions
and guidance on this process for Fred Hutch investigators can be found 
[here](https://sciwiki.fredhutch.org/compdemos/nextflow/). 


## Running PGAP

Once you have the genome FASTAs, annotation YAMLs, and sample sheet CSV, the last thing you
need to decide is where the output files will be placed. With that in hand you can run
the PGAP pipeline as follows:

```
nextflow \
    run \
    FredHutch/PGAP-nf \
    --sample_sheet PATH_TO_SAMPLE_SHEET.CSV \
    --output_folder PATH_TO_SAMPLE_SHEET.CSV
```

Some elaborations on this command may be provided by, e.g.:

  - Specifying a specific version of Nextflow to use (`NXF_VER=19.10.0 nextflow run ...`)
  - Specifying a specific version of PGAP with the `--pgap_version` flag (must match a [specific release](https://github.com/ncbi/pgap/releases))

