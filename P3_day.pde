// you can change value here
int version = 2020;           // only 2019, 2020 is available
final int frame_rate = 3;     // animation frame rate
////////////////////////////////////////////////////////////

import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.core.*;
import de.fhpotsdam.unfolding.data.*;
import de.fhpotsdam.unfolding.events.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.interactions.*;
import de.fhpotsdam.unfolding.mapdisplay.*;
import de.fhpotsdam.unfolding.mapdisplay.shaders.*;
import de.fhpotsdam.unfolding.marker.*;
import de.fhpotsdam.unfolding.providers.*;
import de.fhpotsdam.unfolding.texture.*;
import de.fhpotsdam.unfolding.tiles.*;
import de.fhpotsdam.unfolding.ui.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.utils.*;

import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.core.*;
import de.fhpotsdam.unfolding.data.*;
import de.fhpotsdam.unfolding.events.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.interactions.*;
import de.fhpotsdam.unfolding.mapdisplay.*;
import de.fhpotsdam.unfolding.mapdisplay.shaders.*;
import de.fhpotsdam.unfolding.marker.*;
import de.fhpotsdam.unfolding.providers.*;
import de.fhpotsdam.unfolding.texture.*;
import de.fhpotsdam.unfolding.tiles.*;
import de.fhpotsdam.unfolding.ui.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.utils.*;
import de.fhpotsdam.unfolding.mapdisplay.OpenGLMapDisplay;
import de.fhpotsdam.unfolding.utils.ScreenPosition;

import processing.pdf.*;
import processing.svg.*;

import java.util.Map;
import java.util.*;

import processing.svg.*;

color main_color = #e3ebf8;
color dark_color = #8e9eb3;

HashMap<String, Location> pos_hash;
ArrayList<Table> subway_arr;
Table covid_tab;
Table day_2020;
Table day_2019;
UnfoldingMap map;

int timer;
boolean play;
int date_fin_idx;

final int name_idx = 0;
final int date_idx = 0;

PShape seoul;
PShape virus;

void setup() {
  // version setting
  date_fin_idx = 150 + (version - 2019);
  // canvas setup
  size(1000, 1000);

  // load svg
  seoul = loadShape("map.svg");
  virus = loadShape("virus.svg");

  // load day data
  day_2020 = loadTable("day_2020.csv", "header");
  day_2019 = loadTable("day_2019.csv", "header");

  // generate hash table for location
  Table pos_data = loadTable("all_pos_data.csv", "header");
  pos_hash = new HashMap<String, Location>();
  for (int i = 0; i < pos_data.getRowCount(); i++) {
    String pos_name = pos_data.getString(i, "pos");
    float lat = pos_data.getFloat(i, "latitude");
    float lng = pos_data.getFloat(i, "longitude");
    pos_hash.put(pos_name, new Location(lat, lng));
  }

  // subway csv data load, push_back to subway_arr
  subway_arr = new ArrayList<Table>();
  if (version == 2020) {
    subway_arr.add(loadTable("line1_1(2020).csv"));
    subway_arr.add(loadTable("line1_2(2020).csv"));
    subway_arr.add(loadTable("line2_1(2020).csv"));
    subway_arr.add(loadTable("line2_2(2020).csv"));
    subway_arr.add(loadTable("line2_3(2020).csv"));
    subway_arr.add(loadTable("line3(2020).csv"));
    subway_arr.add(loadTable("line4(2020).csv"));
    subway_arr.add(loadTable("line5_1(2020).csv"));
    subway_arr.add(loadTable("line5_2(2020).csv"));
    subway_arr.add(loadTable("line6(2020).csv"));
    subway_arr.add(loadTable("line7(2020).csv"));
    subway_arr.add(loadTable("line8(2020).csv"));
    subway_arr.add(loadTable("line9(2020).csv"));
  } else if (version == 2019) {
    subway_arr.add(loadTable("line1_1(2019).csv"));
    subway_arr.add(loadTable("line1_2(2019).csv"));
    subway_arr.add(loadTable("line2_1(2019).csv"));
    subway_arr.add(loadTable("line2_2(2019).csv"));
    subway_arr.add(loadTable("line2_3(2019).csv"));
    subway_arr.add(loadTable("line3(2019).csv"));
    subway_arr.add(loadTable("line4(2019).csv"));
    subway_arr.add(loadTable("line5_1(2019).csv"));
    subway_arr.add(loadTable("line5_2(2019).csv"));
    subway_arr.add(loadTable("line6(2019).csv"));
    subway_arr.add(loadTable("line7(2019).csv"));
    subway_arr.add(loadTable("line8(2019).csv"));
    subway_arr.add(loadTable("line9(2019).csv"));
  }

  // region covid data load
  covid_tab = loadTable("region_data.csv");

  // animation setup
  timer = 0;
  //timer = date_fin_idx * frame_rate;
  play = true;

  // map setup
  map = new UnfoldingMap(this);
  map.zoomAndPanTo(10, new Location(37.5642135f, 127.0016985f));
  map.setTweening(true);
}

