library(Hmisc)
# Correlation analysis tree
clust <- varclus(data.matrix(non_competitive_jams[,2:ncol(non_competitive_jams)]))
par(mar = c(4,4,0.1,0.1))
plot(clust)


# Redudancy analysis
library(rms)
library(dplyr)
non_competitive_jams[!names(non_competitive_jams) %in%  c("popular")]%>% 
  redun(~., data=., r2=.8, nk=0, 
        minfreq=40,
        allcat=TRUE)


# Model building
library(caret)
library(e1071)
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

# Summary
summary(lr_non_competitive_jam_boot)
car::Anova(lr_non_competitive_jam_boot$finalModel, test.statistic = "Wald")
varImp(lr_non_competitive_jam_boot$finalModel)

# plot ROC
library(ggplot2)
library(plotROC)
library(scales)

roc_plot <- ggplot(lr_non_competitive_jam_boot$pred, 
                   aes(m = Yes, d = factor(obs, levels = c("Yes", "No")))) + 
  geom_roc(labels=FALSE)
roc_plot + 
  style_roc(theme = theme_grey, ylab = "Sensitivity") +
  annotate("text", x = .75, y = .25, 
           label = paste("AUC =", round(calc_auc(roc_plot)$AUC, 2)))+
  scale_x_continuous("1 - Specificity", breaks = seq(0, 1, by = .1))


# For nomogram analysis
non_competitive_jams$num_hosts <- round(non_competitive_jams$num_hosts,2)
non_competitive_jams$num_vids <- round(non_competitive_jams$num_vids,2)
lr_non_competitive_jam_nomogram <- lrm(popular ~ 
                                          desc_len
                                        + num_vids
                                        + num_imgs 
                                        + num_hosts
                                        + duration,   
                                        x=TRUE, y=TRUE,
                                        data = non_competitive_jams)

# bootcov
lr_non_competitive_jam_nomogram_boot <- bootcov(lr_non_competitive_jam_nomogram, 
                                                B=100,
                                                pr=TRUE,
                                                maxit = 100000000000)

# Calculate AUC of the model used for building nomogram
CalculateAucFromDxy(validate(lr_non_competitive_jam_nomogram_boot,B=100))

# Drawing nomogram
ddist <- datadist(non_competitive_jams)
options(datadist='ddist')
nom <- nomogram(lr_non_competitive_jam_nomogram_boot,
                fun=plogis,
                fun.at=c(0.05,0.1,0.5,0.9, 0.99),
                abbrev = TRUE,
                lp=F,
                funlabel = "Popularity")

par(mar = c(0.2,0,0.2,0))
plot(nom,
     label.every=1,
     fun.side=c(1,1,1,1,1),
     lmgp = 0.15,
     xfrac=.25
)

# Dive deeper............
popular_non_competitive_jams <- subset(non_competitive_jams, popular == "Yes")
unpopular_non_competitive_jams <- subset(non_competitive_jams, popular == "No")

library(effsize)
library(distdiff)
# Comparing description lengths
summary(popular_non_competitive_jams$desc_len)
summary(unpopular_non_competitive_jams$desc_len)
wilcox.test(popular_non_competitive_jams$desc_len, 
            unpopular_non_competitive_jams$desc_len, alternative = "greater")
cliff.delta(popular_non_competitive_jams$desc_len, 
            unpopular_non_competitive_jams$desc_len)

par(mar = c(2,0.1,0.1,0.1))
comp.dist.plot(log(popular_non_competitive_jams$desc_len + 1), 
               log(unpopular_non_competitive_jams$desc_len + 1),
               legend1 = "Popular jams",
               legend2 = "Non-popular jams",
               legendpos = "topleft",
               cut = FALSE)

# Comparing durations
summary(popular_non_competitive_jams$duration)
summary(unpopular_non_competitive_jams$duration)
wilcox.test(popular_non_competitive_jams$duration, 
            unpopular_non_competitive_jams$duration, alternative = "less")
wilcox.test(unpopular_non_competitive_jams$duration,
            popular_non_competitive_jams$duration)
cliff.delta(popular_non_competitive_jams$duration, 
            unpopular_non_competitive_jams$duration)

comp.dist.plot(popular_non_competitive_jams$duration, 
               unpopular_non_competitive_jams$duration,
               legend1 = "Popular jams",
               legend2 = "Non-popular jams",
               legendpos = "topleft",
               cut = FALSE)

