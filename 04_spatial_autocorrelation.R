# Install and load required packages
packages <- c("gstat", "sp", "spdep")
sapply(packages, function(pkg) {
    if (!require(pkg, character.only = TRUE)) {
        install.packages(pkg)
        library(pkg, character.only = TRUE)
    }
})

# Function to load data
load_data <- function(path) {
  read.csv(path)
}

# Function to create and fit a variogram, and calculate Moran's I
analyze_spatial_data <- function(data, coords_x, coords_y, attribute, sill=1, range=300, nugget=1) {
  coordinates(data) <- ~ get(coords_x) + get(coords_y)
  
  # Create and plot the variogram
  v <- variogram(reformulate("1", attribute), data)
  plot(v, main = "Semivariogram")
  
  # Fit a variogram model
  model <- fit.variogram(v, model = vgm(sill, "Sph", range, nugget))
  plot(v, model = model, main = "Fitted Semivariogram")
  
  # Calculate and print Moran's I
  nb <- knn2nb(data)
  lw <- nb2listw(nb, style = "W")
  moran <- moran.test(data[[attribute]], lw)
  print(moran)
  
  # Return the sill and range of the fitted model
  list(sill = model[1, "psill"], range = model[1, "range"])
}

# Load your data
sr <- load_data("/model_broad_class_dropcam_covs_db.csv")

# Analyze spatial data with specified coordinates and attribute
results <- analyze_spatial_data(sr, "coords.x1", "coords.x2", "HardCoralPA")

# Print extracted variogram sill and range
print(paste("Sill:", results$sill))
print(paste("Range:", results$range))
