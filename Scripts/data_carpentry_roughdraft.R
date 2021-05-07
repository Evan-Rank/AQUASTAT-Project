#Practice data manipulation on aquastat

#libraries
library(here)
library(tidyverse)

#Read in data

aquastat <- read_csv(here("Data", "aquastat_flat.csv"))
view(aquastat)

aquastat_wide <- aquastat %>% 
  pivot_wider(names_from = Variable_Name, values_from = Value)

view(aquastat_wide)