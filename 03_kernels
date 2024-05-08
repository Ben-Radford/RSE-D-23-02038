import arcpy
from arcpy import env
from arcpy.sa import *

# Enable Spatial Analyst extension (assuming it's not already enabled)
arcpy.CheckOutExtensionLicense("Spatial")

# Set environment variables with clear and descriptive names
env.workspace = /rasters"  # Assuming this is the folder containing your raster
in_raster = "depth.tif"  # Using a variable for readability

# Define functions for reusability and maintainability
def calculate_aspect_slope(in_raster, aspect_out, slope_out):
  """Calculates aspect and slope from a raster.

  Args:
      in_raster (str): Path to the input raster.
      aspect_out (str): Path to the output aspect raster.
      slope_out (str): Path to the output slope raster.
  """
  arcpy.gp.Aspect_sa(in_raster, aspect_out)
  arcpy.Slope_3d(in_raster, slope_out, "DEGREE", "1")  # Assuming degrees for slope

def calculate_range(in_raster, neighborhood_size, out_raster):
  """Calculates range within a specified circular neighborhood.

  Args:
      in_raster (str): Path to the input raster.
      neighborhood_size (int): Size of the circular neighborhood in cells.
      out_raster (str): Path to the output raster with range values.
  """
  arcpy.gp.FocalStatistics_sa(in_raster, out_raster, f"Circle {neighborhood_size} CELL", "RANGE", "DATA")

def calculate_standard_deviation(in_raster, neighborhood_size, out_raster):
  """Calculates standard deviation within a specified circular neighborhood.

  Args:
      in_raster (str): Path to the input raster.
      neighborhood_size (int): Size of the circular neighborhood in cells.
      out_raster (str): Path to the output raster with standard deviation values.
  """
  arcpy.gp.FocalStatistics_sa(in_raster, out_raster, f"Circle {neighborhood_size} CELL", "STD", "DATA")

def calculate_curvature(in_raster, curvature_out, profile_out, plan_out):
  """Calculates curvature, profile, and plan curvatures from a raster.

  Args:
      in_raster (str): Path to the input raster.
      curvature_out (str): Path to the output curvature raster.
      profile_out (str): Path to the output profile curvature raster.
      plan_out (str): Path to the output plan curvature raster.
  """
  arcpy.gp.Curvature_sa(in_raster, curvature_out, "1", profile_out, plan_out)

def calculate_hypsometry(in_raster, neighborhood_size, mean_out, hypso_out):
  """Calculates mean elevation within a specified neighborhood and hypsometry.

  Args:
      in_raster (str): Path to the input raster.
      neighborhood_size (int): Size of the circular neighborhood in cells.
      mean_out (str): Path to the output raster with mean elevation values.
      hypso_out (str): Path to the output raster with hypsometry values.
  """
  arcpy.gp.FocalStatistics_sa(in_raster, mean_out, f"Circle {neighborhood_size} CELL", "MEAN", "DATA")
  hypsometry = Minus(in_raster, mean_out)
  hypsometry.save(hypso_out)

# Call functions for calculations with meaningful variable names
aspect_out = "asp.tif"
slope_out = "slp.tif"
calculate_aspect_slope(in_raster, aspect_out, slope_out)

curvature_out = "curv.tif"
profile_out = "prof.tif"
plan_out = "plan.tif"

calculate_curvature(in_raster, curvature_out, profile_out, plan_out)

range_neighborhoods = [5, 10, 25, 50]  # List of neighborhood sizes for range
for neighborhood_size in range_neighborhoods:
  out_raster = f"rng{neighborhood_size}.tif"
  calculate_range(in_raster, neighborhood_size, out_raster)

std_neighborhoods = [5, 10, 25, 50]  # List of neighborhood sizes for standard deviation
for neighborhood_size in std_neighborhoods:
  out_raster = f"std{neighborhood_size}.tif"
  calculate_standard_deviation(in_raster, neighborhood_size,out_raster)

hyp_neighborhoods = [5, 10, 25, 50]  # List of neighborhood sizes for standard deviation
for neighborhood_size in hyp_neighborhoods:
  mean_out = f"mean{neighborhood_size}.tif"
  hypso_out = f"hyp{neighborhood_size}.tif"
  calculate_hypsometry(in_raster, neighborhood_size,mean_out, hypso_out)
