/**
 * Displays the subway lines of dublin.
 * 
 * For colleborators: see API at http://unfoldingmaps.org/javadoc/index.html
 */

import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.providers.*;
import de.fhpotsdam.unfolding.data.*;
import de.fhpotsdam.unfolding.marker.*;

import java.util.*;
import java.text.*;

import controlP5.*; 

Location dublinLocation = new Location(53.3f, -6.33f);

// Control panel
ControlP5 cp5;

// Map container
UnfoldingMap map;

// Map providers
AbstractMapProvider provider1;
AbstractMapProvider provider2;
AbstractMapProvider provider3;
AbstractMapProvider provider4;

// Stops
ArrayList <SimplePointMarker> stops;

// Lines
// 

// Congestions
// 

// Data directory
String stopDataDir = "../dublin_data/stop/";
String lineDataDir = "../dublin_data/route/";
String congestionDataDir = "../dublin_data/congestion/";
String dataFile = "siri.20130102.csv";

void setup() {
  size(800, 600, OPENGL);
  smooth();
  
  initProvider();
  readStops(stopDataDir+dataFile);
  readLines(lineDataDir+dataFile);
  readCongestions(congestionDataDir+dataFile);
  mapSetting(); 
  initCP5();
}


void draw() {
  map.draw();
  Location location = map.getLocation(mouseX,mouseY);
  fill(0);
  text(location.getLat() + ", " + location.getLon(), mouseX, mouseY);
}


// Control panel
void initCP5() {
  cp5 = new ControlP5(this);
  cp5.addButton("Map style")
    .setCaptionLabel("style")
    .setPosition(0,0)
    .setSize(100,59);
  // cp5.addButton("More")
  //
}


// Set all map elements
void mapSetting() {
  // Basic Setting
  map = new UnfoldingMap(this, provider1);
  map.zoomToLevel(11);
  map.panTo(dublinLocation);
  map.setZoomRange(9, 17); // prevent zooming too far out
  map.setPanningRestriction(dublinLocation, 50);
  MapUtils.createDefaultEventDispatcher(this, map);
  
  // Stops
  for (SimplePointMarker marker: stops) {
    map.addMarkers(marker);
  }

  // Lines
  //

  // Congestion points
  //
  
}

void initProvider() {
  provider1 = new OpenStreetMap.OpenStreetMapProvider();
  provider2 = new Google.GoogleMapProvider();
  provider3 = new Microsoft.RoadProvider();
  provider4 = new Microsoft.AerialProvider();
}

// Read stops from stop file
void readStops(String directory) {
  String[] geoCoords = loadStrings(directory);
  stops = new ArrayList<SimplePointMarker>();
  Location loc;
  SimplePointMarker spm;
  int i=0;
  for (String line: geoCoords) {
    i += 1;
    if (i>10) break;
    String[] geoCoord = split(line.trim(),",");
    loc = new Location(float(geoCoord[1]),float(geoCoord[0]));
    print (loc);
    spm = new SimplePointMarker(loc);
    stops.add(spm);
  }
}


// Read lines from route file
void readLines(String directory) {

}


// Read congestion points from congestion file 
void readCongestions(String directory) {

}


void keyPressed() {
  // Number keys to change map provider
  if (key == '1') {
    map.mapDisplay.setProvider(provider1);
  } else if (key == '2') {
    map.mapDisplay.setProvider(provider2);
  } else if (key =='3') {
    map.mapDisplay.setProvider(provider3);
  } else if (key =='4') {
    map.mapDisplay.setProvider(provider4);
  } else if (key == '5') {
    for (SimplePointMarker marker: stops) {
      marker.setHidden(true);
    }
  } else if (key =='4') {
  } else if (key =='4') {
  }    
}

