# Single-Cell RNA-seq Workflow: BAM to Analysis with Scanpy and Seurat

## Overview
This project recreates a single-cell RNA-seq workflow characterizing the postnatal day 7 mouse hippocampus. It covers the following:

1. Pre-processing raw sequencing data (BAM → FASTQ → counts matrix)  
2. Downstream analysis and visualization using **Scanpy**  

The workflow integrates **Nextflow** for pipeline automation and **Python/Scanpy** for data analysis.

**Relevant publications:**  
- [Nature Communications: Isoform characterization in mouse hippocampus](https://www.nature.com/articles/s41467-020-20343-5#Abs1)  
- [PMC Article for Scanpy Example](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7815907/)

## Part 1: Pre-processing (BAM → FASTQ → Counts Matrix)

### Objectives
- Download raw BAM files using GEO accession or EMBL-ENA  
- Convert BAM to FASTQ  
- Run **Cell Ranger count** to generate the counts matrix  

### Requirements
- Nextflow  
- Container: `ghcr.io/bf528/cellranger:latest`  
- Samplesheet with file names and FTP links for BAM files  

### Workflow Steps
1. **Download the data:**  
   - Use GEO accession/EMBL-ENA to locate BAM files  
   - Create a Nextflow channel that reads sample names and download links  
   - Use `wget` or another utility to download the files  
2. **Convert BAM → FASTQ:**  
   - Use the `bamtofastq` utility within the Cell Ranger container  
   - Multi-threading can accelerate the process  
3. **Run Cell Ranger Count:**  
   - Execute the `cellranger count` pipeline on the FASTQ files  
   - Reference genome (pre-downloaded): `/projectnb/bf528/materials/single_cell/refs/`  
   - Adjust resources per module as needed  
4. **Re-run pipeline for full dataset:**  
   - Update samplesheet to the full dataset links  
   - Run the pipeline with appropriate CPU and memory allocation  

### Nextflow Requirements
- `main.nf` script  
- `modules/` directory  
- `nextflow.config`  

## Part 2A: Analysis with Scanpy

### Setup
1. Create a Conda environment with required packages (`environment.yml`):
   ```yaml
   name: scRNAseq
   dependencies:
     - scanpy=1.11.1
     - ipykernel=6.29.5

## Citations:

Isaac Virshup, Sergei Rybakov, Fabian J. Theis, Philipp Angerer, F. Alexander Wolf. anndata: Annotated data, JOSS 2024 Sep 16. doi: 10.21105/joss.04371

Wolf, F., Angerer, P. & Theis, F. SCANPY: large-scale single-cell gene expression data analysis, Genome Biol 19, 15 (2018). https://doi.org/10.1186/s13059-017-1382-0

### Paper reference:

Joglekar A, Prjibelski A, Mahfouz A, et al. A spatially resolved brain region- and cell type-specific isoform atlas of the postnatal mouse brain. Nat Commun. 2021;12(1):463. Published 2021 Jan 19. doi:10.1038/s41467-020-20343-5

## Part 2B: Analysis with Seurat

### Analysis Framework

Downstream analysis is performed in R using the following ecosystem:

SingleCellExperiment – core data structure

muscat – pseudobulk aggregation by cell type and sample

DESeq2 – differential expression on pseudobulked counts

Seurat – quality control, dimensionality reduction, clustering, and visualization

This hybrid approach combines robust differential expression testing with standard single-cell visualization and clustering workflows.

### Environment Setup
Software Requirements:

R (≥ 4.2)

RStudio (optional)

R Packages

Seurat

SingleCellExperiment

muscat

DESeq2

tidyverse

## Dataset

The downstream analysis uses the publicly available interferon-β stimulation PBMC dataset from Kang et al. (2018), accessed via the muscData package. This dataset contains annotated immune cell types across multiple individuals and conditions, making it well suited for pseudobulk and clustering analyses.

## Analysis Overview

The analysis implemented in this repository includes:

Exploration of SingleCellExperiment objects

Inspection of cell-level and gene-level metadata

Subsetting by cell type, individual, and condition

Quality control metrics (library size, detected genes, mitochondrial content)

Pseudobulk aggregation by cell type and sample

Differential expression analysis using DESeq2

Seurat-based normalization, clustering, and UMAP visualization

Marker gene identification and heatmap visualization

## Outputs

The analysis produces:

QC summaries for cells and genes

Pseudobulk count matrices per cell population

Differential expression results for stimulated vs control conditions

Clustered Seurat objects

UMAP plots colored by condition and cluster

Marker gene tables and heatmaps

Reproducibility

Pre-processing is fully automated via Nextflow

Analysis steps are documented and executable via R Markdown

Public datasets and containerized tools ensure reproducibility across environments

## Citations:

Satija R et al. Spatial reconstruction of single-cell gene expression data. Nature Biotechnology (2015)

Hao Y et al. Integrated analysis of multimodal single-cell data. Cell (2021)

### Paper reference:
Kang HM et al. Multiplexed droplet single-cell RNA-sequencing using natural genetic variation. Nature Biotechnology (2018)
