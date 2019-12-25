all_jams <- read.csv("D:/ECE720 project/dataset/jams1.csv", 
                     encoding = "UTF-8",
                     stringsAsFactors = FALSE)
library(ggplot2)
library(tidyverse)
library(scales) 
# Analyse jams duration
summary(as.data.frame(as.numeric(difftime(parse_datetime(all_jams$jam_end_date, "%Y-%m-%d %H:%M:%S"),
                                          parse_datetime(all_jams$jam_start_date, "%Y-%m-%d %H:%M:%S"),
                                          units = "days"))))

all_jams$duration <- as.numeric(difftime(parse_datetime(all_jams$jam_end_date, "%Y-%m-%d %H:%M:%S"),
                                         parse_datetime(all_jams$jam_start_date, "%Y-%m-%d %H:%M:%S"),
                                         units = "days"))
### filter data with truncated 1% longest jams, and with duration longer 1 hour
filter_data_on_duration <- all_jams %>% top_frac(1-0.01, -duration)
filter_data_on_duration <- subset(filter_data_on_duration,  
                                  as.numeric(difftime(parse_datetime(jam_end_date, "%Y-%m-%d %H:%M:%S"),
                                                      parse_datetime(jam_start_date, "%Y-%m-%d %H:%M:%S"),
                                                      units = "hours")) > 1)



summary(filter_data_on_duration$duration)
dfs_filtered <- stack(as.data.frame(filter_data_on_duration$duration))

#finding max values
x_max1 <- which.max(density(dfs_filtered$values)$y)
density(dfs_filtered$values)$x[x_max1] # 2.64398
ggplot(dfs_filtered, aes(x=values)) + geom_density(color="darkblue", fill="lightblue")+ 
  geom_vline(xintercept = density(dfs_filtered$values)$x[x_max1])


 ##finding second max value
second_max <- max(density(dfs_filtered$values)$y[density(dfs_filtered$values)$x > 13])
x_max2 <- which(density(dfs_filtered$values)$y == second_max)
density(dfs_filtered$values)$x[x_max2]   # 14.10983 days

##finding third max value
third_max <- max(density(dfs_filtered$values)$y[density(dfs_filtered$values)$x > 17])
x_max3 <- which(density(dfs_filtered$values)$y == third_max)
density(dfs_filtered$values)$x[x_max3]   # 30.32982 days

##finding 4th max value
fourth_max <- max(density(dfs_filtered$values)$y[density(dfs_filtered$values)$x > 50])
x_max4 <- which(density(dfs_filtered$values)$y == fourth_max)
density(dfs_filtered$values)$x[x_max4] # 60.53256

fifth_max <- max(density(dfs_filtered$values)$y[density(dfs_filtered$values)$x > 70])
x_max5 <- which(density(dfs_filtered$values)$y == fifth_max)
density(dfs_filtered$values)$x[x_max5] # 91.2946


d1 <- round(density(dfs_filtered$values)$x[x_max1], 1)
d2 <- round(density(dfs_filtered$values)$x[x_max2], 1)
d3 <- round(density(dfs_filtered$values)$x[x_max3], 1)
d4 <- round(density(dfs_filtered$values)$x[x_max4], 1)
d5 <- round(density(dfs_filtered$values)$x[x_max5], 1) # 91.2946
labels <- data.frame(label_position = c(d1, d2, d3, d4, d5), 
                     label_text = c(d1, d2, d3, d4, d5))

density_duration <- density(filter_data_on_duration$duration)


ggplot(data.frame(x = density_duration$x,
                  y = density_duration$y * density_duration$n), 
       aes(x, y))+
  geom_density(stat = "identity", 
               color="darkblue", fill="lightblue",
               alpha = 0.3)+ 
  geom_vline(xintercept = labels$label_position, lty = 2, colour = "gray50")+
  geom_text(data = labels, aes(x = label_position, y=0, label = label_text),
            size=4, angle = 0, vjust = -10.6, hjust = -0.2)+
  labs(x = "Jam duration (Days)", y = "# of jams")+
  scale_y_continuous(breaks = round(seq(0,300, by = 50), 1))+
  scale_x_continuous(breaks = round(seq(0,150, by = 20), 1))+
  theme(panel.background = element_blank(),
        axis.line = element_line(colour = "black"),
        axis.text=element_text(size=14),
        axis.title = element_text(size=14),
        axis.text.x=element_text(size = 14, hjust=1),
        axis.text.y = element_text(hjust = 0.5, size = 14))



# Finding jam with max duration
max <- 0
jam_max_duration_url <- ""
for (row in  1:nrow(all_jams)) {
  
  diff <- difftime(parse_datetime(all_jams[row, "jam_end_date"], "%Y-%m-%d %H:%M:%S"),
                   parse_datetime(all_jams[row, "jam_start_date"], "%Y-%m-%d %H:%M:%S"),
                   units = "days")
  if (as.numeric(diff) > max) {
    max <- as.numeric(diff);
    jam_max_duration_url <- all_jams[row, "jam_url"]
  }
}

# Finding jam with min duration
min <- 10000
jam_min_duration_url <- ""
for (row in  1:nrow(filter_data_on_duration)) {
  
  diff <- difftime(parse_datetime(filter_data_on_duration[row, "jam_end_date"], "%Y-%m-%d %H:%M:%S"),
                   parse_datetime(filter_data_on_duration[row, "jam_start_date"], "%Y-%m-%d %H:%M:%S"),
                   units = "days")
  if (as.numeric(diff) < min) {
    min <- as.numeric(diff);
    jam_min_duration_url <- all_jams[row, "jam_url"]
  }
}
