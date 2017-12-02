import processing.serial.*;
import java.util.*;

import processing.sound.*;
SinOsc sine;

Serial myPort;
int val;

int screenX;
int screenY;
int signalMin = 36;
int signalMax = 80;
int t = 0;
float normVal = 0.0;
float[] lastVals;
int numVals = 10;
int lastValIndex = 0;
String portName = "/dev/cu.usbserial-A700eI67";
boolean portFound = false;
boolean recording = false;

int particleSize = 20;

void setup(){
  ArrayList<String> ports = new ArrayList<String>(Arrays.asList(Serial.list()));
  if(ports.contains(portName)){
    portFound = true;
    myPort = new Serial(this, portName, 9600);
  }
  
  size(1000,800);
  screenX = 1000;
  screenY = 800;
  lastVals = new float[numVals];
  noStroke();
  blendMode(ADD);
}

void draw(){
  t++;
  
  clear();
  
  samplePort();
  pushMatrix();
  translate(screenX/2, screenY/2);
  
  for(int i=0; i<300*valAvg(); i++){
    pushMatrix();
    rotate(i*t*0.0005*valAvg());
    int x = i;
    int y = 0;
    fill(255,0,0);
    ellipse(x,y,particleSize,particleSize);
    rotate(1);
    fill(0,255,0);
    ellipse(x,y,particleSize,particleSize);
    rotate(1);
    fill(0,0,255);
    ellipse(x,y,particleSize,particleSize);
    popMatrix();
  }
  popMatrix();
  
  if(recording){
    saveFrame("output/phylo_####.png");
  }
}

void keyPressed(){
  if(key=='r'){
    recording = !recording;
  }
}

void fakeSamplePort(){
  lastVals[lastValIndex] = noise(t*0.01);
  lastValIndex = (lastValIndex+1) % numVals;
}

void samplePort(){
  if(portFound && myPort.available() > 0){
    val = myPort.read();
    normVal = map(val, signalMax, signalMin, 0,1);
    println("norm: "+normVal);
    println("raw: "+val);
    
    lastVals[lastValIndex] = normVal;
    lastValIndex = (lastValIndex+1) % numVals;
  }
  if(!portFound){
    fakeSamplePort();
  }
}

float valAvg(){
  float avg = 0;
  for(int i=0; i<numVals; i++){
    float val = lastVals[i];
    avg += val;
  }
  return avg/numVals;
}