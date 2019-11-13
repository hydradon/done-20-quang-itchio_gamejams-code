all_jams <- read.csv("D:/ECE720 project/dataset/jams1.csv", 
                     encoding = "UTF-8",
                     stringsAsFactors = FALSE)

all_jams$duration <- as.numeric(difftime(parse_datetime(all_jams$jam_end_date, "%Y-%m-%d %H:%M:%S"),
                                         parse_datetime(all_jams$jam_start_date, "%Y-%m-%d %H:%M:%S"),
                                units = "days"))
  
# filter data for submissions vs duration analysis
# 1 hour < jam duration < 185 days, 10 < number of submissions < 700
filter_data_on_duration <- subset(all_jams, as.numeric(difftime(parse_datetime(jam_end_date, "%Y-%m-%d %H:%M:%S"),
                                                                  parse_datetime(jam_start_date, "%Y-%m-%d %H:%M:%S"),
                                                                  units = "days")) < 185 &
                                      jam_no_submissions>0 &
                                      jam_no_submissions<700 &
                                      as.numeric(difftime(parse_datetime(jam_end_date, "%Y-%m-%d %H:%M:%S"),
                                                          parse_datetime(jam_start_date, "%Y-%m-%d %H:%M:%S"),
                                                          units = "hours")) > 1)

filter_data_on_duration$duration <- as.numeric(difftime(parse_datetime(filter_data_on_duration$jam_end_date, "%Y-%m-%d %H:%M:%S"),
                                                          parse_datetime(filter_data_on_duration$jam_start_date, "%Y-%m-%d %H:%M:%S"),
                                                          units = "days"))

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
  geom_col(aes(group, avg), fill= "cyan3") +
  geom_text(aes(group, avg, label = round(avg, 0)), hjust = 0.2) +
  scale_x_discrete(labels = function(x) lapply(
    strwrap(x, width = 19, 
            simplify = FALSE),
    paste,
    collapse="\n")
  )+
  theme(axis.title.y=element_blank(),
        axis.text.y=element_text(size=7))+
  ylab("Count")+
  coord_flip()



cor.test(filter_data_on_duration$jam_no_submissions, 
         filter_data_on_duration$duration,
         method = c("spearman")) #-0.03759225
#0.1703439 => low correlation

library("ggpubr")
ggscatter(filter_data_on_duration, x = "jam_no_submissions", y = "duration", 
          add = "reg.line", conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "spearman",
          xlab = "Number of submissions", ylab = "Jam duration/day")

# Shapiro-Wilk normality test
shapiro.test(filter_data_on_duration$jam_no_submissions) #p-value < 2.2e-16 => not normally distributed
shapiro.test(filter_data_on_duration$duration) # p-value < 2.2e-16 => same

shapiro.test(all_jams$jam_no_submissions) #p-value < 2.2e-16 => not normally distributed
shapiro.test(all_jams$duration) # p-value < 2.2e-16 => same


qplot(filter_data_on_duration$jam_no_submissions, 
      filter_data_on_duration$duration, 
      data = filter_data_on_duration, 
      # geom = c("point", "smooth"),
      # se = FALSE,
      # method = "lm",
      xlab = "Number of submissions",
      ylab = "Jam duration/day",
      alpha = I(1 / 5))



