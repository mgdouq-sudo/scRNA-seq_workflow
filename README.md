# Quickly transferring your GitHub Repos

The easiest way to transfer your repos to your own organization is to clone it 
and change the remote. 

```bash
git clone git@github.com:bf528/your-repo.git
cd your-repo/
```

In between this step, go to GitHub and create a new repository under your own 
username. In the command below, replace the SSH link with the SSH link on the
page shown when you create your new repo, and then run the commands. 


```bash
git remote set-url origin git@github.com:<your_github_username>/your_new_repo.git
git push -u origin main
```

Note that this method will **preserve** your commit history. If you want to reset
your history, you will need to use a different method (or you can delete the .git/
folder and follow the steps provided when you create a new repo on the GitHub website)


# Single Cell RNAseq pre-processing

We are going to recreate some of the basic findings from this paper: https://www.nature.com/articles/s41467-020-20343-5#Abs1
The authors were attempting to characterize how isoform expression changes across cell types and spatial resolution. We will
focus primarily on recreating the results of their single cell experiment characterizing the mouse hippocampus at postnatal
day 7.

I will describe the steps you should follow but leave the specifics to you. Hopefully this will get you some practice with
where you would start when constructing your own workflow.

With 10X single cell RNAseq, many studies store the raw data in the form of the aligned BAM files. In order to regenerate a 
counts matrix, you will first need to convert the BAM to a FASTQ and run the Cellranger count pipeline. 

## Objectives

- Use the GEO accession and EMBL-ENA to figure out where to download the apprporiate data
- Construct a small nextflow pipeline that will download the BAM files using wget, 
convert them to FASTQ, and run cellranger count

## Clone the github classroom link 

You'll notice that it's empty, you'll need to create this workflow mostly on your own. 

The minimal set of requirements that you need for a nextflow workflow are:

1. A `main.nf` script
2. A modules directory
3. A nextflow.config

## Downloading the data

Look in the paper for the GEO accession and search for it on EMBL-ENA. This will bring you to a page that describes
the samples in the experiment. **You may start by using the provided samplesheet, which has FTP links to small subsetted
versions of the files. Once you've gotten the channel and module, you can switch to your samplesheet with the real files.**

- Locate the FTP links for how to download the BAM files and encode this information in a samplesheet
- Create a channel that reads in the the name and link to the files
- Create a process that uses `wget` or another utility to download the files

## Generate a module for converting the BAMs to FASTQs

Container for Cellranger:

`ghcr.io/bf528/cellranger:latest`

BAM files containing certain tags (CB, CR, UR, etc.) are able to be properly re-converted back to their original
representation as FASTQ files.

- Use the bamtofastq utility to convert the BAM files to FASTQs
- Using more threads will significantly increase the speed


## Run the Cellranger count pipeline

- Generate a command that will successfully run the cellranger count
pipeline on the two samples. You may find the reference genome pre-downloaded
here: /projectnb/bf528/materials/single_cell/refs/

## Re-run the pipeline for the full data

Switch your samplesheet to the one you generated with the actual links to the
data. Now re-run your pipeline on the full samples. Make sure you give each
module an appropriate amount of resources (cellranger count is a very intensive
process).

## Create your own docker container and push it to the GitHub Container Registry

With any remaining time, please try to generate your own container for CellRanger.
You may find **one** method for creating a CellRanger container here: 
https://github.com/BF528/pipeline_containers

You may also find these instructions helpful for [building a container](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#building-container-images)

Once you've successfully created the container in Docker Desktop on your local
machine. You will need to push it to the container registry. 

Please follow the directions in this order:

[Authenticating to the registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-to-the-container-registry)

[Tagging your container image](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#tagging-container-images)

[Pushing your image to the registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#pushing-container-images)

After you've done this successfully, try switching your pipeline to use your container
image instead of the pre-provided one. 
