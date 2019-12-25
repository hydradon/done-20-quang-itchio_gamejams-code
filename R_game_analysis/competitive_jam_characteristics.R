# jam_desc <- read.csv("D:/Research/ECE720 project/dataset/jam_desc.csv", 
#                               encoding = "UTF-8" ,
#                               stringsAsFactors = FALSE,
#                               na.strings=c("","NA"))
# 
# all_jams <- read.csv("D:/Research/ECE720 project/dataset/jams1.csv", 
#                               encoding = "UTF-8" ,
#                               stringsAsFactors = FALSE,
#                               na.strings=c("","NA"))
# 
# 
# 
# library(tidyverse)
# 
# # Calculate jam duration
# all_jams$duration <- as.numeric(difftime(parse_datetime(all_jams$jam_end_date, "%Y-%m-%d %H:%M:%S"),
#                                          parse_datetime(all_jams$jam_start_date, "%Y-%m-%d %H:%M:%S"),
#                                          units = "days"))
# 
# # filter jams that last less than 1 hour
# all_jams <- subset(all_jams,  
#                     as.numeric(difftime(parse_datetime(jam_end_date, "%Y-%m-%d %H:%M:%S"),
#                                         parse_datetime(jam_start_date, "%Y-%m-%d %H:%M:%S"),
#                                         units = "hours")) > 1)
# 
# all_jams <- all_jams %>% top_frac(1-0.01, -duration)
# 
# #Calculate number of hosts
# all_jams$no_hosts <- lengths(strsplit(all_jams$jam_host, "\\|\\|"))
# 
# 
# # Separate into competitive and non-competitive jam
# non_competitive_jams <- subset(all_jams, is.na(all_jams$X.U.FEFF.jam_criteria))
# competitive_jams <- subset(all_jams, !is.na(all_jams$X.U.FEFF.jam_criteria))
# 
# # Analysing competitive jam
# competitive_jams_with_desc <- merge(competitive_jams, jam_desc, by = "jam_url")
# competitive_jams_with_desc$no_criteria <- lengths(strsplit(competitive_jams_with_desc$X.U.FEFF.jam_criteria, "\\|\\|"))
# competitive_jams_with_desc$no_hosts <- lengths(strsplit(competitive_jams_with_desc$jam_host, "\\|\\|"))
# 
# # MOdel





# Ignore....
competitive_jams <- read.csv("D:/Research/ECE720 project/dataset/competitive_jams_cleaned.csv",
                              encoding = "UTF-8" ,
                              stringsAsFactors = FALSE,
                              na.strings=c("","NA"))
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


library(Hmisc)
# Correlation analysis tree
clust <- varclus(data.matrix(competitive_jams[,2:ncol(competitive_jams)]))
plot(clust)


# Redudancy analysis
library(dplyr)
competitive_jams[!names(competitive_jams) %in%  c("Popular")]%>% 
  redun(~., data=., r2=.8, nk=0, 
        minfreq=40,
        allcat=TRUE)

# random forest
library(randomForest)
library(caret)
library(e1071)

trControl <- trainControl(classProbs = TRUE,
                          # method = "cv",
                          method = "repeatedcv",
                          repeats = 3,
                          number = 10, 
                          search ="grid",
                          savePredictions = TRUE,
                          summaryFunction = twoClassSummary)
# tuning mtry
tuneGrid_competitive_jam <- expand.grid(.mtry = c(11: 30))
rf_competitive_jam <- train(Popular ~ .,            
                          data = competitive_jams,
                          method = "rf",
                          tuneGrid = tuneGrid_competitive_jam,
                          trControl = trControl,
                          importance = TRUE,
                          nodesize = 14,
                          ntree = 100)

# best mtry = 18
tuneGrid_competitive_jam <- expand.grid(.mtry = 18)


