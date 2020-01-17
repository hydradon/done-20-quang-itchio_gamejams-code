library(Hmisc)
# Correlation analysis tree
clust <- varclus(data.matrix(competitive_jams[,2:ncol(competitive_jams)]))
par(mar = c(4,4,0.1,0.1))
plot(clust, sub = test)

# Redudancy analysis
library(rms)
library(dplyr)
competitive_jams[!names(competitive_jams) %in%  c("Popular")]%>% 
  redun(~., data=., r2=.8, nk=0, 
        # minfreq=40,
        allcat=TRUE)


# Model building
library(caret)
library(e1071)
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

# Summary
summary(lr_competitive_jam_boot)
car::Anova(lr_competitive_jam_boot$finalModel, test.statistic = "Wald")
varImp(lr_competitive_jam_boot$finalModel)

# plot ROC
library(ggplot2)
library(plotROC)
library(scales)

roc_plot <- ggplot(lr_competitive_jam_boot$pred, 
                   aes(m = Yes, d = factor(obs, levels = c("Yes", "No")))) + 
  geom_roc(labels=FALSE)
roc_plot + 
  style_roc(theme = theme_grey, ylab = "Sensitivity") +
  annotate("text", x = .75, y = .25, 
           label = paste("AUC =", round(calc_auc(roc_plot)$AUC, 2)))+
  scale_x_continuous("1 - Specificity", breaks = seq(0, 1, by = .1))

# For nomogram analysis 
competitive_jams$num_hosts <- round(competitive_jams$num_hosts,2)
competitive_jams$num_vids <- round(competitive_jams$num_vids,2)
lr_competitive_jam_nomogram <- lrm(popular ~
                                     duration + desc_len
                                   + num_vids + num_criteria
                                   + num_imgs + num_hosts,
                                   x=TRUE, y=TRUE,
                                   data = competitive_jams)

# bootcov
lr_competitive_jam_nomogram_boot <- bootcov(lr_competitive_jam_nomogram, 
                                            B=100,
                                            pr=TRUE,
                                            maxit = 100000000000)

# Calculate AUC of the model used for building nomogram
CalculateAucFromDxy(validate(lr_competitive_jam_nomogram_boot,B=100))

# Drawing nomogram
ddist <- datadist(competitive_jams)
options(datadist='ddist')
nom <- nomogram(lr_competitive_jam_nomogram_boot,
                fun=plogis,
                fun.at=c(.001,0.1,0.5,0.9, .999),
                abbrev = TRUE,
                lp=F,
                funlabel = "Popularity")
par(mar = c(1,0,0.2,0.1))
x <- plot(nom,
          label.every=2,
          fun.side=c(1,3,1,3,1),
          lmgp = 0.15,
          xfrac=.25
)

# Dive deeper............
popular_competitive_jams <- subset(competitive_jams, popular == "Yes")
unpopular_competitive_jams <- subset(competitive_jams, popular == "No")

library(effsize)
library(distdiff)

# Comparing description lengths
summary(popular_competitive_jams$desc_len)
summary(unpopular_competitive_jams$desc_len)
wilcox.test(popular_competitive_jams$desc_len, 
            unpopular_competitive_jams$desc_len, alternative = "greater")
cliff.delta(popular_competitive_jams$desc_len, unpopular_competitive_jams$desc_len)

par(mar = c(2,0.1,0.1,0.1))
comp.dist.plot(log(popular_competitive_jams$desc_len + 1), 
               log(unpopular_competitive_jams$desc_len + 1),
               legend1 = "Popular jams",
               legend2 = "Non-popular jams",
               legendpos = "topleft",
               cut = FALSE)

effsize.range.plot(log(popular_competitive_jams$desc_len + 1),
                   log(unpopular_competitive_jams$desc_len + 1))

# Comparing durations
summary(popular_competitive_jams$duration)
summary(unpopular_competitive_jams$duration)
wilcox.test(popular_competitive_jams$duration, 
            unpopular_competitive_jams$duration, alternative = "less")
cliff.delta(popular_competitive_jams$duration, unpopular_competitive_jams$duration)

comp.dist.plot(popular_competitive_jams$duration, 
               unpopular_competitive_jams$duration,
               legend1 = "Popular jams",
               legend2 = "Non-popular jams",
               legendpos = "topleft",
               cut = FALSE)

# Comparing number of illustrations
summary(popular_competitive_jams$num_imgs)
summary(unpopular_competitive_jams$num_imgs)
wilcox.test(popular_competitive_jams$num_imgs, 
            unpopular_competitive_jams$num_imgs, alternative = "greater")
cliff.delta(popular_competitive_jams$num_imgs,
            unpopular_competitive_jams$num_imgs)

x <- subset(competitive_jams, num_imgs > 0)
summary(x$popular)

# Comparing number of videos
summary(popular_competitive_jams$num_vids)
summary(unpopular_competitive_jams$num_vids)
wilcox.test(popular_competitive_jams$num_vids, 
            unpopular_competitive_jams$num_vids, alternative = "greater")
cliff.delta(popular_competitive_jams$num_vids, unpopular_competitive_jams$jam_no_videos)


# Comparing number of hosts
summary(popular_competitive_jams$num_hosts)
summary(unpopular_competitive_jams$num_hosts)
wilcox.test(popular_competitive_jams$num_hosts, 
            unpopular_competitive_jams$num_hosts, alternative = "greater")
cliff.delta(popular_competitive_jams$num_hosts, unpopular_competitive_jams$num_hosts)


x <- subset(competitive_jams, num_hosts > 1)
summary(x$popular)

# Comparing number of criteria
summary(popular_competitive_jams$num_criteria)
summary(unpopular_competitive_jams$num_criteria)
wilcox.test(popular_competitive_jams$num_criteria, 
            unpopular_competitive_jams$num_criteria, alternative = "greater")
cliff.delta(popular_competitive_jams$num_criteria, unpopular_competitive_jams$num_criteria)

comp.dist.plot(popular_competitive_jams$num_criteria, 
               unpopular_competitive_jams$num_criteria,
               legend1 = "Popular jams",
               legend2 = "Non-popular jams",
               legendpos = "topleft")
summary(competitive_jams$num_criteria)


#================================ random forest experiment ======================================
# random forest
library(randomForest)
library(caret)
library(e1071)

trControl <- trainControl(classProbs = TRUE,
                          method = "boot",
                          number = 100, 
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
rf_competitive_jam <- train(popular ~ .,            
                            data = competitive_jams,
                            method = "rf",
                            tuneGrid = tuneGrid_competitive_jam,
                            trControl = trControl,
                            importance = TRUE,
                            maxnodes = 5,
                            nodesize = 14,
                            ntree = 2000)


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


# Variable importance
varImp(rf_competitive_jam)