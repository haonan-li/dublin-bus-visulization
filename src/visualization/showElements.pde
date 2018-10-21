// ------------------------------- Show elements --------------------------- //
public void show_stops() {
  isShowStops = cp5.getController("show_stops").getValue();
  if (isShowStops == 1.0) {
    stopIndex = int(cp5.getController("in_route:").getValue())-1;
    if (stopIndex == -1) {
      // Show all lines
      for (int i = 0; i < lineNum.size(); i++){
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
        for (int i = 0; i < lineNum.size(); i++){
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
      for (int i = 0; i < lineNum.size(); i++){
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
      for (int i = 0; i < lineNum.size(); i++){
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
        for (int i = 0; i < lineNum.size(); i++){
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
      for (int i = 0; i < lineNum.size(); i++){
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