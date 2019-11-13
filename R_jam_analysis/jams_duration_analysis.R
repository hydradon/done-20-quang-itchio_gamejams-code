# all_jams <- read.csv("D:/ECE720 project/dataset/jams-filter-converted.csv", stringsAsFactors = FALSE)
all_jams <- read.csv("D:/ECE720 project/dataset/jams1.csv", encoding = "UTF-8" ,stringsAsFactors = FALSE)
library(ggplot2)
library(tidyverse)

# Analyse jams duration
summary(as.data.frame(as.numeric(difftime(parse_datetime(all_jams$jam_end_date, "%Y-%m-%d %H:%M:%S"),
                                          parse_datetime(all_jams$jam_start_date, "%Y-%m-%d %H:%M:%S"),
                                          units = "days"))))

diff<- difftime(parse_datetime(all_jams$jam_end_date, "%Y-%m-%d %H:%M:%S"),
                parse_datetime(all_jams$jam_start_date, "%Y-%m-%d %H:%M:%S"),
                units = "days")
dfs <- stack(as.data.frame(as.numeric(diff)))
ggplot(dfs, aes(x=values)) + geom_density(color="darkblue", fill="lightblue")+ 
  geom_vline(xintercept = density(dfs_filtered$values)$x[201])+
  geom_vline(xintercept = density(dfs_filtered$values)$x[110])+
  geom_vline(xintercept = density(dfs_filtered$values)$x[27])+
  xlab("Jam duration/Days")

### filter data with truncated 1% longest jams, and with duration longer 1 hour
filter_data_on_duration <- all_jams %>% top_frac(1-0.01, -duration)
filter_data_on_duration <- subset(filter_data_on_duration,  
                                  as.numeric(difftime(parse_datetime(jam_end_date, "%Y-%m-%d %H:%M:%S"),
                                                      parse_datetime(jam_start_date, "%Y-%m-%d %H:%M:%S"),
                                                      units = "hours")) > 1)


dfs_truncated <- stack(as.data.frame(as.numeric(filter_data_on_duration$duration)))
ggplot(dfs_truncated, aes(x=values)) + geom_density(color="darkblue", fill="lightblue")

filter_data_on_duration$duration <- as.numeric(difftime(parse_datetime(filter_data_on_duration$jam_end_date, "%Y-%m-%d %H:%M:%S"),
                                                        parse_datetime(filter_data_on_duration$jam_start_date, "%Y-%m-%d %H:%M:%S"),
                                                        units = "days"))
summary(filter_data_on_duration$duration)

# plot graph for jams with duration less than 90 days and with more than 10 submissions
diff_filtered <- difftime(parse_datetime(filter_data_on_duration$jam_end_date, "%Y-%m-%d %H:%M:%S"),
                          parse_datetime(filter_data_on_duration$jam_start_date, "%Y-%m-%d %H:%M:%S"),
                          units = "days")

#finding max values
dfs_filtered <- stack(as.data.frame(filter_data_on_duration$duration))

# density(dfs_filtered$values)
x_max1 <- which.max(density(dfs_filtered$values)$y)
density(dfs_filtered$values)$x[x_max1] # 2.64398

 ##finding second max value
second_max <- max(density(dfs_filtered$values)$y[density(dfs_filtered$values)$x > 13])
x_max2 <- which(density(dfs_filtered$values)$y == second_max)
density(dfs_filtered$values)$x[x_max2]   # 14.10983 days
ggplot(dfs_filtered, aes(x=values)) + geom_density(color="darkblue", fill="lightblue")+ 
  geom_vline(xintercept = density(dfs_filtered$values)$x[x_max1])+
  geom_vline(xintercept = density(dfs_filtered$values)$x[x_max2])

##finding third max value
third_max <- max(density(dfs_filtered$values)$y[density(dfs_filtered$values)$x > 17])
x_max3 <- which(density(dfs_filtered$values)$y == third_max)
density(dfs_filtered$values)$x[x_max3]   # 30.32982 days
ggplot(dfs_filtered, aes(x=values)) + geom_density(color="darkblue", fill="lightblue")+ 
  geom_vline(xintercept = density(dfs_filtered$values)$x[x_max1])+
  geom_vline(xintercept = density(dfs_filtered$values)$x[x_max2])+
  geom_vline(xintercept = density(dfs_filtered$values)$x[x_max3])+
  xlab("Jam duration/Days")

fourth_max <- max(density(dfs_filtered$values)$y[density(dfs_filtered$values)$x > 50])
x_max4 <- which(density(dfs_filtered$values)$y == fourth_max)
density(dfs_filtered$values)$x[x_max4] # 60.53256
ggplot(dfs_filtered, aes(x=values)) + geom_density(color="darkblue", fill="lightblue")+ 
  geom_vline(xintercept = density(dfs_filtered$values)$x[x_max1])+
  geom_vline(xintercept = density(dfs_filtered$values)$x[x_max2])+
  geom_vline(xintercept = density(dfs_filtered$values)$x[x_max3])+
  geom_vline(xintercept = density(dfs_filtered$values)$x[x_max4])+
  xlab("Jam duration/Days")

fifth_max <- max(density(dfs_filtered$values)$y[density(dfs_filtered$values)$x > 70])
x_max5 <- which(density(dfs_filtered$values)$y == fifth_max)

d1 <- round(density(dfs_filtered$values)$x[x_max1], 1)
d2 <- round(density(dfs_filtered$values)$x[x_max2], 1)
d3 <- round(density(dfs_filtered$values)$x[x_max3], 1)
d4 <- round(density(dfs_filtered$values)$x[x_max4], 1)
d5 <- round(density(dfs_filtered$values)$x[x_max5], 1) # 91.2946
labels <- data.frame(label_position = c(d1, d2, d3, d4, d5), 
                     label_text = c(d1, d2, d3, d4, d5))


ggplot(dfs_filtered, aes(x=values))+
  geom_density(color="darkblue", fill="lightblue", alpha = 0.4)+ 
  geom_vline(xintercept = labels$label_position, lty = 2, colour = "gray50")+
  geom_text(data = labels, aes(x = label_position, y=0, label = label_text), 
            size=4, angle = 270, vjust = -10.6, hjust = -0.2) +
  xlab("Jam duration (days)")

# plot graph for all jams
diff <- difftime(parse_datetime(all_jams$jam_end_date, "%Y-%m-%d %H:%M:%S"),
                 parse_datetime(all_jams$jam_start_date, "%Y-%m-%d %H:%M:%S"),
                 units = "days")
jam_duration <- density(as.numeric(diff))
plot(jam_duration, main="Jam duration distribution", xlab="Duration/days")

dfs <- stack(as.data.frame(as.numeric(diff)))
ggplot(dfs, aes(x=values))+
  geom_density(color="darkblue", fill="lightblue")


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
