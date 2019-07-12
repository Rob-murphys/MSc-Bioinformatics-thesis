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
seed = c(123,456,789,135,246)
NRMSE.test = NULL
NRMSE.train = NULL
for( s in 1:length(seed)){
  smp.size = floor(0.75*nrow(out))
  set.seed(seed[s])
  selector = sample(seq_len(nrow(out)), size = smp.size )
  
  train.data = cbind.data.frame(t(out[selector,]), NA.count.avg)
  test.data = cbind.data.frame(t(out[-selector,]), NA.count.avg)
  
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
  NRMSE.train[s] = sum(NRMSE)/length(NRMSE)
  out.cut = as.data.frame(t((test.data[test.data$NA.count.avg <= 0.2,])))
  out.cut = out.cut[-nrow(out.cut),]
  out.cut = as.data.frame(sapply(out.cut, as.numeric))
  pred = predict(fit, out.cut, type="response", OOB = TRUE)
  
  fit.predictions = cbind.data.frame("Predcted frequency" = pred, "Actual frequency" = out.cut$Vir_factor_freq)
  row.names(fit.predictions) = rownames(t(test.data)[-ncol(test.data),])
  
  mse = mean((fit.predictions$`Actual frequency` - fit.predictions$`Predcted frequency`)^2)
  NRMSE.test[s] = sqrt(mse)/(max(fit.predictions$`Actual frequency`)-min(fit.predictions$`Actual frequency`))
}
mean.test = mean(NRMSE.test)
sd.test = sd(NRMSE.test)
n.test = length((NRMSE.test))
error.test = qnorm(0.975)*sd.test/sqrt(n.test)
lower.test = mean.test-error
upper.test = mean.test+error

mean.train = mean(NRMSE.train)
sd.train = sd(NRMSE.train)
n.train = length((NRMSE.train))
error.train = qnorm(0.975)*sd.train/sqrt(n.train)
lower.train = mean.train-error
upper.train = mean.train+error
