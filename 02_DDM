import ee
ee.Initialize()

# Define ROI GeoJSON Geometry
roi = ee.Geometry.Polygon([
    [[121.71372107646425, -14.068935915221532],
     [121.69930152080019, -14.119550018457142],
     [121.70410803935488, -14.166158324337708],
     [121.75217322490175, -14.208763260295196],
     [121.82839087626894, -14.226734813471507],
     [121.91010169169863, -14.204103735657231],
     [121.95748023173769, -14.162163701191778],
     [121.99524573466738, -14.116220488390967],
     [121.98494605205019, -14.043624658477597],
     [121.95061377665957, -14.036297193469204],
     [121.75903967997988, -14.029635658337147],
     [121.71715430400332, -14.06160926041821]]
])

# Load Sentinel-2 ImageCollection
sentinel = ee.ImageCollection('COPERNICUS/S2') \
            .filterDate('2020-01-01', '2020-12-31') \
            .filterBounds(roi) \
            .filter(ee.Filter.lt('CLOUDY_PIXEL_PERCENTAGE', 10))  # Filter for minimal cloud cover

# Preprocessing function to mask clouds and select B2 and B3
def preprocess(image):
    cloudProb = image.select('MSK_CLDPRB')
    snowProb = image.select('MSK_SNWPRB')
    cloudMask = cloudProb.lt(5)  # Less than 5% probability of clouds
    snowMask = snowProb.lt(5)    # Less than 5% probability of snow
    combinedMask = cloudMask.And(snowMask)
    return image.updateMask(combinedMask).select("B2", "B3")  # Blue and Green bands

# Map the preprocessing function over the collection
processed = sentinel.map(preprocess)

# Composite the images using median reducer
composite = processed.median()

# Stumpf model for depth estimation
def stumpf_model(image):
    blue = image.select('B2')  # Blue band
    green = image.select('B3')  # Green band
    depth = blue.divide(green).log().multiply(-100)  # Depth model ajusted for Lidar values
    return image.addBands(depth.rename('depth'))

# Apply the Stumpf model
depth_model = stumpf_model(composite)

# Export the depth model to Google Drive
export_task = ee.batch.Export.image.toDrive(
    image=depth_model.select('depth'),
    description='DepthModel_Sentinel2',
    scale=10,
    region=roi.getInfo()['coordinates'],
    fileFormat='GeoTIFF',
    folder='GEE_Exports'
)
export_task.start()
