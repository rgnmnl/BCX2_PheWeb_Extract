#########################################################
## Title: Merge PheWEB Extract from RData Output
## Author: Regina Manansala
## Data: 15-January-2018
#########################################################

library(data.table)
library(dplyr)
library(stringr)
library(tidyr)

# Load Extract RData
load("PheWeb_Extraction_May19_Comp.RData")

# Load SNP list used for PheWEB extract
SNPS_Index <- read.table("SNPS_Index_Flip_May19.txt", sep="\t", header=T)

# List outputs from RData file
outputs <- ls(pattern = "output_")

# Initialize phewas data frame
phewas <- data.frame()

for(i in outputs){
  
  # Get corresponding row in SNP_Index
  output_index_row <- substring(i, 8)
  
  # Get output table
  tmp <- get(i)
  
  # Add pheweb variant to output table
  tmp$SNP_Index<- SNPS_Index[output_index_row, "PW_link"]
  
  # Replace all "<50" to "49" and convert to numeric
  tmp$num_cases <- gsub("\\\\u003c50", "49", tmp$num_cases)
  tmp$num_cases <- as.numeric(as.character(tmp$num_cases))
	
  # Convert pvalue to numeric
  tmp$pval <- as.numeric(as.character(tmp$pval))
  
  # Subset data by number of cases and pvalue
#   cases_gt50 <- subset(tmp, !is.na(tmp$pval) & tmp$num_cases >= 49)
#   p_cutoff <- 1*10^(-4)
# 
#   sig_rows <- subset(cases_gt50, cases_gt50$pval < p_cutoff)
#   phewas <- cases_gt50
#   phewas <- rbind(phewas, sig_rows)

  phewas <- rbind(phewas, tmp)
}

dim(phewas)
View(phewas)

# Annotate PheWEB extract results with rsID
SNPS_Index$PW_link <- as.character(SNPS_Index$PW_link)
SNPS_Index$rsID <- as.character(SNPS_Index$V1)
phewas$SNP_Index <- as.character(phewas$SNP_Index)
phewas_annot <- left_join(phewas, SNPS_Index[,c("PW_link", "rsID")], by=c("SNP_Index"="PW_link"))

dim(phewas_annot)
View(phewas_annot)

# Export results
write.table(phewas_annot, "phewas_annot.txt", sep="\t", row.names = F, col.names = T, quote=F)
