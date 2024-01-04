#Author: Anita Wray
#Date: Feb 2023
#Purpose: This script will both map distribution of samples and a handful of 
#biological information.Additionally, it will run significance testing on the
#entire sample size.

#Map Building                                     
library("reshape")   
library(patchwork)
library("sf")
library("rnaturalearth")
library("rnaturalearthdata")
library(dplyr)
library(viridis)
library(tidyverse)
theme_set(theme_bw())

#Set colors
three_species <- c('vermilion' = '#e31a1c', 'sunset' =  '#ff7f00',
                   'canary' = '#b2df8a')
three_pops <- c('V-A' = '#a6cee3', 'V-B' = '#33a02c', 'V-C'= '#cab2d6')
pops_and_species <- c('V-A' = '#a6cee3', 'V-B' = '#33a02c', 'V-C'= '#cab2d6',
                      'S' =  '#ff7f00',
                      'C' = '#b2df8a')
color_pal_hybrids <- c('vermilion' = "#e31a1c", 'sunset' = "#ff7f00",
                       'SVH' = "#1f78b4")
color_pal_hybrids2 <- c('V-A' = '#a6cee3', 'V-B' = '#33a02c', 'V-C'= '#cab2d6',
                        'S' = "#ff7f00",'SVH' = "#1f78b4")

#### Mapping ------------------------------------------------------------------

#Load in the base R map
world <- ne_countries(scale = "medium", returnclass = "sf")

#And the metadata with depths
metadata <- read.csv("~/Desktop/VermilionRF/unmatched_samples/metadata_matched.csv")

#Lets look at all of the samples first
map_allsamples <- ggplot(data = world) +
  geom_sf() +
  geom_count(data = metadata, aes(x = `LonDD.v2`, y = `LatDD`))+
  coord_sf(xlim = c(-115, -125.57), ylim = c(31.5, 49.5), expand = FALSE)
map_allsamples

#Now lets load in samples we have confident in the Species ID
passed_metadata <- as.data.frame(read.csv("~/Desktop/VermilionRF/metadata/passed_rubias_samples_metadata.csv"))
passed_metadata <- subset(passed_metadata, select = -c(X, X.1))
table(passed_metadata$collection)
#Make sure depth is a continuous variable
passed_metadata$Depth..m. <- as.numeric(passed_metadata$Depth..m.)
passed_metadata$LatDD <- as.numeric(passed_metadata$LatDD) 
passed_metadata$LonDD.v2 <- as.numeric(passed_metadata$LonDD.v2) 
passed_metadata$Fork.length..cm. <- as.numeric(passed_metadata$Fork.length..cm.) 

# And now we graph those ones

map_passedsamples <- ggplot(data = world) +
  geom_sf() +
  facet_wrap(~repunit)+
  geom_count(data = passed_metadata, aes(x = `LonDD.v2`, y = `LatDD`, col = `repunit`))+
  coord_sf(xlim = c(-115, -125.57), ylim = c(30, 48.84), expand = FALSE) +
  scale_x_continuous(breaks = c(-124, -120, -116)) +
  xlab('Longitude')+
  ylab('Latitude')+
  scale_color_manual(values = three_species)


map_passedsamples

#Splitting the dataset between vermilion and sunset to get a closer look
vermilion <- subset(passed_metadata, passed_metadata$repunit == 'vermilion')
sunset <- subset(passed_metadata, passed_metadata$repunit == 'sunset')
combined <- rbind(vermilion, sunset)

vermilion_pop <- ggplot(data = world) +
  geom_sf() +
  facet_wrap(~collection)+
  geom_count(data = vermilion, aes(x = `LonDD.v2`, y = `LatDD`, col = `collection`))+
  coord_sf(xlim = c(-115, -125.57), ylim = c(30, 48.84), expand = FALSE) +
  scale_x_continuous(breaks = c(-124, -120, -116))+
  xlab('Longitude')+
  ylab('Latitude')+
  scale_color_manual(values = three_pops)
