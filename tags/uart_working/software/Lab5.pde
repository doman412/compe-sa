import processing.serial.*;

import controlP5.*;




PFont font;
Serial myPort;

int portCount = -1;
int totalPorts = 0;
int graphTop = 200;
int graphBottom = 575;
int baudRate = 9600;
int x=1,y=graphBottom-20;
int sampleNumber;
int systemMode;

static final int MODE_RT = 1;
static final int MODE_NRT = 2;

char iSignalOk;

ArrayList yvals;

String connectionStatus;
String mode = "Real-Time";
String systemStatus = "Waiting...";
String samplingRate = "9600";

boolean connected = false;


ControlP5 controlP5;
RadioButton serialRadio;
DropdownList freqList;
Button goButton;
Button realTimeButton;
Button nonRealTimeButton;
Textfield sampleField;


void setup(){
  size(700,450);
  smooth();
  controlP5 = new ControlP5(this);
  font = loadFont("Dialog48.vlw");
  textFont(font);
  yvals = new ArrayList();
  graphBottom = height-25;
  
  connectionStatus = "Not Connected";
  
  serialRadio = controlP5.addRadioButton("serialPorts", 2, 15);
  serialRadio.setColorForeground(color(0));
  serialRadio.setColorActive(color(255,255,0));
  serialRadio.setColorLabel(color(255));
  serialRadio.setSpacingColumn(50);
  
  // add the go button
  goButton = controlP5.addButton("goButton", 0, width-199, 110, 75, 35);
  goButton.setLabel("Go");
  
  // add the real time button
  realTimeButton = controlP5.addButton("realTimeButton", 1, 199, 35, 75, 35);
  realTimeButton.setLabel("Real-Time");
  
   // add the non-real time button
  realTimeButton = controlP5.addButton("nonRealTimeButton", 2, 199+75+5, 35, 75, 35);
  realTimeButton.setLabel("Non Real-Time");
  
  // add text field for number of samples
  sampleField = controlP5.addTextfield("sampleField", 199, 110, 150, 35);
    
  // add the freq list
  freqList = controlP5.addDropdownList("freqList", width-199, 61, 120, 50);
  //freqList.setItemHeight(25);
  freqList.setBarHeight(25);
  freqList.captionLabel().set("Select A Frequency");
  freqList.captionLabel().style().marginTop = 5;
  freqList.valueLabel().style().marginTop = 5;
  freqList.setColorBackground(color(142, 142, 142));
  freqList.setColorActive(color(0,0,255,128));
  freqList.addItem("9600",0);
  
  
  // check for updates to the serial ports and add them to the radio list
  updateSerialPorts();
}

void draw(){
  //updateSerialPorts();
  background(color(255,255,255));
  
  // display the connection status
  if(connectionStatus == "Not Connected")
    fill(255, 0, 0);
  else
    fill(0, 255, 0);
  textFont(font,25);
  text(connectionStatus, 2, height-2);
  // disp text for ports
  fill(0,0,0);
  textFont(font,12);
  text("Available Ports:", 2, 12);
  // disp text for mode
  fill(0,0,0);
  textFont(font,25);
  text(mode, 200, height-2);
  // disp text for system Status
  fill(0, 0, 0);
  textFont(font,25);
  text(systemStatus, width-200, height-2);
  // disp sampling rate
  fill(64,91,255);
  textFont(font,25);
  text(baudRate, width-300, height-2);
  // disp number of samples
  fill(0, 0, 0);
  textFont(font,25);
  text("Number of Samples: "+sampleNumber, 199,graphTop-100);
  
  
  
  // draw a line at bottom
  stroke(0,0,0);
  line(0, graphBottom, width, graphBottom);
  // draw line for graph area
  stroke(0,0,0);
  line(0, graphTop, width, graphTop);
  // line for upper separation;
  line(175, 0, 175, graphTop);
  
  // pixle
  for(int i=0; i<yvals.size(); i++){
    set(i,(Integer)yvals.get(i),color(255,0,0));
  }
  
  
  // look for data
//  if(connected){
//    if(myPort.available()>0){
//      println("serial data: " + (char)myPort.read());
//    }
//  }

}


void updateSerialPorts(){
  if(Serial.list().length > 0){
    
    // check if the current list is the same as previously
    if(Serial.list().length != totalPorts){      
      
      for(int i=0; i<Serial.list().length; i++){
        String disp = Serial.list()[i];
        
        // following lines for my Mac only, doesn't harm Win.
        int mid = disp.indexOf("cu");
        if(mid != -1){
          portCount++;
          //serialRadio.setItemsPerRow(portCount);
          continue;
        }
        mid = disp.indexOf(".");
        if(mid != -1)
          disp = disp.substring(mid+1); 
        else
          portCount++;  
        // end Mac code
        
        
        addToRadioButton(serialRadio, disp, i);
      }
    }
  } else {
    println("No Connection!");
  }
}

void addToRadioButton(RadioButton theRadioButton, String theName, int theValue ) {
  //theRadioButton.setSpacingColumn(theName.length()*2);
  Toggle t = theRadioButton.addItem(theName,theValue);
  
  t.captionLabel().setColorBackground(color(80));
  t.captionLabel().style().movePadding(2,0,-1,2);
  t.captionLabel().style().moveMargin(-2,0,0,-3);
  t.captionLabel().style().backgroundWidth = theName.length()*5;
}

void controlEvent(ControlEvent e){
  println("event from " + e.group().name());
  if(e.group().name() == "serialPorts"){
    myPort = new Serial(this, Serial.list()[ ((int)e.group().value())], baudRate);
    println("connect to " + Serial.list()[ ((int)e.group().value())]);
    connectionStatus = "Connected";
    connected = true;
  }
  
}

public void goButton(int theValue){
  println("the go button was pressed ");
  if(!connected) {
    println("cannont go without connection");
  } else {
    // method for activation.
  }
}

public void realTimeButton(int theValue){
  systemMode = MODE_RT;
  mode = "Real-Time";
  println("real time");
}

public void nonRealTimeButton(int theValue){
  systemMode = MODE_NRT;
  mode = "Non Real-Time";
  println("non real time");
}

public void serialEvent(Serial port){
  int inInt = port.read();
  char inByte = (char)inInt;
  println("serial data: " + inInt); 
  float tempY; 
  
  tempY = map(inInt, 0, 255, graphBottom-20, graphBottom-275);
  y = (int)tempY;
  x++;
  if(x>width-2){
    x = 0;
  }
  yvals.add(new Integer(y));
  
  
  //println("sending back: " + inByte);
  //port.write(inByte);
}

public void sampleField(String samples){
  sampleNumber = int(samples);
  println("text entered into the field: " + sampleNumber);
  
}

