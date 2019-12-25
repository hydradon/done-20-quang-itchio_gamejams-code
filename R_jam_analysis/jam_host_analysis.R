host_count <- read.csv("D:/ECE720 project/dataset/host_count_submissions.csv", 
                       encoding = "UTF-8",
                       stringsAsFactors = FALSE)

host_count <- host_count[order(-host_count$count),]
top_host_plot <- top_n(host_count, n=5, count) %>% 
  ggplot(., 
         aes(x = reorder(X.U.FEFF.host, count), y = count))+ 
  geom_bar(stat="identity", color = "darkgreen", fill="chartreuse4", width=0.5)+
  labs(y = "# of jams")+
  scale_x_discrete(labels = function(x) lapply(
    strwrap(x, width = 15, 
            simplify = FALSE),
    paste,
    collapse="\n")
  )+
  scale_y_continuous(breaks = round(seq(0,120, by = 20), 1))+
  coord_flip()+
  theme(panel.background = element_blank(),
        axis.line = element_line(colour = "black"),
        axis.text=element_text(size=14),
        axis.title = element_text(size=14),
        axis.title.y=element_blank(),
        axis.text.x=element_text(size = 14, hjust=1),
        axis.text.y = element_text(hjust = 0.5, size = 14))


host_submission <- host_count[order(-host_count$total_submissions),]
top_host_submission_plot <- top_n(host_submission, n=5, total_submissions) %>% 
  ggplot(., 
         aes(x = reorder(X.U.FEFF.host, total_submissions), y = total_submissions))+ 
  geom_bar(stat="identity", color = "darkgreen", fill="chartreuse4", width=0.5)+
  # geom_text(data = host_submission[1, ], 
  #           aes(label = total_submissions),
  #           colour = "white",
  #           size = 4,
  #           vjust = 0.3, hjust = 2)+
  # theme(axis.text.x=element_text(angle=0, hjust=1),
  #       axis.title.y=element_blank(),
  #       axis.text.y = element_text(hjust = 0.5, size = 10))+
  labs(y = "# of submissions")+
  scale_x_discrete(labels = function(x) lapply(
    strwrap(x, width = 15, 
            simplify = FALSE),
    paste,
    collapse="\n")
  )+
  coord_flip()+
  theme(panel.background = element_blank(),
        axis.line = element_line(colour = "black"),
        axis.text=element_text(size=14),
        axis.title = element_text(size=14),
        axis.title.y=element_blank(),
        axis.text.x=element_text(size = 14, hjust=1),
        axis.text.y = element_text(hjust = 0.5, size = 14))


library(cowplot)
plot_grid(top_host_plot, top_host_submission_plot)

# drawing cdfs
library(ggplot2)
df_host <- as.data.frame(host_count)
ggplot(df_host, aes(x=count))+ 
  stat_ecdf(geom = "step")+
  labs(x = "Jam hosted")+
  theme_classic()+
  geom_vline(xintercept = 8, 
             color = "blue", size=0.5)+
  geom_hline(yintercept = 0.98, 
             color = "blue", size=0.5)






