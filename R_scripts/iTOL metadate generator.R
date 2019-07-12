#####################################################
### Change this to the requierd working direcotry ###
#####################################################

setwd("D:/Desktop/Invidicual project practice/Data/roary output/Trees/VirFinder")
#loading in data and requierd librarys
library(tibble)
library(dplyr)

data = read.csv("dataset_color_string_VirFinder_grouped_ordered_withHomo.csv")
########################################
### Customise colour or colours here ###
########################################
MyColor = "#0f1fe1"

for (col in 2:ncol(data)){
  temp1 = data[,c(1,col)] # taking the isolate name column and which ever gene colun the loop is currently on
  temp1[temp1 == 0] = NA # turns all 0s into NAs
  temp2 = temp1[complete.cases(temp1),] # returns only the isolates (rows) in which the gene is found
  temp3 = add_column(temp2, color = MyColor, .after = "Isolate") # adding a colour column to the dataframe
  #this is formating the header for the metadata, everything by C could be put outside the loop
  a = "DATASET_COLORSTRIP"
  b = "SEPARATOR COMMA"
  c = paste("DATASET_LABEL", colnames(data)[col], sep = ",") #customising the dataset lable for match current gene
  d = paste("COLOR", MyColor, sep = ",")#customising the color for this datasets selected one
  e = "COLOR_BRANCHES,0" 
  f = "DATA"
  header = rbind.data.frame(a,b,c,d,e,f); colnames(header) = "Isolate" #Inputting the header into one dataframe and mating the colname to that first colum of the actual data containing df so we can rbind
  temp4 = bind_rows(header, temp3, .id = NULL)
  colnames(temp4) = NULL
  write.table(temp4, paste(colnames(data)[col],".txt", sep=""), sep = ",", row.names = FALSE, na = "", quote = FALSE)
}

#############################################################################################################################
### THESE .TXT FILES MUST BE PASSED THROUGH SED TO REMOVE THE DOUBLE COMMAS FROM THE MISSING ROWS WHERE THE HEADER EXISTS ###
### uSE THE FOLLOWING COMMAND:                                                                                            ###
###                                                                                                                       ###   
###          for file in *.txt;                                                                                           ###
###          do                                                                                                           ###
###          sed -i s/,,//g $file                                                                                         ###
###          Done                                                                                                         ###
###                                                                                                                       ###  
#############################################################################################################################