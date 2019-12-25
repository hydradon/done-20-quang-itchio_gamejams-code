all_games <- read.csv("D:/ECE720 project/dataset/all_games_details_cleaned.csv", 
                      encoding = "UTF-8" ,
                      stringsAsFactors = FALSE)
all_games <- all_games[!(all_games$game_developers==""),]
all_jams <- read.csv("D:/ECE720 project/dataset/jams1.csv", 
                     encoding = "UTF-8" ,
                     stringsAsFactors = FALSE)



library(ggplot)
library(tidyverse)
library(plyr)
library(scales)
all_games_and_jams <- merge(all_games, all_jams, by = "jam_name")

write.csv(all_games_and_jams, file = "test.csv")

all_games_and_jams <- all_games_and_jams[!(is.na(all_games_and_jams$game_last_update) | all_games_and_jams$game_last_update==""), ]


all_games_and_jams$update_time_post_jam <- as.numeric(difftime(parse_datetime(all_games_and_jams$game_last_update, "%d %B %Y @ %H:%M"),
                                                               parse_datetime(all_games_and_jams$jam_end_date, "%Y-%m-%d %H:%M:%S"),
                                                        units = "hours"))

# Only consider where last update is equal or later than game end date
all_games_and_jams <- all_games_and_jams[!all_games_and_jams$update_time_post_jam < 0, ]
summary(all_games_and_jams$update_time_post_jam)


x_max1 <- which.max(density(all_games_and_jams$update_time_post_jam)$y)
most_common_time <- density(all_games_and_jams$update_time_post_jam)$x[x_max1]

# In normal scale
ggplot(all_games_and_jams, aes(x=update_time_post_jam))+ 
  geom_density(color="darkblue", fill="lightblue")+
  geom_vline(xintercept = density(all_games_and_jams$update_time_post_jam)$x[x_max1])+
  xlab("attr")


# In log scale
d <- density(all_games_and_jams$update_time_post_jam)
most_common_time <- round(d$x[which.max(d$y)], 1)
mean_update_time <- mean(all_games_and_jams$update_time_post_jam)

ggplot(data.frame(x = d$x, y = d$y * d$n), aes(x, y)) + 
  geom_density(stat = "identity", color="darkblue", fill = 'lightblue', alpha = 0.3) + 
  geom_vline(xintercept = mean(all_games_and_jams$update_time_post_jam), lty = 2) +
  scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x)))+
  geom_text(aes(x = mean_update_time,
                y=1, 
                label = paste("Mean: ", paste(round(mean_update_time/730, 1), " months"))),
            size=4, angle = 0, vjust = -10.6, hjust = -0.2)+
  xlab("Time from jam end dates to last update (Hours)")+
  ylab("# of games")+
  scale_y_continuous(breaks = round(seq(0,3, by = 0.5), 1))+
  theme(panel.background = element_blank(),
        axis.line = element_line(colour = "black"),
        axis.text=element_text(size=13),
        axis.title = element_text(size=13),
        axis.text.x=element_text(size = 13, hjust=1),
        axis.text.y = element_text(hjust = 0.5, size = 13))

