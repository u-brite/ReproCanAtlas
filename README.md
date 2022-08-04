# ReproCanAtlas

## Table of Contents

    - [Background](#Background)
    - [Data](#data)
    - [Usage](#usage)
        - [Installation](#installation)
        - [Requirements](#requirements) _Can be named Dependencies as well_
        - [Activate conda environment](#activate-conda-environment) _Optional_
        - [Steps to run ](#steps-to-run) _Optional depending on project_
            - [Step-1](#step-1)
            - [Step-2](#step-2)
    - [Results](#results) _Optional depending on project_
    - [Team Members](#team-members)

## Background

We will create the start of ReproCanAtlas with Endometrial Cancer. This project will integrate single cell RNASeq,  bulk transcriptomics, and genomic data of reproductive/gynecological cancers in order to develop an atlas or knowledge base of those cancers and identify reproductive cancer signatures and therapeutic targets. We will use TCGA via recount3, TissueNexus, COSMIC, DGIdb, and CellMinerCDB. Lastly, we will integrate our findings into an interactive shiny app.

Endometrial Cancer Papers for overview: 
https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3518445/
https://cancerimagingjournal.biomedcentral.com/articles/10.1186/s40644-018-0180-6
https://www.cancer.gov/types/uterine/research


## Data

Data will be accessed through TCGA for Whole Exome Sequencing and bulk RNAseq. 
Single Cell RNAseq (scRNAseq) will be from paper(s). 
These will be provided through Cheaha (UAB's HPC) or through smaller count matrices that you can run locally 

## Usage

The atlas can be used for preliminary analysis by noncomputational groups as well as for clinicians. 
The goal is to be as user friendly as possible 

## Future Directions
The goal is to get this atlas started so that we can add multiple female reproductive cancers to it. 

### Installation of Packages 

The following are required to do this analysis: 
R/ RStudio: https://www.rstudio.com/products/rstudio/download/

Need access to Cheaha for some of the larger data 

Packages within R
 - Shiny: https://shiny.rstudio.com
 - Seurat for single cell: https://satijalab.org/seurat/
 - MAFtools for WXS: https://www.bioconductor.org/packages/devel/bioc/vignettes/maftools/inst/doc/maftools.html
 - DEseq2 for bulk RNAseq: https://bioconductor.org/packages/release/bioc/html/DESeq2.html
 

### Requirements
To Be determined/ edited as the Hackathon progresses 

## Results
:exclamation: _If your project yielded or intends to yield some novel analysis, please include them in your readme. It can be named something other than results as well._ :exclamation:

## Team Members

Emily Page | empage@uab.edu| Team Leader  

