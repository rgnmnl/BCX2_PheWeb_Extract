#########################################################
## Title: PheWEB SAIGE Data Download
## Author: Regina Manansala
## Data: 19-August-2019
#########################################################

library(data.table)
library(rvest)
library(XML)
library(magrittr)
library(RCurl)
library(stringr)
library(plyr)
library(dplyr)
library(knitr)
library(tidyr)

# Read in SNP list (SNP must be in CHR:POS-A1-A2 format) - Use "PheWeb_ID_Flip" to flip alleles to match PheWEB
snps <- read.table("SNPS_Index_Flip_May19.txt", sep="\t", header=T)
# snps$Index_SNP <- str_replace_all(snps$V1, "_", "-")
# snps$ID <- gsub(".*[:]([^-]+)[-].*", "\\1", snps$Index_SNP)

# Initialize PheWEB marker
snps$In_PheWeb <- NA

for(i in 1:nrow(snps)){
  
  # Read html page
  pheweb <- tryCatch(read_html(paste0("http://pheweb.sph.umich.edu/SAIGE-UKB/variant/", snps$PW_link[i])), error = function(e){'empty page'}) 
  
  # If empty page, skip to next variant
  # If webpage available, parse page data and output into table
  if(pheweb[1] == "empty page"){
    snps[i,"In_PheWeb"] <- "No"
  } else {
    snps[i,"In_PheWeb"] <- "Yes"
    table <- pheweb %>% html_nodes('script') %>% html_text()
    foo <- strsplit(table[12], "\\[\\{|\\}\\,\\{|\\}\\]|\\}\\;")
    foo2 <- foo[[1]][2:1449]
    foo2 <- gsub('"','',foo2)
    foo3 <- as.data.frame(str_split_fixed(foo2, 'beta:|\\,category:|\\,num_cases:|\\,num_controls:|\\,phenocode:|\\,phenostring:|\\,pval:|\\,sebeta:|\\,trait_is_bad:', 10))
    names(foo3)  <- c("V1", "beta", "category", "num_cases", "num_controls", "phenocode", "phenostring", "pval", "se_beta")
    foo4 <- foo3[, -c(1, 10)]
    assign(paste0("output_", snps$ID[i], "_", i), foo4)
  }
  closeAllConnections()
}

# Write output tables
save.image("PheWeb_Extraction_0331.RData")