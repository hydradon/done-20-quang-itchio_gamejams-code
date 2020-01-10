game_data <- read.csv("D:/Research/game-jam-crawler-model/dataset/games_cleaned.csv", 
                      encoding = "UTF-8" ,
                      stringsAsFactors = FALSE,
                      na.strings=c("","NA"))
colnames(game_data)[colnames(game_data)=="X.U.FEFF.game_desc_len"] <- "desc_len"    
colnames(game_data)[colnames(game_data)=="game_no_screenshots"] <- "num_imgs"
colnames(game_data)[colnames(game_data)=="number_of_developers"] <- "num_devs"
colnames(game_data)[colnames(game_data)=="aveSession_A.few.minutes"] <- "avgSession_A.few.minutes"    
colnames(game_data)[colnames(game_data)=="madeWith_GameMaker..Studio"] <- "madeWith_GameMaker.Studio"    

game_data[is.na(game_data)] <- 0
# game_data$high_ranking <- game_data$high_ranking=="1"
# game_data$high_ranking <- factor(game_data$high_ranking)

game_data$overall_rank <- NULL

# reorder column
game_data <- game_data[, c(3, 1:2, 4:ncol(game_data))]

# Convert categorical variables to factors
game_data <- data.frame(lapply(game_data, function(x) as.factor((x))))

# Convert non-categorical variables back to numberic
game_data$desc_len <- as.numeric(game_data$desc_len)
game_data$num_imgs  <- as.numeric(game_data$num_imgs)
game_data$num_devs <- as.numeric(game_data$num_devs)

# Add label to response variable
game_data$high_ranking <- factor(game_data$high_ranking, 
                                 levels = c(1, 0), 
                                 labels = c("Yes", "No"))

                        