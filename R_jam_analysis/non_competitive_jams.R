all_jams <- read.csv("D:/ECE720 project/dataset/jams1.csv", encoding = "UTF-8" ,stringsAsFactors = FALSE)

non_competitive_jams <- subset(all_jams, lengths(strsplit(X.U.FEFF.jam_criteria, "\\|\\|")) == 0)
competitive_jams <- subset(all_jams, lengths(strsplit(X.U.FEFF.jam_criteria, "\\|\\|")) > 0)

sample_non_competitive_jams <- non_competitive_jams[sample(nrow(non_competitive_jams), 91), ]

write.csv(sample_non_competitive_jams, file = "non-competitive-jams-sample.csv",row.names=FALSE)



library(tidyverse)
library(beanplot)
summary(all_jams$jam_no_submissions)
summary(competitive_jams$jam_no_submissions)
summary(non_competitive_jams$jam_no_submissions)

beanplot(competitive_jams$jam_no_submissions)

boxplot(competitive_jams$jam_no_submissions ~ non_competitive_jams$jam_no_submissions)
boxplot(non_competitive_jams$jam_no_submissions)

wilcox.test(competitive_jams$jam_no_submissions, 
            non_competitive_jams$jam_no_submissions, alternative = "less")


library(effsize)
cliff.delta(non_competitive_jams$jam_no_submissions, competitive_jams$jam_no_submissions)
