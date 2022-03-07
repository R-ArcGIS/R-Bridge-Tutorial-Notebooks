library(arcgisbinding)
library(leaflet)
library(leaflet.esri)
library(raster)
library(reticulate)
library(sf)
library(vegclust)

arc.check_product()

base_ecoregion_url <- 'https://services3.arcgis.com/oZfKvdlWHN1MwS48/arcgis/rest/services/Ecoregions/FeatureServer/0'
base_ecoregion_obj <- arc.open(base_ecoregion_url)
base_ecoregion_obj

base_ecoregion_arc <- arc.select(base_ecoregion_obj)
base_ecoregion_sf <- arc.data2sf(base_ecoregion_arc)

L<-leaflet(elementId='ecoregion_map1') %>%
  addProviderTiles(providers$Esri) %>%
  addPolygons(data =  base_ecoregion_sf)
L

ecoregions_data.arc <- arc.select(arc.open('C:/Users/orhu8849/Documents/ArcGIS/Projects/DevSummit2021PlenaryAydin/DevSummit2021PlenaryAydin.gdb/ecoregions_data'))
ecoregions_data.sf <- arc.data2sf(ecoregions_data.arc)

vars <- c("FAPAR_MAX_ZONAL", "FAPAR_MEAN_ZONAL", "FAPAR_MIN_ZONAL", "FAPAR_RANGE_ZONAL",
          "FAPAR_STD_ZONAL", "LAI_MAX_ZONAL",   "LAI_MEAN_ZONAL",  "LAI_MIN_ZONAL",   "LAI_RANGE_ZONAL",
          "LAI_STD_ZONAL",   "PRECIP_MAX_ZONAL", "PRECIP_MEAN_ZONAL", "PRECIP_MIN_ZONAL", "PRECIP_RANGE_ZONAL",
          "PRECIP_STD_ZONAL", "TEMP_MAX_ZONAL",  "TEMP_MEAN_ZONAL", "TEMP_MIN_ZONAL",  "TEMP_RANGE_ZONAL",
          "TEMP_STD_ZONAL")

eco.vars <- st_drop_geometry(ecoregions_data.sf[vars])
  
eco_groups <- vegclust(x = eco.vars, mobileCenters=25, method="KMdd", nstart=20)
group_id <- defuzzify(eco_groups)$cluster
group_id <- unclass(factor(group_id))

ecoregions_data.sf['Defuzzy Groups'] <- group_id

arc.write('C:/Users/orhu8849/Documents/ArcGIS/Projects/DevSummit2021PlenaryAydin/DevSummit2021PlenaryAydin.gdb/ecoregions_R', ecoregions_data.sf, overwrite=TRUE)
