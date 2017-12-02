import processing.serial.*;

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

void setup(){
  printArray(Serial.list());
  String portName = "/dev/cu.usbserial-A700eI67";
  myPort = new Serial(this, portName, 9600);
  size(1000,800);
  screenX = 1000;
  screenY = 800;
  lastVals = new float[numVals];
}

void draw(){
  t++;
  
  clear();

  if(myPort.available() > 0){
    val = myPort.read();
    normVal = map(val, signalMax, signalMin, 0,1);
    println("norm: "+normVal);
    println("raw: "+val);
    
    lastVals[lastValIndex] = normVal;
    lastValIndex = (lastValIndex+1) % numVals;
  }
  rect(0,screenY, screenX,-screenY*valAvg());
}

float valAvg(){
  float avg = 0;
  for(int i=0; i<numVals; i++){
    float val = lastVals[i];
    avg += val;
  }
  return avg/numVals;
}