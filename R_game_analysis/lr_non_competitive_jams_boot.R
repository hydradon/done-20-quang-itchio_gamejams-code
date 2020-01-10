non_competitive_jams <- read.csv("D:/Research/game-jam-crawler-model/dataset/non_competitive_jams_cleaned.csv",
                                 encoding = "UTF-8" ,
                                 stringsAsFactors = FALSE,
                                 na.strings=c("","NA"))
colnames(non_competitive_jams)[colnames(non_competitive_jams)=="jam_duration"] <- "duration"   
colnames(non_competitive_jams)[colnames(non_competitive_jams)=="jam_no_illustrations"] <- "num_imgs"   
colnames(non_competitive_jams)[colnames(non_competitive_jams)=="jam_no_videos"] <- "num_vids"   
colnames(non_competitive_jams)[colnames(non_competitive_jams)=="jam_desc_len"] <- "desc_len"  

non_competitive_jams$X.U.FEFF.jam_criteria <- NULL 
non_competitive_jams$jam_end_date <- NULL
non_competitive_jams$jam_start_date <- NULL
non_competitive_jams$jam_host <- NULL
non_competitive_jams$jam_name_x <- NULL
non_competitive_jams$jam_name_y <- NULL
non_competitive_jams$jam_no_joined <- NULL
non_competitive_jams$jam_no_rating <- NULL
non_competitive_jams$jam_url <- NULL
non_competitive_jams$jam_english <- NULL
non_competitive_jams$jam_no_submissions <- NULL

# reorder column
non_competitive_jams <- non_competitive_jams[, c(6, 1:5)]

# Add label to response variable
non_competitive_jams$popular <- factor(non_competitive_jams$popular)

# Convert to log scale
non_competitive_jams$desc_len<-log(non_competitive_jams$desc_len + 1)
non_competitive_jams$duration<-log(non_competitive_jams$duration + 1)
non_competitive_jams$num_vids<-log(non_competitive_jams$num_vids + 1)
non_competitive_jams$num_imgs<-log(non_competitive_jams$num_imgs + 1)
non_competitive_jams$num_hosts<-log(non_competitive_jams$num_hosts + 1)


# Model building
trControl_boot <- trainControl(classProbs = TRUE,
                               method = "boot",
                               number = 100, 
                               savePredictions = TRUE,
                               summaryFunction = twoClassSummary)

lr_non_competitive_jam_boot <- train(popular ~ .,            
                                 data = non_competitive_jams,
                                 method = "glm",
                                 family = "binomial",
                                 trControl = trControl_boot)

# Drawing ROC
roc_plot <- ggplot(lr_non_competitive_jam_boot$pred, 
                   aes(m = Yes, d = factor(obs, levels = c("Yes", "No")))) + 
  geom_roc(labels=FALSE)
roc_plot + 
  style_roc(theme = theme_grey, ylab = "Sensitivity") +
  annotate("text", x = .75, y = .25, 
           label = paste("AUC =", round(calc_auc(roc_plot)$AUC, 2)))+
  scale_x_continuous("1 - Specificity", breaks = seq(0, 1, by = .1))


# Summary
summary(lr_non_competitive_jam_boot)
car::Anova(lr_non_competitive_jam_boot$finalModel, test.statistic = "Wald")
varImp(lr_non_competitive_jam_boot$finalModel)



# For nomogram analysis - built without the insignificant predictors
non_competitive_jams$num_hosts <- round(non_competitive_jams$num_hosts,2)
non_competitive_jams$num_vids <- round(non_competitive_jams$num_vids,2)
lr_non_competitive_jam_boot_nomogram <- lrm(popular ~ 
                                              desc_len
                                        + num_vids
                                        + num_imgs 
                                        + num_hosts
                                        + duration,   
                                        data = non_competitive_jams,
)

car::Anova(lr_non_competitive_jam_boot_nomogram, test.statistic = "Wald")

ddist <- datadist(non_competitive_jams)
options(datadist='ddist')
nom <- nomogram(lr_non_competitive_jam_boot_nomogram,
                fun=plogis,
                fun.at=c(.001,0.1,0.5,0.9, 0.99),
                abbrev = TRUE,
                lp=F,
                funlabel = "Popularity")
plot(nom,
     label.every=2,
     fun.side=c(1,1,1,1,1),
     lmgp = 0.15,
     xfrac=.25
)

par(mar = c(2,0.1,0.2,0.1))
