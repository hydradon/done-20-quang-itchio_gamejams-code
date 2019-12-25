game_data_reduced <- read.csv("D:/Research/ECE720 project/dataset/games_cleaned_reduced.csv", 
                      encoding = "UTF-8" ,
                      stringsAsFactors = FALSE,
                      na.strings=c("","NA"))
colnames(game_data_reduced)[colnames(game_data_reduced)=="X.U.FEFF.game_desc_len"] <- "game_desc_len"                               

game_data_reduced[is.na(game_data_reduced)] <- 0
# game_data_reduced$high_ranking <- game_data_reduced$high_ranking=="1"
# game_data_reduced$high_ranking <- factor(game_data_reduced$high_ranking)

game_data_reduced$overall_rank <- NULL

# reorder column
game_data_reduced <- game_data_reduced[, c(3, 1:2, 4:ncol(game_data_reduced))]

# Convert categorical variables to factors
game_data_reduced <- data.frame(lapply(game_data_reduced, function(x) as.factor((x))))

# Convert non-categorical variables back to numberic
game_data_reduced$game_desc_len <- as.numeric(game_data_reduced$game_desc_len)
game_data_reduced$game_no_screenshots  <- as.numeric(game_data_reduced$game_no_screenshots)
game_data_reduced$number_of_developers <- as.numeric(game_data_reduced$number_of_developers)

# Add label to response variable
game_data_reduced$high_ranking <- factor(game_data_reduced$high_ranking, 
                                 levels = c(1, 0), 
                                 labels = c("Yes", "No"))



library(Hmisc)
# Correlation analysis tree
clust <- varclus(data.matrix(game_data_reduced[,2:ncol(game_data_reduced)]))
plot(clust)

#remove correlated factors
game_data_reduced$madeWith_Logic.Pro <- NULL
game_data_reduced$input_OSVR..Open.Source.Virtual.Reality. <- NULL
game_data_reduced$input_NeuroSky.Mindwave <- NULL


# Redudancy analysis
library(dplyr)
game_data_reduced[!names(game_data_reduced) %in%  c("high_ranking")]%>% 
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
tuneGrid <- expand.grid(.mtry = c(11: 30))
rf_model_reduced <- train(high_ranking ~ .,            
                      data = game_data_reduced,
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
                      data = game_data_reduced,
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
                       data = game_data_reduced,
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
rf_model_reduced <- train(high_ranking ~ .,            
                      data = game_data_reduced,
                      method = "rf",
                      # metric = "Accuracy",
                      tuneGrid = tuneGrid,
                      trControl = trControl,
                      importance = TRUE,
                      maxnodes = 30,
                      nodesize = 14,
                      ntree = 100)


# plot ROC
library(ggplot2)
library(plotROC)
library(scales)


# All
selectedIndices <- rf_model_reduced$pred$mtry == 11

roc_plot <- ggplot(rf_model_reduced$pred[selectedIndices, ], 
                   aes(m = Yes, d = factor(obs, levels = c("Yes", "No")))) + 
  geom_roc(labels=FALSE)
roc_plot + 
  style_roc(theme = theme_grey, ylab = "Sensitivity") +
  annotate("text", x = .75, y = .25, 
           label = paste("AUC =", round(calc_auc(roc_plot)$AUC, 2)))+
  scale_x_continuous("1 - Specificity", breaks = seq(0, 1, by = .1))


# Logistic
model_reduced <- train(high_ranking ~ .,            
                   data = game_data_reduced,
                   method = "glm",
                   family = "binomial",
                   trControl = trControl)
roc_plot <- ggplot(model_reduced$pred, 
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
car::Anova(model_all$finalModel, test.statistic="Wald")

# RF
varImp(rf_model_all)


results <- resamples(list(GLM=model_all, RF=rf_model_all))
plot(varImp(object=rf_model_all),main="RF - Variable Importance")