# Comparing number of illustrations
summary(popular_non_competitive_jams$num_imgs)
summary(unpopular_non_competitive_jams$num_imgs)
wilcox.test(popular_non_competitive_jams$num_imgs, 
            unpopular_non_competitive_jams$num_imgs, alternative = "greater")
cliff.delta(popular_non_competitive_jams$num_imgs, 
            unpopular_non_competitive_jams$num_imgs)

x <- subset(non_competitive_jams, num_imgs > 0)
summary(x$popular)


# Comparing number of videos
summary(popular_non_competitive_jams$jam_no_videos)
summary(unpopular_non_competitive_jams$jam_no_videos)
wilcox.test(popular_non_competitive_jams$jam_no_videos, 
            unpopular_non_competitive_jams$jam_no_videos, alternative = "greater")
cliff.delta(popular_non_competitive_jams$jam_no_videos, 
            unpopular_non_competitive_jams$jam_no_videos)



# Comparing number of hosts
summary(popular_non_competitive_jams$num_hosts)
summary(unpopular_non_competitive_jams$num_hosts)
wilcox.test(popular_non_competitive_jams$num_hosts, 
            unpopular_non_competitive_jams$num_hosts, alternative = "greater")
cliff.delta(popular_non_competitive_jams$num_hosts, 
            unpopular_non_competitive_jams$num_hosts)

x <- subset(non_competitive_jams, num_hosts > 1)
summary(x$popular)


#================================ random forest experiment ======================================
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
tuneGrid_non_competitive_jam <- expand.grid(.mtry = c(11: 30))
rf_non_competitive_jam <- train(popular ~ .,            
                                data = non_competitive_jams,
                                method = "rf",
                                tuneGrid = tuneGrid_non_competitive_jam,
                                trControl = trControl,
                                importance = TRUE,
                                nodesize = 14,
                                ntree = 100)

# best mtry = 19
tuneGrid_non_competitive_jam <- expand.grid(.mtry = 19)


# tuning maxnode
store_maxnode <- list()
for (maxnodes in c(5: 30)) {
  set.seed(1234)
  rf_maxnode <- train(popular~.,
                      data = non_competitive_jams,
                      method = "rf",
                      tuneGrid = tuneGrid_non_competitive_jam,
                      trControl = trControl,
                      importance = TRUE,
                      nodesize = 14,
                      maxnodes = maxnodes,
                      ntree = 100)
  current_iteration <- toString(maxnodes)
  store_maxnode[[current_iteration]] <- rf_maxnode
}
results_node <- resamples(store_maxnode)
summary(results_node)
#best -> 9, 12, 15

# tuning ntree
store_maxtrees <- list()
for (ntree in c(100, 250, 300, 350, 400, 450, 500, 550, 600, 800, 1000, 2000)) {
  set.seed(5678)
  rf_maxtrees <- train(popular~.,
                       data = non_competitive_jams,
                       method = "rf",
                       tuneGrid = tuneGrid_non_competitive_jam,
                       trControl = trControl,
                       importance = TRUE,
                       nodesize = 14,
                       maxnodes = 12,
                       ntree = ntree)
  key <- toString(ntree)
  store_maxtrees[[key]] <- rf_maxtrees
}
results_tree <- resamples(store_maxtrees)
summary(results_tree)

# actual
rf_non_competitive_jam <- train(popular ~ .,            
                                data = non_competitive_jams,
                                method = "rf",
                                tuneGrid = tuneGrid_non_competitive_jam,
                                trControl = trControl,
                                importance = TRUE,
                                maxnodes = 12,
                                nodesize = 14,
                                ntree = 250)
# plot ROC
library(ggplot2)
library(plotROC)
library(scales)

roc_plot <- ggplot(rf_non_competitive_jam$pred, 
                   aes(m = Yes, d = factor(obs, levels = c("Yes", "No")))) + 
  geom_roc(labels=FALSE)
roc_plot + 
  style_roc(theme = theme_grey, ylab = "Sensitivity") +
  annotate("text", x = .75, y = .25, 
           label = paste("AUC =", round(calc_auc(roc_plot)$AUC, 2)))+
  scale_x_continuous("1 - Specificity", breaks = seq(0, 1, by = .1))


# Variable importance
varImp(rf_non_competitive_jam)






