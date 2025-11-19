#!/usr/bin/env nextflow

process COUNT {

    label 'process_veryhigh'
    container 'ghcr.io/bf528/cellranger:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(name), path(fastq)
    path(index)

    output:
    path('*')

    script:
    """
    cellranger count --id=$name \
           --transcriptome=$index \
           --fastqs=$fastq \
           --create-bam=true \
           --localcores=16 \
           --localmem=256
    """

    stub:
    """
    touch stub.fastq
    """


}