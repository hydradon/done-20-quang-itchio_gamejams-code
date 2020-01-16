# Import dataset
competitive_jams <- read.csv("D:/Research/game-jam-crawler-model/dataset/competitive_jams_cleaned.csv",
                             encoding = "UTF-8" ,
                             stringsAsFactors = FALSE,
                             na.strings=c("","NA"))

colnames(competitive_jams)[colnames(competitive_jams)=="jam_duration"] <- "duration"   
colnames(competitive_jams)[colnames(competitive_jams)=="jam_no_illustrations"] <- "num_imgs"   
colnames(competitive_jams)[colnames(competitive_jams)=="jam_no_videos"] <- "num_vids"   
colnames(competitive_jams)[colnames(competitive_jams)=="jam_desc_len"] <- "desc_len"  

competitive_jams$X.U.FEFF.jam_criteria <- NULL
competitive_jams$jam_end_date <- NULL
competitive_jams$jam_start_date <- NULL

competitive_jams$jam_host <- NULL
competitive_jams$jam_name_x <- NULL
competitive_jams$jam_name_y <- NULL
competitive_jams$jam_no_joined <- NULL
competitive_jams$jam_no_rating <- NULL
competitive_jams$jam_url <- NULL
competitive_jams$jam_english <- NULL
competitive_jams$jam_no_submissions <- NULL

# reorder column
competitive_jams <- competitive_jams[, c(7, 1:6)]

# Add label to response variable
competitive_jams$popular <- factor(competitive_jams$popular)

# Convert to log scale
competitive_jams$desc_len<-log(competitive_jams$desc_len + 1)
competitive_jams$duration<-log(competitive_jams$duration + 1)
competitive_jams$num_vids<-log(competitive_jams$num_vids + 1)
competitive_jams$num_imgs<-log(competitive_jams$num_imgs + 1)
competitive_jams$num_criteria<-log(competitive_jams$num_criteria + 1)
competitive_jams$num_hosts<-log(competitive_jams$num_hosts + 1)

library(caret)
# Model building
trControl_boot <- trainControl(classProbs = TRUE,
                               method = "boot",
                               number = 100, 
                               savePredictions = TRUE,
                               summaryFunction = twoClassSummary)

lr_competitive_jam_boot <- train(popular ~ .,            
                            data = competitive_jams,
                            method = "glm",
                            family = "binomial",
                            trControl = trControl_boot)

lr_competitive_jam_boot_condensed <- train(popular ~ duration + desc_len + num_imgs + num_hosts,            
                                 data = competitive_jams,
                                 method = "glm",
                                 family = "binomial",
                                 trControl = trControl_boot)

# Drawing ROC
roc_plot <- ggplot(lr_competitive_jam_boot_condensed$pred, 
                   aes(m = Yes, d = factor(obs, levels = c("Yes", "No")))) + 
  geom_roc(labels=FALSE)
roc_plot + 
  style_roc(theme = theme_grey, ylab = "Sensitivity") +
  annotate("text", x = .75, y = .25, 
           label = paste("AUC =", round(calc_auc(roc_plot)$AUC, 2)))+
  scale_x_continuous("1 - Specificity", breaks = seq(0, 1, by = .1))


# Summary
summary(lr_competitive_jam_boot)
car::Anova(lr_competitive_jam_boot$finalModel, test.statistic = "Wald")
# car::Anova(lr_competitive_jam_boot$finalModel)
varImp(lr_competitive_jam_boot$finalModel)



# For nomogram analysis - built without the insignificant predictors
competitive_jams$num_hosts <- round(competitive_jams$num_hosts,2)
competitive_jams$num_vids <- round(competitive_jams$num_vids,2)

lr_competitive_jam_boot_nomogram <- lrm(popular ~
                                          duration + desc_len + num_imgs + num_hosts, x=TRUE, y=TRUE,
                                          # duration + desc_len
                                          # + num_vids + num_criteria
                                          # + num_imgs + num_hosts,   
                                   data = competitive_jams)

CalculateAucFromDxy(validate(lr_competitive_jam_boot_nomogram,B=100))
ddist <- datadist(competitive_jams)
options(datadist='ddist')
nom <- nomogram(lr_competitive_jam_boot_nomogram,
                fun=plogis,
                fun.at=c(.001,0.1,0.5,0.9, .999),
                abbrev = TRUE,
                lp=F,
                funlabel = "Popularity")
x <- plot(nom,
          label.every=2,
          fun.side=c(1,3,1,3,1),
          lmgp = 0.15,
          xfrac=.25
)
box()
par(mar = c(2,0.1,0.1,0.1))
