all_games <- read.csv("D:/ECE720 project/dataset/non_competitive_game_details.csv", 
                      encoding = "UTF-8" ,
                      stringsAsFactors = FALSE)
all_jams <- read.csv("D:/ECE720 project/dataset/jams1.csv", 
                     encoding = "UTF-8" ,
                     stringsAsFactors = FALSE)
library(ggplot2)

# Game description lengths
summary(all_games$game_desc_len)
most_common_desc_len <- which.max(density(all_games$game_desc_len)$y)
ggplot(all_games, aes(x=game_desc_len))+ 
  geom_density(color="darkblue", fill="lightblue")+
  geom_vline(xintercept = most_common_desc_len)+
  xlab("attr")

require(scales)
desc_density <- density(all_games$game_desc_len)
plot(desc_density)
most_common_desc_len <- round(desc_density$x[which.max(d$y)], 1)

ggplot(data.frame(x = desc_density$x, 
                  y = desc_density$y * desc_density$n),
       aes(x, y))+ 
  geom_density(stat = "identity", fill = 'chartreuse1', alpha = 0.3) + 
  # geom_vline(xintercept = most_common_desc_len, lty = 2) +
  scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x)))+
  # geom_text(aes(x = most_common_desc_len, 
  #               y=10, 
  #               label = paste(most_common_desc_len, "characters", sep = " ")),
  #           size=3.5, angle = 90, vjust = -0.4, hjust = 3)+
  xlab("Description length (Character)")+
  ylab("Count")+
  scale_y_continuous(breaks = round(seq(0,100, by = 10), 1))



# Game number of screenshots 
library(tidyverse)
summary(all_games$game_no_screenshots)

df <- 
  all_games %>% 
  group_by(game_no_screenshots) %>% 
  count()

df %>% 
  ggplot(aes(x = game_no_screenshots, y = n)) +
  geom_col(width = 1, color = "cyan4", fill = "cyan3") +
  geom_text(data = . %>% filter(game_no_screenshots == 1), aes(label = n, y = n + 10000)) +
  scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x)))+
  scale_x_continuous(breaks = df %>% pull(game_no_screenshots))+ 
  theme(panel.grid.major.x = element_blank(), 
        panel.grid.minor.x = element_blank(),
        axis.text.x = element_text(hjust = 0.5, size = 7))+
  ylab("Count")+
  xlab("Number of screenshots")



# Game average session length
library(plotrix)
ggplot(all_games, aes(x=game_ave_session))+ 
  geom_bar(width = 0.5, fill = "coral3")+
  geom_text(stat='count', aes(label = ..count..), vjust = -0.5)+
  theme(axis.text.x=element_text(angle=50, hjust=1))+
  scale_y_continuous(expand = expand_scale(mult = c(0, .1)))+
  xlab("Game average session length")+
  scale_x_discrete(limits= c(
                             "A few seconds", 
                             "A few minutes", 
                             "About a half-hour",
                             "About an hour",
                             "A few hours",
                             "Days or more"),
                   label=c(
                           "A few seconds", 
                           "A few minutes", 
                           "About a half-hour",
                           "About an hour",
                           "A few hours",
                           "Days or more"))

# Game top 10 engines
library("dplyr") 
engine_count <- read.csv("D:/ECE720 project/dataset/game_made_with_count.csv", 
                      encoding = "UTF-8" ,
                      stringsAsFactors = FALSE)
engine_count <- engine_count[-c(1),]
engine_count %>%
  mutate(group = if_else(count < 410, "Others", X.U.FEFF.game_made_with)) %>%
  group_by(group) %>%
  summarize(avg = mean(count), count = n()) %>%
  ungroup() %>%
  mutate(group = if_else(group == "Others",
                         paste0("Others (n =", count, ")"),
                         group)) %>%
  mutate(group = forcats::fct_reorder(group, avg)) %>%
  ggplot() + 
  geom_col(aes(group, avg), 
           width = 0.5,
           fill = "aquamarine3") +
  geom_text(aes(group, avg, label = round(avg, 0)), 
            size = 3, hjust = -0.1) +
  theme(axis.title.y=element_blank())+
  ylab("Count")+
  coord_flip()



# Game top 20 game tags
library("dplyr") 
tag_count <- read.csv("D:/ECE720 project/dataset/game_tags_count.csv", 
                         encoding = "UTF-8" ,
                         stringsAsFactors = FALSE)
