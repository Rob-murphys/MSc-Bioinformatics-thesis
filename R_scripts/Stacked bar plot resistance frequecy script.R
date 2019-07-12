# setting the working directory and loading librarys
setwd("D:/Desktop/Invidicual project practice/Data")
library(ggplot2)
library(plyr)
library(tibble)
library(tidyverse)
# inporting the data to be used
data = read.csv("Vir_freq_grouped_PerIsolate_orderd.csv")

#Setting the objects needed for the for loop
group_ID = unique(data$Order)
out = NULL
Vir_names = factor(colnames(data)[c(-1,-2)])
#A for loop that calculates the frequency of gene by order of species isolated from
for (ID in 1:length(unique(data$Order))){
  temp = data[data$Order %in% group_ID[ID],] # This returns all the rows int he dataset that macth a specific order everything else is just the summing and dataframe manipulation
  temp = t(temp[,c(-1,-2)])
  temp = rowSums(temp)/ncol(temp)
  temp = as.data.frame(temp)
  temp = add_column(temp, Order = as.factor(group_ID[ID]), .after = temp[,1])
  temp = add_column(temp, Vir_factor = Vir_names, .before = "Order")
  temp$Vir_factor = factor(temp$Vir_factor, levels = temp$Vir_factor)
  out = rbind(out,temp)
}
rownames(out) = NULL
ggplot(out, aes(y = temp, x = Vir_factor, fill = Order))+
  geom_bar(stat = "identity", width = 0.95)+
  theme_minimal()+
  theme(axis.text.x = element_text(angle = 60, hjust = 1))+
  scale_y_reverse()+
  labs(y = "Frequency", x = "Antibiotic")+
  scale_fill_manual(values = c("#f80000", "#f89e00", "#f8f400","#56f800", "#00f8e5",
                               "#0017f8", "#8700ff", "#ff00f7", "#999699", "#0a0a0a",
                               "#2e5c2a", "#34495e", "#05f3cf", "#178070", "#7c4a18", "#6b8c30"))
