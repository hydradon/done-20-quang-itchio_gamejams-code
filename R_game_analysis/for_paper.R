

library(ggplot2)
library(dplyr) 
library(scales)

# Game top 10 engines
engine_count <- read.csv("D:/ECE720 project/dataset/game_made_with_count.csv", 
                         encoding = "UTF-8" ,
                         stringsAsFactors = FALSE)
engine_count <- engine_count[!(engine_count$X.U.FEFF.game_made_with==""),]
engine_count <- engine_count[order(-engine_count$count),]
top_engine_plot <- top_n(engine_count, n=5, count) %>% 
  ggplot(., 
         aes(x = reorder(X.U.FEFF.game_made_with, count), y = count))+ 
  geom_bar(stat="identity", 
           color = "darkgreen", fill="chartreuse4",
           width=0.5)+
  # geom_text(data = engine_count[1, ], 
  #           aes(label = count),
  #           colour = "white",
  #           size = 3,
  #           vjust = 0.3, hjust = 2)+
  labs(x = "Tools", y = "# of games")+
  scale_x_discrete(labels = function(x) lapply(
    strwrap(x, width = 15, 
            simplify = FALSE),
    paste,
    collapse="\n")
  )+
  scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x)))+
  coord_flip()+
  theme(panel.background = element_blank(),
        axis.line = element_line(colour = "black"),
        axis.text=element_text(size=9),
        axis.title = element_text(size=9),
        axis.text.x=element_text(size = 9, hjust=1),
        axis.text.y = element_text(hjust = 0.5, size = 9))


# Game all accessibility
accessibility_count <- read.csv("D:/ECE720 project/dataset/game_accessibility_count.csv", 
                                encoding = "UTF-8" ,
                                stringsAsFactors = FALSE)
accessibility_count <- accessibility_count[!(accessibility_count$X.U.FEFF.game_accessibility==""),]
accessibility_count <- accessibility_count[order(-accessibility_count$count),]
top_acc_plot <- top_n(accessibility_count, n=10, count) %>% 
  ggplot(., aes(x = reorder(X.U.FEFF.game_accessibility, count),
                y = count))+ 
  geom_bar(stat="identity", color = "darkgreen", fill="chartreuse4", width=0.5)+
  # geom_text(data = accessibility_count[1, ], 
  #           aes(label = count),
  #           colour = "white",
  #           size = 3,
  #           vjust = 0.3, hjust = 2)+
  labs(x = "Accessibility support type", y = "# of games")+
  scale_x_discrete(labels = function(x) lapply(
    strwrap(x, width = 19, 
            simplify = FALSE),
    paste,
    collapse="\n")
  )+
  coord_flip()+
  theme(panel.background = element_blank(),
        axis.line = element_line(colour = "black"),
        axis.text=element_text(size=9),
        axis.title = element_text(size=9),
        axis.text.x=element_text(size = 9, hjust=1),
        axis.text.y = element_text(hjust = 0.5, size = 8))


# Game all inputs
input_count <- read.csv("D:/ECE720 project/dataset/game_inputs_count.csv", 
                        encoding = "UTF-8" ,
                        stringsAsFactors = FALSE)
input_count <- input_count[!(input_count$X.U.FEFF.game_inputs==""),]
input_count <- input_count[order(-input_count$count),]

top_input_plot <- top_n(input_count, n=5, count) %>% 
  ggplot(., aes(x = reorder(X.U.FEFF.game_inputs, count),
                y = count))+ 
  geom_bar(stat="identity", color = "darkgreen", fill="chartreuse4", width=0.5)+
  # geom_text(data = input_count[1, ], 
  #           aes(label = count),
  #           colour = "white",
  #           size = 3,
  #           vjust = 0.3, hjust = 2)+
  labs(x = "Input support type", y = "# of games")+
  scale_x_discrete(labels = function(x) lapply(
    strwrap(x, width = 13, 
            simplify = FALSE),
    paste,
    collapse="\n")
  )+
  scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x)))+
  coord_flip()+
  theme(panel.background = element_blank(),
        axis.line = element_line(colour = "black"),
        axis.text=element_text(size=9),
        axis.title = element_text(size=9),
        axis.text.x=element_text(size = 9, hjust=1),
        axis.text.y = element_text(hjust = 0.5, size = 9))



