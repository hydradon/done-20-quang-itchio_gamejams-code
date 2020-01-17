game_data_bef_encoding <- read.csv("D:/Research/game-jam-crawler-model/dataset/games_cleaned_before_encoding.csv", 
                                   encoding = "UTF-8" ,
                                   stringsAsFactors = FALSE,
                                   na.strings=c("","NA"))
game_data_bef_encoding <- game_data_bef_encoding[!names(game_data_bef_encoding) 
                                                 %in% c("jam_url",
                                                        "jam_name",
                                                        "game_url",
                                                        "game_name",
                                                        "game_submission_page",
                                                        "game_scores",
                                                        "game_raw_scores",
                                                        "game_developers_url",
                                                        "game_developers",
                                                        "game_criteria")]


library(reshape2)
library(ggplot2)
library(dplyr)
ggplot_missing <- function(x){
  
  x %>% 
    is.na %>%
    melt %>%
    ggplot(data = .,
           aes(x = Var2,
               y = Var1)) +
    geom_raster(aes(fill = value)) +
    scale_fill_grey(name = "",
                    labels = c("Present","Missing")) +
    theme_minimal() + 
    theme(axis.text.x  = element_text(angle=45, vjust=0.5)) + 
    labs(x = "Variables in Dataset",
         y = "Rows / observations")
}
ggplot_missing(game_data_bef_encoding)











game_data <- read.csv("D:/Research/ECE720 project/dataset/games_cleaned.csv", 
                      encoding = "UTF-8" ,
                      stringsAsFactors = FALSE,
                      na.strings=c("","NA"))
colnames(game_data)[colnames(game_data)=="X.U.FEFF.game_desc_len"] <- "game_desc_len"                               

game_data[is.na(game_data)] <- 0
game_data$high_ranking <- game_data$high_ranking=="1"
game_data$high_ranking <- factor(game_data$high_ranking)

# game_data$X.U.FEFF.game_ave_session_0 <- NULL
# game_data$game_source_code <- NULL
game_data$overall_rank <- NULL
game_data$game_no_ratings <- NULL
# game_data$X.U.FEFF.game_accessibility <- NULL

# reorder column
# game_data <- game_data[, c(6, 1:5, 7:ncol(game_data))]
game_data <- game_data[, c(3, 1:2, 4:ncol(game_data))]
# splitting
train <- game_data[1:7036,]
test <- game_data[7037:7818,]


library(Hmisc)
# Correlation analysis tree
clust <- varclus(data.matrix(game_data[,2:ncol(game_data)]))
plot(clust)

# Redudancy analysis
game_data[!names(game_data) %in%  c("high_ranking")]%>% 
  redun(~., data=., r2=.8, nk=0, 
        minfreq=40,
        allcat=TRUE)

names(game_data)

#using k-fold cross validation
library(tidyverse)
library(caret)
set.seed(123) 
# train.control <- trainControl(method = "cv", number = 10, savePredictions = TRUE)
train.control <- trainControl(method = "repeatedcv", 
                              number = 10, repeats = 3)
model_some <- train(high_ranking ~   
                  aveSession_A.few.hours                  
                +aveSession_A.few.minutes                 
                +aveSession_A.few.seconds                
                +aveSession_About.a.half.hour             
                +aveSession_About.an.hour                
                +aveSession_Days.or.more   
                + game_desc_len
                + game_no_screenshots
                + number_of_developers
                + platform_HTML5
                + platform_Linux
                + platform_Windows
                + platform_macOS
                + genre_Action
                + genre_Platformer
                + genre_Puzzle
                + input_Keyboard
                + input_Mouse
                + madeWith_Unity
                + has_accesibility,
               data = game_data,
               method = "glm",
               family = "binomial",
               trControl = train.control)


model_all <- train(high_ranking ~ .,            
                    data = game_data,
                    method = "glm",
                    family = "binomial",
                    trControl = train.control)

# using glm to fill all
glm_fit_all <- glm(
  high_ranking ~ .,
  data = train,
  family = binomial
)


library(car)
car::Anova(glm_fit_all, test.statistic="Wald")

