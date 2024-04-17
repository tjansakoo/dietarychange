
library(here)
library(maps)
library(ggplot2)
library(tidyverse)
library(reshape2)
library(scales)
library(lubridate)
library(readr)
library(stringr)

region <- read.csv("../output/csv/o3_pm25_rechange_region.csv", sep = ",") %>% filter(Scenarios == "SC3-SC4")
subregion <- read.csv("../output/csv/o3_pm25_rechange_subregion.csv", sep = ",") %>% filter(Scenarios == "SC3-SC4")
country <- read.csv("../output/csv/o3_pm25_rechange_country.csv", sep = ",") %>% filter(Scenarios == "SC3-SC4")

SEA <- subregion %>% filter(Subregion == "South-eastern Asia") %>%
  #ggplot(aes(x=Emi_yr, y=value_avg, color=Scenarios, linetype=Species, shape=Species)) +
  ggplot(aes(x=Emi_yr, y=value_avg, color=Species)) +
  geom_line() +
  geom_point(size=2.5) + ylim(-4, 4) +
  theme_bw() + ggtitle("Sountheast Asia") +
  theme(panel.grid = element_blank()) +
  scale_color_brewer(palette = "Dark2") + xlab("Year") + ylab("Relative Change (%)") +
  scale_x_continuous(breaks = seq(2020, 2100, 10), labels = seq(2020, 2100, 10)) +
  geom_hline(yintercept = 0, linetype = "solid", color = "black", size=0.5)
SEA

EU <- region %>% filter(Region == "Europe") %>%
  ggplot(aes(x=Emi_yr, y=value_avg, color=Species)) +
  geom_line() +
  geom_point(size=2.5) + ylim(-4, 4) +
  theme_bw() + ggtitle("Europe") +
  theme(panel.grid = element_blank()) +
  scale_color_brewer(palette = "Dark2") + xlab("Year") + ylab("Relative Change (%)") +
  scale_x_continuous(breaks = seq(2020, 2100, 10), labels = seq(2020, 2100, 10)) +
  geom_hline(yintercept = 0, linetype = "solid", color = "black", size=0.5)
EU

BRA <- country %>% filter(Country == "Brazil") %>%
  ggplot(aes(x=Emi_yr, y=value_avg, color=Species)) +
  geom_line() +
  geom_point(size=2.5) + ylim(-4, 4) +
  theme_bw() + ggtitle("Brazil") +
  theme(panel.grid = element_blank()) +
  scale_color_brewer(palette = "Dark2") + xlab("Year") + ylab("Relative Change (%)") +
  scale_x_continuous(breaks = seq(2020, 2100, 10), labels = seq(2020, 2100, 10)) +
  geom_hline(yintercept = 0, linetype = "solid", color = "black", size=0.5)
BRA

CHN <- country %>% filter(Country == "China") %>%
  ggplot(aes(x=Emi_yr, y=value_avg, color=Species)) +
  geom_line() +
  geom_point(size=2.5) + ylim(-4, 4) +
  theme_bw() + ggtitle("China") +
  theme(panel.grid = element_blank()) +
  scale_color_brewer(palette = "Dark2") + xlab("Year") + ylab("Relative Change (%)") +
  scale_x_continuous(breaks = seq(2020, 2100, 10), labels = seq(2020, 2100, 10)) +
  geom_hline(yintercept = 0, linetype = "solid", color = "black", size=0.5)
CHN

XAF <- region %>% filter(Region == "Africa") %>%
  ggplot(aes(x=Emi_yr, y=value_avg, color=Species)) +
  geom_line() +
  geom_point(size=2.5) + ylim(-4, 4) +
  theme_bw() + ggtitle("Africa") +
  theme(panel.grid = element_blank()) +
  scale_color_brewer(palette = "Dark2") + xlab("Year") + ylab("Relative Change (%)") +
  scale_x_continuous(breaks = seq(2020, 2100, 10), labels = seq(2020, 2100, 10)) +
  geom_hline(yintercept = 0, linetype = "solid", color = "black", size=0.5)
XAF

XAM <- subregion %>% filter(Subregion == "Latin America and the Caribbean") %>%
  ggplot(aes(x=Emi_yr, y=value_avg, color=Species)) +
  geom_line() +
  geom_point(size=2.5) + ylim(-4, 4) +
  theme_bw() + ggtitle("Latin America and the Caribbean") +
  theme(panel.grid = element_blank()) +
  scale_color_brewer(palette = "Dark2") + xlab("Year") + ylab("Relative Change (%)") +
  scale_x_continuous(breaks = seq(2020, 2100, 10), labels = seq(2020, 2100, 10)) +
  geom_hline(yintercept = 0, linetype = "solid", color = "black", size=0.5)
XAM

library(patchwork)
figure <- EU + BRA + XAM + XAF + CHN + SEA + plot_layout(guides="collect") & theme(legend.position = 'bottom') +
  theme(legend.key.size = unit(0.5, 'cm')) +
  theme(text=element_text(size=10)) 
figure

ggsave(file=paste("/Users/thanapatjan/Library/CloudStorage/OneDrive-KyotoUniversity/THESIS Project/Analysis/DietaryChange/output/figure/relative_change_New.png", sep = ""),plot=figure,width=12,height=6)


