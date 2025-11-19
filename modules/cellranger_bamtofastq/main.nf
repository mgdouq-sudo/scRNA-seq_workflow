#!/usr/bin/env nextflow

process BAMTOFASTQ {

    container 'ghcr.io/bf528/cellranger:latest'
    label 'process_medium'

    input:
    tuple val(name), path(bam)

    output:
    tuple val(name), path("${name}/**", type: 'dir')

    script:
    """
    cellranger bamtofastq $bam ${name}/
    """

    stub:
    """
    touch stub.fastq
    """


}