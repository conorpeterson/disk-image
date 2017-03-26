import processing.pdf.*;

String filename = "disk-image.img";
String loadfile = "/home/arden/Dropbox/projects/python/disk-image/" + filename;
byte[] bytes;
int tracksPerDisk = 80;
int bytesPerSector = 512;
int sectorsPerTrack = 18;
int bytesPerTrack = bytesPerSector * sectorsPerTrack;
int trackRenderWidth = 1;
int pdfPadding = 200;

//inner radius of 3.5in disk is 0.5in
int innerRadius = 100;
int lowScore = 0;
int highScore = 0;


void settings() {
  //width and height will be diameter of largest circle
  int boxSide = int(2 * bytesPerTrack / PI);

  //inner radius of 3.5in disk is 0.5in
  innerRadius = int(0.5 * boxSide / 3.5)*2;
  size(boxSide, boxSide, PDF, fileDate());
}

void setup() 
{
  bytes = loadBytes(loadfile);
  //get scale of data so we can have pretty colors 
  for (byte b : bytes) {
    score(b);
  }
}

void score( byte byte_) {
  Byte b = new Byte(byte_);
  if (b.intValue() < lowScore) {
    lowScore = b.intValue();
  } else if (b.intValue() > highScore) {
    highScore = b.intValue();
  }
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
  } else {
    return 0;
  }
}

float hueFromByteGrad( byte byte_ ) {
  Byte b = new Byte(byte_);
  return map(b.intValue(), lowScore, highScore, 0, 270);
}

float weightFromByte( byte byte_, int weight) {

  Byte b = new Byte(byte_);

  if (b.intValue() < 0) {
    return weight;
  } else {
    return 1;
  }
}

void dataCircle( byte[] bytes_, int w_, int trackheight) {
  //make a circle of bytes whose diameter is w_

  float trackRad = w_ / 2;
  float angle = 0;
  int bytecounter = 0;
  for (byte b : bytes_) {

    score(b);

    angle = map(bytecounter, 0, bytes_.length, 0, 360);

    float x = trackRad * cos(radians(angle));
    float y = trackRad * sin(radians(angle));

    float col = hueFromByteGrad(b);
    stroke(col, 255, 255);

    float weight = weightFromByte(b, trackheight);
    strokeWeight(weight);

    point(x, y);

    bytecounter++;
  }
}

void draw() 
{

  translate(width /2, height/2);
  println("rendering... this may take a while.");

  background(0);
  colorMode(HSB);
  noFill();

  int trackOffset = 80;

  for (int t = 0; t < tracksPerDisk; t++) {

    int t_off_ = trackOffset + t;
    int b_off_ = t_off_ * bytesPerTrack;
    println(b_off_);
    println("track " + t_off_);

    byte[] bytes_ = new byte[bytesPerTrack];
    System.arraycopy(bytes, b_off_, bytes_, 0, bytesPerTrack);

    int maxWidth = width - pdfPadding;
    int minWidth = innerRadius;
    int trackWidth = (int)map(t, 0, tracksPerDisk, maxWidth, minWidth);
    int trackHeight = minWidth / tracksPerDisk;

    println("width " + trackWidth + ", height " + trackHeight);

    //circles decrease in size because track 0 is on outside
    dataCircle(bytes_, trackWidth, trackHeight);
  }

  noLoop();
  println("done!");
  println("low:" + lowScore + " hi:" + highScore);
  exit();  // Quit the program
}