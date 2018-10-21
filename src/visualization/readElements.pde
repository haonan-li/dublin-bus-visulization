// ------------------------------- Read Elements --------------------------- //
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
  // Visit each row
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


// Read lines from the route file
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


void readPopulation(String file) {
  String [] geoCoords = loadStrings(file);
  hmPopulation = new HashMap<String, Float>();
  for (String line : geoCoords) {
    String[] geoCoord = split(line.trim(), ",");
    hmPopulation.put(geoCoord[0],float(geoCoord[1]));
  }
}


// Read congestion points from congestion file
void readCongestion(String file) {
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