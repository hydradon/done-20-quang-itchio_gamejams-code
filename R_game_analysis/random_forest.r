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
game_data$input_Keyboard <- NULL

# Redudancy analysis
library(dplyr)
game_data[!names(game_data) %in%  c("high_ranking")]%>% 
  redun(~., data=., r2=0.8, nk=0, 
        allcat=TRUE)


# random forest
library(randomForest)
library(caret)
library(e1071)

trControl <- trainControl(classProbs = TRUE,
                          # method = "cv",
                          method = "boot",
                          # repeats = 3,
                          number = 100, 
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
summary(high_ranking_games$desc_len)
summary(low_ranking_games$desc_len)
wilcox.test(high_ranking_games$desc_len, 
            low_ranking_games$desc_len, alternative = "greater")
cliff.delta(high_ranking_games$desc_len, 
            low_ranking_games$desc_len)

par(mar = c(2,0.1,0.1,0.1))
comp.dist.plot(high_ranking_games$desc_len, 
                     low_ranking_games$desc_len,
                     legend1 = "High-ranking games",
                     legend2 = "Low-ranking games",
                     legendpos = "topleft",
                      cut = FALSE)


# Comparing number of screenshots
summary(high_ranking_games$num_imgs)
summary(low_ranking_games$num_imgs)
wilcox.test(high_ranking_games$num_imgs, 
            low_ranking_games$num_imgs, alternative = "greater")
cliff.delta(high_ranking_games$num_imgs, 
            low_ranking_games$num_imgs)

comp.dist.plot(high_ranking_games$num_imgs, 
                    low_ranking_games$num_imgs,
                    legend1 = "High-ranking games",
                    legend2 = "Low-ranking games",
                    legendpos = "topleft",
                    cut = FALSE)
par(mar = c(2,0.1,0.1,0.1))


# Comparing number of developers
summary(high_ranking_games$num_devs)
summary(low_ranking_games$num_devs)
wilcox.test(high_ranking_games$num_devs, 
            low_ranking_games$num_devs, alternative = "greater")
cliff.delta(high_ranking_games$num_devs, 
            low_ranking_games$num_devs)

comp.dist.plot(high_ranking_games$num_devs, 
               low_ranking_games$num_devs,
               legend1 = "High-ranking games",
               legend2 = "Low-ranking games",
               legendpos = "topleft",
               cut = FALSE)

x <- subset(game_data, num_devs > 1)
summary(x$high_ranking)
# Platform========================================================================================
# Comparing platform_Windows
summary(high_ranking_games$platform_Windows)
summary(low_ranking_games$platform_Windows)
wilcox.test(high_ranking_games$platform_Windows, 
            low_ranking_games$platform_Windows, alternative = "two.sided")
cliff.delta(as.numeric(high_ranking_games$platform_Windows), 
            as.numeric(low_ranking_games$platform_Windows))

# Comparing platform_macOS
summary(high_ranking_games$platform_macOS)
summary(low_ranking_games$platform_macOS)
wilcox.test(as.numeric(high_ranking_games$platform_macOS), 
            as.numeric(low_ranking_games$platform_macOS), alternative = "two.sided")
cliff.delta(as.numeric(high_ranking_games$platform_macOS), 
            as.numeric(low_ranking_games$platform_macOS))

# Comparing platform_Android
summary(high_ranking_games$platform_Android)
summary(low_ranking_games$platform_Android)
wilcox.test(as.numeric(high_ranking_games$platform_Android), 
            as.numeric(low_ranking_games$platform_Android), alternative = "two.sided")
cliff.delta(as.numeric(high_ranking_games$platform_Android), 
            as.numeric(low_ranking_games$platform_Android))

# Comparing platform_HTML5
summary(high_ranking_games$platform_HTML5)
summary(low_ranking_games$platform_HTML5)
wilcox.test(as.numeric(high_ranking_games$platform_HTML5), 
            as.numeric(low_ranking_games$platform_HTML5), alternative = "two.sided")
cliff.delta(as.numeric(high_ranking_games$platform_HTML5), 
            as.numeric(low_ranking_games$platform_HTML5))

# AVG session=================================================================================
# Comparing aveSession_A.few.minutes
summary(high_ranking_games$avgSession_A.few.minutes)
summary(low_ranking_games$avgSession_A.few.minutes)

stat_sig_genre <- subset(game_data, avgSession_A.few.minutes == 1 | 
                           genre_Platformer == 1 | 
                           genre_Interactive.Fiction == 1 | 
                           genre_Puzzle == 1)

summary(stat_sig_genre$high_ranking)



# Comparing has_asset_license
summary(high_ranking_games$has_asset_license)
summary(low_ranking_games$has_asset_license)
wilcox.test(as.numeric(high_ranking_games$has_asset_license), 
            as.numeric(low_ranking_games$has_asset_license), alternative = "two.sided")
cliff.delta(as.numeric(high_ranking_games$has_asset_license), 
            as.numeric(low_ranking_games$has_asset_license))

# Comparing input_Xbox.controller
summary(high_ranking_games$input_Xbox.controller)
summary(low_ranking_games$input_Xbox.controller)
wilcox.test(as.numeric(high_ranking_games$input_Xbox.controller), 
            as.numeric(low_ranking_games$input_Xbox.controller), alternative = "two.sided")
cliff.delta(as.numeric(high_ranking_games$input_Xbox.controller), 
            as.numeric(low_ranking_games$input_Xbox.controller))


# GENRE========================================================================================
# Comparing genre_Puzzle
summary(high_ranking_games$genre_Puzzle)
summary(low_ranking_games$genre_Puzzle)
wilcox.test(as.numeric(high_ranking_games$genre_Puzzle), 
            as.numeric(low_ranking_games$genre_Puzzle), alternative = "two.sided")
cliff.delta(as.numeric(high_ranking_games$genre_Puzzle), 
            as.numeric(low_ranking_games$genre_Puzzle))


# Comparing  genre_Platformer
summary(high_ranking_games$genre_Platformer)
summary(low_ranking_games$genre_Platformer)
wilcox.test(as.numeric(high_ranking_games$genre_Platformer), 
            as.numeric(low_ranking_games$genre_Platformer), alternative = "two.sided")
cliff.delta(as.numeric(high_ranking_games$genre_Platformer), 
            as.numeric(low_ranking_games$genre_Platformer))


# Comparing genre_Interactive.Fiction
summary(high_ranking_games$genre_Interactive.Fiction)
summary(low_ranking_games$genre_Interactive.Fiction)
wilcox.test(as.numeric(high_ranking_games$genre_Interactive.Fiction), 
            as.numeric(low_ranking_games$genre_Interactive.Fiction), alternative = "two.sided")
cliff.delta(as.numeric(high_ranking_games$genre_Interactive.Fiction), 
            as.numeric(low_ranking_games$genre_Interactive.Fiction))

# Comparing genre_Action
summary(high_ranking_games$genre_Action)
summary(low_ranking_games$genre_Action)

stat_sig_genre <- subset(game_data, genre_Action == 1 | 
                           genre_Platformer == 1 | 
                           genre_Interactive.Fiction == 1 | 
                           genre_Puzzle == 1)

summary(stat_sig_genre$high_ranking)

# Made With=======================================================================================
# Comparing madeWith_PICO.8
summary(high_ranking_games$madeWith_PICO.8)
summary(low_ranking_games$madeWith_PICO.8)
wilcox.test(as.numeric(high_ranking_games$madeWith_PICO.8), 
            as.numeric(low_ranking_games$madeWith_PICO.8), alternative = "two.sided") #0.03
cliff.delta(as.numeric(high_ranking_games$madeWith_PICO.8),  
            as.numeric(low_ranking_games$madeWith_PICO.8))  #0.009809579 (negligible)

# Comparing madeWith_GIMP
summary(high_ranking_games$madeWith_GIMP)
summary(low_ranking_games$madeWith_GIMP)
wilcox.test(as.numeric(high_ranking_games$madeWith_GIMP), 
            as.numeric(low_ranking_games$madeWith_GIMP), alternative = "two.sided") # 0.5885
cliff.delta(as.numeric(high_ranking_games$madeWith_GIMP), 
            as.numeric(low_ranking_games$madeWith_GIMP))  # 0.001731102 (negligible)

# Comparing madeWith_GameMaker.Studio
summary(high_ranking_games$madeWith_GameMaker.Studio)
summary(low_ranking_games$madeWith_GameMaker.Studio)
wilcox.test(as.numeric(high_ranking_games$madeWith_GameMaker.Studio), 
            as.numeric(low_ranking_games$madeWith_GameMaker.Studio), alternative = "two.sided") #0.003774
cliff.delta(as.numeric(high_ranking_games$madeWith_GameMaker.Studio), 
            as.numeric(low_ranking_games$madeWith_GameMaker.Studio))  #0.02077323 (negligible)

# Comparing madeWith_Paint.net
summary(high_ranking_games$madeWith_Paint.net)
summary(low_ranking_games$madeWith_Paint.net)
wilcox.test(as.numeric(high_ranking_games$madeWith_Paint.net), 
            as.numeric(low_ranking_games$madeWith_Paint.net), alternative = "two.sided") #0.6164
cliff.delta(as.numeric(high_ranking_games$madeWith_Paint.net), 
            as.numeric(low_ranking_games$madeWith_Paint.net))    #0.001154068 (negligible)

# Comparing madeWith_OpenFL
summary(high_ranking_games$madeWith_OpenFL)
summary(low_ranking_games$madeWith_OpenFL)
wilcox.test(as.numeric(high_ranking_games$madeWith_OpenFL), 
            as.numeric(low_ranking_games$madeWith_OpenFL), alternative = "two.sided")  #0.2842
cliff.delta(as.numeric(high_ranking_games$madeWith_OpenFL), 
            as.numeric(low_ranking_games$madeWith_OpenFL))    #0.002308136 (negligible)
