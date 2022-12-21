if(!require(leaflet)){
  install.packages("leaflet")
  library(leaflet)
}
if(!require(shiny)){
  install.packages("shiny")
  library(shiny)
}
if(!require(RColorBrewer)){
  install.packages("RColorBrewer")
  library(RColorBrewer)
}
if(!require(devtools)){
  install.packages("devtools")
  library(devtools)
}
# A custom package for interfacing with ArcGIS Online or Enterprise
if(!require(arcgis)){
  devtools::install_github("gbrunner/arcgis-r-demos",
                           force=TRUE)
  library(arcgis)
}
if(!require(httr)){
  install.packages("httr")
  library(httr)
}
if(!require(geojsonio)){
  install.packages("geojsonio")
  library(geojsonio)
}
if(!require(jsonlite)){
  install.packages("jsonlite")
  library(jsonlite)
}

# Layout for the Shiny UI
# Contains a text label, an editble text box, a search button, and a 
# check box to search for only content in your account
ui <- bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(top = 10, right = 10,
                textInput("searchTerm", "Search for Feature Layers", value = "NJ_Demographics",
                          width = NULL, placeholder = NULL
                ),
                actionButton("searchButton", "Search"),
                checkboxInput("owner", "Your Content?", TRUE)
  )
)

# The app
server <- function(input, output, session) {
  
  v <- reactiveValues(data = NULL)
  
  # Create a new GIS object
  gis <- new("GIS",
             url="https://learngis.maps.arcgis.com/",
             username = "gbrunner_LearnGIS",
             password = "####")

  # Log into ArcGIS Online  
  gis <- login(gis)
  
  observeEvent(input$searchButton, {
    v$col <- 1
    ind <- 1
    
    # Create the ArcGIS search query
    if (input$owner==TRUE) {
      # Search only my content
      search_term <- paste("owner:",gis@username, " AND ", input$searchTerm," AND type:feature service", set="")
    }
    else{
      # Search all ArcGIS Online
      search_term <- paste(input$searchTerm," AND type:feature service")
    }
    print(input$searchTerm)
    
    # Run the search
    items <- search_gis(gis, search_term)
    print(items$results)
    
    # Convert results to spatial dataframe
    v$spdf <- get_sdf(gis, items$results[[1]], 0)
    
    # Infer column in dataframe to render on map
    ind <- get_column_to_render(v$spdf) #v$spdf$TOTPOP_CY #
    v$col <- v$spdf@data[,ind]
    v$colname <- colnames(v$spdf@data)[ind]
    print(v$colname)

  }, ignoreNULL = FALSE)
  
  pal <- colorNumeric("viridis", NULL)
  
  # https://rstudio.github.io/leaflet/markers.html
  
  output$map <- renderLeaflet({
    if (is.null(v$spdf)){
      leaflet() %>%
        addProviderTiles(providers$Esri.WorldStreetMap)
    }
    else{
      if (class(v$spdf) == "SpatialPolygonsDataFrame") {
        m <- add_polygons_layer(v$spdf, v$colname)
      }
      else if (class(v$spdf) == "SpatialPointsDataFrame") {
        m <- add_points_layer(v$spdf, v$colname)
      }
      else if (class(v$spdf) == "SpatialLinesDataFrame") {
        m <- add_polylines_layer(v$spdf, v$colname)
      }
      else if (class(v$spdf) == "SpatialMultiPointsDataFrame") {
        m <- add_multipoints_layer(v$spdf, v$colname)
      }
      else {
        leaflet() %>%
          addProviderTiles(providers$Esri.WorldStreetMap) %>%
          addMarkers()
      }
    }
  })
  
  
}

# Run the app
shinyApp(ui, server)