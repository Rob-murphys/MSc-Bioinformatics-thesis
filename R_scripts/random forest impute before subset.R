#setting working directory and loading in modules
setwd("D:/Desktop/Invidicual project practice/Data")
library(tidyverse)
library(missForest)
library(randomForest)
data = read.csv("Vir_freq_grouped_PerIsolate_orderd_withHomo.csv")
meta = read.csv("Regression_meta.csv",stringsAsFactors = FALSE)
meta[meta == -999] = NA

############### Counting th number of genes per isolate ##########
sum = rowSums(data[,-1:-4])
sum.iso  = cbind.data.frame(data[,c(1,4)], "Vir_factor_freq" = sum)

######### This is merging the extrapolated values with the real value columns in the metadata ###################
meta.merge = meta; meta.merge[is.na(meta.merge)] = "" 
meta.merge$Adult.Body.Mass_g = paste(meta.merge$Adult.Body.Mass_g, meta.merge$AdultBodyMass_g_EXT)
meta.merge$LittersPerYear = paste(meta.merge$LittersPerYear, meta.merge$LittersPerYear_EXT)
meta.merge$NeonateBodyMass_g = paste(meta.merge$NeonateBodyMass_g, meta.merge$NeonateBodyMass_g_EXT)
meta.merge$WeaningBodyMass_g = paste(meta.merge$WeaningBodyMass_g, meta.merge$WeaningBodyMass_g_EXT)
meta.merge = meta.merge[,-36:-39]; 
meta.merge[meta.merge == ""] = NA
meta.merge[meta.merge == " "] = NA
meta.merge[,6:ncol(meta.merge)] = sapply(meta.merge[,6:ncol(meta.merge)], as.numeric)

############# Imputing missing data on whole metadataset ########################
outNoMiss = missForest(meta.merge[-1:-5], ntree = 100, maxiter = 10)
out.imp = cbind(meta.merge[,1:5], outNoMiss$ximp)

out = NULL
tempOut = NULL
out.noImp = NULL
tempOut.noImp = NULL
for (iso in 1:nrow(sum.iso)){
  temp1 = sum.iso[iso,]
  temp2 = out.imp[out.imp$Binomial %in% temp1$Spieces,]
  temp3 = meta.merge[meta.merge$Binomial %in% temp1$Spieces,]
  if (nrow(temp2) == 0) next
  tempOut = cbind(temp1, temp2[,-1:-5])
  tempOut.noImp = cbind(temp1,temp3[,-1:-5])
  out = rbind(out,tempOut)
  out.noImp = rbind(out.noImp, tempOut.noImp)
}
out[out == "NaN"] = NA; out.noImp[out.noImp == "NaN"] = NA
rownames(out) = out$Isolate; out = out[,-1:-2]; rownames(out.noImp) = out.noImp$Isolate; out.noImp = out.noImp[,-1:-2]



# Counting the number of missing values in the metadata
NA.count = apply(out.noImp, 2, function(x) length(which(is.na(x))))
NA.count.avg = NA.count/nrow(out.noImp) # getting the ratio of missingness
barplot(sort(NA.count.avg), las = 2)

######################## Excplcit training and test dataset ##########################

# seperating the dataset randomly into training and test dtasets 
smp.size = floor(0.75*nrow(out))
set.seed(123)
selector = sample(seq_len(nrow(out)), size = smp.size )

train.data = cbind.data.frame(t(out[selector,]), NA.count.avg)
test.data = cbind.data.frame(t(out[-selector,]), NA.count.avg)

################ Sensitivity analysis for missingness threshold ##########################################

