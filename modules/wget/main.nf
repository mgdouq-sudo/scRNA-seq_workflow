#!/usr/bin/env nextflow

process WGET {

    input:
    tuple val(name), val(ftp)

    output:
    tuple val(name), path('*bam.1')

    script:
    """
    wget $ftp
    """

    stub:
    """
    touch stub.bam
    """


}