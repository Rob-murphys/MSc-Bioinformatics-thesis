setwd("D:/Desktop/Invidicual project practice/Data")
library(ggplot2)
# loading in the data to a dataframe and setting colnames
N50_data = as.data.frame(as.matrix(read.csv("N50_output")))
colnames(N50_data) = "N50"

# removing the outlier and colnames of new dataframe
N50_data1 = as.data.frame(N50_data$N50[-62]) 
colnames(N50_data1) = "N50"

N50_title1 = expression(paste("N50 of aligned", ~italic("E. coli")," ", "genomes"))
N50_title2 = expression(paste("N50 of aligned", ~italic("E. coli")," ", "genomes with outliers removed"))

# plotting the N50 with the outlier included
ggplot(N50_data, aes(x = N50))+
  geom_density()+
  xlab(" N50 of Alignment")+
  ylab("Density")+
  theme(axis.title = element_text(size = 16))+
  ggtitle(N50_title1)

#lotting the N50 with the outlier removed
ggplot(N50_data1, aes(x = N50))+
  geom_density()+
  xlab(" N50 of Alignment")+
  ylab("Density")+
  theme(axis.title = element_text(size = 16))+
  ggtitle(N50_title2)
#---------------------------------------------------------------------
# loading in the data to a dataframe and setting colnames. Need to be dataframe for ggplot
NC_data = as.data.frame(as.matrix(read.csv("NumContig_output.csv")))
colnames(NC_data) = "Number_of_contigs"

NC_data1 = as.data.frame(NC_data[NC_data < 1000])
colnames(NC_data1) = "Number_of_contigs"

density_title1 = expression(paste("Number of contigs for aligned", ~italic("E. coli")," ", "genomes"))
density_title2 = expression(paste("Number of contigs for aligned", ~italic("E. coli")," ", "genomes with outliers removed"))

ggplot(NC_data, aes(x = Number_of_contigs))+
  geom_density()+
  xlab(" Total number of contigs")+
  ylab("Density")+
  theme(axis.title = element_text(size = 16))+
  ggtitle(density_title1)

ggplot(NC_data1, aes(x = Number_of_contigs))+
  geom_density()+
  xlab(" Total number of contigs")+
  ylab("Density")+
  theme(axis.title = element_text(size = 16))+
  ggtitle(density_title2)
#--------------------------------------------------------------------
PanG_df = data.frame(
  group = c("Core genes", "Soft core genes", "Shell genes", "Cloud genes"),
  counts = c(684, 0, 4910, 8783)
)

ggplot(PanG_df, aes(x = "", y = counts, fill = group))+
  geom_bar(stat = "identity", width = 1)+
  coord_polar("y", start = 0)+
  geom_text(aes(label = paste0(round(counts))), position = position_stack(vjust = 0.5))+
  labs(x = NULL, y = NULL, fill = NULL, title = "Pangenome distribution - Total genes = 14377")+
  theme_classic() + theme(axis.line = element_blank(),
                          axis.text = element_blank(),
                          axis.ticks = element_blank(),
                          plot.title = element_text(hjust = 0.5, color = "#666666"))
