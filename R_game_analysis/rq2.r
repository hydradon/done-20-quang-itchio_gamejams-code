library(Hmisc)
# Correlation analysis tree
clust <- varclus(data.matrix(game_data[,2:ncol(game_data)]))
par(mar = c(0.1,4.5,0,0))
plot(clust)

#remove correlated factors
game_data$madeWith_Logic.Pro <- NULL
game_data$input_OSVR..Open.Source.Virtual.Reality. <- NULL
game_data$input_NeuroSky.Mindwave <- NULL
game_data$num_inputs <- NULL


# Redudancy analysis
library(rms)
library(dplyr)
game_data[!names(game_data) %in%  c("high_ranking")]%>% 
  redun(~., data=., r2=0.8, nk=0, 
        # minfreq = 40,
        allcat=TRUE)
game_data$num_madeWiths <- NULL
game_data$num_platforms <- NULL
game_data$num_genres <- NULL


# Building model
library(caret)
library(e1071)
trControl_boot <- trainControl(classProbs = TRUE,
                               method = "boot",
                               number = 100, 
                               savePredictions = TRUE,
                               summaryFunction = twoClassSummary)

lr_games_full <- train(high_ranking ~ .,            
                       data = game_data,
                       method = "glm",
                       family = "binomial",
                       trControl = trControl_boot)
# Summary
summary(lr_games_full)
car::Anova(lr_games_full$finalModel, test.statistic = "Wald")
varImp(lr_games_full)

# plot ROC
library(ggplot2)
library(plotROC)
library(scales)

roc_plot <- ggplot(lr_games_full$pred, 
                   aes(m = Yes, d = factor(obs, levels = c("Yes", "No")))) + 
  geom_roc(labels=FALSE)
roc_plot +  
  style_roc(theme = theme_grey, ylab = "Sensitivity") +
  annotate("text", x = .75, y = .25, 
           label = paste("AUC =", round(calc_auc(roc_plot)$AUC, 2)))+
  scale_x_continuous("1 - Specificity", breaks = seq(0, 1, by = .1))



# For nomogram analysis - condensed model built with only the statisically signigicant predictors
game_data$num_devs <- round(game_data$num_devs, 2)
ddist <- datadist(game_data)
options(datadist='ddist')

lr_games_condensed <- lrm(high_ranking ~ 
                            desc_len + num_imgs + num_devs 
                          + platform_Android + platform_HTML5 + platform_Windows + platform_macOS
                          + genre_Interactive.Fiction + genre_Platformer 
                          + genre_Puzzle + genre_Action
                          + avgSession_A.few.minutes
                          + madeWith_GIMP + madeWith_GameMaker.Studio
                          + madeWith_MonoGame + madeWith_PICO.8 + madeWith_Paint.net
                          + has_asset_license,  
                          data = game_data,
                          x=TRUE,y=TRUE)

# bootcov
lr_games_condensed_boot <- bootcov(lr_games_condensed, B=100,pr=TRUE,maxit = 100000000000)

nom <- nomogram(lr_games_condensed_boot,
                fun=plogis,
                fun.at=c(0.05, seq(.1,.9,by=.2), 0.95, 0.99),
                abbrev = TRUE,
                lp=F,
                vnames = "labels",
                varname.label=TRUE,
                funlabel = "High-ranking")
par(mar = c(0.1,0.1,0.1,0.1))
plot(nom,
     label.every=1,
     lmgp = 0.15,
     xfrac=.4
)


# Function used to calculate AUC of condensed model
CalculateAucFromDxy <- function(validate) {
  ## Test if the object is correct
  stopifnot(class(validate) == "validate")
  
  ## Calculate AUCs from Dxy's
  aucs <- (validate["Dxy", c("index.orig","training","test","optimism","index.corrected")])/2 + 0.5
  
  ## Get n
  n <- validate["Dxy", c("n")]
  
  ## Combine as result
  res <- rbind(validate, AUC = c(aucs, n))
  
  ## Fix optimism
  res["AUC","optimism"] <- res["AUC","optimism"] - 0.5
  
  ## Return results
  res
}

# Calculate AUC of the condensed model
CalculateAucFromDxy(validate(lr_games_condensed_boot,B=100)) #=> 0.77


# Dive deeper............
high_ranking_games <- subset(game_data, high_ranking == "Yes")
low_ranking_games <- subset(game_data, high_ranking == "No")

library(effsize)
library(distdiff)
# Comparing description lengths
summary(high_ranking_games$desc_len)
summary(low_ranking_games$desc_len)
wilcox.test(high_ranking_games$desc_len, 
            low_ranking_games$desc_len, alternative = "greater")
cliff.delta(high_ranking_games$desc_len, 
            low_ranking_games$desc_len)

par(mar = c(2,0.4,0.1,0.1))
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

x <- subset(game_data, num_devs > 1)
summary(x$high_ranking)

# Platform========================================================================================
# Comparing platform_Windows
summary(high_ranking_games$platform_Windows)
summary(low_ranking_games$platform_Windows)


# Comparing platform_macOS
summary(high_ranking_games$platform_macOS)
summary(low_ranking_games$platform_macOS)


# Comparing platform_Android
summary(high_ranking_games$platform_Android)
summary(low_ranking_games$platform_Android)


# Comparing platform_HTML5
summary(high_ranking_games$platform_HTML5)
summary(low_ranking_games$platform_HTML5)


# AVG session=================================================================================
# Comparing aveSession_A.few.minutes
summary(high_ranking_games$avgSession_A.few.minutes)
summary(low_ranking_games$avgSession_A.few.minutes)


# Comparing has_asset_license
summary(high_ranking_games$has_asset_license)
summary(low_ranking_games$has_asset_license)


# GENRE========================================================================================
# Comparing genre_Puzzle
summary(high_ranking_games$genre_Puzzle)
summary(low_ranking_games$genre_Puzzle)


# Comparing  genre_Platformer
summary(high_ranking_games$genre_Platformer)
summary(low_ranking_games$genre_Platformer)


# Comparing genre_Interactive.Fiction
summary(high_ranking_games$genre_Interactive.Fiction)
summary(low_ranking_games$genre_Interactive.Fiction)


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


# Comparing madeWith_GIMP
summary(high_ranking_games$madeWith_GIMP)
summary(low_ranking_games$madeWith_GIMP)


# Comparing madeWith_GameMaker.Studio
summary(high_ranking_games$madeWith_GameMaker.Studio)
summary(low_ranking_games$madeWith_GameMaker.Studio)


# Comparing madeWith_Paint.net
summary(high_ranking_games$madeWith_Paint.net)
summary(low_ranking_games$madeWith_Paint.net)


# Comparing madeWith_MonoGame
summary(high_ranking_games$madeWith_MonoGame)
summary(low_ranking_games$madeWith_MonoGame)



#================================ random forest experiment ======================================
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



# Variable importance
varImp(rf_model_all)