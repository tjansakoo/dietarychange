
library(ggplot2)
library(tidyverse)

setwd("/Users/thanapatjan/Desktop/OneDrive - 京都大学/THESIS Project/Analysis/DietaryChange/R") #on Macbook
mor_sav_diff <- read.csv2("../output/csv/Mortality_save_diff.csv",sep = ",")
mor_sav_diff$value <- as.numeric(mor_sav_diff$value)

Global <- mor_sav_diff %>% mutate(mor = value/1000) %>% filter(Region == "World") %>%
  ggplot(aes(x=Syr, y=mor, color=Scenarios, linetype=Species, shape=Species)) +
  geom_line() +
  geom_point(size=2.5) +
  theme_bw() + ggtitle("Global") +
  theme(panel.grid = element_blank()) +
  scale_color_brewer(palette = "Dark2") + xlab("Year") + ylab("Mortality Change (1000/yr)") +
  scale_x_continuous(breaks = seq(2020, 2100, 10), labels = seq(2020, 2100, 10)) +
  geom_hline(yintercept = 0, linetype = "solid", color = "black", size=0.5)
Global

CHN <- mor_sav_diff %>% mutate(mor = value/1000) %>% filter(Region == "CHN") %>%
  ggplot(aes(x=Syr, y=mor, color=Scenarios, linetype=Species, shape=Species)) +
  geom_line() +
  geom_point(size=2.5) +
  theme_bw() + ggtitle("China") +
  theme(panel.grid = element_blank()) +
  scale_color_brewer(palette = "Dark2") + xlab("Year") + ylab("Mortality Change (1000/yr)") +
  scale_x_continuous(breaks = seq(2020, 2100, 10), labels = seq(2020, 2100, 10)) +
  geom_hline(yintercept = 0, linetype = "solid", color = "black", size=0.5)
CHN


XSE <- mor_sav_diff %>% mutate(mor = value/1000) %>% filter(Region == "XSE") %>%
  ggplot(aes(x=Syr, y=mor, color=Scenarios, linetype=Species, shape=Species)) +
  geom_line() +
  geom_point(size=2.5) +
  theme_bw() + ggtitle("Southeast Asia") +
  theme(panel.grid = element_blank()) +
  scale_color_brewer(palette = "Dark2") + xlab("Year") + ylab("Mortality Change (1000/yr)") +
  scale_x_continuous(breaks = seq(2020, 2100, 10), labels = seq(2020, 2100, 10)) +
  geom_hline(yintercept = 0, linetype = "solid", color = "black", size=0.5)
XSE

XE25 <- mor_sav_diff %>% mutate(mor = value/1000) %>% filter(Region == "XE25") %>%
  ggplot(aes(x=Syr, y=mor, color=Scenarios, linetype=Species, shape=Species)) +
  geom_line() +
  geom_point(size=2.5) +
  theme_bw() + ggtitle("Europe") +
  theme(panel.grid = element_blank()) +
  scale_color_brewer(palette = "Dark2") + xlab("Year") + ylab("Mortality Change (1000/yr)") +
  scale_x_continuous(breaks = seq(2020, 2100, 10), labels = seq(2020, 2100, 10)) +
  geom_hline(yintercept = 0, linetype = "solid", color = "black", size=0.5)
XE25

XNF <- mor_sav_diff %>% mutate(mor = value/1000) %>% filter(Region == "XNF") %>%
  ggplot(aes(x=Syr, y=mor, color=Scenarios, linetype=Species, shape=Species)) +
  geom_line() +
  geom_point(size=2.5) +
  theme_bw() + ggtitle("North Africa") +
  theme(panel.grid = element_blank()) +
  scale_color_brewer(palette = "Dark2") + xlab("Year") + ylab("Mortality Change (1000/yr)") +
  scale_x_continuous(breaks = seq(2020, 2100, 10), labels = seq(2020, 2100, 10)) +
  geom_hline(yintercept = 0, linetype = "solid", color = "black", size=0.5)
XNF

USA <- mor_sav_diff %>% mutate(mor = value/1000) %>% filter(Region == "USA") %>%
  ggplot(aes(x=Syr, y=mor, color=Scenarios, linetype=Species, shape=Species)) +
  geom_line() +
  geom_point(size=2.5) +
  theme_bw() + ggtitle("United States of America") +
  theme(panel.grid = element_blank()) +
  scale_color_brewer(palette = "Dark2") + xlab("Year") + ylab("Mortality Change (1000/yr)") +
  scale_x_continuous(breaks = seq(2020, 2100, 10), labels = seq(2020, 2100, 10)) +
  geom_hline(yintercept = 0, linetype = "solid", color = "black", size=0.5)
USA

library(patchwork)
figure <- Global + CHN + XSE + XE25 + XNF + USA + plot_layout(guides="collect") & theme(legend.position = 'bottom') +
  theme(legend.key.size = unit(0.5, 'cm')) +
  theme(text=element_text(size=10)) 
figure

ggsave(file=paste("mortality change.png", sep = ""),plot=figure,width=10,height=6)



