panc <- read.table('Beta_Cell_expression_matrix.csv', header=TRUE, sep=',', stringsAsFactors=FALSE)
panc$TPM <- rowSums( panc[,2:205] )
panc <- panc[ -c(2:205) ]

write.table(panc, "Panc_ag.csv", sep=",", quote=FALSE, row.names=FALSE, col.names=TRUE)


source('sc-intregnet-preprocessing.R')
panc <- read.table('Panc_ag.csv', header=TRUE, sep=',', stringsAsFactors=FALSE)
exp_file = preprocess_exp_sample(panc$hgnc_symbol, gene_format=c('hgnc_symbol'), panc$TPM)
write.table(exp_file, "Panc_agg.tsv", sep="\t", quote=FALSE, row.names=FALSE, col.names=TRUE)