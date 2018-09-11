import org.gicentre.utils.spatial.*;    // For map projections.
 
ArrayList<PVector>coords;    // Projected GPS coordinates.
PImage backgroundMap;        // OpenStreetMap.
PVector tlCorner,brCorner;   // Map corners in WebMercator coordinates.

final color MINCOL=color(255, 10, 10);
final color MAXCOL=color(10, 10, 255);
 
void setup()
{
  size(1000,600);
  background(202, 226, 245);
  fill(1);
  noLoop();
  readData();
}
 
void draw()
{
  // Background map.
  //image(backgroundMap,0,0,width,height);
  
  // Projected GPS coordinates
  noFill();
  stroke(150,50,50,150);
  strokeWeight(6);
   
  beginShape(POINTS);
  int i=0;
  for (PVector coord : coords)
  { 

    PVector scrCoord = geoToScreen(coord);
    vertex(scrCoord.x,scrCoord.y);  
  }

  endShape();
}
 
void readData()
{
  // Read the GPS data and background map.
  String[] geoCoords = loadStrings("../dublin_data/congestion.csv");

  // backgroundMap = loadImage("background.png");
   
  WebMercator proj = new WebMercator();
   
  // Convert the GPS coordinates from lat/long to WebMercator
  coords = new ArrayList<PVector>();  
  for (String line: geoCoords)
  {
    String[] geoCoord = split(line.trim(),",");
    float lng = float(geoCoord[1]);
    float lat = float(geoCoord[2]);
    coords.add(proj.transformCoords(new PVector(lng,lat)));
  } 

   
  // Store the WebMercator coordinates of the corner of the map.
  // The lat/long of the corners was provided by OpenStreetMap
  // when exporting the map tile.
  tlCorner = proj.transformCoords(new PVector(-6.00,53.00));
  brCorner = proj.transformCoords(new PVector(-6.70,53.70));
}
 
// Convert from WebMercator coordinates to screen coordinates.
PVector geoToScreen(PVector geo)
{
  return new PVector(map(geo.x,tlCorner.x,brCorner.x,0,width),
                     map(geo.y,tlCorner.y,brCorner.y,0,height));
}