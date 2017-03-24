import java.io.*;

PImage srcImage;
int threshold = 60;
int imgOffX = 0;
int imgOffY = 0;
float imgScale = 1;
float innerRadius;

boolean saveLatch = false;

void setup() {
  size(600, 600);
  srcImage = loadImage("ds1.jpg");
  noSmooth();
  innerRadius = 0.5 * width / 3.5;
}

String fileDate() {

  return year() + "-" + month() + 
    "-" + day() + "-" + hour() + 
    ":" + minute() + ":" + second() + 
    "-output.jpg";
}

void draw() {
  noSmooth();
  //cheap-and-dirty bitmapping
  image(srcImage, imgOffX, imgOffY, srcImage.width*imgScale, srcImage.height*imgScale);
  loadPixels();
  for (int x = 0; x < pixels.length; x++) {
    if (brightness(pixels[x]) < threshold) {
      pixels[x] = color(0);
    } else {
      pixels[x] = color(255);
    }
  }
  updatePixels();

  //Draw disk dimensions
  if (!saveLatch) {
    pushMatrix();
    ellipseMode(CENTER);
    noFill();
    colorMode(RGB);
    stroke(0, 255, 0);
    strokeWeight(1);
    translate(width/2, height/2);
    ellipse(0, 0, width-1, height-1);

    float innerDiameter = int(0.5 * width / 3.5)*2;
    ellipse(0, 0, innerDiameter, innerDiameter); 
    popMatrix();
  } else {
    //Don't draw disk dimensions when saving 
    String fn = fileDate();
    save(fn);
    println("wrote " + fn);
    saveLatch = false;
  }
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      imgOffY -= 5;
    } else if (keyCode == DOWN) {
      imgOffY += 5;
    } else if (keyCode == LEFT) {
      imgOffX -= 5;
    } else if (keyCode == RIGHT) {
      imgOffX += 5;
    }
  } else {
    if (key == '[') {
      threshold -= 5;
    } else if (key == ']') {
      threshold += 5;
    } else if (key == ',') {
      imgScale -= 0.1;
    } else if (key == '.') {
      imgScale += 0.1;
    } else if (key =='f') {
      saveLatch = true;
    }
  }
}