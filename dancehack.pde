import processing.serial.*;
import processing.sound.*;
import ddf.minim.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;
import java.util.*;

// declare everything we need to play our file
Minim minim;
FilePlayer filePlayer;
AudioOutput out;
TickRate rateControl;


SoundFile soundFile;

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

int numOsc = 2;
int baseFreq = 300;
ArrayList<SinOsc> oscList1 = new ArrayList<SinOsc>();
ArrayList<SinOsc> oscList2 = new ArrayList<SinOsc>();

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
  
  
  for(int i=0; i<numOsc; i++){
    SinOsc osc = new SinOsc(this); 
    osc.freq(baseFreq+(i*100));
    //osc.play();
    oscList1.add(osc);
  }
  
  for(int i=0; i<numOsc; i++){
    SinOsc osc = new SinOsc(this); 
    osc.freq(200+(i*200));
    //osc.play();
    oscList2.add(osc);
  }
  
  
  
  // create our Minim object for loading audio
  minim = new Minim(this);
        
  // this creates a TickRate UGen with the default playback speed of 1.
  // ie, it will sound as if the file is patched directly to the output
  rateControl = new TickRate(1.f);
  rateControl.setInterpolation( true );
                                                  
  // a FilePlayer reads from an AudioRecordingStream, which we 
  // can easily get from Minim using loadFileStream
  filePlayer = new FilePlayer( minim.loadFileStream("drumLoop.wav") );
  // and then we'll tell the file player to loop indefinitely
  filePlayer.loop();
  
  // get a line out from Minim. It's important that the file is the same audio format 
  // as our output (i.e. same sample rate, number of channels, etc).
  out = minim.getLineOut();
  
  // patch the file player to the output
  filePlayer.patch(rateControl).patch(out);
   
}

void draw(){
  t++;
  clear();
  
  samplePort();
  
  float avg = valAvg();
  float osc1 = map(sin(t*0.1), -1,1, 0,400*avg);
  
  rateControl.value.setLastValue(1+avg);
  
  for(int i=1; i< numOsc; i++){
    SinOsc s = oscList1.get(i);
    s.freq((baseFreq+i*avg*20));
  }
  
  pushMatrix();
  translate(screenX/2, screenY/2);
  
  for(int i=0; i<300*valAvg(); i++){
    pushMatrix();
    rotate(i*t*0.00005);
    int x = i;
    int y = 0;
    fill(255);
    ellipse(x,y,particleSize,particleSize);
    rotate(1);
    fill(0,255,0);
    //ellipse(x,y,particleSize,particleSize);
    rotate(1);
    fill(0,0,255);
    //ellipse(x,y,particleSize,particleSize);
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