# tuning maxnode
store_maxnode <- list()
for (maxnodes in c(5: 30)) {
  set.seed(1234)
  rf_maxnode <- train(Popular~.,
                      data = competitive_jams,
                      method = "rf",
                      tuneGrid = tuneGrid_competitive_jam,
                      trControl = trControl,
                      importance = TRUE,
                      nodesize = 14,
                      maxnodes = maxnodes,
                      ntree = 100)
  current_iteration <- toString(maxnodes)
  store_maxnode[[current_iteration]] <- rf_maxnode
}
results_node <- resamples(store_maxnode)

#best -> 5

# tuning ntree
store_maxtrees <- list()
for (ntree in c(100, 250, 300, 350, 400, 450, 500, 550, 600, 800, 1000, 2000)) {
  set.seed(5678)
  rf_maxtrees <- train(Popular~.,
                       data = competitive_jams,
                       method = "rf",
                       tuneGrid = tuneGrid_competitive_jam,
                       trControl = trControl,
                       importance = TRUE,
                       nodesize = 14,
                       maxnodes = 5,
                       ntree = ntree)
  key <- toString(ntree)
  store_maxtrees[[key]] <- rf_maxtrees
}
results_tree <- resamples(store_maxtrees)
summary(results_tree)

# actual
rf_competitive_jam <- train(Popular ~ .,            
                          data = competitive_jams,
                          method = "rf",
                          tuneGrid = tuneGrid_competitive_jam,
                          trControl = trControl,
                          importance = TRUE,
                          maxnodes = 5,
                          nodesize = 14,
                          ntree = 2000)

rf_competitive_jam2 <- train(popular ~ jam_desc_len
                                     + jam_no_illustrations
                                     + num_hosts
                                     + num_criteria,            
                            data = competitive_jams,
                            method = "rf",
                            tuneGrid = tuneGrid_competitive_jam,
                            trControl = trControl,
                            importance = TRUE,
                            maxnodes = 5,
                            nodesize = 14,
                            ntree = 100)



# plot ROC
library(ggplot2)
library(plotROC)
library(scales)


# All
# selectedIndices <- rf_model_reduced$pred$mtry == 11

roc_plot <- ggplot(rf_competitive_jam$pred, 
                   aes(m = Yes, d = factor(obs, levels = c("Yes", "No")))) + 
  geom_roc(labels=FALSE)
roc_plot + 
  style_roc(theme = theme_grey, ylab = "Sensitivity") +
  annotate("text", x = .75, y = .25, 
           label = paste("AUC =", round(calc_auc(roc_plot)$AUC, 2)))+
  scale_x_continuous("1 - Specificity", breaks = seq(0, 1, by = .1))



# Logistic
lr_competitive_jam <- train(popular ~ .,            
                       data = competitive_jams,
                       method = "multinom",
                       family = "binomial",
                       trControl = trControl)

roc_plot <- ggplot(lr_competitive_jam$pred, 
                   aes(m = Yes, d = factor(obs, levels = c("Yes", "No")))) + 
  geom_roc(labels=FALSE)
roc_plot + 
  style_roc(theme = theme_grey, ylab = "Sensitivity") +
  annotate("text", x = .75, y = .25, 
           label = paste("AUC =", round(calc_auc(roc_plot)$AUC, 2)))+
  scale_x_continuous("1 - Specificity", breaks = seq(0, 1, by = .1))



# Logistic regression 2 # NOTE: this does not improve!!!
lr_competitive_jam2 <- lrm(popular ~ ., 
                           data = competitive_jams,
                           x=TRUE, y=TRUE)
lr_competitive_jam2_bootcov <- bootcov(lr_competitive_jam2, B=100)
car::Anova(lr_competitive_jam2_bootcov, test.statistic="Wald")

lrtest(lr_competitive_jam2_bootcov, "jam_duration") # 11.445  0.0007167 ***
lrtest(lr_competitive_jam2_bootcov, "jam_desc_len") # 101.45  < 2.2e-16 ***
lrtest(lr_competitive_jam2_bootcov, "jam_no_illustrations") # 21.116  4.322e-06 ***
lrtest(lr_competitive_jam2_bootcov, "jam_no_videos") # 2.7305    0.09845 .
lrtest(lr_competitive_jam2_bootcov, "num_hosts") # 24.853  6.186e-07 ***
lrtest(lr_competitive_jam2_bootcov, "num_criteria") # 3.1713    0.07494 .

