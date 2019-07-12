setwd("D:/Desktop/Invidicual project practice/Data/roary output")
library(ggplot2)
library(ggfortify)
library(ggrepel)
library(gridExtra)
library(dplyr)
##################### If you need to generate the distance matrix ###############
# importing the data
data = read.alignment("core_snp.fa", format = "fasta")

# calculating the pairwise distance matrix
data2 = dist.alignment(data, matrix = "similarity")

# converting into a neighbour joining tree and saving it to a nexus format
tree = nj(data2)
write.nexus(tree, file = "core_snps.tre")

#################### If you already have the distance matrix start here###########################
# reading in the data and metadata
labels = read.csv("lables_clean.csv") # cleaning meaning no NF or clade 1
data = as.data.frame(read.csv("core_snp_pdm_NF&clade_I_RM.csv")) # NF and clade one have been removed from this
rownames(data) = data$X
data = data[,-1]
# performing multidimensional scaling on the distance matric generated perviously
mds_data = cmdscale(data)

#plotting in multidimensional scaling like a pseudo PCA as PCA can't be conducted on a distance matrix
title = expression(paste("MDS for pairwise distance of ", italic("E. coli"), " isolates"))

grid.arrange(
#MDS with low alpha on phylogroup
ggplot(mds_data, aes(x = mds_data[,1], y = mds_data[,2], color = labels$Phylogroup_N))+
  geom_point(size = 3)+
  theme_minimal()+
  labs(x = "MDS 1", y = "MDS 2", colour = "Phylogroup")+
  theme(axis.title.x = element_text(size = 12), axis.title.y = element_text(size = 12), legend.text = element_text(size = 16), legend.title = element_text(size = 16)),


#MDS normal with low alpha on Order
ggplot(mds_data, aes(x = mds_data[,1], y = mds_data[,2], color = labels$Order))+
  geom_point(size = 3, shape = 1)+
  theme_minimal()+
  labs(x = "MDS 1", y = "MDS 2", colour = "Order")+
  guides(colour = guide_legend(override.aes = list(alpha = 1)))+
  theme(axis.title.x = element_text(size = 12), axis.title.y = element_text(size = 12), legend.text = element_text(size = 16), legend.title = element_text(size = 16))+
  scale_color_manual(values = c("#f80000", "#f89e00", "#f8f400","#56f800", "#00f8e5",
                                "#0017f8", "#8700ff", "#ff00f7", "#999699", "#0a0a0a",
                                "#2e5c2a", "#34495e", "#05f3cf", "#178070", "#7c4a18", "#6b8c30")),
ncol = 2)

tempLab = labels; tempLab[tempLab$Spieces != "Urocyon cinereoargenteus",] = NA
#MDS with hallow points
ggplot(mds_data, aes(x = mds_data[,1], y = mds_data[,2], labels = tempLab$Spieces))+
  geom_point()+
  geom_label_repel(label = tempLab$Spieces)+
  theme_minimal()+
  labs(x = "MDS 1", y = "MDS 2", colour = "Phylogroup")+
  theme(axis.title.x = element_text(size = 18), axis.title.y = element_text(size = 18))
  
  replace.if(tempLab, Spieces=NA, .if=Spieces = "Tapirus bairdii")

