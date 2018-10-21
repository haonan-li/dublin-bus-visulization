// ------------------------------- Control panel --------------------------- //
void initCP5() {
  cp5 = new ControlP5(this);
  ControlFont cf = new ControlFont(createFont("Arial", panelFontSize));
  cp5.setFont(cf);
  cp5.setColorBackground(colorBg);

  // group 1: stops
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

  // group 2: lines
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

  // group 3: congestion
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

  // group 4: population
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

  // add groups to the accordion
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
  // Number keys to change the map providers
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