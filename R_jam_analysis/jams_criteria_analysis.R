# all_jams <- read.csv("D:/ECE720 project/dataset/jams-filter-converted.csv", stringsAsFactors = FALSE)
all_jams <- read.csv("D:/ECE720 project/dataset/jams1.csv", 
                     encoding = "UTF-8",
                     stringsAsFactors = FALSE)

sample_all_jams <- all_jams[sample(nrow(all_jams), 93), ]
write.csv(sample_all_jams, file = "jams-sample.csv",row.names=FALSE)

criteria_count <- read.csv("D:/ECE720 project/dataset/criteria_combined.csv", 
                     encoding = "UTF-8",
                     stringsAsFactors = FALSE)

library(ggplot2)
# Number of ranking ============================
num_rankings <- lengths(strsplit(competitive_jams$X.U.FEFF.jam_criteria, "\\|\\|"))
summary(num_rankings)
df_num_ranking <- as.data.frame(num_rankings)
ggplot(df_num_ranking, aes(x=num_rankings)) + 
  geom_histogram(binwidth=0.5)+
  ylab("Number of jams")+
  stat_bin(aes(label = ifelse(..count.. > 0, ..count.., "")), 
           geom="text", 
           binwidth=1, 
           vjust=-0.4)+
  scale_x_continuous("Number of criteria", 
                     labels = as.character(num_rankings), 
                     breaks = num_rankings)

# Top ranking criteria
library(tidyverse)
top10_crit <- criteria_count[order(-criteria_count$count),]
top_n(top10_crit, n=10, count) %>%
ggplot(., 
       aes(x = reorder(X.U.FEFF.criteria, -count), y = count))+ 
  geom_bar(stat="identity", fill="steelblue", width=0.5)+
  geom_text(aes(label = count), vjust=-0.3)+
  theme(axis.text.x=element_text(angle=0, hjust=0.5))+
  xlab("Ranking criteria")


# Find jam with most criteria
max <- 0
jam_max_criteria_url <- ""
for (row in  1:nrow(competitive_jams)) {
  
  num_criteria <- length(as.list(strsplit(competitive_jams[row, "X.U.FEFF.jam_criteria"], "\\|\\|")))
  print(num_criteria)
  # print(competitive_jams[row, "X.U.FEFF.jam_criteria"])
  if (num_criteria > max) {
    max <- num_criteria;
    jam_max_criteria_url <- competitive_jams[row, "jam_url"]
  }
}