ScreenPosition screen_pos(String pos_name) {
  return map.getScreenPosition(pos_hash.get(pos_name));
}

float log10(float x) {
  return (log(x)/log(10));
}

void drawBar(int t) {
  fill(255, 0, 0);
  noStroke();
  if (t/frame_rate != 0) {
    float confirmed = (float)covid_tab.getInt(1+t/frame_rate, covid_tab.getColumnCount()-1) - (float)covid_tab.getInt(t/frame_rate, covid_tab.getColumnCount()-1);
    float size = log10(confirmed)*70.0f;
    rectMode(CENTER);
    rect(width/2, 650, size, 5);
  }
}

void drawCovid(int t) {
  noStroke();
  for (int region = 1; region < covid_tab.getColumnCount()-1; region++) {
    ScreenPosition pos = screen_pos(covid_tab.getString(name_idx, region));
    float size = covid_tab.getInt(1+t/frame_rate, region)*1.2f;
    shapeMode(CENTER);
    virus.disableStyle();
    fill(255, 0, 0, 120);
    shape(virus, pos.x, pos.y, size, size);
  }
}

void drawLine(int t) {
  noStroke();
  for (int tmp = 0; tmp < subway_arr.size(); tmp++) {
    Table subway_line = subway_arr.get(tmp);
    for (int station = 1; station < subway_line.getColumnCount(); station++) {
      // println(subway_line.getString(name_idx, station));
      ScreenPosition pos = screen_pos(subway_line.getString(name_idx, station));
      float size = subway_line.getFloat(1+t/frame_rate, station)/5000.0f;
      if (station != 1) {
        ScreenPosition prev_pos = screen_pos(subway_line.getString(name_idx, station-1));
        stroke(dark_color);
        line(prev_pos.x, prev_pos.y, pos.x, pos.y);
      }
      fill(dark_color);
      noStroke();
      ellipse(pos.x, pos.y, size, size);
    }
  }
}

void showDate(int t) {
  textSize(32);
  fill(255);
  String date = "";
  String what_day = "";
  if (version == 2020) {
    date = day_2020.getString(t/frame_rate, 0);
    what_day = day_2020.getString(t/frame_rate, 1);
  } else if (version == 2019) {
    date = day_2019.getString(t/frame_rate, 0);
    what_day = day_2019.getString(t/frame_rate, 1);
  }
  text(date, 200, 300);
  text(what_day, 200, 350);
}

String output_name(int t) {
  if (version == 2020) {
    return "P3_" + day_2020.getString(t/frame_rate, 0) + ".svg";
  } else if (version == 2019) {
    return "P3_" + day_2019.getString(t/frame_rate, 0) + ".svg";
  } else return "NULL";
}

void mousePressed() {
  play = !play;
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if (!play && e == 1.0f) {
    if (timer >= date_fin_idx*frame_rate) {
      timer = 0;
    } else {
      timer += frame_rate;
    }
  } else if (!play && e == -1.0f) {
    if (timer <= 0) {
      timer = (date_fin_idx)*frame_rate;
    } else {
      timer -= frame_rate;
    }
  }
}

public void draw() {
  //beginRecord(SVG, output_name(timer));
  background(dark_color);

  seoul.disableStyle();
  noStroke();
  fill(main_color);
  shapeMode(CENTER);
  shape(seoul, 480, 500, 500, 500);
  drawLine(timer);
  if (version == 2020) {
    drawCovid(timer);
    drawBar(timer);
  }
  showDate(timer);

  //endRecord();
  // timer update (for animation)
  if (play) {
    if (timer >= date_fin_idx * frame_rate) {
      timer = 0;
    } else {
      timer ++;
    }
  }
}
