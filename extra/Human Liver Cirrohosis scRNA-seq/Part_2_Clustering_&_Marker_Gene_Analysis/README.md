# Human Liver Cirrhosis scRNA-seq — Part 2: Clustering & Marker Gene Analysis

## Overview

This lab processes sorted liver biopsy single-cell data from Ramachandran et al.
(2019) through the full Seurat clustering pipeline, with a focus on using
data-driven tools to make and justify analytical decisions. The biological target
is the TREM2+CD9+ scar-associated macrophage population identified in the paper.

---

## Key Concepts

**Fraction-specific clustering.** CD45+ (immune) and CD45− (parenchymal) cells
are clustered independently.

**Resolution as a tuning parameter.** The Louvain algorithm's `resolution`
argument controls cluster granularity — it is not a fixed biological quantity.
Choosing it requires balancing sensitivity to real subpopulations against the
risk of over-splitting.

**Stability-based resolution selection with Clustree.** In the absence of a
reference annotation, resolution choice can be guided by tree stability: prefer
the lowest resolution at which nodes have a single dominant parent and splits
are clean. Multiple incoming arrows signal instability. Known marker genes
(here, TREM2 and CD9) can be overlaid on the tree to identify the resolution
at which a biologically meaningful population first separates stably.

**Marker gene interpretation.** `FindAllMarkers()` runs a Wilcoxon rank-sum
test for each cluster vs. all remaining cells. The key columns are `avg_log2FC`
(effect size), `pct.1` / `pct.2` (expression prevalence within and outside the
cluster), and `p_val_adj` (BH-corrected p-value). High `pct.1` with low `pct.2`
identifies the most discriminating markers.

**Condition enrichment.** Comparing cluster composition across healthy and
cirrhotic samples can reveal disease-associated populations. Proportional
comparisons should be interpreted cautiously when samples differ in cell yield
or sequencing depth. Time permitting, it would be beneficial to compare both
integrated and unintegrated samples to discern if cells are truly specific
to a condition.

---

## Key Functions

| Function | Purpose |
|----------|---------|
| `JoinLayers()` | Merges split Seurat v5 layers before downstream steps |
| `FindVariableFeatures()` | Selects the most informative genes for PCA |
| `ScaleData()` | Centers and scales expression for PCA |
| `RunPCA()` | Dimensionality reduction; inspect with `ElbowPlot()` |
| `RunUMAP()` | 2-D layout for visualisation |
| `FindNeighbors()` | Builds the KNN graph used for clustering |
| `FindClusters()` | Louvain community detection; `resolution` controls granularity |
| `clustree()` | Visualises cluster stability across a resolution sweep |
| `FindAllMarkers()` | Wilcoxon marker gene test, one cluster vs. all others |
| `FeaturePlot()` | Maps gene expression onto the UMAP |
| `VlnPlot()` | Expression distribution across clusters |
| `DotPlot()` | Expression level and prevalence for a gene panel across clusters |
| `DoHeatmap()` | Scaled expression heatmap for top marker genes |

---

## Data

**Source:** Ramachandran et al. 2019, GSE136103  
**Input:** `cd45+_liver_cirrhosis.rds` — pre-filtered Seurat object  
**Fractions:** CD45+ (immune), CD45− (non-immune; optional extension)