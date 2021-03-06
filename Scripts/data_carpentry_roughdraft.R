#Practice data manipulation on aquastat

#libraries
library(here)
library(tidyverse)
library(maps)
library(mapdata)
library(mapproj)
library(ggrepel)
library(ghibli)

#Story - 1. Current water stress worldwide 2. How did we get here?  3. Is it associated with economic success?

#Water stress occurs when the demand for water exceeds the available 
#amount during a certain period or when poor quality restricts its use. 
#Water stress causes deterioration of fresh water resources in terms of quantity 
#(aquifer over-exploitation, dry rivers, etc.) and quality (eutrophication, organic 
#matter pollution, saline intrusion, etc.) -EEA of the EU
#https://www.eea.europa.eu/archived/archived-content-water-topic/wise-help-centre/glossary-definitions/water-stress

#Read in data

aquastat <- read_csv(here("Data", "aquastat_flat.csv"))

#cleaning
aquastat_wide <- aquastat %>% 
  select(Area, Variable_Name, Year, Value) %>% 
  filter(complete.cases(.)) %>% 
  pivot_wider(names_from = Variable_Name, values_from = Value)

colClean <- function(x){ colnames(x) <- gsub(" ", "_", colnames(x)); x }

aquastat_clean <- colClean(aquastat_wide)


#1. Mapping
library(maps)
library(mapdata)
library(mapproj)
world <- map_data("world") #map_data gets base layer

head(world)

#prep to join

aquastat_stress <- aquastat_clean %>% 
  select(Area, SDG_6.4.2._Water_Stress, Year) %>% 
  filter(complete.cases(.)) %>% 
  rename(region = Area)

anti_2017 <- aquastat_stress %>% 
  filter(Year==2017) %>% 
  anti_join(world)

aquastat_stress1 <- aquastat_clean %>% 
  select(Area, SDG_6.4.2._Water_Stress, Year) %>% 
  filter(complete.cases(.)) %>% 
  rename(region = Area) %>% 
  mutate(region = str_replace(region, "United States of America", "USA")) %>% 
  mutate(region = str_replace(region, "Russian Federation", "Russia")) %>% 
  mutate(region = str_replace(region, "Democratic People's Republic of Korea", "North Korea")) %>% 
  mutate(region = str_replace(region, "Venezuela \\(Bolivarian Republic of\\)", "Venezuela")) %>% 
  mutate(region = str_replace(region, "Viet Nam", "Vietnam")) %>%
  mutate(region = str_replace(region, "Bolivia \\(Plurinational State of\\)", "Bolivia")) %>%
  mutate(region = str_replace(region, "Brunei Darussalam", "Brunei")) %>%
  mutate(region = str_replace(region, "Cabo Verde", "Cape Verde")) %>%
  mutate(region = str_replace(region, "Côte d'Ivoire", "Ivory Coast")) %>%
  mutate(region = str_replace(region, "Iran \\(Islamic Republic of\\)", "Iran")) %>%
  mutate(region = str_replace(region, "Republic of Korea", "South Korea")) %>%
  mutate(region = str_replace(region, "Republic of Moldova", "Moldova")) %>%
  mutate(region = str_replace(region, "United Kingdom", "UK")) %>%
  mutate(region = str_replace(region, "United Republic of Tanzania", "Tanzania")) %>%
  mutate(region = str_replace(region, "Syrian Arab Republic", "Syria")) %>% 
  mutate(region = str_replace(region, "Congo", "Republic of Congo")) %>% 
  mutate(region = str_replace(region, "Democratic Republic of the Republic of Congo", "Democratic Republic of the Congo"))

#Double check

anti_20171 <- aquastat_stress1 %>% 
  filter(Year==2017) %>% 
  anti_join(world)

view(anti_20171)

#Join

stress_2017 <- aquastat_stress1 %>% 
  filter(Year==2017) %>% 
  left_join(world)

view(stress_2017)
 #Map

ghibli_palettes$KikiMedium

ggplot()+
  geom_polygon(data=stress_2017, aes(x=long, y=lat, group=group, fill=SDG_6.4.2._Water_Stress), color="black")+
  theme_minimal()+
  coord_map("mercator", xlim=c(-180, 180))+
  scale_fill_gradient(trans="log10", low="#B50A2AFF", high="#0E84B4FF")+
  labs(title="World Water Stress, ~2017",
       x="",
       y="",
       fill="Water Stress (log10)")+
  theme(plot.title = element_text(hjust = 0.5, color = "#333544FF"),
        legend.title = element_text(color = "#333544FF"))

#2. Time Series

library(ggrepel)
#Data wrangling <-
aquastat_stress2 <- aquastat_clean %>% 
  select(Area, SDG_6.4.2._Water_Stress, Year, Total_population) %>% 
  filter(complete.cases(.)) %>% 
  filter(Year==1992)

view(aquastat_stress2)

aquastat_high_pop <- aquastat_clean %>% 
  select(Area, SDG_6.4.2._Water_Stress, Year, Total_population) %>% 
  filter(complete.cases(.)) %>% 
  filter(str_detect(Area, "China|India|United States of America|Indonesia|Brazil|Russian Federation|Japan|Pakistan|Nigeria|Mexico|Germany|Viet Nam|Iran \\(Islamic Republic of\\)|Egypt|United Kingdom"))

view(aquastat_high_pop)

ggplot(aquastat_high_pop, aes(x=Year, y= SDG_6.4.2._Water_Stress, color=Area, label=Area))+
  geom_line(size=1.5)+
  geom_text_repel(data = aquastat_high_pop %>% filter(Year == 2017), nudge_x = 2, size=3, show.legend = FALSE)+
  labs(x= "Year",
       y= "Water Stress",
       title= "Water Stress by Year",
       subtitle="In Worldwide High-Population Nations",
       color= "Country")+
  scale_color_viridis_d()+
  theme(plot.title=element_text(hjust=0.5),
        plot.subtitle=element_text(hjust=0.5))
 

# geom_label(aes(label = Area),
           # data = aquastat_high_pop %>% filter(Year == 2017), size = 3, position=position_dodge(.7))

  
  # geom_text(aes(label=Area), position=position_dodge(.9))
  
#3. Related to economic success? (GDP)

aquastat_WS_GDP <- aquastat_clean %>% 
  select(Area, SDG_6.4.2._Water_Stress, Year, Total_population, `Gross_Domestic_Product_(GDP)`) %>% 
  filter(complete.cases(.)) %>% 
  filter(str_detect(Area, "China|India|United States of America|Indonesia|Brazil|Russian Federation|Japan|Pakistan|Nigeria|Mexico|Germany|Viet Nam|Iran \\(Islamic Republic of\\)|Egypt|United Kingdom"))

  ggplot(aquastat_WS_GDP, aes(x=SDG_6.4.2._Water_Stress, y=`Gross_Domestic_Product_(GDP)`, color=Area))+ 
    geom_point(size=4)+
    facet_wrap(~Year)+
    labs(x="Water Stress",
         y= "Gross Domestic Product",
         title="Water stress vs GDP Over Time",
         subtitle="In Worldwide High-Population Nations")+
    scale_color_viridis_d()
  