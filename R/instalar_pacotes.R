pacotes <- c("data.table","dplyr","stringr","sf","countrycode","rnaturalearth",
             "rnaturalearthdata","geobr","ggspatial","hexbin","ggplot2","scales",
             "leaflet","terra","rmarkdown","knitr")
faltam <- pacotes[!vapply(pacotes,requireNamespace,logical(1),quietly=TRUE)]
if(length(faltam)) install.packages(faltam,repos="https://cloud.r-project.org")
