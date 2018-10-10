/**
 * Displays the subway lines of dublin.
 * 
 * For colleborators: see API at http://unfoldingmaps.org/javadoc/index.html
 * Unfolding Tutorial: http://unfoldingmaps.org/tutorials/getting-started-in-processing.html
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

Location dublinLocation = new Location(53.33f, -6.25f);

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
ArrayList <SimpleLinesMarker> lines;

// Congestions
// 

// Data directory
String stopFile = "../../data/stops.csv";
String lineFile = "../../data/lines.csv";
String congestionFile = "../../data/congestions.csv";

void setup() {
  size(800, 600, OPENGL);
  smooth();
  
  initProvider();
  readStops(stopFile);
  readLines(lineFile);
  readCongestions(congestionFile);
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
  for (SimpleLinesMarker marker: lines) {
    map.addMarkers(marker);
  }

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
void readStops(String file) {
  String[] geoCoords = loadStrings(file);
  stops = new ArrayList<SimplePointMarker>();
  Location loc;
  SimplePointMarker spm;
  int i=0;
  for (String line: geoCoords) {
    i += 1;
    String[] geoCoord = split(line.trim(),",");
    loc = new Location(float(geoCoord[1]),float(geoCoord[0]));
    print (loc);
    spm = new SimplePointMarker(loc);
    stops.add(spm);
  }
}


// Read lines from route file
void readLines(String file) {
  String[] geoLines = loadStrings(file);
  lines = new ArrayList<SimpleLinesMarker>();
  Location sLoc, eLoc;
  SimpleLinesMarker splm;
  for (String line: geoLines) {
    String[] geoLine = split(line.trim(),",");
    sLoc = new Location(float(geoLine[1]),float(geoLine[0]));
    eLoc = new Location(float(geoLine[3]),float(geoLine[2]));
    splm = new SimpleLinesMarker(sLoc,eLoc);
    splm.setColor(color(233, 57, 35));
    splm.setStrokeWeight(3);
    lines.add(splm);
  }
}


// Read congestion points from congestion file 
void readCongestions(String file) {

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
    for (SimpleLinesMarker marker: lines) {
      marker.setHidden(true);
    }
  } else if (key =='6') {
    for (SimpleLinesMarker marker: lines) {
      marker.setHidden(false);
    }
  } else if (key =='4') {
  }    
}

