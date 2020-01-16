# Logistic regression 2 # NOTE: this does not improve!!!
library(rms)

#remove correlated factors
game_data$madeWith_Logic.Pro <- NULL
game_data$input_OSVR..Open.Source.Virtual.Reality. <- NULL
game_data$input_NeuroSky.Mindwave <- NULL





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

# lr_games_boot <- train(high_ranking ~ 
#                          game_desc_len 
#                        + game_no_screenshots 
#                        + number_of_developers  
#                        + platform_HTML5
#                        + genre_Puzzle,            
#                    data = game_data,
#                    method = "glm",
#                    family = "binomial",
#                    trControl = trControl_boot)


roc_plot <- ggplot(lr_games_full$pred, 
                   aes(m = Yes, d = factor(obs, levels = c("Yes", "No")))) + 
  geom_roc(labels=FALSE)
roc_plot +  
  style_roc(theme = theme_grey, ylab = "Sensitivity") +
  annotate("text", x = .75, y = .25, 
           label = paste("AUC =", round(calc_auc(roc_plot)$AUC, 2)))+
  scale_x_continuous("1 - Specificity", breaks = seq(0, 1, by = .1))

# Summary
summary(lr_games_boot)
car::Anova(lr_games_full$finalModel, test.statistic = "Wald")
varImp(lr_games_boot)


# For nomogram analysis - built without the insignificant predictors
game_data$num_devs <- round(game_data$num_devs, 2)

               
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

varImp(lr_games_condensed_boot)

# bootcov
lr_games_condensed_boot <- bootcov(lr_games_condensed, B=100,pr=TRUE,maxit = 100000000000)
# lr_games_condensed_boot$coefficients <- -lr_games_condensed_boot$coefficients



ddist <- datadist(game_data)
options(datadist='ddist')
nom <- nomogram(lr_games_condensed_boot,
                fun=plogis,
                fun.at=c(0.05, seq(.1,.9,by=.2), 0.95, 0.99),
                abbrev = TRUE,
                lp=F,
                vnames = "labels",
                varname.label=TRUE,
                funlabel = "High-ranked")
par(mar = c(0.1,0.1,0.1,0.1))
plot(nom,
     label.every=1,
     lmgp = 0.15,
     xfrac=.4
)



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

CalculateAucFromDxy(validate(lr_games_condensed_boot,B=100)) #=> 0.77




ggplot(Predict(lr_games_condensed_boot, desc_len, platform_Windows, fun=plogis),
       pval = T,
       adj.subtitle=FALSE,
       cex.anova=17,
       cex.axis=2,cex.adj=2,cex=2)
+ theme(text = element_text(size=14),
        axis.text.x = element_text(size=14),
        axis.text.y = element_text(size=14))
+ ylab('Probability') + coord_cartesian(ylim = c(0,1))

