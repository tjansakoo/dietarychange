#Netcdf plot in R

library(ncdf4)
library(here)
library(lubridate)
library(RColorBrewer)
library(rasterVis)
library(sp)
library(sf)
library(lattice)
library(latticeExtra)
library(maps)
library(maptools)
library(ggplot2)
library(tidyverse)

specieslist <- c("o3")
ylist <- c("2015", "2030", "2050", "2100")
scenariolist <- c("SSP2_BaU_NoCC","SSP2_500C_CACN_DAC_NoCC", 
                  "SSP2_BaU_DEMFWR", "SSP2_500C_CACN_DAC_DEMFWR")

## Create a SpatialLines object

countries <- maps::map("world", plot=FALSE) 
countries <- map2SpatialLines(countries, proj4string = CRS("+proj=longlat"))

#concentration
for (j in 1:length(scenariolist)) {
  for (yr in 1:length(ylist)) {
    for (sp in 1:length(specieslist)){
      
      names <- paste0("05x05_",scenariolist[j], "_", ylist[yr],"_off_off_", specieslist[sp] ,"_Surface_Re_yearavg")
      filepath <- file.path(here(paste("../", scenariolist[j], "/",ylist[yr], sep='')),
                            paste(names,".nc4",sep="")) 
      nc_file <- nc_open(paste0(filepath))
      
      longitude <- nc_file$dim[[3]]$vals
      latitude <- nc_file$dim[[4]]$vals
      time <- nc_file$dim[[1]]$vals
      
      #get time variable 
      t_units <- ncatt_get(nc_file, "time", "units")
      nc_array <-  ncvar_get(nc_file,nc_file$var[[2]])
      
      #convert time variable
      
      t_ustr <- strsplit(t_units$value, " ")
      t_dstr <- strsplit(unlist(t_ustr)[3], "-")
      date <- ymd(t_dstr) + dminutes(time)
      date
      
      #t <- 1 #to select time slice
      #nc_slice <- paste0(specieslist,"_array")[t]
      
      #Plot 
      
      # Download World boundaries (might take time)
      
      grid <- expand.grid(lon=longitude, lat=latitude)  #create a set of lonxlat pairs of values, one for each element in the Temp_array
      
      if(!dir.exists(paste("../output/figure/spatial/",specieslist[sp], sep = ""))) {
        # Create the folder if it doesn't exist
        dir.create(paste("../output/figure/spatial/",specieslist[sp], sep = ""))
      } else {
        # Display a message if the folder already exists
        message("The folder already exists.")
      }
      
      tiff(file=paste("../output/figure/spatial/",specieslist[sp],"/",names,".tiff", sep = ""),
           width=14,height=8, units = 'in', res=300)
      
      if (specieslist[sp] == "o3") {
        title <- paste0("Annual Ozone Concentrations in ",ylist[yr]," (ppbv)")
        cuts <- c(-Inf,5,10,15,20,25,30,35,40,45,50,Inf)   # set colorbar
      } else if (specieslist[sp] == "pm25") {
        title <- paste0("Annual PM2.5 Concentrations in ",ylist[yr]," (µg/m³)")
        cuts <- c(-Inf, 10,20,30,40,50,60,70,80,90,100,110,120,130,140,150, Inf)
      } else if (specieslist[sp] == "nh4") {
        title <- paste0("Annual Ammonium Concentrations in ",ylist[yr]," (µg/m³)")
        cuts <- c(-Inf,2,4,6,8,10,12,14,16,18,20,Inf)
      } else if (specieslist[sp] == "nit") {
        title <- paste0("Annual Nitrate Concentrations in ",ylist[yr]," (µg/m³)")
        cuts <- c(-Inf,2,4,6,8,10,12,14,16,18,20,Inf)
      } else if (specieslist[sp] == "so4") {
        title <- paste0("Annual Sulfate Concentrations in ",ylist[yr]," (µg/m³)")
        cuts <- c(-Inf,2,4,6,8,10,12,14,16,18,20,Inf)
      }
      
      my_palette <- colorRampPalette(brewer.pal(11, "OrRd"))(17)
      
        p1 <- levelplot(nc_array ~ lon * lat,
                        data=grid, region=TRUE,
                        pretty=T, at=cuts, cuts=10,
                        col.regions=((my_palette)), contour=0,
                        xlab = "Longitude", ylab = "Latitude",
                        main = title
        ) + latticeExtra::layer(sp.lines(countries))
      
      print(p1)
      dev.off()
      
    }
  }
}


specieslist <- c("o3")
ylist <- c("2030", "2050", "2100")
scenariolist <- c("SSP2_BaU_DEMFWR","SSP2_500C_CACN_DAC_DEMFWR")

#Relative Change
for (j in 1:length(scenariolist)) {
  for (yr in 1:length(ylist)) {
    for (sp in 1:length(specieslist)){
      
      names <- paste0("05x05_",specieslist[sp], "_",scenariolist[j],"_",ylist[yr],"_Rechange_com_yearavg")
      filepath <- file.path(here(paste("../", scenariolist[j], "/",ylist[yr], "/Rechange_com",sep='')),
                            paste(names,".nc",sep="")) 
      nc_file <- nc_open(paste0(filepath))
      
      longitude <- nc_file$dim[[3]]$vals
      latitude <- nc_file$dim[[4]]$vals
      time <- nc_file$dim[[1]]$vals
      
      #get time variable 
      t_units <- ncatt_get(nc_file, "time", "units")
      nc_array <-  ncvar_get(nc_file,nc_file$var[[2]])
      
      #convert time variable
      
      t_ustr <- strsplit(t_units$value, " ")
      t_dstr <- strsplit(unlist(t_ustr)[3], "-")
      date <- ymd(t_dstr) + dminutes(time)
      date
      
      #t <- 1 #to select time slice
      #nc_slice <- paste0(specieslist,"_array")[t]
      
      #Plot 
      
      # Download World boundaries (might take time)
      
      grid <- expand.grid(lon=longitude, lat=latitude)  #create a set of lonxlat pairs of values, one for each element in the Temp_array
      rev_colors <- rev(colorRampPalette(brewer.pal(11, "RdBu"))(100))
      
      tiff(file=paste("../output/figure/spatial/Relative_com/",names,".tiff", sep = ""),
           width=14,height=8, units = 'in', res=300)
      p1 <- levelplot(nc_array ~ lon * lat,
                      data = grid,
                      region = TRUE,
                      col.regions = rev_colors,
                      at = c(-Inf, seq(-5, 5, length.out = 100), Inf),  # Include -Inf, Inf in the at sequence
                      contour = 0,
                      xlab = "Longitude",
                      ylab = "Latitude",
                      main = "Relative change O3 Concentrations"
      ) + latticeExtra::layer(sp.lines(countries))
      print(p1)
      dev.off()
      
    }
  }
}