vermilion_pop

#Map split by species and zoomed into SoCal where most of our samples are from
split_by_species <- ggplot(data = world) +
  geom_sf() +
  geom_count(data = combined, 
             aes(x = `LonDD.v2`, y = `LatDD`,
                 color = `Depth..m.`)) +
  coord_sf(xlim = c(-117, -122), ylim = c(31.75, 36), expand = FALSE)+
  scale_color_viridis(option = 'magma') +
  facet_wrap(~repunit)+
  theme(legend.position = 'left')+
  xlab('Longitude')+
  ylab('Latitude')+
  scale_x_continuous(breaks = c(-121, -120, -119, -118))+
  labs(color='Depth (m)')

split_by_species


##### Significance Testing ----------------------------------------------------

#Let's look to see if the depths are significant
ggplot(data = passed_metadata,
       aes(x = `repunit`, y = `Depth..m.`,
           col = `repunit`)) +
  geom_boxplot()+
  theme(legend.position = 'none') +
  ylab('Depth (m)')+
  xlab('Species')+
  scale_color_manual(values = three_species)

one.way <- aov(passed_metadata$Depth..m. ~ `repunit`, 
               data = passed_metadata)
summary(one.way)

#Let's look to see if latitude is significant for the three pops
ggplot(data = vermilion,
       aes(x = `collection`, y = `LatDD`,
           col = `collection`)) +
  geom_boxplot()+
  theme(legend.position = 'none') +
  ylab('Latitude')+
  xlab('Population')+
  scale_color_manual(values = three_pops)

one.way_collection <- aov(vermilion$LatDD ~ `collection`,
               data = vermilion)
summary(one.way_collection)


#Zooming in specifically on V-B and V-C since it's hard to tell in the graph
B <- subset(vermilion,
            vermilion$collection == "V-B")

C <- subset(vermilion,
            vermilion$collection == "V-C")

B_and_C <- rbind(B,C)

ggplot(data = B_and_C,
       aes(x = `collection`, y = `LatDD`,
           col = `collection`)) +
  geom_boxplot()+
  theme(legend.position = 'none') +
  ylab('Latitude')+
  xlab('Population')

# Sex versus depth and latitude
vermilion$Sex[nchar(vermilion$Sex)==0] <- "Unknown"
passed_metadata$Sex[nchar(passed_metadata$Sex)==0] <- "Unknown"
not_unknown <- subset(vermilion, vermilion$Sex!= 'Unknown') 	

one.way_sex <- aov(`Depth..m.` ~ `Sex`,
                          data = not_unknown)
summary(one.way_sex)

## Biological Data Per Species -----------------------------------------------
pdf(file = '~/Desktop/VermilionRF/assignment_output/Biological_Data_Per_Species.pdf')

ggplot(data = passed_metadata,
       aes(x = `collection`, y = `Depth..m.`,
           col = `collection`)) +
  geom_boxplot()+
  facet_wrap(~Sex)+
  theme(legend.position = 'none') +
  ylab('Depth (m)')+
  xlab('Population')+
  ggtitle('Depth per Sex per population')+
  scale_color_manual(values = pops_and_species)


# Weight versus collection
ggplot(data = passed_metadata,
       aes(x = `collection`, y = `Wt..kg.`,
           col = `collection`)) +
  geom_boxplot()+
  theme(legend.position = 'none') +
  ylab('Weight (kg)')+
  xlab('Population')+
  ggtitle('Weight versus collection')+
  scale_color_manual(values = pops_and_species)


#Fork Length
ggplot(data = passed_metadata,
       aes(x = `collection`, y = `Fork.length..cm.`,
           col = `collection`)) +
  geom_boxplot()+
  theme(legend.position = 'none') +
  ylab('Fork Length (cm)')+
  xlab('Population')+
  ggtitle('Fork Length versus collection')+
  scale_color_manual(values = pops_and_species)

