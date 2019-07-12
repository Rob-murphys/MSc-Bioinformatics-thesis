setwd("D:/Desktop/Invidicual project practice/Data/roary output")
library(ggplot2)
library(gridExtra)
#Loading in the data and lables used for itteration then cleaning the data a bit
PDM = as.data.frame (read.csv("core_snp_pdm_NF&clade_I_RM.csv")) # need to use the NF phylogroup removed version as we are labeling by phylogroup
labelsX = read.csv("lables_clean.csv")
labelsY = read.csv("lables_clean.csv")
rownames(PDM) = PDM$X
PDM2 = PDM[,-1]

same_insert.label = "Same"
different_insert.label = "Different"
#setting the storage vectors for successful data
label_same = character()
distance_same = numeric()

#For every lable in X I am looping over all lables in Y to find ones that are the same then take the ith and jth cell in PDM2
for (i in 1:nrow(labelsX)){
  for (j in 1:nrow(labelsY)){
      if (labelsX$Order[i] == labelsY$Order[j]){
      label_same = c(label_same, as.character(labelsX$Order[i]))
      distance_same = c(distance_same, as.numeric(PDM2[i,j]))
    }
  }
}
Group = data.frame(Group = rep(same_insert.label, length(distance_same)))
label_same = as.data.frame(cbind(label = label_same, distance = as.numeric(distance_same), Group))



label_different = factor()
distance_different = numeric()
#For every lable in X I am looping over all lables in Y to find ones that are the same then take the ith and jth cell in PDM2
for (i in 1:nrow(labelsX)){
  for (j in 1:nrow(labelsY)){
    if (labelsX$Order[i] != labelsY$Order[j]){
      label_different = c(label_different, as.character(labelsX$Order[i]))
      distance_different = c(distance_different, as.numeric(PDM2[i,j]))
    }
  }
}
Group = data.frame(Group = rep(different_insert.label, length(distance_different)))
label_different = as.data.frame(cbind(label = label_different, distance = as.numeric(distance_different), Group))

#combining the data to make an overlapping histogram with both groups
hist_data = as.data.frame(rbind(label_same, label_different))
hist_data = hist_data[hist_data$distance != 0,]

#plotting the histogram
species = ggplot(hist_data, aes(x = distance, fill = Group))+
  geom_histogram(aes(y = ..density..), binwidth = 0.005, alpha = 0.5, position = "identity", color = "white")+
  geom_density(alpha = 0.3, position = "identity")+
  labs(x = "Pairwise distance", y = "Density")+
  theme_minimal()+
  theme(legend.position = "none")

genus = ggplot(hist_data, aes(x = distance, fill = Group))+
  geom_histogram(aes(y = ..density..), binwidth = 0.005, alpha = 0.5, position = "identity", color = "white")+
  geom_density(alpha = 0.3, position = "identity")+
  labs(x = "Pairwise distance", y = "Density")+
  theme_minimal()+
  theme(legend.position = "none")

order = ggplot(hist_data, aes(x = distance, fill = Group))+
  geom_histogram(aes(y = ..density..), binwidth = 0.005, alpha = 0.5, position = "identity", color = "white")+
  geom_density(alpha = 0.3, position = "identity")+
  labs(x = "Pairwise distance", y = "Density")+
  theme_minimal()+
  theme(legend.position = "none")

phylogroup = ggplot(hist_data, aes(x = distance, fill = Group))+
  geom_histogram(aes(y = ..density..), binwidth = 0.005, alpha = 0.5, position = "identity", color = "white")+
  geom_density(alpha = 0.3, position = "identity")+
  labs(x = "Pairwise distance", y = "Density")+
  theme_minimal()

grid.arrange(species, genus, order, phylogroup, ncol = 2)
