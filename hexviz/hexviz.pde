String filename = "../disk_image_processing/2017-3-23-14:49:2-output.img";
byte[] bytes;
int offset = 0;
int stepsize = 1; 

void setup() {
  size(800, 800);
  bytes = loadBytes(filename);
}

void draw() {

  colorMode(RGB);
  background(51);

  colorMode(HSB);

  loadPixels();

  for (int x = 0; x < width; x++ ) {
    for (int y = 0; y < height; y++ ) {
      if ( (x + y * width) + (offset * stepsize) < bytes.length) {
        pixels[x + y * width] = color( hueFromByte( bytes[(x + y * width) + (offset * stepsize)]), 255, 255);
      } else {
        pixels[x + y * width] = color(51, 51, 51);
      }
    }
  }

  updatePixels();
}

float hueFromByte( byte byte_ ) {

  return map( byte_, -128, 127, 0.0, 180.0);
}


void keyPressed() {

  if (key == CODED) {
    if (keyCode == UP) {
      offset -= stepsize; 
      if (offset < 0 ) {
        offset = 0;
      }
      println("up. " + offset);
    } else if (keyCode == DOWN) {
      offset += stepsize;
      println("down. " + offset);
    } else if (keyCode == LEFT) {
      stepsize -= 1;
      if (stepsize < 1) {
        stepsize = 1;
      }
      println("left. " + stepsize);
    } else if (keyCode == RIGHT) {
      stepsize += 1;
      println("right " + stepsize);
    }
  }
}