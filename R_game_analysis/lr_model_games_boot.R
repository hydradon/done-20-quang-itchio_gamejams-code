# Logistic regression 2 # NOTE: this does not improve!!!
library(rms)

#remove correlated factors
game_data$madeWith_Logic.Pro <- NULL
game_data$input_OSVR..Open.Source.Virtual.Reality. <- NULL
game_data$input_NeuroSky.Mindwave <- NULL


# Convert to log scale
game_data$desc_len<-log(game_data$desc_len + 1)
game_data$num_devs<-log(game_data$num_devs + 1)
game_data$num_imgs<-log(game_data$num_imgs + 1)


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


lr_games_boot <- train(high_ranking ~ 
                         game_desc_len 
                       + game_no_screenshots 
                       + number_of_developers  
                       + platform_HTML5
                       + genre_Puzzle,            
                   data = game_data,
                   method = "glm",
                   family = "binomial",
                   trControl = trControl_boot)


roc_plot <- ggplot(lr_games_boot$pred, 
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
car::Anova(lr_games_full$finalModel)
varImp(lr_games_boot$finalModel)


# For nomogram analysis - built without the insignificant predictors
game_data$num_devs <- round(game_data$num_devs, 2)

var.labels = c(number_of_developers_round="number_of_developers",
               game_no_screenshots="game_no_screenshots",
               game_desc_len="game_desc_len",
               platform_HTML5="platform_HTML5",
               genre_Puzzle="genre_Puzzle")
label(game_data) = as.list(var.labels[match(names(game_data), names(var.labels))])


               
lr_games_condensed <- lrm(high_ranking ~ 
                                desc_len + num_imgs + num_devs + platform_Android
                              + platform_HTML5 + platform_Windows + platform_macOS
                              + genre_Interactive.Fiction + genre_Platformer 
                              + genre_Puzzle + input_Xbox.controller + aveSession_A.few.minutes
                              + madeWith_GIMP + madeWith_GameMaker..Studio
                              + madeWith_OpenFL + madeWith_PICO.8 + madeWith_Paint.net
                              + has_asset_license,  
                              data = game_data,
                              x=TRUE,y=TRUE)

# bootcov
lr_games_condensed_boot <- bootcov(lr_games_condensed, B=100,pr=TRUE,maxit = 1000000)
lr_games_condensed_boot$coefficients <- -lr_games_condensed_boot$coefficients



ddist <- datadist(game_data)
options(datadist='ddist')
nom <- nomogram(lr_games_condensed_boot,
                fun=plogis,
                fun.at=c(0.01, seq(.1,.9,by=.2), 0.95),
                abbrev = TRUE,
                lp=F,
                vnames = "labels",
                varname.label=TRUE,
                funlabel = "Popularity")
par(mar = c(0.1,0.1,0.1,0.1))
plot(nom,
     label.every=1,
     # fun.side=c(1,1,1,1,1),
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

