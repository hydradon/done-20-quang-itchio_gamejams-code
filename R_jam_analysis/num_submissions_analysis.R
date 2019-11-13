all_jams <- read.csv("D:/ECE720 project/dataset/jams1.csv", 
                     encoding = "UTF-8",
                     stringsAsFactors = FALSE)

filter_data_on_submissions <- subset(all_jams, jam_no_submissions>0 &
                                               jam_no_submissions<700)

library(ggplot2)
library(scales)

density_no_submissions <- density(all_jams$jam_no_submissions)

ggplot(all_jams, aes(x=jam_no_submissions))+
# ggplot(df_no_submissions, aes(x=values))+
  # geom_density(color="darkblue", fill="lightblue")+
  stat_density(aes(y=..count..), color="black", fill="blue", alpha=0.3)+
  # scale_x_continuous(breaks=c(0,1,2,3,4,5,10,30,100,300,1000,2000,3000), trans="log1p", expand=c(0,0))+
  xlab("Number of submissions")+
  ylab("Number of jams")+
  geom_vline(xintercept = mean(all_jams$jam_no_submissions))


ggplot(data.frame(x = density_no_submissions$x, 
                  y = density_no_submissions$y * density_no_submissions$n), 
       aes(x, y)) + 
  geom_density(stat = "identity", fill = 'blue', alpha = 0.3) + 
  # geom_vline(xintercept = most_common_time, lty = 2) +
  scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x)))+
  # geom_text(aes(x = most_common_time, 
  #               y=10, 
  #               label = paste(most_common_time, "Hours", ssep = " ")),
  #           size=3.5, angle = 90, vjust = -0.4, hjust = 3)+
  xlab("Number of submissions")+
  ylab("Count")+
  scale_y_continuous(breaks = round(seq(0,300, by = 20), 1))



summary(all_jams$jam_no_submissions)



