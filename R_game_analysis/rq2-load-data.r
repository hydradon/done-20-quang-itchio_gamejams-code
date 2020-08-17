game_data <- read.csv("../dataset/games_cleaned.csv", 
                      encoding = "UTF-8" ,
                      stringsAsFactors = FALSE,
                      na.strings=c("","NA"))
colnames(game_data)[colnames(game_data)=="X.U.FEFF.game_desc_len"] <- "desc_len"    
colnames(game_data)[colnames(game_data)=="game_no_screenshots"] <- "num_imgs"   
colnames(game_data)[colnames(game_data)=="madeWith_GameMaker..Studio"] <- "madeWith_GameMaker.Studio"    

game_data[is.na(game_data)] <- 0
game_data$high_ranking <- factor(game_data$high_ranking)

# reorder column
game_data <- game_data[, c(3, 1:2, 4:ncol(game_data))]

# Convert categorical variables to factors
game_data <- data.frame(lapply(game_data, function(x) as.factor((x))))

# Convert non-categorical variables back to numberic
game_data$desc_len <- as.numeric(game_data$desc_len)
game_data$num_imgs  <- as.numeric(game_data$num_imgs)
game_data$num_devs <- as.numeric(game_data$num_devs)
game_data$num_platforms <- as.numeric(game_data$num_platforms)
game_data$num_genres <- as.numeric(game_data$num_genres)
game_data$num_inputs <- as.numeric(game_data$num_inputs)
game_data$num_madeWiths <- as.numeric(game_data$num_madeWiths)

# Convert to log scale
game_data$desc_len<-log(game_data$desc_len + 1)
game_data$num_devs<-log(game_data$num_devs + 1)
game_data$num_imgs<-log(game_data$num_imgs + 1)
game_data$num_platforms<-log(game_data$num_platforms + 1)
game_data$num_genres<-log(game_data$num_genres + 1)
game_data$num_inputs<-log(game_data$num_inputs + 1)
game_data$num_madeWiths<-log(game_data$num_madeWiths + 1)

                        