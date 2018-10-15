/**
 *  Dublin bus line visualization
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

// --------------------------------- Varition -------------------------------- //
Location dublinLocation = new Location(53.33f, -6.35f);

// Control panel
ControlP5 cp5;
Accordion accordion;
int days;
int panelFontSize;

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
Location newLocation;
int bgHeight;
color colorBg, bgColor, outTextColor, inTextColor;

// Stops
int stopIndex, stopLastIndex;
float isShowStops, isLastShowStops;
HashMap<String, ArrayList <SimplePointMarker>> hmStops;

// Lines
int lineIndex, lineLastIndex;
float isShowLines, isLastShowLines;
ArrayList<String> lineNum ;
HashMap<String, ArrayList <SimpleLinesMarker>> hmLines;

// Congestions
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

  minZoomRange = 9;
  maxZoomRange = 17;
  maxPanningDistance = 50;

  panelFontSize = 10;
  colorBg = #2E5C6E;
  bgColor = 0x7fA5DEE4;
  outTextColor = color(0);
  inTextColor = color(255);
  bgHeight = 160;

  initProvider();
  readShape(districtFile);
  readPopulation(populationFile);
  readLinesID(lineIDFile);
  readStops(stopFile);
  readLines(lineFile);
  readCongestions(congestionFile);
  mapSetting();
  initCP5();
  println ("Init done!!!!");
}


// ---------------------------------- Drow --------------------------------- //
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

  // Lines
  show_lines();
  // Stops
  show_stops();
  // Congestion
  show_congestion();
  // Population
  show_population();
  
  // Show title
  textSize(20);
  fill(0);
  textAlign(CENTER);
  text("Dublin bus visualization",500,25);
  textSize(10);
}

// ------------------------------- Control panel --------------------------- //
void initCP5() {
  cp5 = new ControlP5(this);
  ControlFont cf = new ControlFont(createFont("Arial", panelFontSize));
  cp5.setFont(cf);
  cp5.setColorBackground(colorBg);
  
  Group g1 = cp5.addGroup("stop")
    .setBackgroundColor(bgColor)
    .setBackgroundHeight(bgHeight)
    .setBarHeight(20)
    ;

  Toggle t1 = cp5.addToggle("show_stops")
    .setValue(0)
    .setPosition(10, 10)
    .setSize(20, 20)
    .setColorLabel(outTextColor)
    .moveTo(g1)
    ;

  Label l1 = t1.getCaptionLabel();
  l1.getStyle().marginLeft = 25;
  l1.getStyle().marginTop = -20;

  cp5.addScrollableList("in_route:")
    .setPosition(10, 40)
    .setSize(130, 110)
    .setBarHeight(20)
    .setItemHeight(20)
    .addItem("All",0)
    .addItems(lineNum)
    .setColorLabel(inTextColor)
    .moveTo(g1)
    ;

  Group g2 = cp5.addGroup("route")
    .setBackgroundColor(bgColor)
    .setBackgroundHeight(bgHeight)
    .setBarHeight(20)
    ;

  Toggle t2 = cp5.addToggle("show_routes")
    .setValue(0)
    .setPosition(10, 10)
    .setSize(20, 20)
    .setColorLabel(outTextColor)
    .moveTo(g2)
    ;

  Label l2 = t2.getCaptionLabel();
  l2.getStyle().marginLeft = 25;
  l2.getStyle().marginTop = -20;

  cp5.addScrollableList("show_route:")
    .setPosition(10, 40)
    .setSize(130, 110)
    .setBarHeight(20)
    .setItemHeight(20)
    .addItem("All",0)
    .addItems(lineNum)
    .setColorLabel(inTextColor)
    .moveTo(g2)
    ;

  Group g3 = cp5.addGroup("congestion")
    .setBackgroundColor(bgColor)
    .setBackgroundHeight(40)
    .setBarHeight(20)
    ;

  Toggle t3 = cp5.addToggle("show_congestion")
    .setValue(0)
    .setPosition(10, 10)
    .setSize(20, 20)
    .setColorLabel(outTextColor)
    .moveTo(g3)
    ;

  Label l3 = t3.getCaptionLabel();
  l3.getStyle().marginLeft = 25;
  l3.getStyle().marginTop = -20;

  cp5.addSlider("days")
    .setValue(1)
    .setPosition(10, 40)
    .setSize(95, 20)
    .setRange(1, 31)
    .setColorLabel(outTextColor)
    .setSliderMode(Slider.FLEXIBLE)
    .moveTo(g3)
    ;

  Group g4 = cp5.addGroup("population")
    .setBackgroundColor(bgColor)
    .setBackgroundHeight(40)
    .setBarHeight(20)
    ;

  Toggle t4 = cp5.addToggle("show_population")
    .setValue(0)
    .setPosition(10, 10)
    .setSize(20, 20)
    .setColorLabel(outTextColor)
    .moveTo(g4)
    ;

  Label l4 = t4.getCaptionLabel();
  l4.getStyle().marginLeft = 25;
  l4.getStyle().marginTop = -20;

  accordion = cp5.addAccordion("acc")
    .setPosition(10, 30)
    .setWidth(150)
    .addItem(g1)
    .addItem(g2)
    .addItem(g3)
    .addItem(g4)
    ;

  accordion.open(0, 1, 2, 3);

  accordion.setCollapseMode(Accordion.MULTI);  
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
  }
}


// ------------------------------- Show elements --------------------------- //
public void show_stops() {
  isShowStops = cp5.getController("show_stops").getValue();
  if (isShowStops == 1.0) {
    stopIndex = int(cp5.getController("in_route:").getValue())-1;
    if (stopIndex == -1) {
      // Show all lines
      for (int i=0; i<lineNum.size(); i++){
        for (SimplePointMarker marker : hmStops.get(lineNum.get(i))){
          marker.setHidden(false);
        }
      }
    } else {
      if (stopLastIndex != -1) {
        // Hide last shown 
        for (SimplePointMarker marker : hmStops.get(lineNum.get(stopLastIndex))){
          marker.setHidden(true);
          }
      } else {
        // If last show is all, hidden all
        for (int i=0; i<lineNum.size(); i++){
          for (SimplePointMarker marker : hmStops.get(lineNum.get(i))){
            marker.setHidden(true);
          }
        }
      }
      // Show current line
      for (SimplePointMarker marker : hmStops.get(lineNum.get(stopIndex))){
        marker.setHidden(false);
        }
      }
      stopLastIndex = stopIndex;
      isLastShowStops = isShowStops;
    } else if (isLastShowStops == 1.0){
      // Hide all 
      for (int i=0; i<lineNum.size(); i++){
        for (SimplePointMarker marker : hmStops.get(lineNum.get(i))){
          marker.setHidden(true);
        }
      }
      isLastShowStops = 0.0;
  }
}


public void show_lines() {
  isShowLines = cp5.getController("show_routes").getValue();
  if (isShowLines == 1.0) {
    lineIndex = int(cp5.getController("show_route:").getValue())-1;
    if (lineIndex == -1) {
      // Show all lines
      for (int i=0; i<lineNum.size(); i++){
        for (SimpleLinesMarker marker : hmLines.get(lineNum.get(i))){
          marker.setHidden(false);
        }
      }
    } else {
      if (lineLastIndex != -1) {
        // Hide last shown 
        for (SimpleLinesMarker marker : hmLines.get(lineNum.get(lineLastIndex))){
          marker.setHidden(true);
          }
      } else {
        // If last show is all, hidden all
        for (int i=0; i<lineNum.size(); i++){
          for (SimpleLinesMarker marker : hmLines.get(lineNum.get(i))){
            marker.setHidden(true);
          }
        }
      }
      // Show current line
      for (SimpleLinesMarker marker : hmLines.get(lineNum.get(lineIndex))){
        marker.setHidden(false);
        }
      }
      lineLastIndex = lineIndex;
      isLastShowLines = isShowLines;
    } else if (isLastShowLines == 1.0){
      // Hide all 
      for (int i=0; i<lineNum.size(); i++){
        for (SimpleLinesMarker marker : hmLines.get(lineNum.get(i))){
          marker.setHidden(true);
        }
      }
      isLastShowLines = 0.0;
  }
}

public void show_congestion() {
  isShowCongestion = cp5.getController("show_congestion").getValue();
  if (isShowCongestion == 1.0) {
    // First hide last show, then show current
    intDay = Math.round(cp5.getController("days").getValue());
    for (SimplePointMarker marker : hmCongestion.get (str (intLastDay))) {
      marker.setHidden(true);
    }
    for (SimplePointMarker marker : hmCongestion.get (str (intDay))) {
      marker.setHidden(false);
    }
    intLastDay = intDay;
    isLastShowCongestion = isShowCongestion;
  } else if (isLastShowCongestion == 1.0) {
    for (SimplePointMarker marker: hmCongestion.get(str(intLastDay))){
      marker.setHidden(true);
    }
    isLastShowCongestion = 0.0;
  }
}

public void show_population() {
  isShowPopulation = cp5.getController("show_population").getValue();
  if (isShowPopulation == 1.0) {
    for (Marker marker : countyMarkers) {
      marker.setHidden(false);
    }
    isLastShowPopulation = isShowPopulation;
  } else if (isLastShowPopulation == 1.0){
    for (Marker marker : countyMarkers) {
      marker.setHidden(true);
    }
    isLastShowPopulation = 0.0;
  }
}

// ---------------------------- Init Map setting ------------------------- //
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
    marker.setColor(color(50, popuLevel, 999, 100));
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

void initProvider() {
  provider1 = new OpenStreetMap.OpenStreetMapProvider();
  provider2 = new Google.GoogleMapProvider();
  provider3 = new Microsoft.RoadProvider();
  provider4 = new Microsoft.AerialProvider();
}

// ------------------------------- Read elements --------------------------- //
void readLinesID(String file) {
  String [] geoCoords = loadStrings(file);
  lineNum = new ArrayList<String>();
  ArrayList<Integer> tmp = new ArrayList<Integer>();
  for (String line: geoCoords) {
    tmp.add(int(float(line.trim())));
  }
  Collections.sort(tmp);
  for(int i=0; i<tmp.size(); i++) {
    lineNum.add(str(tmp.get(i)));
  }
}

void readShape(String file) {
  district = GeoJSONReader.loadData(this, file);
  countyMarkers = MapUtils.createSimpleMarkers(district);
}

void readPopulation(String file) {
  String [] geoCoords = loadStrings(file);
  hmPopulation = new HashMap<String, Float>();
  for (String line : geoCoords) {
    String[] geoCoord = split(line.trim(), ",");
    hmPopulation.put(geoCoord[0],float(geoCoord[1]));
  }
}

void readStops(String file) {
  //Load String data
  String[] geoCoords = loadStrings(file);
  //Hash Map: key is line id and value is an Arraylist of location's SimplePointMarker
  hmStops = new HashMap<String, ArrayList <SimplePointMarker>>();
  Location loc;
  SimplePointMarker spm;
  for (int i=0; i<lineNum.size(); i++) {
    ArrayList<SimplePointMarker> oneLine = new ArrayList<SimplePointMarker>();
    hmStops.put(lineNum.get(i),oneLine);
  }
  //Visit each row
  for (String line : geoCoords) {
    String[] geoCoord = split(line.trim(), ",");
    String lineID = str(int(geoCoord[1]));
    loc = new Location(float(geoCoord[3]), float(geoCoord[2]));
    spm = new SimplePointMarker(loc);
    spm.setStrokeWeight(0);
    spm.setColor(color(255, 120, 0, 150));
    spm.setRadius(5);
    ArrayList<SimplePointMarker> tmp = hmStops.get(lineID);
    tmp.add(spm);
    hmStops.put(lineID, tmp);
  }
}

// Read lines from route file
void readLines(String file) {
  String[] geoLines = loadStrings(file);
  hmLines = new HashMap<String, ArrayList <SimpleLinesMarker>>();
  for (int i=0; i<lineNum.size(); i++) {
    ArrayList<SimpleLinesMarker> oneLine = new ArrayList<SimpleLinesMarker>();
    hmLines.put(lineNum.get(i),oneLine);
  };
  Location sLoc, eLoc;
  SimpleLinesMarker splm;
  String lineID;
  for (String line: geoLines) {
    String[] geoLine = split(line.trim(),",");
    lineID = str(int(float(geoLine[0])));
    sLoc = new Location(float(geoLine[2]),float(geoLine[1]));
    eLoc = new Location(float(geoLine[4]),float(geoLine[3]));
    splm = new SimpleLinesMarker(sLoc,eLoc);
    splm.setColor(color(108, 104, 248, 180));
    splm.setStrokeWeight(2);
    ArrayList <SimpleLinesMarker> tmp = hmLines.get(lineID);
    tmp.add(splm);
    hmLines.put(lineID,tmp);
  }
}

// Read congestion points from congestion file
void readCongestions(String file) {
  String[] geoCoords = loadStrings(file);
  hmCongestion = new HashMap<String, ArrayList<SimplePointMarker>>();
  for (int i=0; i<32; i++) {
    ArrayList <SimplePointMarker> oneDayCong = new ArrayList<SimplePointMarker>();
    hmCongestion.put(Integer.toString(i), oneDayCong);
  }
  Location loc;
  int level;
  String day;
  SimplePointMarker spcm;
  float ratio=1.2;
  for (String line: geoCoords) {
    String[] geoCoord = split(line.trim(), ",");
    loc = new Location(float(geoCoord[1]), float(geoCoord[0]));
    level=int(geoCoord[2]);
    day = geoCoord[3];
    spcm = new SimplePointMarker(loc);
    spcm.setRadius(sqrt(level/100)*10*ratio);
    colorMode(HSB);
    spcm.setColor(color(5,level/4+40,240,180));
    //assign color to markers based on congestion level;
    colorMode(RGB);
    spcm.setStrokeWeight(0);
    ArrayList <SimplePointMarker> tmp = hmCongestion.get(day);
    tmp.add(spcm);
    hmCongestion.put(day, tmp);
  }
}

