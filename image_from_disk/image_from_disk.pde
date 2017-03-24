import processing.pdf.*;
String filename = "test-image.img";
String loadfile = "/home/arden/Dropbox/projects/python/disk-image/disk_image_processing/" + filename;
byte[] bytes;
int tracksPerDisk = 80;
int bytesPerSector = 512;
int sectorsPerTrack = 18;
int bytesPerTrack = bytesPerSector * sectorsPerTrack;
int trackRenderWidth = 1;


int innerRadius = 100;
int trackWidth = 10;
int trackPadding = 5;

int highestbyte = 0;
int lowestbyte = 0;


void settings() {
  //width and height will be diameter of largest circle
  int boxSide = int(2 * bytesPerTrack / PI);
  size(boxSide, boxSide, PDF, fileDate());
}

void setup() 
{
  bytes = loadBytes(loadfile);
  bytesPerTrack = bytes.length / tracksPerDisk;
}

String fileDate() {

  return year() + "-" + month() + 
    "-" + day() + "-" + hour() + 
    ":" + minute() + ":" + second() + 
    "-output.pdf";
}

float hueFromByte( byte byte_ ) {

  Byte b = new Byte(byte_);
  
  if (b.intValue() < 0) {
    return 127;
  }
  else {
    return 0; 
  }
  
  //if (b.intValue() > highestbyte) {
  //   highestbyte = b.intValue();
  //} else if ( b.intValue() < lowestbyte ) {
  //   lowestbyte = b.intValue(); 
  //}
  
  //return map( b.intValue(), 0x0, 0xFF, 0, 180);
}

float weightFromByte( byte byte_, int max) {
 
  return map( new Byte(byte_).intValue(), 0x0, 0xFF, 1, max);
  
}

void dataCircle( byte[] bytes_, int w_, int trackheight) {
  //make a circle of bytes whose diameter is w_

  float trackRad = w_ / 2;

  float angle = 0;
  int bytecounter = 0;
  for (byte b : bytes_) {

    angle = map(bytecounter, 0, bytes_.length, 0, 360);

    float x = trackRad * cos(radians(angle));
    float y = trackRad * sin(radians(angle));

    float col = hueFromByte(b);
    stroke(col, 255, 255);

    float weight = weightFromByte(b, trackheight);
    //line(prevX, prevY, x, y);
    //strokeWeight(weight);

    point(x, y);

    bytecounter++;
  }
}

void draw() 
{

  background(0);
  colorMode(HSB);
  noFill();

  translate(width /2, height/2);

  println("rendering... this may take a while.");

  for (int t = 0; t < tracksPerDisk; t++) {

    println("track " + t);

    byte[] bytes_ = new byte[bytesPerTrack];
    System.arraycopy(bytes, t*bytesPerTrack, bytes_, 0, bytesPerTrack);

    int trackheight = width / 2 / tracksPerDisk;

    //circles decrease in size because track 0 is on outside
    dataCircle(bytes_, width - (t * trackheight), trackheight / 4);
  }
  noLoop();
  println("done!");
  println("highest: "+highestbyte);
  println("lowest: "+lowestbyte);
  exit();  // Quit the program
}