tag_count <- tag_count[-c(9),]
tag_count %>%
  mutate(group = if_else(count < 950, "Others", X.U.FEFF.game_tag)) %>%
  group_by(group) %>%
  summarize(avg = mean(count), count = n()) %>%
  ungroup() %>%
  mutate(group = if_else(group == "Others",
                         paste0("Others (n =", count, ")"),
                         group)) %>%
  mutate(group = forcats::fct_reorder(group, avg)) %>%
  ggplot() + 
  geom_col(aes(group, avg), 
           width = 0.7,
           fill = "tomato1") +
  geom_text(aes(group, avg, label = round(avg, 0)), 
            size = 3, hjust = 0.3, vjust = 0.38) +
  theme(axis.title.y=element_blank())+
  ylab("Count")+
  coord_flip()



# Game all genres
library("dplyr") 
genre_count <- read.csv("D:/ECE720 project/dataset/game_genre_count.csv", 
                      encoding = "UTF-8" ,
                      stringsAsFactors = FALSE)
genre_count <- genre_count[-c(5),]
genre_count %>%
  mutate(group = if_else(count < 0, "Others", X.U.FEFF.game_genre)) %>%
  group_by(group) %>%
  summarize(avg = mean(count), count = n()) %>%
  ungroup() %>%
  mutate(group = if_else(group == "Others",
                         paste0("Others (n =", count, ")"),
                         group)) %>%
  mutate(group = forcats::fct_reorder(group, avg)) %>%
  ggplot() + 
  geom_col(aes(group, avg), 
           width = 0.7,
           fill = "mediumorchid2") +
  geom_text(aes(group, avg, label = round(avg, 0)), 
            size = 3, hjust = 0.3, vjust = 0.38) +
  theme(axis.title.y=element_blank())+
  ylab("Count")+
  coord_flip()



# Game all accessibility
library("dplyr") 
accessibility_count <- read.csv("D:/ECE720 project/dataset/game_accessibility_count.csv", 
                        encoding = "UTF-8" ,
                        stringsAsFactors = FALSE)
accessibility_count <- accessibility_count[-c(1),]
accessibility_count %>%
  mutate(group = if_else(count < 0, "Others", X.U.FEFF.game_accessibility)) %>%
  group_by(group) %>%
  summarize(avg = mean(count), count = n()) %>%
  ungroup() %>%
  mutate(group = if_else(group == "Others",
                         paste0("Others (n =", count, ")"),
                         group)) %>%
  mutate(group = forcats::fct_reorder(group, avg)) %>%
  ggplot() + 
  geom_col(aes(group, avg), 
           width = 0.7,
           fill = "yellow3") +
  geom_text(aes(group, avg, label = round(avg, 0)), 
            size = 3, hjust = 0.3, vjust = 0.38) +
  theme(axis.title.y=element_blank())+
  ylab("Count")+
  coord_flip()



# Game all inputs
library("dplyr") 
input_count <- read.csv("D:/ECE720 project/dataset/game_input_count.csv", 
                                encoding = "UTF-8" ,
                                stringsAsFactors = FALSE)
input_count <- input_count[-c(1),]
input_count %>%
  mutate(group = if_else(count < 0, "Others", X.U.FEFF.game_input)) %>%
  group_by(group) %>%
  summarize(avg = mean(count), count = n()) %>%
  ungroup() %>%
  mutate(group = if_else(group == "Others",
                         paste0("Others (n =", count, ")"),
                         group)) %>%
  mutate(group = forcats::fct_reorder(group, avg)) %>%
  ggplot() + 
  geom_col(aes(group, avg), 
           width = 0.7,
           fill = "cyan1") +
  geom_text(aes(group, avg, label = round(avg, 0)), 
            size = 3, hjust = 0.3, vjust = 0.38) +
  theme(axis.title.y=element_blank())+
  ylab("Count")+
  coord_flip()



# Game all status
library("dplyr") 
status_count <- read.csv("D:/ECE720 project/dataset/game_status_count.csv", 
                        encoding = "UTF-8" ,
                        stringsAsFactors = FALSE)
status_count <- status_count[-c(4),]
status_count %>%
  mutate(group = if_else(count < 0, "Others", X.U.FEFF.game_status)) %>%
  group_by(group) %>%
  summarize(avg = mean(count), count = n()) %>%
  ungroup() %>%
  mutate(group = if_else(group == "Others",
                         paste0("Others (n =", count, ")"),
                         group)) %>%
  mutate(group = forcats::fct_reorder(group, avg)) %>%
  ggplot() + 
  geom_col(aes(group, avg), 
           width = 0.7,
           fill = "khaki3") +
  geom_text(aes(group, avg, label = round(avg, 0)), 
            size = 3, hjust = 0.3, vjust = 0.38) +
  theme(axis.title.y=element_blank())+
  ylab("Count")+
  coord_flip()

