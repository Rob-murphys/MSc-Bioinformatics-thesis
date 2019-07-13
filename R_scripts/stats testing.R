setwd("D:/Desktop/Invidicual project practice/Data")
library(tidyverse)
library(multcomp)

data = read.csv("phylo_totals.csv")

group_by(data, Phylogroup) %>%
  summarise(count = n(),
            mean = mean(Total, na.rm  = TRUE),
            sd = sd(Total, na.rm = TRUE)
            )

res.aov = aov(Total~Phylogroup, data = data)

summary(glht(res.aov, linfct = mcp(Phylogroup = "Tukey")))
