##Step 1: correlation and redundancy analysis
##Step 2: Build model and then bootcov it

set.seed(40)
#,
data<-data_load('C:\\Users\\Gopi\\Documents\\p2_final_model_data_20190810.csv')
##cor and red done "num_former_author","num_tester","num_author","num_mascot","num_ticket_manager","num_translator","num_maintainer","num_artist","num_contributor",
data<-data[,c("popularity","is_cat_misc","is_cat_food","is_cat_world_gen","is_cat_magic","is_cat_library_api","is_cat_fabric","is_cat_technology","is_cat_armor_weapons_tools","is_cat_addons","is_cat_adventure_rpg","is_cat_server_utility","is_cat_redstone","is_cat_map_info","is_cat_twitch_integration","is_cat_cosmetic",
              "num_words_short_desc","num_words_long_desc","is_mod_wiki_url","num_images",
              
              "latest_num_mc_versions","latest_num_java_versions","latest_num_bukkit_versions","num_incompatible_dep","num_tool_dep","num_required_dep","num_embedded_lib_dep","num_optional_dep",
              "is_paypal_url","is_patreon_urls",
              "is_mod_issues","is_mod_source_code")]
data$num_words_long_desc<-log(data$num_words_long_desc + 1)
data$num_images<-log(data$num_images + 1)
#Overall model without team characteristics
dd = datadist(data) 
options(datadist='dd')
overall_model<-lrm(popularity~is_cat_misc + is_cat_food + is_cat_world_gen + is_cat_magic + is_cat_library_api + is_cat_fabric + is_cat_technology + is_cat_armor_weapons_tools + is_cat_addons + is_cat_adventure_rpg + is_cat_server_utility + is_cat_redstone + is_cat_map_info + is_cat_twitch_integration + is_cat_cosmetic
                   + num_words_short_desc + num_words_long_desc + is_mod_wiki_url + num_images
                   
                   + latest_num_mc_versions + latest_num_java_versions + latest_num_bukkit_versions + num_incompatible_dep + num_tool_dep + num_required_dep + num_embedded_lib_dep + num_optional_dep
                   + is_paypal_url + is_patreon_urls + is_mod_issues + is_mod_source_code,data=data,x=TRUE,y=TRUE)

#Bootcov 
overall_boot<-bootcov(overall_model, B=100, pr=TRUE,maxit = 1000000)


#fastbw ,"is_mod_issues","is_mod_source_code"
reduced_features<-fastbw(overall_boot)
#change the features that are subsetted 
reduced<-data[,c("is_cat_misc","is_cat_food","is_cat_world_gen","is_cat_library_api","is_cat_fabric","is_cat_armor_weapons_tools","is_cat_addons","is_cat_server_utility","num_words_short_desc","num_words_long_desc","is_mod_wiki_url","num_images","latest_num_bukkit_versions","num_required_dep","is_paypal_url","is_patreon_urls","is_mod_issues","is_mod_source_code","popularity")]

reduced$popularity<-data$popularity

# generate model on the reduced features
dd = datadist(reduced) 
options(datadist='dd')
final_model<-lrm(popularity~.,data=reduced,x=TRUE,y=TRUE)

#Bootcov it
final_boot<-bootcov(final_model,B=100,pr=TRUE,maxit = 1000000)

#Generate them nomograms
final_noms <- nomogram(final_boot, fun=function(x)1/(1+exp(-x)),  # or fun=plogis
                                fun.at=c(.001,seq(.1,.9,by=.5),.999),
                                lp = FALSE,
                                funlabel="Downloadability",
                                abbrev = TRUE)
# Plot nomogram
par(mar = c(0.1,0.1,0.1,0.1))
plot(final_noms, xfrac=.30, cex.var = 1.0, cex.axis = 0.7)

#anova
an<-anova(final_boot)

CalculateAucFromDxy(validate(final_boot,B=100))

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

final_noms <- nomogram(mod_sans_comm_boot, fun=function(x)1/(1+exp(-x)),  # or fun=plogis
                       fun.at=c(.001,seq(.1,.9,by=.5),.999),
                       lp = FALSE,
                       funlabel="Downloadability",
                       abbrev = TRUE)
# Plot nomogram
par(mar = c(0.1,0.1,0.1,0.1))
plot(final_noms, xfrac=.30, cex.var = 1.0, cex.axis = 0.7)

#Partial plots


ggplot(Predict(final_model,num_words_long_desc,is_mod_wiki_url,fun=plogis),pval = T,adj.subtitle=FALSE,cex.anova=17,cex.axis=2,cex.adj=2,cex=2)+ theme(text = element_text(size=14),axis.text.x = element_text(size=14),axis.text.y = element_text(size=14))+ylab('Probability') + coord_cartesian(ylim = c(0,1))
ggplot(Predict(final_model,num_images,is_paypal_url,fun=plogis),pval = T,adj.subtitle=FALSE,cex.anova=17,cex.axis=2,cex.adj=2,cex=2)+ theme(text = element_text(size=14),axis.text.x = element_text(size=14),axis.text.y = element_text(size=14))+ylab('Probability') + coord_cartesian(ylim = c(0,1))
ggplot(Predict(final_model,num_images,is_mod_wiki_url,fun=plogis),pval = T,adj.subtitle=FALSE,cex.anova=17,cex.axis=2,cex.adj=2,cex=2)+ theme(text = element_text(size=14),axis.text.x = element_text(size=14),axis.text.y = element_text(size=14))+ylab('Probability') + coord_cartesian(ylim = c(0,1)) 
ggplot(Predict(final_model,num_words_long_desc,is_mod_issues,fun=plogis),pval = T,adj.subtitle=FALSE,cex.anova=17,cex.axis=2,cex.adj=2,cex=2)+ theme(text = element_text(size=14),axis.text.x = element_text(size=14),axis.text.y = element_text(size=14))+ylab('Probability') + coord_cartesian(ylim = c(0,1)) 
