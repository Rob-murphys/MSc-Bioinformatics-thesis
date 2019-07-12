setwd("D:/Desktop/Invidicual project practice/Data/roary output")
library(plotly)
data = read.csv("summary_statistics.csv")[-5,]

plot_ly(data, labels = ~gene_type, values = ~count, type = "pie", textposition = "outside", textinfo = "text",text = ~paste(gene_type,"-", count), sort = FALSE, height = 350, width = 350)%>%
  layout(
    xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
    yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE, size = 20), showlegend = FALSE
    )  

setwd("D:/Desktop/Invidicual project practice/Data")
library(plotly)
data = read.csv("ResFinder_binary_gene_frequency.csv")[-5,]

plot_ly(data, labels = ~Resistance_gene, values = ~Frequency, type = "pie", textinfo = "text",text = ~paste(Resistance_gene), sort = FALSE, height = 450, width = 450)%>%
  layout(
    xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
    yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE), showlegend = FALSE,
    font = list(size = 14),
    margin = list(Resistance_gene = 160)
    )  


