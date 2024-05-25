# Predict Marine Habitat - 2020

# Load required libraries
library(randomForest)
library(randomForestSRC)
library(ranger)
library(terra)
library(cluster)
library(dbscan)
library(caret)

# Set working directory and file paths
setwd("/path/to/habitat_data")
wd <- "/path/to/habitat_data"

# Load depth covariates
xvars <- terra::rast(file.path(wd, "depth_covariates_stack.tif"))
xvars <- stack(xvars)

# Sample data
set.seed(42)  # For reproducibility
xvars_smp <- sample(xvars, 100000, replace = TRUE)
xvars_smp <- data.frame(xvars_smp)
xvars_smp <- xvars_smp[complete.cases(xvars_smp),]

# Perform unsupervised random forest clustering
mrfrus <- rfsrc(Unsupervised() ~ ., data = xvars_smp)
srunsup <- randomForest(x = xvars_smp, oob.times = 5, mtry = 5, ntree = 2000, proximity = TRUE)
prox <- srunsup$proximity

# PAM clustering
pam_rf <- pam(prox, 4)
xvars_smp_clust <- cbind(cluster = pam_rf$clustering, xvars_smp)

# Ranger model
rangrf3 <- ranger(as.factor(cluster) ~ ., data = xvars_smp_clust, num.trees = 1000)

# Predict and save results
terra::predict(xvars, rangrf3, index = 1:4, filename = "predicted_habitat_ranger.tif", type = 'response', progress = 'text', fun = function(model, ...) predict(model, ...)$predictions, overwrite = TRUE)

# Confusion matrix
print(confusionMatrix(rangrf3$confusion.matrix))

# Random forest model
rf3 <- randomForest(as.factor(cluster) ~ ., data = xvars_smp_clust, num.trees = 1000)
terra::predict(xvars, rf3, index = 1:4, filename = "predicted_habitat_rf.tif", type = 'prob', progress = 'text', overwrite = TRUE)

# HDBSCAN clustering
res <- hdbscan(xvars_smp, minPts = 5)
res2 <- hdbscan(prox, minPts = 5)

# Combine HDBSCAN clusters with original data
xvars_smp_rf_hdscan <- cbind(cluster = res2$cluster, xvars_smp)
rangrf4 <- ranger(as.factor(cluster) ~ ., data = xvars_smp_rf_hdscan, num.trees = 1000)

# Predict and save results
terra::predict(xvars, rangrf4, filename = "predicted_habitat_hdbscan_ranger.tif", type = 'response', progress = 'text', fun = function(model, ...) predict(model, ...)$predictions, overwrite = TRUE)

# Plot results
plot(rast(file.path(wd, "predicted_habitat_rf.tif")))
plot(rast(file.path(wd, "predicted_habitat_ranger.tif")))

unsup <- rast(file.path(wd, "predicted_habitat_ranger.tif"))
plot(unsup[[1]], scale = TRUE)
