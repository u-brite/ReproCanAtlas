if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("recount3")
BiocManager::install("tximport")
BiocManager::install("GenomicFeatures")
BiocManager::install("TxDb.Hsapiens.UCSC.hg19.knownGene")
BiocManager::install("vsn")
BiocManager::install("DESeq2")
BiocManager::install("maftools")
BiocManager::install("apeglm")
install.packages("tidyverse")
install.packages("shinycssloaders")