# Game all status
status_count <- read.csv("D:/ECE720 project/dataset/game_status_count.csv", 
                         encoding = "UTF-8" ,
                         stringsAsFactors = FALSE)
status_count <- status_count[!(status_count$X.U.FEFF.game_status==""),]
status_count <- status_count[order(-status_count$count),]
top_status_plot <- top_n(status_count, n=10, count) %>% 
  ggplot(., aes(x = reorder(X.U.FEFF.game_status, count),
                y = count))+ 
  geom_bar(stat="identity", color = "darkgreen", fill="chartreuse4", width=0.5)+
  # geom_text(data = status_count[1, ], 
  #           aes(label = count),
  #           colour = "white",
  #           size = 3,
  #           vjust = 0.3, hjust = 2)+
  labs(x = "Game status", y = "# of games")+
  scale_x_discrete(labels = function(x) lapply(
    strwrap(x, width = 14, 
            simplify = FALSE),
    paste,
    collapse="\n")
  )+
  scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x)))+
  coord_flip()+
  theme(panel.background = element_blank(),
        axis.line = element_line(colour = "black"),
        axis.text=element_text(size=9),
        axis.title = element_text(size=9),
        axis.text.x=element_text(size = 9, hjust=1),
        axis.text.y = element_text(hjust = 0.5, size = 9))

# Game platform count
platform_count <- read.csv("D:/ECE720 project/dataset/game_platforms_count.csv", 
                           encoding = "UTF-8" ,
                           stringsAsFactors = FALSE)
platform_count <- platform_count[!(platform_count$X.U.FEFF.game_platforms=="" | platform_count$X.U.FEFF.game_platforms=="java"),]
platform_count <- platform_count %>%
  mutate(X.U.FEFF.game_platforms = factor(X.U.FEFF.game_platforms,
                                          levels = c("windows","html5", "macos", "linux",
                                                     "android", "unity", "flash"),
                                          labels = c("Windows", "HTML5", "MacOS", "Linux",
                                                     "Android", "Unity", "Flash")))
platform_count <- platform_count[order(-platform_count$count),]

top_platform_plot <- top_n(platform_count, n=5, count) %>% 
  ggplot(., aes(x = reorder(X.U.FEFF.game_platforms, count),
                y = count))+ 
  geom_bar(stat="identity", color = "darkgreen", fill="chartreuse4", width=0.5)+
  # geom_text(data = platform_count[1, ], 
  #           aes(label = count),
  #           colour = "white",
  #           size = 3,
  #           vjust = 0.3, hjust = 2)+
  labs(x = "Supported platforms", y = "# of games")+
  scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x)))+
  coord_flip()+
  theme(panel.background = element_blank(),
        axis.line = element_line(colour = "black"),
        axis.text=element_text(size=9),
        axis.title = element_text(size=9),
        axis.text.x=element_text(size = 9, hjust=1),
        axis.text.y = element_text(hjust = 0.5, size = 9))

# Game number of developers
num_dev <- lengths(strsplit(all_games$game_developers, "\\|\\|"))
numdev_count <- as.data.frame(num_dev)
top_numdev_plot <-  
  numdev_count %>% 
  group_by(num_dev) %>% 
  count() %>% 
  ggplot(., aes(x = num_dev, y = n)) +
  geom_col(width = 0.5, color = "darkgreen", fill = "chartreuse4") +
  # geom_text(data = . %>% filter(num_dev == 1), 
  #           aes(label = n),
  #           colour = "white",
  #           size = 3,
  #           vjust = 0.3, hjust = 2)+
  scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x)))+
  scale_x_continuous(labels = as.character(num_dev), 
                     breaks = num_dev)+
  labs(x = "# of developers", y = "# of games")+
  coord_flip()+
  theme(panel.background = element_blank(),
        axis.line = element_line(colour = "black"),
        axis.text=element_text(size=9),
        axis.title = element_text(size=9),
        axis.text.x=element_text(size = 9, hjust=1),
        axis.text.y = element_text(hjust = 0.5, size = 9))



library(cowplot)
plot_grid(top_engine_plot, 
          top_acc_plot,
          top_input_plot,
          top_status_plot,
          top_platform_plot,
          top_numdev_plot)
