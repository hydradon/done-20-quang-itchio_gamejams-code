#random forest way
source("pre_process_gamedata.r")

library(Hmisc)
# Correlation analysis tree
clust <- varclus(data.matrix(game_data[,2:ncol(game_data)]))
plot(clust)

#remove correlated factors
game_data$madeWith_Logic.Pro <- NULL
game_data$input_OSVR..Open.Source.Virtual.Reality. <- NULL
game_data$input_NeuroSky.Mindwave <- NULL


# Redudancy analysis
library(dplyr)
game_data[!names(game_data) %in%  c("high_ranking")]%>% 
  redun(~., data=., r2=0.8, nk=0, 
        # minfreq=40,
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
tuneGrid <- expand.grid(.mtry = c(11: 30))
rf_model_all <- train(high_ranking ~ .,            
                      data = game_data,
                      method = "rf",
                      # metric = "Accuracy",
                      tuneGrid = tuneGrid,
                      trControl = trControl,
                      importance = TRUE,
                      nodesize = 14,
                      ntree = 100)

# best mtry = 11
tuneGrid <- expand.grid(.mtry = 11)

# tuning maxnode
store_maxnode <- list()
for (maxnodes in c(5: 30)) {
  set.seed(1234)
  rf_maxnode <- train(high_ranking~.,
                      data = game_data,
                      method = "rf",
                      metric = "Accuracy",
                      tuneGrid = tuneGrid,
                      trControl = trControl,
                      importance = TRUE,
                      nodesize = 14,
                      maxnodes = maxnodes,
                      ntree = 100)
  current_iteration <- toString(maxnodes)
  store_maxnode[[current_iteration]] <- rf_maxnode
}
results_node <- resamples(store_maxnode)

#max node = 6, 7, 30

# tuning ntree
store_maxtrees <- list()
for (ntree in c(100, 250, 300, 350, 400, 450, 500, 550, 600, 800, 1000, 2000)) {
  set.seed(5678)
  rf_maxtrees <- train(high_ranking~.,
                       data = game_data,
                       method = "rf",
                       tuneGrid = tuneGrid,
                       trControl = trControl,
                       importance = TRUE,
                       nodesize = 14,
                       maxnodes = 30,
                       ntree = ntree)
  key <- toString(ntree)
  store_maxtrees[[key]] <- rf_maxtrees
}
results_tree <- resamples(store_maxtrees)
summary(results_tree)

# actual
rf_model_all <- train(high_ranking ~ .,            
                      data = game_data,
                      method = "rf",
                      tuneGrid = tuneGrid,
                      trControl = trControl,
                      importance = TRUE,
                      maxnodes = 30,
                      nodesize = 14,
                      ntree = 100)

# actual
rf_model_all <- train(high_ranking ~ .,            
                      data = game_data,
                      method = "rf",
                      tuneGrid = tuneGrid,
                      trControl = trControl_boot,
                      importance = TRUE,
                      maxnodes = 30,
                      nodesize = 14,
                      ntree = 100)


# plot ROC
library(ggplot2)
library(plotROC)
library(scales)


# All
roc_plot <- ggplot(rf_model_all$pred, 
                   aes(m = Yes, d = factor(obs, levels = c("Yes", "No")))) + 
  geom_roc(labels=FALSE)
roc_plot + 
  style_roc(theme = theme_grey, ylab = "Sensitivity") +
  annotate("text", x = .75, y = .25, 
           label = paste("AUC =", round(calc_auc(roc_plot)$AUC, 2)))+
  scale_x_continuous("1 - Specificity", breaks = seq(0, 1, by = .1))


# Logistic
trControl_lr <- trainControl(classProbs = TRUE,
                          method = "cv",
                          # method = "repeatedcv",
                          # repeats = 1,
                          number = 10, 
                          search ="grid",
                          savePredictions = TRUE,
                          summaryFunction = twoClassSummary)

model_all <- train(high_ranking ~ .,            
                   data = game_data,
                   # method = "glm",
                   method="glmStepAIC",
                   direction ="backward",
                   family = "binomial",
                   trControl = trControl_lr)

roc_plot <- ggplot(model_all$pred, 
                   aes(m = Yes, d = factor(obs, levels = c("Yes", "No")))) + 
  geom_roc(labels=FALSE)
roc_plot +  
  style_roc(theme = theme_grey, ylab = "Sensitivity") +
  annotate("text", x = .75, y = .25, 
           label = paste("AUC =", round(calc_auc(roc_plot)$AUC, 2)))+
  scale_x_continuous("1 - Specificity", breaks = seq(0, 1, by = .1))


# Backward feature selection NOT WORKING
library(rms)
model_all_fastbw <- fastbw(model_all$finalModel)


# Explanatory power of features
library(car)
car::Anova(model_all$finalModel, test.statistic="Wald")


# Variable importance
varImp(rf_model_all)
varImp(model_all)

# Coefficients and p-values
summary(model_all)
summary(rf_model_all$finalModel)

# Dive deeper............
library(effsize)
high_ranking_games <- subset(game_data, high_ranking == "Yes")
low_ranking_games <- subset(game_data, high_ranking == "No")

# Comparing description lengths
summary(high_ranking_games$game_desc_len)
summary(low_ranking_games$game_desc_len)
wilcox.test(high_ranking_games$game_desc_len, 
            low_ranking_games$game_desc_len, alternative = "greater")
cliff.delta(high_ranking_games$game_desc_len, 
            low_ranking_games$game_desc_len)

comp.dist.plot(high_ranking_games$game_desc_len, 
                     low_ranking_games$game_desc_len,
                     legend1 = "High-ranking games",
                     legend2 = "Low-ranking games",
                     legendpos = "topright",
                     xlab = "Median description length",
                      cut = FALSE)


# Comparing number of screenshots
summary(high_ranking_games$game_no_screenshots)
summary(low_ranking_games$game_no_screenshots)
wilcox.test(high_ranking_games$game_no_screenshots, 
            low_ranking_games$game_no_screenshots, alternative = "greater")
cliff.delta(high_ranking_games$game_no_screenshots, 
            low_ranking_games$game_no_screenshots)

comp.dist.plot(high_ranking_games$game_no_screenshots, 
                    low_ranking_games$game_no_screenshots,
                    legend1 = "High-ranking games",
                    legend2 = "Low-ranking games",
                    legendpos = "topright",
                    xlab = "Median number of screenshots",
                    cut = FALSE)



# Comparing number of developers
summary(high_ranking_games$number_of_developers)
summary(low_ranking_games$number_of_developers)
wilcox.test(high_ranking_games$number_of_developers, 
            low_ranking_games$number_of_developers, alternative = "greater")
cliff.delta(high_ranking_games$number_of_developers, 
            low_ranking_games$number_of_developers)

comp.dist.plot(high_ranking_games$number_of_developers, 
               low_ranking_games$number_of_developers,
               legend1 = "High-ranking games",
               legend2 = "Low-ranking games",
               legendpos = "topright",
               xlab = "Median number of developers",
               cut = FALSE)


# Comparing platform_Windows
summary(high_ranking_games$platform_Windows)
summary(low_ranking_games$platform_Windows)
wilcox.test(as.numeric(high_ranking_games$platform_Windows), 
            as.numeric(low_ranking_games$platform_Windows), alternative = "two.sided")
cliff.delta(as.numeric(high_ranking_games$platform_Windows), 
            as.numeric(low_ranking_games$platform_Windows))

# Comparing platform_HTML5
summary(high_ranking_games$platform_HTML5)
summary(low_ranking_games$platform_HTML5)
wilcox.test(as.numeric(high_ranking_games$platform_HTML5), 
            as.numeric(low_ranking_games$platform_HTML5), alternative = "two.sided")
cliff.delta(as.numeric(high_ranking_games$platform_HTML5), 
            as.numeric(low_ranking_games$platform_HTML5))

# Comparing aveSession_A.few.minutes
summary(high_ranking_games$aveSession_A.few.minutes)
summary(low_ranking_games$aveSession_A.few.minutes)
wilcox.test(as.numeric(high_ranking_games$aveSession_A.few.minutes), 
            as.numeric(low_ranking_games$aveSession_A.few.minutes), alternative = "two.sided")
cliff.delta(as.numeric(high_ranking_games$aveSession_A.few.minutes), 
            as.numeric(low_ranking_games$aveSession_A.few.minutes))