library(rms)
lr_competitive_jam_fastbw <- fastbw(lr_competitive_jam2_bootcov) #### Backward feature selection

lr_competitive_jam2_final <- train(popular ~ jam_desc_len
                                    + jam_no_illustrations
                                    + num_hosts
                                    + num_criteria,            
                            data = competitive_jams,
                            method = "multinom",
                            family = "binomial",
                            trControl = trControl)
roc_plot <- ggplot(lr_competitive_jam2_final$pred, 
                   aes(m = Yes, d = factor(obs, levels = c("Yes", "No")))) + 
  geom_roc(labels=FALSE)
roc_plot + 
  style_roc(theme = theme_grey, ylab = "Sensitivity") +
  annotate("text", x = .75, y = .25, 
           label = paste("AUC =", round(calc_auc(roc_plot)$AUC, 2)))+
  scale_x_continuous("1 - Specificity", breaks = seq(0, 1, by = .1))




# Explanatory power of features
library(car)
# LR
car::Anova(lr_competitive_jam$finalModel, test.statistic="Wald")

# Variable importance
varImp(rf_competitive_jam)
varImp(lr_competitive_jam)
importance(rf_competitive_jam$finalModel)


# Dive deeper............
library(effsize)
popular_competitive_jams <- subset(competitive_jams, popular == "Yes")
unpopular_competitive_jams <- subset(competitive_jams, popular == "No")

# Comparing description lengths
summary(popular_competitive_jams$jam_desc_len)
summary(unpopular_competitive_jams$jam_desc_len)
wilcox.test(popular_competitive_jams$jam_desc_len, 
            unpopular_competitive_jams$jam_desc_len, alternative = "greater")
cliff.delta(popular_competitive_jams$jam_desc_len, unpopular_competitive_jams$jam_desc_len)

# Comparing durations
summary(popular_competitive_jams$jam_duration)
summary(unpopular_competitive_jams$jam_duration)
wilcox.test(popular_competitive_jams$jam_duration, 
            unpopular_competitive_jams$jam_duration, alternative = "less")
cliff.delta(popular_competitive_jams$jam_duration, unpopular_competitive_jams$jam_duration)

# Comparing number of illustrations
summary(popular_competitive_jams$jam_no_illustrations)
summary(unpopular_competitive_jams$jam_no_illustrations)
wilcox.test(popular_competitive_jams$jam_no_illustrations, 
            unpopular_competitive_jams$jam_no_illustrations, alternative = "greater")
cliff.delta(popular_competitive_jams$jam_no_illustrations, unpopular_competitive_jams$jam_no_illustrations)

# Comparing number of videos
summary(popular_competitive_jams$jam_no_videos)
summary(unpopular_competitive_jams$jam_no_videos)
wilcox.test(popular_competitive_jams$jam_no_videos, 
            unpopular_competitive_jams$jam_no_videos, alternative = "greater")
cliff.delta(popular_competitive_jams$jam_no_videos, unpopular_competitive_jams$jam_no_videos)


# Comparing number of hosts
summary(popular_competitive_jams$num_hosts)
summary(unpopular_competitive_jams$num_hosts)
wilcox.test(popular_competitive_jams$num_hosts, 
            unpopular_competitive_jams$num_hosts, alternative = "greater")
cliff.delta(popular_competitive_jams$num_hosts, unpopular_competitive_jams$num_hosts)

# Comparing number of criteria
summary(popular_competitive_jams$num_criteria)
summary(unpopular_competitive_jams$num_criteria)
wilcox.test(popular_competitive_jams$num_criteria, 
            unpopular_competitive_jams$num_criteria, alternative = "greater")
cliff.delta(popular_competitive_jams$num_criteria, unpopular_competitive_jams$num_criteria)





