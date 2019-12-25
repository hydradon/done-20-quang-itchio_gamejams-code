all_jams <- read.csv("D:/ECE720 project/dataset/jams1.csv", 
                     encoding = "UTF-8",
                     stringsAsFactors = FALSE)

filter_data_on_submissions <- subset(all_jams, jam_no_submissions>0 &
                                               jam_no_submissions<700)

library(ggplot2)
library(scales)

density_no_submissions <- density(all_jams$jam_no_submissions)

ggplot(data.frame(x = density_no_submissions$x, 
                  y = density_no_submissions$y * density_no_submissions$n), 
       aes(x, y)) + 
  geom_density(stat = "identity", fill = 'blue', alpha = 0.3) + 
  geom_vline(xintercept = mean(all_jams$jam_no_submissions), lty = 2) +
  scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x)))+
  geom_text(data = labels, aes(x = mean(all_jams$jam_no_submissions), y=0, 
                               label = round(mean(all_jams$jam_no_submissions), 1)),
            size=4, angle = 0, vjust = -10.6, hjust = -0.2)+
  xlab("Number of submissions")+
  ylab("Count")+
  scale_y_continuous(breaks = round(seq(0,300, by = 20), 1))



summary(all_jams$jam_no_submissions)

#  top jams by numver of submission
all_jams %>%
  mutate(group = if_else(jam_no_submissions < 300, "Others", jam_name)) %>%
  group_by(group) %>%
  summarize(avg = mean(jam_no_submissions), count = n()) %>%
  ungroup() %>%
  mutate(group = if_else(group == "Others",
                         paste0("Others (n = ", count, "), average count"),
                         group)) %>%
  mutate(group = forcats::fct_reorder(group, avg)) %>%
  ggplot() + 
  geom_col(aes(group, avg), 
           fill= "grey", width = 0.5) +
  geom_text(aes(group, avg, label = round(avg, 0)), 
            color = "black",
            size = 4,
            hjust = 0.2) +
  scale_x_discrete(labels = function(x) lapply(
    strwrap(x, width = 19, 
            simplify = FALSE),
    paste,
    collapse="\n")
  )+
  theme(axis.title.y=element_blank(),
        axis.text.y=element_text(size=10))+
  ylab("Count")+
  coord_flip()



