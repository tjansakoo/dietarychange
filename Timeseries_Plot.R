
library(here)
library(maps)
library(ggplot2)
library(tidyverse)
library(reshape2)
library(scales)
library(lubridate)
library(readr)
library(stringr)

species_name=c("pm25")
Scenariolist =c("SSP2_BaU_DEMFWR", 
                "SSP2_500C_CACN_DAC_DEMFWR")
Yearlist = c("2015", "2030", "2050", "2100")



timesseries <- function(species_name){
  #Get txt file
  for (sce in 1:length(Scenariolist)){
    for (y in 1:length(Yearlist)){
      names <- paste("05x05_",species_name,"_",Scenariolist[sce],"_",Yearlist[y],"_rechange_yearavg", sep = '')
      filepath <- file.path(here(paste0("../",Scenariolist[sce],"/",Yearlist[y],"/csv")),paste(names,".txt",sep=""))
      dat1   <- read.table(filepath, sep= "", header = TRUE)
      dat1$Country <- map.where(database="world", dat1$lon, dat1$lat)
      dat_txt <- dat1 %>% mutate(scenario = paste0(Scenariolist[sce]),
                                 Emi_yr = paste0(Yearlist[y])) %>% separate(Country, c('Country','addition'), ":")
      all_avg <- dat_txt %>% group_by(name, Country, date, scenario, Emi_yr)  %>% dplyr::summarize(value_avg = mean(value)) 
      assign(paste0(Scenariolist[sce],"_all_avg", Yearlist[y]), all_avg)
      
      
    }
    
  }
  
  df_names <- ls(pattern = "^SSP2")
  df_list <- mget(df_names)
  all_country_yearavg <- bind_rows(df_list)
  
  #all_country_monavg$date <- as.Date(all_country_monavg$date)

  dat_txt2 <- all_country_yearavg %>% mutate(year  = lubridate::year(date), 
                                            month = lubridate::month(date), 
                                            day   = lubridate::day(date))
  
  all_country_yearavg <- dat_txt2 %>% group_by(name, scenario, Country, month, Emi_yr) %>% 
    dplyr::summarize(value_avg = mean(value_avg)) 

  ## Regional Average
  
  df_list2 <- list(dat_txt2, unRegion) 
  dat_txt3 <- df_list2 %>% reduce(right_join, by='Country') %>% drop_na() 
  
  all_regional_yearavg  <- dat_txt3 %>% group_by(name, scenario, Region, month, Emi_yr) %>% 
    dplyr::summarize(value_avg = mean(value_avg)) 
  
  all_subregional_yearavg  <- dat_txt3 %>% group_by(name, scenario, Subregion, month, Emi_yr) %>% 
    dplyr::summarize(value_avg = mean(value_avg)) 
  
  #all_regional_yearavg <- all_regional_monavg %>% group_by(name, scenario, Region, Emi_yr) %>% 
  #  dplyr::summarize(value_avg = mean(value_avg))
  
  #all_World_monavg   <- dat_txt3 %>% group_by(name, scenario, month, Emi_yr) %>% 
  #  dplyr::summarize(value_avg = mean(value_avg))
  
  all_World_yearavg  <- dat_txt3 %>% group_by(name, scenario, Emi_yr) %>% 
    dplyr::summarize(value_avg = mean(value_avg))
  

  write.csv(all_country_monavg , paste("output/",species_name,"_country_monavg.csv", sep=""), row.names = FALSE)
  write.csv(dat_txt3 ,paste("output/",species_name,"_country_rechange_yearavg.csv", sep=""), row.names = FALSE)
  write.csv(all_regional_monavg , paste("output/",species_name,"_regional_monavg.csv", sep=""), row.names = FALSE)
  write.csv(all_subregional_yearavg ,paste("output/",species_name,"_subregional_rechange_yearavg.csv", sep=""), row.names = FALSE)
  write.csv(all_regional_yearavg ,paste("output/",species_name,"_regional_rechange_yearavg.csv", sep=""), row.names = FALSE)
  write.csv(all_World_monavg , paste("output/",species_name,"_World_monavg.csv", sep=""), row.names = FALSE)
  write.csv(all_World_yearavg ,paste("output/",species_name,"_World_yearavg.csv", sep=""), row.names = FALSE)
  
  #Plot
  
  
  legend_colors <- c("SSP2_BaU_NoCC" = "#1B9E77", "SSP2_BaU_DEMFWR" = "#D95F02", "SSP2_500C_CACN_DAC_NoCC" = "#7570B3",
                     "SSP2_500C_CACN_DAC_DEMFWR" = "#E7298A")
  
  all_regional_yearavg$scenario <- factor(  all_regional_yearavg$scenario,                                    # Change ordering manually
                                   levels = c("SSP2_BaU_NoCC", "SSP2_BaU_DEMFWR", 
                                              "SSP2_500C_CACN_DAC_NoCC", "SSP2_500C_CACN_DAC_DEMFWR"))
  
  p1 <- ggplot(data = all_regional_yearavg,aes(x=Emi_yr, y=value_avg, fill=scenario)) + 
    geom_bar(stat="identity", position=position_dodge())+
    ylab("Relative change (%)") +
    xlab("Year") +
    theme_minimal() +
    ggtitle("Species : Ozone") +
    labs(color = "Regional") + 
    facet_wrap(~ Region, ncol=3) + theme(panel.spacing = unit(1, "lines")) +
    scale_fill_brewer(palette="Dark2") + 
    theme(legend.position="bottom")
  
  p1
  
  ggsave(file=paste("/Users/thanapatjan/Library/CloudStorage/OneDrive-京都大学/THESIS Project/team meeting/Individual (12Jun)/Compare_",species_name,"rechange_regional.png", sep = ""),plot=p1,width=10,height=6)
  
}

#setwd("E:/tjansakoo/OneDrive - Kyoto University/THESIS Project/Analysis/Spatially_Continuous_Data/prog/R")
#Yearlist = c("2014", "2015", "2016", "2017", "2018", "2019")
specieslist = c("nh4", "so4", "nit")
Scenariolist =c("SSP2_BaU_NoCC", "SSP2_BaU_DEMFWR", "SSP2_500C_CACN_DAC_NoCC", 
                "SSP2_500C_CACN_DAC_DEMFWR")

unRegion <- read.delim("../../../data/UNSD_country_code.txt", header = T)


for (i in 1:length(specieslist)){
  timesseries(specieslist[i])
}