# Game number of developers
num_dev <- lengths(strsplit(all_games$game_developers, "\\|\\|"))
num_dev <- num_dev[num_dev >0]
df_num_dev <- as.data.frame(num_dev)

summary(num_dev)
ggplot(df_num_dev, aes(x=num_dev)) + 
  geom_histogram(binwidth=0.5, color = "khaki4", fill = "khaki3")+
  stat_bin(aes(label = ifelse(..count.. > 0, ..count.., "")), 
           geom="text", 
           binwidth=1, 
           vjust=-0.4)+
  scale_x_continuous("Number of developers per game", 
                     labels = as.character(num_dev), 
                     breaks = num_dev)+
  scale_y_log10("Count",
                breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x)))


# Game platforms count
platform_count <- read.csv("D:/ECE720 project/dataset/game_platforms_count.csv", 
                         encoding = "UTF-8" ,
                         stringsAsFactors = FALSE)
platform_count <- platform_count[-c(4, 9),]
platform_count %>%
  mutate(X.U.FEFF.game_platform = factor(X.U.FEFF.game_platform, 
                    levels = c("windows", "macos", "html5", "linux", "android", "unity", "flash"),
                    labels = c("Windows", "MacOS", "HTML5", "Linux", "Android", "Unity", "Flash"))) %>%
  ggplot(., aes(x = reorder(X.U.FEFF.game_platform, -count), y = count))+ 
  geom_bar(stat="identity", fill="darkturquoise", width = 0.5)+
  geom_text(aes(label = count), vjust=-0.3)+
  xlab("Platform")+
  scale_y_continuous(breaks = round(seq(0,40000, by = 5000), 1))



# Game license count
library(stringr)
library(scales)
license_count <- read.csv("D:/ECE720 project/dataset/game_license_count.csv", 
                           encoding = "UTF-8" ,
                           stringsAsFactors = FALSE)
license_count <- license_count[!(license_count$X.U.FEFF.game_license==""), ]
ggplot(license_count, 
       aes(x = reorder(X.U.FEFF.game_license, count), y = count))+
  geom_bar(stat = "identity", fill = "cadetblue")+
  geom_text(aes(label = count), 
            size = 3, hjust = -0.1, vjust = 0.38) +
  scale_x_discrete(labels = function(x) lapply(
    strwrap(x, width = 19, 
            simplify = FALSE),
    paste,
    collapse="\n")
  )+
  theme(axis.title.y=element_blank())+
  coord_flip()



# Game asset license count
library(stringr)
library(scales)
asset_license_count <- read.csv("D:/ECE720 project/dataset/game_asset_license_count.csv", 
                          encoding = "UTF-8" ,
                          stringsAsFactors = FALSE)
asset_license_count <- asset_license_count[!(asset_license_count$X.U.FEFF.game_asset_license==""), ]
ggplot(asset_license_count, 
       aes(x = reorder(X.U.FEFF.game_asset_license, count), y = count))+
  geom_bar(stat = "identity", fill = "darkgrey")+
  geom_text(aes(label = count), 
            size = 3, hjust = -0.1, vjust = 0.38) +
  scale_x_discrete(labels = function(x) lapply(
    strwrap(x, width = 19, 
            simplify = FALSE),
    paste,
    collapse="\n")
  )+
  theme(axis.title.y=element_blank())+
  coord_flip()






# Sample for SO
library(ggplot2)  
myData <- data.frame(
  x = c(rep(1, 22500), 
        rep(2, 6000), 
        rep(3, 8000), 
        rep(4, 5000), 
        rep(11, 86), 
        rep(16, 15), 
        rep(31, 1), 
        rep(32, 1), 
        rep(47, 1))
)

ggplot(myData, aes(x=x)) + 
  geom_bar(width = 0.5, color = "cyan4", fill = "cyan3")+
  geom_text(stat='count', aes(label = ..count..), vjust = -1, size=3)+
  scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x)))+
  scale_x_continuous(breaks=(seq(1:47)))



df <- 
  myData %>% 
  group_by(x) %>% 
  count()

df %>% 
  ggplot(aes(x = x, y = n)) +
  geom_col(color = "cyan4", fill = "cyan3") +
  geom_text(data = . %>% filter(x == 1), aes(label = n, y = n + 10000)) +
  scale_y_log10()+
  scale_x_continuous(breaks = df %>% pull(x))+ 
  theme(panel.grid.major.x = element_blank(), 
        panel.grid.minor.x = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1))
