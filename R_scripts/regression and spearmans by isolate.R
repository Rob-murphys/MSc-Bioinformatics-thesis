#setting working directory and loading in modules
setwd("D:/Desktop/Invidicual project practice/Data")
library(tidyverse)
library(gridExtra)
# loading in data and metadata and getting true spearmans and LM values
data = read.csv("virFac_PerIso_with_meta.csv")[,c(1,2,4)]; row.names(data) = data$X; data = data[,-1]
spearmanTrue = as.numeric(cor.test(data$Adult.Body.Mass_g, data$Vir_factor_freq, method="spearman")[c(1,3,4)])
lmTrue = cbind("adj_r_square" = summary(lm(Vir_factor_freq~Adult.Body.Mass_g, data))$adj.r.squared, 
               "f_stat" = summary(lm(Vir_factor_freq~Adult.Body.Mass_g, data))$fstatistic[1],
               "p_val" = summary(lm(Vir_factor_freq~Adult.Body.Mass_g, data))$coefficients[2,4])

ggplot(data, aes(x = log10(Adult.Body.Mass_g), y = Vir_factor_freq))+
  geom_point()+
  stat_smooth(method = "lm", col = "red")+
  theme_minimal()+
  labs(x = "Log 10 Adult Body Mass", y = "Virulence Factor Frequency")
############### Resampling the data to conduct spearmans and LM on it ###########

R = 100 # number of times to resample
size = 82 # size of resampled dataframe
LMoutSummary = NULL
spearman = NULL
for (sample in 1:R){
  boot.sample = sample_n(data, size, replace = T) # the sampling
  bootReg = cbind("adj_r_square" = summary(lm(Vir_factor_freq~Adult.Body.Mass_g, boot.sample))$adj.r.squared, 
                  "f_stat" = summary(lm(Vir_factor_freq~Adult.Body.Mass_g, boot.sample))$fstatistic[1],
                  "p_val" = summary(lm(Vir_factor_freq~Adult.Body.Mass_g, boot.sample))$coefficients[2,4])# the regression
  LMoutSummary  = rbind.data.frame(LMoutSummary, bootReg)
  spearman = rbind.data.frame(spearman, as.numeric(cor.test(boot.sample$Adult.Body.Mass_g, boot.sample$Vir_factor_freq, method="spearman")[c(1,3,4)]))
}
colnames(spearman) = c("s_stat", "p_val", "rho")

######## Counting the number bootstrap sampeld datasets with larger of smaller relavent stats from the tests #######
LMoutSummaryCounts = rbind("larger_adj_r" = sum(as.numeric(LMoutSummary$adj_r_square > 0.006426783)), 
                           "smaller_adj_r" = sum(as.numeric(LMoutSummary$adj_r_square < 0.006426783)),
                           "larger_f_stat" = sum(as.numeric(LMoutSummary$f_stat > 1.523937)),
                           "smaller_f_stat" = sum(as.numeric(LMoutSummary$f_stat < 1.523937)),
                           "larger_p_value" = sum(as.numeric(LMoutSummary$p_val > 0.2206386)),
                           "smaller_p_value" = sum(as.numeric(LMoutSummary$p_val < 0.2206386)))
write.csv(LMoutSummaryCounts, "LM_bootstrap_counts.csv")

spearmanCounts = rbind("larger_s_stat" = sum(as.numeric(spearman$s_stat > 9.038083e+04)), 
                             "smaller_s_stat" = sum(as.numeric(spearman$s_stat < 9.038083e+04)),
                             "larger_p_value" = sum(as.numeric(spearman$p_val > 8.842452e-01)),
                             "smaller_p_value" = sum(as.numeric(spearman$p_val < 8.842452e-01)),
                             "larger_rho" = sum(as.numeric(spearman$rho > 1.632730e-02)),
                             "smaller_rho" = sum(as.numeric(spearman$rho < 1.632730e-02)))
write.csv(spearmanCounts,"spearman_bbostrap_count.csv")

######Plotting the above distributions and counts ###################
grid.arrange(ggplot(spearman, aes(x = s_stat))+
               geom_histogram(bins = 100)+
               geom_vline(aes(xintercept=spearmanTrue[1]), color="red", linetype="dashed", size =1)+
               labs(x = "s statistic", y = "Frequency")+
               theme_minimal(),
             
             ggplot(spearman, aes(x = p_val))+
               geom_histogram(bins = 100)+
               geom_vline(aes(xintercept = spearmanTrue[2]), color = "red", linetype="dashed")+
               labs(x = "p-value", y = "Frequency")+
               theme_minimal(),
             
             ggplot(spearman, aes(x = rho))+
               geom_histogram(bins = 100)+
               geom_vline(aes(xintercept = spearmanTrue[3], color = "True value"), linetype="dashed")+
               labs(x = "rho", y = "Frequency")+
               theme_minimal()+
               scale_color_manual(name = "Lines", values = c("True value" = "red")),
             ncol = 2)


grid.arrange(ggplot(LMoutSummary, aes(x = adj_r_square))+
              geom_histogram(bins = 100)+
              geom_vline(aes(xintercept=lmTrue[1]), color="red", linetype="dashed", size=1)+
              labs(x = "Adjusted R squared value", y = "Frequency")+
              theme_minimal(),

           ggplot(LMoutSummary, aes(x = f_stat))+
              geom_histogram(bins = 100)+
              geom_vline(aes(xintercept=lmTrue[2]), color = "red", linetype="dashed", size=1)+
              labs(x = "F statistic", y = "Frequency")+
              theme_minimal(),

            ggplot(LMoutSummary, aes(x = p_val))+
              geom_histogram(bins = 100)+
              geom_vline(aes(xintercept=lmTrue[3], color="True value"), linetype="dashed", size=1)+
              labs(x = "P-value", y = "Frequency")+
              theme_minimal()+
              scale_color_manual(name = "Lines", values = c("True value" = "red")),
            ncol = 2)
