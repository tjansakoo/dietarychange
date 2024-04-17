#Plot SNA Proportion 

library(here)
library(maps)
library(ggplot2)
library(tidyverse)
library(reshape2)
library(scales)
library(lubridate)
library(readr)
library(stringr)
library(countrycode)
library(reshape2)



#Yearlist = c("2015", "2030", "2050", "2100")
ylist = c("2015")
specieslist = c("nh4", "nit", "so4")
#scenariolist <- c("SSP2_BaU_NoCC","SSP2_500C_CACN_DAC_NoCC", 
#                  "SSP2_BaU_DEMFWR","SSP2_500C_CACN_DAC_DEMFWR")
scenariolist <- c("SSP2_BaU_NoCC")
sp <- c("nh4", "so4", "nit")

for (j in 1:length(scenariolist)) {
  for (yr in 1:length(ylist)) {
    for (sp in 1:length(specieslist)){
      
      names <- paste0("05x05_",specieslist[sp],"_",scenariolist[j], "_", ylist[yr],"_pro_yearavg")
      filepath <- file.path(here(paste("../", scenariolist[j], "/",ylist[yr], "/csv",sep='')),
                            paste(names,".txt",sep="")) 
      dat1   <- read.table(filepath, sep= "", header = TRUE)
      dat1$Country <- map.where(database="world", dat1$lon, dat1$lat) 
      dat_txt <- dat1 %>% separate(Country, c('Country','addition'), ":")
      all <- dat_txt %>% group_by(name, Country, date, scenario) %>% dplyr::summarize(!!paste0(specieslist[sp]) := mean(value))
      assign(paste0(specieslist[sp],"_country_avg_", ylist[yr]), all)
    }
  }
}



df_joined <- left_join(nh4_country_avg_2015, nit_country_avg_2015, by = c("Country", "date", "scenario")) %>%
  left_join(so4_country_avg_2015, by = c("Country", "date", "scenario")) %>% select(-contains("name"))

pm25_pro <- df_joined %>% mutate(other = 100 - (nit+nh4+so4),
                                 sum = other+nit+nh4+so4) 
pm25_pro$code <- countrycode(sourcevar = pm25_pro$Country, 
                             origin = "country.name", destination = "iso3c")

region <- read.table("../../../data/UNSD_country_code.txt", header = TRUE, sep = "\t")
region$code <- countrycode(sourcevar = region$Country, 
                      origin = "country.name", destination = "iso3c") 
region <- region %>% select(-Country)

pm25_pro_country <- left_join(pm25_pro, region, by = "code") %>% filter(Region != "Ocea")
pm25_pro_subregion <- pm25_pro_country %>% group_by(Subregion, date, scenario) %>% 
  dplyr::summarize(Ammonuim = mean(nh4),
                   Nitrate = mean(nit),
                   Sulfate = mean(so4),
                   Other = mean(other)) %>% mutate(sum = Other+Nitrate+Ammonuim+Sulfate)

pm25_pro_region <- pm25_pro_country %>% group_by(Region, date, scenario) %>% 
  dplyr::summarize(Ammonuim = mean(nh4),
                   Nitrate = mean(nit),
                   Sulfate = mean(so4),
                   Other = mean(other)) %>% mutate(sum = Other+Nitrate+Ammonuim+Sulfate)

dat_p <- melt(pm25_pro_region, id.vars = c("Region", "date", "scenario")) %>% filter(variable != "sum") 
my_order <- c("Other","Sulfate", "Nitrate", "Ammonuim")
dat_p$group_factor <- factor(dat_p$variable, levels = my_order)


p1 <- ggplot(dat_p, aes(x = Region, y = value, fill = group_factor)) +
      geom_bar(stat = "identity") +
      geom_text(aes(label = ifelse(value > 10, round(value, 1), "")),
            position = position_stack(vjust = 0.5), size=3, angle = 90) +  
      labs(title = "",
               y = "Proportion (%)",
               fill = "Species") + 
      scale_fill_manual(values=c("#CCCCCC",
                                 "#FF6666",
                                 "#FFCC00",
                                 "#99CCFF")) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust=1, size=12))
p1

dat_p2 <- melt(pm25_pro_subregion, id.vars = c("Subregion", "date", "scenario")) %>% filter(variable != "sum") 
my_order <- c("Other","Sulfate", "Nitrate", "Ammonuim")
dat_p2$group_factor <- factor(dat_p2$variable, levels = my_order)

p2 <- ggplot(dat_p2, aes(x = Subregion, y = value, fill = group_factor)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = ifelse(value > 10, round(value, 1), "")),
            position = position_stack(vjust = 0.5), size=3, angle = 90) +  
  labs(title = "",
       y = "",
       fill = "Species") + 
  scale_fill_manual(values=c("#CCCCCC",
                             "#FF6666",
                             "#FFCC00",
                             "#99CCFF")) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust=1, size=10),
        axis.text.y = element_blank())
  
p2

library(patchwork)
p4 <- (p1+p2)+plot_layout(guides="collect") & theme(legend.position = 'right') +
  theme(legend.key.size = unit(1.0, 'cm')) + 
  theme(text=element_text(size=10))
p4

ggsave("../output/figure/PM25_proportion.png", p4, width = 10, height = 5, dpi=321)


