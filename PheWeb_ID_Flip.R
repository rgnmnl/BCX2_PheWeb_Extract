#########################################################
## Title: PheWEB SNP ID flip
## Author: Regina Manansala
## Data: 3-April-2019
#########################################################

# Load SNP subsets not found on PheWEB
snps_no_pheweb <- fread("snps_no_pheweb_0331.txt")
names(snps_no_pheweb) <- c("ID", "Index_SNP", "In_PheWeb")

# Split string then concatenate string with alleles flipped
index_split <- str_split_fixed(snps_no_pheweb$Index_SNP, ':|-', 4)
snps_no_pheweb$Index_Comb <- paste0(index_split[,1], ":", index_split[,2], "-", index_split[,4], "-", index_split[,3])
snps_no_pheweb$PW_link <- ifelse(snps_no_pheweb$In_PheWeb == "Yes", snps_no_pheweb$Index_SNP, snps_no_pheweb$Index_Comb)

# Output file to rerun
write.table(snps_no_pheweb, "SNPS_Index_Flip_May19.txt", sep="\t", row.names = F, col.names = T, quote = F)
