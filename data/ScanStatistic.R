#Wrapping Functionality
tool_exec <- function(in_params, out_params){

#####################################################################################################  
### Obtain Geoprocessing Environment Settings
#####################################################################################################   
  env <- arc.env()
  workspace <- env$workspace
  cat(paste0("\n", "............................................", "\n"))
  cat(paste0("\n", "Current Workspace:", "\n"))
  print(workspace)

#####################################################################################################  
### Check/Load Required Packages  
#####################################################################################################   
  arc.progress_label("Loading packages...")
  arc.progress_pos(20)
  
  if(!requireNamespace("arcgisbinding", quietly = TRUE))
    install.packages("arcgisbinding", quiet = TRUE, dependencies = TRUE)  
  if(!requireNamespace("spatstat", quietly = TRUE))
    install.packages("spatstat", quiet = TRUE, dependencies = TRUE)
  if(!requireNamespace("maptools", quietly = TRUE))
    install.packages("maptools", quiet = TRUE, dependencies = TRUE)  
  if(!requireNamespace("raster", quietly = TRUE))
    install.packages("raster", quiet = TRUE, dependencies = TRUE)
  
  require(arcgisbinding)
  require(spatstat)
  require(maptools)
  require(raster)

##################################################################################################### 
### Step 1: Define input and output parameters
#####################################################################################################
  

##################################################################################################### 
### Step 2: Create a progress label
#####################################################################################################
  
  
##################################################################################################### 
### Load Data and Create an object of class "ppp"
#####################################################################################################
  
  d <- arc.open(occurrence_dataset)
  d_sub <- arc.select(d, fields = "*", where_clause = agency)
  occurrence <- arc.data2sp(d_sub)
  occurrence_ppp <- as(occurrence, "ppp")

##################################################################################################### 
### Calculate Scan Statistic
#####################################################################################################
  arc.progress_label("Calculating Scan Statistic:")
  arc.progress_pos(60)
  cat(paste0("\n", "............................................", "\n"))
  cat(paste0("\n", "Beginning Simulations...", "\n"))
  
  dist_incr = (radius_max - radius_min)/dist_bands

  if(model_type == "Poisson"){
    scan_result <- scan.test(occurrence_ppp, r = seq(radius_min, radius_max, by = dist_incr), method = "poisson", nsim = num_sims, alternative = "two.sided")
  }

  if(model_type == "Binomial"){
    scan_result <- scan.test(occurrence_ppp, r = seq(radius_min, radius_max, by = dist_incr), method = "binomial", nsim = num_sims, alternative = "two.sided")
  }
  
  cat(paste0("\n", "............................................", "\n"))
  cat(paste0("\n", "Scan Test Results...", "\n"))
  print(scan_result)
  
  pixel_result <- as.im.scan.test(scan_result)
  raster_result <- raster(pixel_result)

##################################################################################################### 
### Write Output
#####################################################################################################
  arc.progress_label("Writing Output...")
  arc.progress_pos(80)
  
  if(!is.null(out_raster) && out_raster != "NA")
    arc.write(out_raster, raster_result)
  if(!is.null(out_feature) && out_feature != "NA")
    arc.write(out_feature, occurrence)
  
  arc.progress_pos(100)
  
}