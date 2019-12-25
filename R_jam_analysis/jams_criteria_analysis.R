# all_jams <- read.csv("D:/ECE720 project/dataset/jams-filter-converted.csv", stringsAsFactors = FALSE)
all_jams <- read.csv("D:/ECE720 project/dataset/jams1.csv", 
                     encoding = "UTF-8",
                     stringsAsFactors = FALSE)

# sample_all_jams <- all_jams[sample(nrow(all_jams), 93), ]
# write.csv(sample_all_jams, file = "jams-sample.csv",row.names=FALSE)
competitive_jams <- subset(all_jams, lengths(strsplit(X.U.FEFF.jam_criteria, "\\|\\|")) > 0)
library(ggplot2)
library(dplyr)

# Number of ranking ============================
num_rankings <- lengths(strsplit(competitive_jams$X.U.FEFF.jam_criteria, "\\|\\|"))
summary(num_rankings)
df_num_ranking <- as.data.frame(num_rankings)


num_ranking_plot <-
  df_num_ranking %>%
  group_by(num_rankings) %>% 
  count() %>% 
  ggplot(., aes(x = num_rankings, y = n)) +
  geom_col(width = 0.5, color = "darkgreen", fill = "chartreuse4") +
  # geom_text(data = . %>% filter(num_rankings == 5), 
  #           aes(label = n),
  #           colour = "white",
  #           size = 3,
  #           vjust = 0.3, hjust = 2)+
  scale_x_continuous(labels = as.character(num_rankings), 
                     breaks = num_rankings)+
  labs(x = "# of criteria", y = "# of jams")+
  coord_flip()+
  theme(panel.background = element_blank(),
        axis.line = element_line(colour = "black"),
        axis.text=element_text(size=13),
        axis.title = element_text(size=13),
        axis.text.x=element_text(size = 13, hjust=1),
        axis.text.y = element_text(hjust = 0.5, size = 13))




# Top ranking criteria
criteria_count <- read.csv("D:/ECE720 project/dataset/criteria_combined.csv", 
                           encoding = "UTF-8",
                           stringsAsFactors = FALSE)

criteria_count <- criteria_count[order(-criteria_count$count),]

top_crit_plot <- top_n(criteria_count, n=10, count) %>% 
  ggplot(., 
         aes(x = reorder(X.U.FEFF.criteria, count), y = count))+ 
  geom_bar(stat="identity", color = "darkgreen", fill="chartreuse4", width=0.5)+
  # geom_text(data = criteria_count[1, ], 
  #           aes(label = count),
  #           colour = "white",
  #           size = 3,
  #           vjust = 0.3, hjust = 2)+
  theme(axis.text.x=element_text(angle=0, hjust=1),
        axis.text.y = element_text(hjust = 0.5, size = 7))+
  labs(x = "Ranking criteria", y = "# of jams")+
  coord_flip()+
  theme(panel.background = element_blank(),
        axis.line = element_line(colour = "black"),
        axis.text=element_text(size=13),
        axis.title = element_text(size=13),
        axis.text.x=element_text(size = 13, hjust=1),
        axis.text.y = element_text(hjust = 0.5, size = 13))


# Combine
library(cowplot)
plot_grid(num_ranking_plot, top_crit_plot)





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


