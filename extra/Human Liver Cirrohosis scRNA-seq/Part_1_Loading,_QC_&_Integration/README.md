# Lab 11 — Human Liver Cirrhosis: Loading, QC & Integration

**Course:** BF530 | **Dataset:** Ramachandran et al. 2019, GSE136103 | **Estimated time:** 2–3 hours

---

## Overview

This lab takes you from raw 10X Genomics count matrices to a clean, integrated Seurat object ready for biological interpretation. You will process samples from **10 donors** (5 healthy, 5 cirrhotic) across two sorted cell fractions (CD45+ and CD45−), giving roughly 17 sample directories once A/B sequencing lanes are accounted for.

The emphasis is twofold: writing R code that scales cleanly across many samples at once using `lapply()` and `mapply()`, and making *justified* QC decisions rather than accepting default values. The decisions you make here — which cells to keep, how aggressively to filter doublets, how many principal components to use — directly shape every downstream result in Part 2.

---

## Learning Objectives

1. Load 10X Genomics count matrices into Seurat and navigate the object structure
2. Use `lapply()` and `mapply()` to apply a function across many samples simultaneously
3. Calculate standard QC metrics and understand what each one detects
4. Apply MAD-based adaptive filtering and justify your threshold choice
5. Detect and remove putative doublets on a per-sample basis
6. Understand why donor batch effects arise and how Harmony integration addresses them
7. Evaluate integration quality visually using UMAP

---

## Dataset

Ramachandran et al. (2019, *Nature*) profiled >100,000 single cells from healthy and cirrhotic human liver, identifying a novel **TREM2+CD9+ macrophage subpopulation** that expands in fibrosis.

| Property | Detail |
|---|---|
| Donors | 5 healthy, 5 cirrhotic (NAFLD, alcohol, PBC) |
| Fractions | CD45+ (immune cells) and CD45− (endothelial, mesenchymal) |
| Lanes | Some CD45− samples split across two sequencing lanes (A and B) |
| Data path (cluster) | `/projectnb/bf530/materials/lab11-data/data/` |

Each sample directory contains three files that together define the count matrix:

```
data/
├── GSM4041150_healthy1_cd45+/
│   ├── barcodes.tsv.gz     ← one cell barcode per row
│   ├── features.tsv.gz     ← one gene per row
│   └── matrix.mtx.gz       ← sparse counts (gene index, cell index, count)
├── GSM4041151_healthy1_cd45-A/
├── GSM4041151_healthy1_cd45-B/   ← same biological sample, two lanes
└── ...
```

---

## Key Functions

This lab introduces several functions you will use repeatedly in single-cell work. Most code is provided — your job is to complete the gaps and understand what each step is doing.

### Loading and object creation

- **`Read10X(data.dir)`** — reads all three 10X output files from a directory into a sparse genes × cells count matrix. Handles `.gz` compression automatically.
- **`CreateSeuratObject(counts, min.cells, min.features)`** — wraps a count matrix into a Seurat object. `min.cells` drops very sparse genes; `min.features` drops likely empty droplets.

### Scaling across samples with `lapply()` and `mapply()`

Rather than copying processing code once per sample, this lab uses two closely related R functions:

- **`lapply(list, function)`** — applies a function to every element of a list and returns a list of results. Used whenever the same operation needs to run on every sample.
- **`mapply(function, arg1, arg2)`** — like `lapply()` but lets you vary multiple arguments at once. Used at the loading step where each sample needs both a file path and a sample name.

Getting comfortable with this pattern is one of the main technical goals of the lab. A `for` loop would produce identical results, but `lapply()` is less error-prone, keeps results automatically organised, and is standard practice in R-based bioinformatics pipelines.

### QC metrics

- **`PercentageFeatureSet(pattern)`** — calculates the percentage of each cell's counts that come from genes matching a regex pattern. The pattern `"^MT-"` captures human mitochondrial genes. High mitochondrial percentage indicates a damaged or dying cell whose cytoplasmic mRNA has leaked out.

### Adaptive QC filtering

- **`isOutlier(metric, nmads, type, log)`** from `scuttle` — identifies cells whose QC values are more than `nmads` median absolute deviations (MADs) from the median. Unlike a fixed threshold, this adapts to each sample's own distribution. `type = "lower"` flags unusually low values; `type = "higher"` flags unusually high ones.

### Doublet detection

- **`scDblFinder(sce)`** — simulates artificial doublets by combining random cell pairs, then trains a classifier to distinguish real cells from the simulated ones. Returns a score (0–1) and a binary call (`"singlet"` or `"doublet"`) per cell.

  > **Important:** run this per sample, before merging. If you run it on the merged object, cells from different donors are compared against each other and the false positive rate rises sharply.

### Normalisation and feature selection

- **`NormalizeData(normalization.method, scale.factor)`** — divides each cell's counts by its total UMIs, multiplies by a scale factor (typically 10,000), then takes log1p. This corrects for differences in sequencing depth so cells can be compared fairly.
- **`FindVariableFeatures(selection.method, nfeatures)`** — identifies genes that vary more across cells than expected given their mean expression. These highly variable genes (HVGs) are the input to PCA.

### Dimensionality reduction

- **`ScaleData()`** — centres and scales each gene to mean 0, variance 1. Required before PCA so that highly expressed genes do not dominate the principal components purely by scale.
- **`RunPCA(npcs)`** — performs PCA on the scaled HVG matrix, reducing ~18,000 genes to a manageable number of principal components.
- **`ElbowPlot()`** — plots the standard deviation explained by each PC. Use this to choose how many PCs to pass to downstream steps: look for where the curve flattens.
- **`RunUMAP(dims, reduction)`** — projects high-dimensional PCA coordinates into 2D for visualisation. You will run this twice: once on the raw PCA (to see batch effects) and once on the Harmony embedding (to confirm they are corrected).

---

## The QC Filtering Decision

The most conceptually important part of this lab is Section 5.3. There is no single correct QC threshold — the goal is to understand the trade-off you are making.

**The problem with hard cutoffs** (e.g. `percent.mt > 20%`): the same number is applied to every sample regardless of how that sample actually behaves. A sample with genuinely higher mitochondrial content — due to tissue type or dissociation conditions — gets over-filtered. A low-quality batch might slip through.

**MAD-based filtering** sets thresholds relative to each sample's own distribution. A cell is flagged if its value is more than `nmads` MADs from that sample's median. The threshold still has a free parameter (`nmads`), but it adapts to each sample rather than being fixed globally.

You will be asked to try `nmads = 2`, `nmads = 3`, and `nmads = 5` and describe what changes. Neither extreme is obviously correct — the point is to articulate the trade-off.

---

## Your Tasks

The following chunks require you to write or complete code. Everything else is provided.

| Section | Task |
|---|---|
| 3 | Bar chart of cells per sample, coloured by condition, using `ggplot2` |
| 5.1 | Add `percent.mt` using `PercentageFeatureSet()` |
| 5.2 | Violin plots of QC metrics using `VlnPlot()` |
| 5.3 | Complete `filter_by_mad()`: choose which metrics to test, the direction for each, and `nmads` |
| 5.4 | Apply the QC filter using `subset()` |
| 6 | Fill in the two `sce$___` blanks to transfer doublet results back to Seurat |
| 8 | Complete the `NormalizeData()` and `FindVariableFeatures()` arguments |
| 10 | Produce an elbow plot and set `n_pcs` |
| 10.1 | Three UMAP plots of the unintegrated data coloured by donor, condition, and fraction |


---


## Submission

The final chunk saves `liver_cirrhosis_part1.rds`, which is your input for Part 2 (clustering and cell type annotation).