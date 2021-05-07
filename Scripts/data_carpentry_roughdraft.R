#Practice data manipulation on aquastat

#libraries
library(here)
library(tidyverse)

#Read in data

aquastat <- read_csv(here("Data", "aquastat_flat.csv"))
view(aquastat)

aquastat_wide <- aquastat %>% 
  select(Area, Variable_Name, Year, Value) %>% 
  pivot_wider(names_from = Variable_Name, values_from = Value)

view(aquastat_wide)

ggplot(aquastat_wide, x="Area", y="SDG 6.4.2. Water Stress", color="Year")+
  geom_bar()