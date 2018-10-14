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
import java.math.*;

import controlP5.*;


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
float maxPanningDistance;
Location newLocation;

int panelFontSize;
color colorBg, bgColor, outTextColor, inTextColor;
int bgHeight;

// Stops
float isShowStops, isLastShowStops;
HashMap<String, ArrayList <SimplePointMarker>> hmStops;

// Lines
int lineIndex, lineLastIndex;
float isShowLines, isLastShowLines;
HashMap<String, ArrayList <SimpleLinesMarker>> hmLines;

// Congestions
int intDay, intLastDay;
float isShowCongestion, isLastShowCongestion;
HashMap<String, ArrayList <SimplePointMarker>> hmCongestion;

// Data directory
String stopFile = "../../data/stops.csv";
String lineFile = "../../data/lines.csv";
String lineIDFile = "../../data/lineID.csv";
String congestionFile = "../../data/congestion.csv";

ArrayList<String> lineNum ;

void setup() {
  size(1000, 600, OPENGL);
  smooth();

  minZoomRange = 9;
  maxZoomRange = 17;
  maxPanningDistance = 50;

  panelFontSize = 10;
  colorBg = #2E5C6E;
  bgColor = 0x33A5DEE4;
  outTextColor = color(0);
  inTextColor = color(255);
  bgHeight = 170;

  initProvider();
  readLinesID(lineIDFile);
  readStops(stopFile);
  readLines(lineFile);
  readCongestions(congestionFile);
  mapSetting();
  initCP5();
  println ("Init done!!!!");
}


void draw() {
  map.draw();
  Location location = map.getLocation(mouseX, mouseY);
  zoomLevel = map.getZoomLevel();
  map.setZoomRange(minZoomRange, maxZoomRange);
  map.setPanningRestriction(dublinLocation, maxPanningDistance);
  newLocation = map.getCenter();

  if (mouseX > 160 || mouseY < 30 || mouseY > 580) {
    fill(0);
    text(location.getLat() + ", " + location.getLon(), mouseX, mouseY);
  }
  if (mouseX <= 160 && (mouseY >= 30 || mouseY <= 580)) {
    map.setZoomRange(zoomLevel, zoomLevel);
    map.setPanningRestriction(newLocation, 0);
  }

  // Congestion
  show_congestion();
  // Lines
  show_lines();
}


// Control panel
void initCP5() {
  cp5 = new ControlP5(this);
  ControlFont cf = new ControlFont(createFont("Arial", panelFontSize));
  cp5.setFont(cf);
  cp5.setColorBackground(colorBg);
//  cp5.setColorForeground(0xff660000);
  
  Group g1 = cp5.addGroup("stop")
    .setBackgroundColor(bgColor)
    .setBackgroundHeight(bgHeight)
    .setBarHeight(20)
//    .setColor(color(255))
    ;

  Toggle t1 = cp5.addToggle("show_stops")
    .setValue(0)
    .setPosition(10, 20)
    .setSize(20, 20)
    .setColorLabel(outTextColor)
    .moveTo(g1)
    ;

  Label l1 = t1.getCaptionLabel();
  l1.getStyle().marginLeft = 25;
  l1.getStyle().marginTop = -20;

  cp5.addScrollableList("in_route:")
    .setPosition(10, 50)
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
    .setPosition(10, 20)
    .setSize(20, 20)
    .setColorLabel(outTextColor)
    .moveTo(g2)
    ;

  Label l2 = t2.getCaptionLabel();
  l2.getStyle().marginLeft = 25;
  l2.getStyle().marginTop = -20;

  cp5.addScrollableList("show_route:")
    .setPosition(10, 50)
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
    .setBackgroundHeight(60)
    .setBarHeight(20)
    ;

  Toggle t3 = cp5.addToggle("show_congestion")
    .setValue(0)
    .setPosition(10, 20)
    .setSize(20, 20)
    .setColorLabel(outTextColor)
    .moveTo(g3)
    ;

  Label l3 = t3.getCaptionLabel();
  l3.getStyle().marginLeft = 25;
  l3.getStyle().marginTop = -20;

  cp5.addSlider("days")
    .setValue(0)
    .setPosition(10, 60)
    .setSize(95, 20)
    .setRange(1, 31)
    .setColorLabel(outTextColor)
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

// Set all map elements
void mapSetting() {
  // Basic Setting
  map = new UnfoldingMap(this, provider1);
  map.zoomToLevel(11);
  map.panTo(dublinLocation);
  map.setZoomRange(minZoomRange, maxZoomRange); // prevent zooming too far out
  map.setPanningRestriction(dublinLocation, maxPanningDistance);
  MapUtils.createDefaultEventDispatcher(this, map);

  // Stops
  for (String key : hmStops.keySet ()) {
    ArrayList<SimplePointMarker> value = new ArrayList<SimplePointMarker>();
    value = hmStops.get(key);
    for (SimplePointMarker marker : value) {
      map.addMarkers(marker);
    }
  }


  // // Lines
  // for (SimpleLinesMarker marker: lines) {
  //   map.addMarkers(marker);
  // }

  // Congestion points
  intDay = 1;
  intLastDay = 1;
  for (String day: hmCongestion.keySet()) {
    for (SimplePointMarker marker: hmCongestion.get(day)){
      marker.setHidden(true);
      map.addMarkers(marker);
    }
  }
  // Lines
  lineIndex = 1;
  lineLastIndex = 1;
  for (String lineID: hmLines.keySet()) {
    println (hmLines.get(lineID).size());
    for (SimpleLinesMarker marker: hmLines.get(lineID)){
      marker.setHidden(true);
      map.addMarkers(marker);
    }
  }

}

void initProvider() {
  provider1 = new OpenStreetMap.OpenStreetMapProvider();
  provider2 = new Google.GoogleMapProvider();
  provider3 = new Microsoft.RoadProvider();
  provider4 = new Microsoft.AerialProvider();
}

void readLinesID(String file) {
  String [] geoCoords = loadStrings(file);
  lineNum = new ArrayList<String>();
  for (String line: geoCoords) {
    lineNum.add(str(int(float(line.trim()))));
  }
  print (lineNum);
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
    if (geoCoord[1].equals(lastLine)) {
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
    splm.setColor(color(233, 57, 35));
    splm.setStrokeWeight(3);
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
  float ratio=0.9;
  for (String line: geoCoords) {
    String[] geoCoord = split(line.trim(), ",");
    loc = new Location(float(geoCoord[1]), float(geoCoord[0]));
    level=int(geoCoord[2]);
    day = geoCoord[3];
    spcm = new SimplePointMarker(loc);
    ///////////////////////////////////////////////////////
    // Modify this part ---------------------start---------
    spcm.setColor(color(153, 0, 13));
    spcm.setRadius(sqrt(level/100)*10*ratio);
    tint(255, 127);
    if (level<3000) {
      spcm.setColor(color(203, 24, 29));
      spcm.setRadius(sqrt(level/100)*10*ratio);
    }
    if (level<2000) {
      spcm.setColor(color(239, 59, 44));
    }
    if (level<1000) {
      spcm.setColor(color(251, 106, 74));
    }
    //-----------------------------------------end---------
    ///////////////////////////////////////////////////////
    spcm.setStrokeWeight(0);
    ArrayList <SimplePointMarker> tmp = hmCongestion.get(day);
    tmp.add(spcm);
    hmCongestion.put(day, tmp);
  }
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
  } else if (key =='6') {
  } else if (key =='4') {
  }
}
