
library(Hmisc)
# Correlation analysis tree
clust <- varclus(data.matrix(non_competitive_jams[,2:ncol(non_competitive_jams)]))
plot(clust)


# Redudancy analysis
library(dplyr)
non_competitive_jams[!names(non_competitive_jams) %in%  c("popular")]%>% 
  redun(~., data=., r2=.8, nk=0, 
        minfreq=40,
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

# RF
roc_plot <- ggplot(rf_non_competitive_jam$pred, 
                   aes(m = Yes, d = factor(obs, levels = c("Yes", "No")))) + 
  geom_roc(labels=FALSE)
roc_plot + 
  style_roc(theme = theme_grey, ylab = "Sensitivity") +
  annotate("text", x = .75, y = .25, 
           label = paste("AUC =", round(calc_auc(roc_plot)$AUC, 2)))+
  scale_x_continuous("1 - Specificity", breaks = seq(0, 1, by = .1))


# Logistic
lr_non_competitive_jam <- train(popular ~ .,            
                            data = non_competitive_jams,
                            # method = "glm",
                            method="glmStepAIC",
                            direction ="backward",
                            family = "binomial",
                            trControl = trControl)

lr_non_competitive_jam_final <- train(popular ~ 
                                        jam_desc_len +
                                        jam_no_illustrations +
                                        jam_no_videos +
                                        num_hosts,            
                                  data = non_competitive_jams,
                                  # method = "glm",
                                  method="glmStepAIC",
                                  direction ="backward",
                                  family = "binomial",
                                  trControl = trControl)


roc_plot <- ggplot(lr_non_competitive_jam$pred, 
                   aes(m = Yes, d = factor(obs, levels = c("Yes", "No")))) + 
  geom_roc(labels=FALSE)
roc_plot + 
  style_roc(theme = theme_grey, ylab = "Sensitivity") +
  annotate("text", x = .75, y = .25, 
           label = paste("AUC =", round(calc_auc(roc_plot)$AUC, 2)))+
  scale_x_continuous("1 - Specificity", breaks = seq(0, 1, by = .1))



roc_plot <- ggplot(lr_non_competitive_jam_final$pred, 
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
car::Anova(lr_non_competitive_jam$finalModel, test.statistic="Wald")


# Variable importance
varImp(rf_non_competitive_jam)
varImp(lr_non_competitive_jam)

# Summary coefficient
summary(lr_non_competitive_jam)

# For nomogram analysis
lr_non_competitive_jam_nomogram <- lrm(popular ~ 
                                         jam_desc_len +
                                         jam_no_illustrations +
                                         jam_no_videos +
                                         num_hosts,
                                   # family = binomial,
                                   data = non_competitive_jams,)
ddist <- datadist(non_competitive_jams)
options(datadist='ddist')
nom_non_competitive_ams <- nomogram(lr_non_competitive_jam_nomogram,
                                  fun=function(x)1/(1+exp(-x)),
                                  fun.at=c(.001,.01,seq(.5,.9,by=.2),.99,.999),
                                  # conf.int=c(0.1,0.7),
                                  abbrev = TRUE,
                                  lp=F,
                                  funlabel = "Popularity")
plot(nom_non_competitive_ams,
     # col.conf=c('red','green'),
     # conf.space=c(0.1,0.2),
     label.every=1,
     # fun.side=c(1,3,1,1,3,1,3,1,1,1,1,1,1,3),
     fun.side=c(1,1,1,3,1,1,1),
     lmgp = 0.15,
     # col.grid = gray(c(0.8, 0.95)),
     # col.grid = gray(c(0.8, 0.95)),
     xfrac=.45
)


# Dive deeper............
library(effsize)
popular_non_competitive_jams <- subset(non_competitive_jams, popular == "Yes")
unpopular_non_competitive_jams <- subset(non_competitive_jams, popular == "No")

# Comparing description lengths
summary(popular_non_competitive_jams$jam_desc_len)
summary(unpopular_non_competitive_jams$jam_desc_len)
wilcox.test(popular_non_competitive_jams$jam_desc_len, 
            unpopular_non_competitive_jams$jam_desc_len, alternative = "greater")
cliff.delta(popular_non_competitive_jams$jam_desc_len, 
            unpopular_non_competitive_jams$jam_desc_len)

log(non_competitive_jams$desc_len + 1)

comp.dist.plot(log(popular_non_competitive_jams$jam_desc_len + 1), 
               log(unpopular_non_competitive_jams$jam_desc_len + 1),
               legend1 = "Popular jams",
               legend2 = "Non-popular jams",
               legendpos = "topleft",
               cut = FALSE)

# Comparing durations
summary(popular_non_competitive_jams$jam_duration)
summary(unpopular_non_competitive_jams$jam_duration)
wilcox.test(popular_non_competitive_jams$jam_duration, 
            unpopular_non_competitive_jams$jam_duration, alternative = "less")
wilcox.test( 
            unpopular_non_competitive_jams$jam_duration,popular_non_competitive_jams$jam_duration)
cliff.delta(popular_non_competitive_jams$jam_duration, 
            unpopular_non_competitive_jams$jam_duration)

comp.dist.plot(popular_non_competitive_jams$jam_duration, 
               unpopular_non_competitive_jams$jam_duration,
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

comp.dist.plot(popular_non_competitive_jams$jam_no_illustrations, 
               unpopular_non_competitive_jams$jam_no_illustrations,
               legend1 = "Popular non-competitive jams",
               legend2 = "Non-popular non-competitive jams",
               legendpos = "topleft",
               xlab = "Median jam duration (in log scale)",
               cut = FALSE)

x <- subset(non_competitive_jams, num_imgs > 0)
summary(x$popular)


# Comparing number of videos
summary(popular_non_competitive_jams$jam_no_videos)
summary(unpopular_non_competitive_jams$jam_no_videos)
wilcox.test(popular_non_competitive_jams$jam_no_videos, 
            unpopular_non_competitive_jams$jam_no_videos, alternative = "greater")
cliff.delta(popular_non_competitive_jams$jam_no_videos, 
            unpopular_non_competitive_jams$jam_no_videos)

comp.dist.plot(popular_non_competitive_jams$jam_no_videos, 
               unpopular_non_competitive_jams$jam_no_videos,
               legend1 = "Popular non-competitive jams",
               legend2 = "Non-popular non-competitive jams",
               legendpos = "topleft",
               xlab = "Median jam duration (in log scale)",
               cut = FALSE)


# Comparing number of hosts
summary(popular_non_competitive_jams$num_hosts)
summary(unpopular_non_competitive_jams$num_hosts)
wilcox.test(popular_non_competitive_jams$num_hosts, 
            unpopular_non_competitive_jams$num_hosts, alternative = "greater")
cliff.delta(popular_non_competitive_jams$num_hosts, 
            unpopular_non_competitive_jams$num_hosts)

comp.dist.plot(popular_non_competitive_jams$num_hosts, 
               unpopular_non_competitive_jams$num_hosts,
               legend1 = "Popular non-competitive jams",
               legend2 = "Non-popular non-competitive jams",
               legendpos = "topleft",
               xlab = "Median jam duration (in log scale)",
               cut = FALSE)


x <- subset(non_competitive_jams, num_hosts > 1)
summary(x$popular)


wilcox.test(competitive_jams$jam_no_submissions, 
            non_competitive_jams$jam_no_submissions, alternative = "greater")
cliff.delta(competitive_jams$jam_no_submissions, 
            non_competitive_jams$jam_no_submissions)