summary(glm_fit_all)
glm.probs_all <- predict(glm_fit_all, newdata = test, type = "response")

glm.pred_all = ifelse(glm.probs_all > 0.5, TRUE, FALSE)
table(glm.pred_all, test$high_ranking)
mean(glm.pred_all == test$high_ranking)


# # using glm to fit some
glm_fit_some <- glm(high_ranking  ~ 
                      
  aveSession_A.few.hours                  
  +aveSession_A.few.minutes                 
  +aveSession_A.few.seconds                
  +aveSession_About.a.half.hour             
  +aveSession_About.an.hour                
  +aveSession_Days.or.more   
  # game_ave_session_1
  # + game_ave_session_2
  # + game_ave_session_3
  + game_desc_len
  + game_no_screenshots
  + number_of_developers
  + platform_HTML5
  + platform_Linux
  + platform_Windows
  + platform_macOS
  + genre_Action
  + genre_Platformer
  + genre_Puzzle
  + input_Keyboard
  + input_Mouse
  + madeWith_Unity
  + has_accesibility,
  data = train,
  family = binomial
)
summary(glm_fit_some)
glm.probs_some <- predict(glm_fit_some, newdata = test, type = "response")
glm.pred_some = ifelse(glm.probs_some > 0.5, TRUE, FALSE)
table(glm.pred_some, test$high_ranking)
mean(glm.pred_some == test$high_ranking)

library(ROCR)
pr <- prediction(glm.probs_some, test$high_ranking)
prf <- performance(pr, measure = "tpr", x.measure = "fpr")
plot(prf, colorize=TRUE)

auc <- performance(pr, measure = "auc")
auc <- auc@y.values[[1]]
auc


library(plotROC)
library(scales)
auc_df <- data.frame("D" = test$high_ranking, 
                     "M1" = glm.probs_all,
                     "M2" = glm.probs_some)
longtest <- melt_roc(auc_df, "D", c("M1", "M2"))
test_plot <- 
  ggplot(longtest, aes(d = D, m = M, color = name))+ 
  geom_roc(labels=FALSE)+
  style_roc(theme = theme_classic, ylab = "Sensitivity")


test_plot <-
  test_plot+
  scale_color_hue(labels = c(paste(paste("128\n(AUC =", round(calc_auc(test_plot)$AUC[[1]], 2)), ")"),
                             paste(paste("20\n(AUC =", round(calc_auc(test_plot)$AUC[[2]], 2)), ")")))+
  guides(color=guide_legend("# of factors"))+
  scale_x_continuous("1 - Specificity", breaks = seq(0, 1, by = .2))+
  theme(
    legend.position = c(.95, .55),
    legend.justification = c("right", "top"),
    legend.box.just = "left",
    legend.margin = margin(6, 6, 6, 6),
    # panel.background = element_blank(),
    # axis.line = element_line(colour = "black"),
    axis.text=element_text(size=13),
    axis.title = element_text(size=13),
    axis.text.x=element_text(size = 13, hjust=1),
    axis.text.y = element_text(hjust = 0.5, size = 13),
    legend.background = element_rect(size=0.5, linetype="solid",
                                     colour ="black"),
    legend.text=element_text(size=13),
    legend.title = element_text(size=13)
  )

test_plot

  theme(panel.background = element_blank(),
        axis.line = element_line(colour = "black"),
        axis.text=element_text(size=9),
        axis.title = element_text(size=9),
        axis.text.x=element_text(size = 9, hjust=1),
        axis.text.y = element_text(hjust = 0.5, size = 9))
 

roc_plot <- ggplot(data.frame("predictions" = glm.probs, 
                              "labels" = test$high_ranking), 
                   aes(m = predictions, d = labels))+
  geom_roc(labels=FALSE)

roc_plot + 
  style_roc(theme = theme_grey, ylab = "Sensitivity") +
  # theme(axis.text = element_text(colour = "blue")) +
  annotate("text", x = .75, y = .25, 
           label = paste("AUC =", round(calc_auc(roc_plot)$AUC, 2)))+
  scale_x_continuous("1 - Specificity", breaks = seq(0, 1, by = .1))