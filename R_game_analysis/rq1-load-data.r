#===================== Loading non-competitive jams data=======================================#
non_competitive_jams <- read.csv("../dataset/non_competitive_jams_cleaned.csv",
                                 encoding = "UTF-8" ,
                                 stringsAsFactors = FALSE,
                                 na.strings=c("","NA"))
# Rename column
colnames(non_competitive_jams)[colnames(non_competitive_jams) == "X.U.FEFF.duration"] <- "duration"

# reorder column
non_competitive_jams <- non_competitive_jams[, c(6, 1:5)]

# Add label to response variable
non_competitive_jams$popular <- factor(non_competitive_jams$popular)

# Convert to log scale
non_competitive_jams$desc_len<-log(non_competitive_jams$desc_len + 1)
non_competitive_jams$duration<-log(non_competitive_jams$duration + 1)
non_competitive_jams$num_vids<-log(non_competitive_jams$num_vids + 1)
non_competitive_jams$num_imgs<-log(non_competitive_jams$num_imgs + 1)
non_competitive_jams$num_hosts<-log(non_competitive_jams$num_hosts + 1)
#==============================================================================================#


#===================== Loading competitive jams data===========================================#
competitive_jams <- read.csv("../dataset/competitive_jams_cleaned.csv",
                             encoding = "UTF-8" ,
                             stringsAsFactors = FALSE,
                             na.strings=c("","NA"))

# Rename column
colnames(competitive_jams)[colnames(competitive_jams) == "X.U.FEFF.duration"] <- "duration"


# reorder column
competitive_jams <- competitive_jams[, c(7, 1:6)]

# Add label to response variable
competitive_jams$popular <- factor(competitive_jams$popular)

# Convert to log scale
competitive_jams$desc_len<-log(competitive_jams$desc_len + 1)
competitive_jams$duration<-log(competitive_jams$duration + 1)
competitive_jams$num_vids<-log(competitive_jams$num_vids + 1)
competitive_jams$num_imgs<-log(competitive_jams$num_imgs + 1)
competitive_jams$num_criteria<-log(competitive_jams$num_criteria + 1)
competitive_jams$num_hosts<-log(competitive_jams$num_hosts + 1)