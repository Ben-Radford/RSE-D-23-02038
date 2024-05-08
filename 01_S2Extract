// Define ROI
var roi = ee.Geometry.Polygon([
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
], null, false);

// Define cloud and cirrus bit masks
var cloudBitMask = ee.Number(2).pow(10).int();
var cirrusBitMask = ee.Number(2).pow(11).int();

// Function to mask out clouds, shadows, and undesirable Satellite Indices
function mask(img) {
  var qa = img.select('QA60');
  var mask = qa.bitwiseAnd(cloudBitMask).eq(0)
              .and(qa.bitwiseAnd(cirrusBitMask).eq(0))
              .and(img.select('SCL').not().in([3, 4, 5, 8, 9, 10]))
              .and(img.select('B9').gt(50).and(img.select('B9').lt(300)))
              .and(img.select('B3').gt(100))
              .focal_min({kernel: ee.Kernel.circle({radius: 1}), iterations: 1});
  
  img = img.updateMask(mask)
            .updateMask(img.select([4]).lt(1000))
            .updateMask(img.select([7]).lt(300));

  var ndwi_revise = img.normalizedDifference(['B3', 'B7']).gt(0);
  return img.updateMask(ndwi_revise);
}

// Load Sentinel-2 ImageCollection, filter by ROI and date
var sentinel = ee.ImageCollection('COPERNICUS/S2_SR')
                .filterBounds(roi)
                .filterDate('2019-01-01', '2020-12-31')
                .map(mask);

// Get the median composite
var median = sentinel.reduce(ee.Reducer.median());

// Select bands for output
var s2export = median.select(['B1_median', 'B2_median', 'B3_median', 'B4_median', 'B5_median', 'B6_median', 'B7_median', 'B8_median']);

// Display output
print('Processed Sentinel-2 Data:', s2export);

Map.addLayer(median, {bands: ['B3_median', 'B2_median', 'B1_median'], min: 0, max: 0.3}, 'Clean Mosaic');

// Export image to Google Drive
Export.image.toDrive({
  image: s2export,
  description: 'SouthScott_S2_2020_Satellite_median_pixel_10m_year_2019_2020',
  region: roi,
  scale: 10,
  maxPixels: 1e13
});