# defining the variables needed for the loop
cut.off = c(0.2,0.25,0.3,0.35,0.4,0.45,0.5,0.55,0.6,0.65,0.7,0.75,0.8,0.85,0.9,0.95)
NRMSE = NULL
NRMSE.avg = NULL
NRMSE.out = NULL
for (CO in 1:length(cut.off)){
  out.cut = as.data.frame(t((train.data[train.data$NA.count.avg <= cut.off[CO],])), stringsAsFactors = FALSE)
  out.cut = out.cut[-nrow(out.cut),]
  out.cut = as.data.frame(sapply(out.cut, as.numeric))
  for(run in 1:100){
    fit = randomForest(out.cut$Vir_factor_freq ~ .,out.cut[,-1], importance = TRUE, ntree = 500, replace = TRUE)
    NRMSE[run] = sqrt(fit$mse[length(fit$mse)])/(max(out.cut$Vir_factor_freq)-min(out.cut$Vir_factor_freq))
    }
  NRMSE.avg = cbind(cut.off[CO], sum(NRMSE)/length(NRMSE))
  NRMSE.out = rbind(NRMSE.out,NRMSE.avg)
  }
}
colnames(NRMSE.out) = c("missingness threshold", "NRMSE"); NRMSE.out = as.data.frame(NRMSE.out)
############################ Sensitivity analysis for mtry ######################################
out.cut = as.data.frame(t((train.data[train.data$NA.count.avg <= 0.2,])), stringsAsFactors = FALSE) # setting s static subset data as we know the optimal threshold now
out.cut = out.cut[-nrow(out.cut),]
out.cut = as.data.frame(sapply(out.cut, as.numeric))
mtry = c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30)
NRMSE.avg = NULL
NRMSE.out = NULL
for(mt in 1:length(mtry)){
  NRMSE.store = NULL
  for(run in 1:100){
    fit = randomForest(out.cut$Vir_factor_freq ~ .,out.cut[,-1], importance = TRUE, ntree = 700, replace = TRUE, mtry = mtry[mt])
    NRMSE[run] = sqrt(fit$mse[length(fit$mse)])/(max(out.cut$Vir_factor_freq)-min(out.cut$Vir_factor_freq))
  }
  NRMSE.avg = cbind(mtry[mt], sum(NRMSE)/length(NRMSE))
  NRMSE.out = rbind(NRMSE.out,NRMSE.avg)
}
colnames(NRMSE.out) = c("mtry", "NRMSE"); NRMSE.out = as.data.frame(NRMSE.out)

ggplot(NRMSE.out, aes(x = mtry, y = NRMSE))+
  geom_point()+
  scale_y_reverse()+
  geom_smooth(se = FALSE, method = "gam", formula = y ~ log(x))

################ This is the actual Random Forest, ran 100 times so we can average over the ################
################## feature importance (as it seems to change with each run) ##################################

# This look is the actual random forest loop, allowing me to get an average feature importance for each feature
out.cut = as.data.frame(t((train.data[train.data$NA.count.avg <= 0.2,])), stringsAsFactors = FALSE) # setting s static subset data as we know the optimal threshold now
out.cut = out.cut[-nrow(out.cut),]
out.cut = as.data.frame(sapply(out.cut, as.numeric))
rownames(out.cut) = rownames(out.cut)
nforest = 100
features = NULL
NRMSE = NULL
for (forest in 1:nforest){
  fit = randomForest(out.cut$Vir_factor_freq ~ .,out.cut[,-1], importance = TRUE, ntree = 700, replace = TRUE, mtry = 7)
  df = as.data.frame(fit$importance) %>% rownames_to_column(., "Features")
  features = rbind.data.frame(features, df)
  NRMSE[forest] = sqrt(fit$mse[length(fit$mse)])/(max(out.cut$Vir_factor_freq)-min(out.cut$Vir_factor_freq))
}
NRMSE.avg = sum(NRMSE)/length(NRMSE)
unq.feat = unique(as.character(features$Features))
# This is averaging the featue importance from all the forests
avg.feat = NULL
for(x in 1:length(unique(features$Features))){
  subset = features[features$Features %in% unq.feat[x],]
  subset.avg = colSums(subset[,-1]/nrow(subset))
  avg.feat = rbind(avg.feat,subset.avg)
}
var.imp = cbind.data.frame(unq.feat, avg.feat, row.names = NULL); colnames(var.imp) = c("Features", "IncMSE", "IncNodePurity")

ggplot(var.imp, aes(x=reorder(Features, IncMSE) , y=as.numeric(IncMSE))) + 
  geom_point(color =  "#0a39f9" ) +
  geom_segment(aes(xend=Features), yend=0, color = "#0a39f9")+
  ylab("% Increased MSE") +
  xlab("Feature Name") +
  theme_minimal()+
  coord_flip()+
  theme(panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))

out.cut = as.data.frame(t((test.data[test.data$NA.count.avg <= 0.2,])))
out.cut = out.cut[-nrow(out.cut),]
out.cut = as.data.frame(sapply(out.cut, as.numeric))
pred = predict(fit, out.cut, type="response", OOB = TRUE)

fit.predictions = cbind.data.frame("Predcted frequency" = pred, "Actual frequency" = out.cut$Vir_factor_freq)
row.names(fit.predictions) = rownames(t(test.data)[-ncol(test.data),])
write.csv(fit.predictions, "predicted_vir_factors.csv")
