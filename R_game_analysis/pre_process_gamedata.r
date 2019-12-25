game_data <- read.csv("D:/Research/ECE720 project/dataset/games_cleaned.csv", 
                      encoding = "UTF-8" ,
                      stringsAsFactors = FALSE,
                      na.strings=c("","NA"))
colnames(game_data)[colnames(game_data)=="X.U.FEFF.game_desc_len"] <- "game_desc_len"                               

game_data[is.na(game_data)] <- 0
# game_data$high_ranking <- game_data$high_ranking=="1"
# game_data$high_ranking <- factor(game_data$high_ranking)

game_data$overall_rank <- NULL

# reorder column
game_data <- game_data[, c(3, 1:2, 4:ncol(game_data))]

# Convert categorical variables to factors
game_data <- data.frame(lapply(game_data, function(x) as.factor((x))))

# Convert non-categorical variables back to numberic
game_data$game_desc_len <- as.numeric(game_data$game_desc_len)
game_data$game_no_screenshots  <- as.numeric(game_data$game_no_screenshots)
game_data$number_of_developers <- as.numeric(game_data$number_of_developers)

# Add label to response variable
game_data$high_ranking <- factor(game_data$high_ranking, 
                                 levels = c(1, 0), 
                                 labels = c("Yes", "No"))

                        