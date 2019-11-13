all_games <- read.csv("D:/ECE720 project/dataset/non_competitive_game_details.csv", 
                      encoding = "UTF-8" ,
                      stringsAsFactors = FALSE)
all_jams <- read.csv("D:/ECE720 project/dataset/jams1.csv", 
                     encoding = "UTF-8" ,
                     stringsAsFactors = FALSE)



library(ggplot)
library(tidyverse)
library(plyr)

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
density(all_games_and_jams$update_time_post_jam)$x[x_max1]

# In normal scale
ggplot(all_games_and_jams, aes(x=update_time_post_jam))+ 
  geom_density(color="darkblue", fill="lightblue")+
  geom_vline(xintercept = density(all_games_and_jams$update_time_post_jam)$x[x_max1])+
  xlab("attr")


# In log scale
d <- density(all_games_and_jams$update_time_post_jam)
most_common_time <- round(d$x[which.max(d$y)], 1)

ggplot(data.frame(x = d$x, y = d$y * d$n), aes(x, y)) + 
  geom_density(stat = "identity", fill = 'burlywood', alpha = 0.3) + 
  geom_vline(xintercept = most_common_time, lty = 2) +
  scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x)))+
  geom_text(aes(x = most_common_time, 
                y=10, 
                label = paste(most_common_time, "Hours", ssep = " ")),
            size=3.5, angle = 90, vjust = -0.4, hjust = 3)+
  xlab("Time from jam end dates to last update (Hours)")+
  ylab("Count")+
  scale_y_continuous(breaks = round(seq(0,12, by = 1), 1))
























event <- data.frame(
  e_name = c("E1", "E2", "E3", "E4"),
  attr = c("attr1", "attr2", "attr3", "attr4")
)

activity <- data.frame(
  activity_name = c("A1-1", "A1-2", "A1-3", "A2", "A3-1", "A3-2"),
  e_name = c("E1", "E1", "E1", "E2", "E3", "E3")
)

merge(y=event, x=activity, by = "e_name")

