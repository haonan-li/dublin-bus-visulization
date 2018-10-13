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

//Location dublinLocation = new Location(53.33f, -6.25f);
Location dublinLocation = new Location(53.33f, -6.35f);

// Control panel
ControlP5 cp5;
Accordion accordion;


// Map container
UnfoldingMap map;

// Map providers
AbstractMapProvider provider1;
AbstractMapProvider provider2;
AbstractMapProvider provider3;
AbstractMapProvider provider4;

int zoomLevel, prevZoomLevel, minZoomRange, maxZoomRange;

// Stops
HashMap<String, ArrayList <SimplePointMarker>> hmStops;

// Lines
ArrayList <SimpleLinesMarker> lines;

// Congestions
//

// Data directory
String stopFile = "../../data/stops.csv";
String lineFile = "../../data/lines.csv";
String congestionFile = "../../data/congestions.csv";

String[] arr = {"1", "2", "8", "11", "22", "221", "240"};

void setup() {
  size(1000, 600, OPENGL);
  smooth();

  minZoomRange = 9;
  maxZoomRange = 17;

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
  zoomLevel = map.getZoomLevel();
  map.setZoomRange(minZoomRange, maxZoomRange);

  if (mouseX > 160 || mouseY < 30 || mouseY > 580) {
    fill(0);
    text(location.getLat() + ", " + location.getLon(), mouseX, mouseY);
//    println(zoomLevel);
  }
  if (mouseX <= 160 && (mouseY >= 30 || mouseY <= 580)) {
    map.setZoomRange(zoomLevel, zoomLevel);
  }
}


// Control panel
void initCP5() {
  cp5 = new ControlP5(this);
  ControlFont cf = new ControlFont(createFont("Arial", 9));
  cp5.setFont(cf);

  Group g1 = cp5.addGroup("stop")
    .setBackgroundColor(color(200))
    .setBackgroundHeight(190)
    .setBarHeight(20)
    ;

  cp5.addToggle("show_stops")
     .setValue(0)
     .setPosition(10, 20)
     .setSize(20, 20)
     .moveTo(g1)
     ;

  cp5.addScrollableList("show_stops_in_route:")
    .setPosition(10, 70)
    .setSize(130, 110)
    .setBarHeight(20)
    .setItemHeight(20)
    .addItems(arr)
    .setColorLabel(color(255))
    .moveTo(g1)
    ;

  Group g2 = cp5.addGroup("route")
    .setBackgroundColor(color(200))
    .setBackgroundHeight(190)
    .setBarHeight(20)
    ;

  cp5.addToggle("show_routes")
     .setValue(0)
     .setPosition(10, 20)
     .setSize(20, 20)
     .moveTo(g2)
     ;

  cp5.addScrollableList("show_route:")
    .setPosition(10, 70)
    .setSize(130, 110)
    .setBarHeight(20)
    .setItemHeight(20)
    .addItems(arr)
    .setColorLabel(color(255))
    .moveTo(g2)
    ;

  Group g3 = cp5.addGroup("congestion")
    .setBackgroundColor(color(200))
    .setBackgroundHeight(60)
    .setBarHeight(20)
    ;

  cp5.addToggle("show_congestion")
     .setValue(0)
     .setPosition(10, 25)
     .setSize(20, 20)
     .moveTo(g3)
     ;

  cp5.addSlider("days")
    .setValue(0)
    .setPosition(10,70)
    .setSize(95,20)
    .setRange(1,31)
    .moveTo(g3)
    ;

  accordion = cp5.addAccordion("acc")
    .setPosition(10, 30)
    .setWidth(150)
    .addItem(g1)
    .addItem(g2)
    .addItem(g3)
    ;

  accordion.open(0, 1, 2);

  accordion.setCollapseMode(Accordion.MULTI);
}


public void show_stops() {

}


// Set all map elements
void mapSetting() {
  // Basic Setting
  map = new UnfoldingMap(this, provider1);
  map.zoomToLevel(11);
  map.panTo(dublinLocation);
  map.setZoomRange(minZoomRange, maxZoomRange); // prevent zooming too far out
  map.setPanningRestriction(dublinLocation, 50);
  MapUtils.createDefaultEventDispatcher(this, map);

  // Stops
  for (SimplePointMarker marker : hmStops.values ()) {
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
  //Load String data
  String[] geoCoords = loadStrings(file);
  ArrayList <SimplePointMarker> stops = new ArrayList<SimplePointMarker>();
  //Hash Map: key is line id and value is an Arraylist of location's SimplePointMarker
  hmStops = new HashMap<String, ArrayList <SimplePointMarker>>();
  Location loc;
  SimplePointMarker spm;

  //Line ID of previous row
  String lastLine = "1";

  //Visit each row
  for (String line : geoCoords) {
    String[] geoCoord = split(line.trim(), ",");
    //If line ID is same as the last one, save in a same ArrayList
    if (geoCoord[1] == lastLine) {
      loc = new Location(float(geoCoord[3]), float(geoCoord[2]));
      spm = new SimplePointMarker(loc);
      stops.add(spm);
    } else {
      //If line ID is different with the last one, write data to hashmap
      //Create a new arraylist to save the next line
      hmStops.put(lastLine, stops);
      lastLine = geoCoord[1];
      stops.clear();
      loc = new Location(float(geoCoord[3]), float(geoCoord[2]));
      spm = new SimplePointMarker(loc);
      stops.add(spm);
    }
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
    for (SimplePointMarker marker : hmStops.values ()) {
      marker.setHidden(true);
    }
  } else if (key =='6') {
    for (SimplePointMarker marker : hmStops.valu6556es ()) {
      marker.setHidden(false);
    }
  } else if (key =='4') {
  }
}

