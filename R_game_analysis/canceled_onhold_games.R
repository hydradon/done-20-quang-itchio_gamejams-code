all_games <- read.csv("D:/ECE720 project/dataset/all_games_details_cleaned.csv", 
                      encoding = "UTF-8" ,
                      stringsAsFactors = FALSE)
# Remove games with in accessible, private page:
all_games <- all_games[!(all_games$game_developers==""),]
all_games_and_jams <- merge(all_games, all_jams, by = "jam_name")
# Analyse special cases
# On-hold and Cancelled games

canceled_games <- all_games[(all_games$game_status=="Canceled"),]
onhold_games <- all_games[(all_games$game_status=="On hold"),]

sample_canceled_games <- canceled_games[sample(nrow(canceled_games), 69), ]
sample_onhold_games <- onhold_games[sample(nrow(onhold_games), 78), ]


# write.csv(sample_canceled_games, file = "sample_canceled_games.csv",row.names=FALSE)
# write.csv(sample_onhold_games, file = "sample_onhold_games.csv",row.names=FALSE)