#Age
ggplot(data = passed_metadata,
       aes(x = `collection`, y = `Age..yrs.`,
           col = `collection`)) +
  geom_boxplot()+
  theme(legend.position = 'none') +
  ylab('Age (years)')+
  xlab('Population') +
  ggtitle('Age versus collection')+
  scale_color_manual(values = pops_and_species)

depth <- passed_metadata %>%
  drop_na(Depth..m.)

ggplot(data = depth,
       aes(x = `collection`, y = `Depth..m.`,
           col = `collection`)) +
  geom_boxplot()+
  facet_wrap(~Survey)+
  theme(legend.position = 'none') +
  xlab('Population')+
  ylab('Depth (m)') +
  ggtitle('Depth average per species per survey type')+
  scale_color_manual(values = pops_and_species)

dev.off()

### Mapping Hybrid Samples ------------------



hybrids <- as.data.frame(read_csv(file = "~/Desktop/VermilionRF/metadata/F1_hybrids_metadata.csv",
                    show_col_types = FALSE))
hybrids$repunit <- 'SVH'
hybrids$collection <- 'SVH'
hybrids$Z_flag <- 'TRUE'
hybrids <- hybrids[,1:(ncol(hybrids)-1)] %>%
 rename('Raw.Reads' = 'Raw_Reads',
        'On.Target.Reads' = 'On_Target_Reads',
        'X..GT' = 'X_GT',
        'X..On.Target' = 'X_On_Target')
##Sometimes rename gets angry, try restarting R


all <- rbind(passed_metadata, hybrids)
all$Depth..m. <- as.numeric(all$Depth..m.)

#removing canary
all <- subset(all, all$collection != "C")

pdf(file = '~/Desktop/VermilionRF/assignment_output/hybrid_biological_comparisons.pdf')

ggplot(data = world) +
  geom_sf() +
  geom_count(data = all, aes(x = `LonDD.v2`, y = `LatDD`, col = repunit))+
  facet_wrap(~repunit)+
  coord_sf(xlim = c(-115, -125.57), ylim = c(30, 48.84), expand = FALSE) +
  scale_x_continuous(breaks = c(-124, -120, -116)) +
  xlab('Longitude')+
  ylab('Latitude')+
  scale_color_manual(values = color_pal_hybrids)

ggplot(data = all,
       aes(x = factor(`collection`, level=c('S', 'SVH', 'V-C', 'V-B', 'V-A')),
           y = `LatDD`,
           col = `collection`)) +
  geom_boxplot()+
  theme(legend.position = 'none') +
  ylab('Latitude')+
  xlab('Population')+
  scale_color_manual(values = color_pal_hybrids2)

ggplot(data = all,
       aes(x = factor(`collection`, level=c('S', 'SVH', 'V-C', 'V-B', 'V-A')),
           y = `Depth..m.`,
           col = `collection`)) +
  geom_boxplot()+
  theme(legend.position = 'none') +
  ylab('Depth (m)')+
  xlab('Species')+
  scale_color_manual(values = color_pal_hybrids2)

ggplot(data = all,
       aes(x = factor(`collection`, level=c('S', 'SVH', 'V-C', 'V-B', 'V-A')),
           y = `Wt..kg.`,
           col = `collection`)) +
  geom_boxplot()+
  theme(legend.position = 'none') +
  ylab('Weight (kg))')+
  xlab('Species')+
  scale_color_manual(values = color_pal_hybrids2)

ggplot(data = all,
       aes(x = factor(`collection`, level=c('S', 'SVH', 'V-C', 'V-B', 'V-A')),
           y = `Fork.length..cm.`,
           col = `collection`)) +
  geom_boxplot()+
  theme(legend.position = 'none') +
  ylab('Fork Length (cm)')+
  xlab('Species')+
  scale_color_manual(values = color_pal_hybrids2)

dev.off()

