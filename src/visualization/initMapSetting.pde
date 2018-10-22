// ---------------------------- Init Map Setting ------------------------- //
void initProvider() {
  provider1 = new OpenStreetMap.OpenStreetMapProvider();
  provider2 = new Google.GoogleMapProvider();
  provider3 = new Microsoft.RoadProvider();
  provider4 = new Microsoft.AerialProvider();
}


void mapSetting() {
  // Basic Setting
  map = new UnfoldingMap(this, provider1);
  map.zoomToLevel(11);
  map.panTo(dublinLocation);
  map.setZoomRange(minZoomRange, maxZoomRange); // prevent zooming too far out
  map.setPanningRestriction(dublinLocation, maxPanningDistance);
  MapUtils.createDefaultEventDispatcher(this, map);
  barScale = new BarScaleUI(this, map, 950, 570);

  // District
  minPopulation = 0;
  maxPopulation = 20000;
  for (Marker marker : countyMarkers) {
    String edName = marker.getProperty("EDNAME").toString();
    float population = hmPopulation.get(edName);
    colorMode(HSB);
    float popuLevel = population/maxPopulation * 500 + 40;
    marker.setColor(color(225, popuLevel, 999, 100));
    colorMode(RGB);
    marker.setHidden(true);
    marker.setStrokeColor(color(120));
    marker.setStrokeWeight(1);
  }

  // Stops
  stopIndex = 1;
  stopLastIndex = 1;
  for (String key : hmStops.keySet()) {
    for (SimplePointMarker marker : hmStops.get(key)) {
      marker.setHidden(true);
      map.addMarkers(marker);
    }
  }

  // Lines
  lineIndex = 1;
  lineLastIndex = 1;
  for (String lineID: hmLines.keySet()) {
    for (SimpleLinesMarker marker: hmLines.get(lineID)){
      marker.setHidden(true);
      map.addMarkers(marker);
    }
  }

  // Congestion points
  intDay = 1;
  intLastDay = 1;
  for (String day: hmCongestion.keySet()) {
    for (SimplePointMarker marker: hmCongestion.get(day)){
      marker.setHidden(true);
      map.addMarkers(marker);
    }
  }
  map.addMarkers(countyMarkers);
}
