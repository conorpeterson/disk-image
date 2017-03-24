/**
 * Large Page. 
 * 
 * Saves one frame as a PDF with a size larger
 * than the screen. When PDF is used as the renderer
 * (the third parameter of size) the display window 
 * does not open. The file is saved to the sketch folder.
 * You can open it by "Sketch->Show Sketch Folder."
 */


import processing.pdf.*;
String loadfile = "/home/arden/Dropbox/projects/python/disk-image/disk_image_processing/output-1252236.txt";
byte[] bytes;
int tracknum = 80;
int bytespertrack = 500 * 18;
int trackRenderWidth = 1;

void setup() 
{

  size(800, 800);

  bytes = loadBytes(loadfile);
  println(bytespertrack);
  bytespertrack = bytes.length / tracknum;
  println(bytespertrack);
  beginRecord(PDF, fileDate());
}

String fileDate() {

  return year() + "-" + month() + 
    "-" + day() + "-" + hour() + 
    ":" + minute() + ":" + second() + 
    "-output.pdf";
}

float hueFromByte( byte byte_ ) {
  return map( byte_, -128, 127, 0.0, 360.0);
}

void draw() 
{

  background(0);
  colorMode(HSB);
  noFill();

  translate(width /2, height/2);

  println("rendering... this may take a while.");

  float roffset = (width - width/0.5) / tracknum;

  for (int t = 0; t < tracknum; t++) {

    println(t);

    // Draw a circle composed of vertexes,
    // (whose colors correlate to byte values)
    // for every track

    float segDist = t * roffset + width / 8;

    float prevx_ = segDist;
    float prevy_ = 0;

    //beginShape();

    for (int b = 0; b < bytespertrack; b++) {

      byte byte_ = bytes[t * b + b];
      //println(byte_);
      float angle = map(b, 0, bytespertrack, 0.0, 360.0);

      float x_ = segDist * cos(radians(angle));
      float y_ = segDist * sin(radians(angle));

      float hue_ = hueFromByte(byte_);
      stroke(hue_, 255, 255);
      //stroke(0);
      strokeWeight(10);
      line(prevx_, prevy_, x_, y_);
      prevx_ = x_;
      prevy_ = y_;
    }
    //println(w_ + " " + h_);
  }
  noLoop();
  println("done!");
  //exit();  // Quit the program
}