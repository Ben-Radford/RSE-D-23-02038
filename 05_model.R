# Load required libraries
library(randomForest)
library(terra) 
library(caret)  
library(data.table) 
library(tidyverse)  

# Set seed for reproducibility
set.seed(123)

# Set working directory for data input/output
setwd("/BatchOutput")

# Load raster data
xvarsagg <- terra::rast("/depth_covariates_stack.tif")

# Load and prepare shapefile data
dc <- vect("ssdropcam_2020_spatial_auto_rm.shp")
dc <- dc %>% mutate(
  CoralCAPA = ifelse(Acrspp_ >= 10 & Prtspp_ >= 10 & Crllnal >= 10, 1, 0)
)

# Create buffered shapefile for extraction
dcbuff <- buffer(dc, width=20, dissolve=FALSE)
dcbuff <- vect(dcbuff)

# Extract median values from raster based on buffered shapefile
dc_rvals <- terra::extract(xvarsagg, dcbuff, fun=median, method="simple")

# Create combined data frame and clean NA values
dcdb <- data.frame(dc, dc_rvals) %>% na.omit()

# training and testing sets
smp_size <- floor(0.70 * nrow(dcdb))
train_indices <- sample(seq_len(nrow(dcdb)), size = smp_size)
train <- dcdb[train_indices, ]
test <- dcdb[-train_indices, ]

# Function to run and evaluate random forest models
run_rf_model <- function(data, response_var) {
  model <- randomForest(as.factor(response_var) ~ ., data=data, ntree=1000, mtry=(round((dim(data)[2]-1)/3)), importance=TRUE)
  predictions <- predict(model, test)
  cm <- confusionMatrix(table(predictions, test[,response_var]))
  return(list(model=model, cm=cm))
}

# Run and evaluate model for CoralCAPA
results <- run_rf_model(train, train$CoralCAPA)
print(results$cm)

# Save test set with predictions
testsp <- vect(test, geom=c("coords.x1", "coords.x2"), crs="epsg:4326")
writeVector(testsp, "path_to_output.shp", overwrite=TRUE)
