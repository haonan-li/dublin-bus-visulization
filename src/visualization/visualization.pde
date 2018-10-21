/**
 *  Dublin Bus Visualization
 *
 * For colleborators: see API at http://unfoldingmaps.org/javadoc/index.html
 * Unfolding Tutorial: http://unfoldingmaps.org/tutorials/getting-started-in-processing.html
 */

import de.fhpotsdam.unfolding.ui.BarScaleUI;
import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.providers.*;
import de.fhpotsdam.unfolding.data.*;
import de.fhpotsdam.unfolding.marker.*;

import java.util.*;
import java.text.*;
import java.math.*;

import controlP5.*;


// --------------------------------- Variable Declaration -------------------------------- //
// Location for centering the map
Location dublinLocation;
Location newLocation;

// Control panel
ControlP5 cp5;
Accordion accordion;
int days;
int panelFontSize;
int bgHeight;
color colorBg, bgColor, outTextColor, inTextColor;

// Map providers
AbstractMapProvider provider1;
AbstractMapProvider provider2;
AbstractMapProvider provider3;
AbstractMapProvider provider4;

// Map setting
UnfoldingMap map;
BarScaleUI barScale;
int zoomLevel, prevZoomLevel, minZoomRange, maxZoomRange;
float maxPanningDistance;

// Stops
int stopIndex, stopLastIndex;
float isShowStops, isLastShowStops;
HashMap<String, ArrayList <SimplePointMarker>> hmStops;

// Lines
int lineIndex, lineLastIndex;
float isShowLines, isLastShowLines;
ArrayList<String> lineNum ;
HashMap<String, ArrayList <SimpleLinesMarker>> hmLines;

// Congestion
int intDay, intLastDay;
float isShowCongestion, isLastShowCongestion;
HashMap<String, ArrayList <SimplePointMarker>> hmCongestion;

// Population
float isShowPopulation, isLastShowPopulation;
float minPopulation, maxPopulation;
HashMap<String, Float> hmPopulation;

// District
List<Feature> district;
List<Marker> countyMarkers;

// Data directory
String stopFile = "../../data/stops.csv";
String lineFile = "../../data/lines.csv";
String lineIDFile = "../../data/lineID.csv";
String districtFile = "../../data/district.geojson";
String populationFile = "../../data/population.csv";
String congestionFile = "../../data/congestion.csv";


// --------------------------------- Setup -------------------------------- //
void setup() {
  size(1000, 600, OPENGL);
  smooth();

  dublinLocation = new Location(53.33f, -6.35f);

  minZoomRange = 9;
  maxZoomRange = 17;
  maxPanningDistance = 50;

  panelFontSize = 10;
  colorBg = #2E5C6E;
  bgColor = 0x7fA5DEE4;
  outTextColor = color(0);
  inTextColor = color(255);
  bgHeight = 160;

  readShape(districtFile);
  readLinesID(lineIDFile);
  readStops(stopFile);
  readLines(lineFile);
  readPopulation(populationFile);
  readCongestion(congestionFile);
  initProvider();
  mapSetting();
  initCP5();
}


// ---------------------------------- Draw --------------------------------- //
void draw() {
  map.draw();
  Location location = map.getLocation(mouseX, mouseY);
  zoomLevel = map.getZoomLevel();
  map.setZoomRange(minZoomRange, maxZoomRange);
  map.setPanningRestriction(dublinLocation, maxPanningDistance);
  newLocation = map.getCenter();
  barScale.draw();

  if (mouseX > 160 || mouseY < 30 || mouseY > 580) {
    fill(0);
    text(location.getLat() + ", " + location.getLon(), mouseX, mouseY);
  }
  if (mouseX <= 160 && (mouseY >= 30 || mouseY <= 580)) {
    map.setZoomRange(zoomLevel, zoomLevel);
    map.setPanningRestriction(newLocation, 0);
  }

  // Population
  show_population();
  // Stops
  show_stops();
  // Lines
  show_lines();
  // Congestion
  show_congestion();

  // Show title
  textSize(20);
  fill(0);
  textAlign(CENTER);
  text("Dublin Bus Visualization", 500, 25);
  textSize(10);
}
