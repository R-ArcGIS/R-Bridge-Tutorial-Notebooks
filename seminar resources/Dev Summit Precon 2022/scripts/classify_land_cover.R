library(arcgisbinding)
library(doParallel)
library(caret)
library(raster)
library(e1071)

arc.check_product()

root.gdb <- "C:/Users/orhu8849/OneDrive - Esri/Documents/ESRI Conferences/Dev Summit 2022/Preconference Seminar/Project/classification.gdb"
## List contents of gdb
arc.open(root.gdb)
train.data.loc <- file.path(root.gdb, "farm_training")
training.data <- arc.select(arc.open(train.data.loc))
head(training.data)

## Set Up Parallel Computing Env
mc <- makeCluster(detectCores())

## Fit Naive Bayes Classifier
set.seed(12345)
data.df <- as.data.frame(training.data)
training.df <- as.data.frame(training.data)

model.NaiveBayes <- naiveBayes(as.factor(Classname)~RED+GREEN+BLUE, 
                data=data.df)
model.NaiveBayes 


## Get Prediction Data from Raster
raster.path <- file.path(root.gdb, "landsat")
pred.raster <- arc.raster(arc.open(raster.path), nrow = 200, ncol = 200)
pred.raster.R <- as.raster(pred.raster)

plotRGB(pred.raster.R)

pred.df <- as.data.frame(pred.raster.R)

colnames(pred.df) <- c("RED", "GREEN", "BLUE")

registerDoParallel(mc)
pred.vector <- predict(model.NaiveBayes, pred.df)
stopCluster(mc)

## What Happened? Scaling and Standardizing
std.cont <- scale(training.data[,5:7], center=TRUE, scale=TRUE)
data.df.std <- as.data.frame(std.cont)
data.df.std["Classname"] = training.data$Classname

pred.df.std <- scale(pred.df, center=TRUE, scale=TRUE)
pred.df.std <- as.data.frame(pred.df.std)

model.NaiveBayes.std <- naiveBayes(as.factor(Classname)~RED+GREEN+BLUE, 
                               data=data.df.std)
model.NaiveBayes.std

registerDoParallel(mc)
pred.vector.std <- predict(model.NaiveBayes.std, pred.df.std)
stopCluster(mc)
unique(pred.vector.std)

## Create a Raster
pred.raster.R["LAND_COVER_PRED"] <- pred.vector.std

pred.raster$ncol
pred.raster$nrow

new_raster <- raster(nrows = pred.raster$nrow, 
                     ncols = pred.raster$ncol,
                     ext = extent(pred.raster.R))

values(new_raster) <- factor(pred.vector.std)

arc.write(file.path(root.gdb, "raster_output1"),new_raster)

