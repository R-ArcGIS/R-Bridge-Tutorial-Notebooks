library(arcgisbinding)

data.url <- 'https://services1.arcgis.com/0MSEUqKaxRlEPj5g/arcgis/rest/services/ncov_cases2_v1/FeatureServer/3'
data.time.url <- 'https://services1.arcgis.com/0MSEUqKaxRlEPj5g/arcgis/rest/services/ncov_cases2_v1/FeatureServer/4'
data.open <- arc.open(data.url)
data <- arc.select(data.open, where_clause = "Country_Region = 'US'")
data.sf <- arc.data2sf(data)
head(data.sf)
colnames(data.sf)

data.time.US <- arc.select(arc.open(data.time.url), where_clause = "Country_Region = 'US'")
unique(data.time.US$Province_State)
data.time.CA <- data.time.US[data.time.US$Province_State=="California",]
data.time.CA
colnames(data.time.CA)
data.time.CA['time']=as.POSIXct(data.time.CA$Report_Date_String, format="%Y/%m/%d", tz="UTC")

## Plot GGPlot
library(ggplot2)
p <- ggplot(data.time.CA, aes(x=time, y=Confirmed)) +
  geom_line() + 
  xlab("")
p
