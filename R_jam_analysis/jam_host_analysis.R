host_count <- read.csv("D:/ECE720 project/dataset/host_count_submissions.csv", 
                       encoding = "UTF-8",
                       stringsAsFactors = FALSE)


host_count %>%
  mutate(group = if_else(count < 10, "Others", X.U.FEFF.host)) %>%
  group_by(group) %>%
  summarize(avg = mean(count), count = n()) %>%
  ungroup() %>%
  mutate(group = if_else(group == "Others",
                         paste0("Others (n =", count, ")"),
                         group)) %>%
  mutate(group = forcats::fct_reorder(group, avg)) %>%
  ggplot() + 
  geom_col(aes(group, avg)) +
  geom_text(aes(group, avg, label = round(avg, 0)), hjust = -0.5) +
  theme(axis.title.y=element_blank())+
  ylab("Number of submissions")+
  coord_flip()

host_count %>%
  mutate(group = if_else(total_submissions < 550, "Others", X.U.FEFF.host)) %>%
  group_by(group) %>%
  summarize(avg = mean(total_submissions), count = n()) %>%
  ungroup() %>%
  mutate(group = if_else(group == "Others",
                         paste0("Others (n =", count, ")"),
                         group)) %>%
  mutate(group = forcats::fct_reorder(group, avg)) %>%
  ggplot() + 
  geom_col(aes(group, avg)) +
  geom_text(aes(group, avg, label = round(avg, 0)), hjust = -0.5) +
  theme(axis.title.y=element_blank())+
  ylab("Number of submissions")+
  coord_flip()

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


# Creat bar chart for jam language
library("ggplot2")  # Data visualization
library("dplyr")    # Data manipulation
library("RColorBrewer")
myPalette <- brewer.pal(5, "Set2") 


jam_languages <- data.frame(
  Languages = c("English", "French", "Spanish", "Portuguese", "Others"),
  n = c(81, 4, 3, 2, 3),
  prop = c(87.1, 4.3, 3.2, 2.2, 3.2)
)

# Add label position
jam_languages <-jam_languages %>%
  arrange(desc(Languages)) %>%
  # mutate(lab.ypos = cumsum(n) - 0.5*n)
  mutate(end = 2 * pi * cumsum(prop)/sum(prop),
       start = lag(end, default = 0),
       middle = 0.5 * (start + end),
       hjust = ifelse(middle > pi, 1, 0),
       vjust = ifelse(middle < pi/2 | middle > 3 * pi/2, 0, 1))


ggplot(jam_languages, aes(x = "", y = n, fill = Languages)) +
  geom_bar(width = 1, stat = "identity", color = "white") +
  coord_polar("y", start = 0)+
  geom_text(aes(y = lab.ypos, label = n), color = "white")+
  scale_fill_manual(values = myPalette) +
  theme_void()

lang = c("English", "French", "Spanish", "Portuguese", "Others")
prop = c(87.1, 4.3, 3.2, 2.2, 3.2)
pie(prop, labels = prop, main = "Jam languages",col = myPalette)
legend("topright", lang, cex = 0.8,
       fill = myPalette)


ggplot(jam_languages) + 
  geom_arc_bar(aes(x0 = 0, y0 = 0, r0 = 0, r = 1,
                   start = start, end = end, fill = Languages)) +
  geom_text(aes(x = 1.05 * sin(middle), y = 1.05 * cos(middle), label = prop,
                hjust = hjust, vjust = vjust)) +
  coord_fixed() +
  scale_x_continuous(limits = c(-1.5, 1.4),  # Adjust so labels are not cut off
                     name = "", breaks = NULL, labels = NULL) +
  scale_y_continuous(limits = c(-1, 1),      # Adjust so labels are not cut off
                     name = "", breaks = NULL, labels = NULL)


par(mfrow=c(1,1), mai = c(0, 0.1, 0.5, 0.1))
pie(1:5)
pie(rep(1,5))


library(RColorBrewer)
Languages = c("English", "French", "Spanish", "Portuguese", "Others")
n = c(81, 4, 3, 2, 3)
prop = c("87.1", "4.3", "3.2", "2.2", "3.2")

lbls <- paste(n, "(", sep = " ")
lbls <- paste(lbls, prop, sep = "")
lbls <- paste(lbls,"%",sep=" ")
lbls <- paste(lbls,")",sep="")
lgd <- c("English", "French", "Spanish", "Portuguese", "Others")
cols = brewer.pal(n = length(prop), name = 'Set2')
pie(n, labels = lbls, col=cols)
legend("topright", legend=lgd, cex=1, bty = "y", fill = cols)

