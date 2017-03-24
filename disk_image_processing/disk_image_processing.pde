import java.io.*;

PImage srcImage;
PImage offscreen;
int threshold = 60;

int bitsPerByte = 8;
int bytesPerSector = 512; //original information says 512 but this doesn't fit on disk?? or maybe it does??
int sectorsPerTrack = 18;
int tracksPerDisk = 80;

int step = 0;
int stepsMax = bitsPerByte * bytesPerSector * sectorsPerTrack;
float lineAngle = 0;
float trackHeight = 1; 

String bitChunk = "";
String[] tracks = new String[tracksPerDisk];
byte[] bytes = new byte[tracksPerDisk];
boolean scanning = false;
boolean scanComplete = false;

void setup() {

  //change this to reflect actual media dimensions,
  //which it turns out you will have to measure yourself. 
  size(600, 600);
  srcImage = loadImage("mementomori.jpg");

  lineAngle = 0;
  noSmooth();

  //Initialize array
  for (int x = 0; x < tracksPerDisk; x++) {
    tracks[x] = "";
  }
}

float radialX(int len, float angle) {
  return len * cos(radians(angle));
}

float radialY(int len, float angle) {
  return len * sin(radians(angle));
}

String fileDate() {

  return year() + "-" + month() + 
    "-" + day() + "-" + hour() + 
    ":" + minute() + ":" + second() + 
    "-output.img";
}

void draw() {
  noSmooth();
  //cheap-and-dirty bitmapping
  image(srcImage, 0, 0, width, height);
  loadPixels();
  for (int x = 0; x < pixels.length; x++) {
    if (brightness(pixels[x]) < threshold) {
      pixels[x] = color(0);
    } else {
      pixels[x] = color(255);
    }
  }
  updatePixels();

  if (scanning) {
    //get bits for all tracks intersecting line
    //loadPixels();

    //grab values of all 80 tracks per iteration      
    for (int i = 0; i < tracksPerDisk; i++) {
      
      //calculate length of segment
      int segment = int(i * trackHeight);
      
      //calculate location relative to 0,0
      float x = radialX(segment, lineAngle);
      float y = radialY(segment, lineAngle);
      
      //offset location relative to center
      x += width / 2;
      y += height / 2;
      
      //offset again by inner radius
      float innerRadius = width / 2 - tracksPerDisk * trackHeight;
      float offx = radialX(int(innerRadius), lineAngle);
      float offy = radialY(int(innerRadius), lineAngle);   
      x += offx;
      y += offy;
 
      //grab pixel at location, convert to bit
      color pixel = pixels[int(x) + int(y) * width];
      String bit = makeBit( pixel );
      //byte byte_ = makeByte( pixel );

      //helpful for debugging
      println(" i" + i + " x" + x + " y" + y + " r" + red(pixel) + " g" + green(pixel) + " b" + blue(pixel));

       //pack bits into track array
      tracks[i] = tracks[i] + bit;
      //tracks[i] = tracks[i] + byte_;
    }

    //iterate!!
    step+=1;
    lineAngle=map(step, 0, stepsMax, 0, 360);

    //visualize process
    pushMatrix();

    translate(width/2, height/2);
    rotate(radians(lineAngle));
    stroke(255, 0, 0);

    //A bunch of little lines to represent all the tracks
    for (int x = 0; x < tracksPerDisk; x++) {

      if (x %2 == 0) {
        stroke(255, 0, 0);
      } else {
        stroke(0, 0, 255);
      }
      float x1 = width/2 - x * trackHeight;
      float x2 = x1 - trackHeight;
      line(x1, 0, x2, 0);
    }
    popMatrix();

    println("step " + step + " of " + stepsMax + "\t" + lineAngle + "\t");

    //Commit bits to file
    if (step >= stepsMax) {
      scanning = false;
      scanComplete = true;
      println("Done scanning!");

      writeFile();
    }
  }

  //Draw image boundaries
  pushMatrix();
  ellipseMode(CENTER);
  noFill();
  colorMode(RGB);
  stroke(0, 255, 0);
  strokeWeight(1);
  translate(width/2, height/2);
  ellipse(0, 0, width-1, height-1);
  ellipse(0, 0, width-tracksPerDisk*2*trackHeight, height-tracksPerDisk*2*trackHeight);
  popMatrix();

  if (scanComplete) {
    ellipseMode(CORNER);
    fill(255, 0, 0);
    noStroke();
    ellipse(10, 10, 20, 20);
  }
}

String makeBit( color value ) {

  //println (value);

  if (red(value) == 255) {
    //white
    return "0";
  } else {
    return "1";
  }
}

byte makeByte( color value ) {
   if (red(value) == 255) {
    return (byte) Integer.parseInt("00000000", 2);
   }
   else {
     return (byte) Integer.parseInt("11111111", 2);
   }
}

void writeFile() {

  PrintWriter outfile;
  String fn = fileDate();
  outfile = createWriter(fn);

  //iterate bit array, chunk into bytes, write to disk.
  //possible that this is not working as intended.
  
  
  //iterate reverse over array since tracks[0] 
  //actually corresponds to disk track 80,
  //and disk track 0 is on the outside
  for (int i = tracksPerDisk - 1; i >= 0; i-- ) {
    String bitChunk = "";
    for (int j = 0; j < tracks[i].length(); j++) {          
      bitChunk = bitChunk + tracks[i].charAt(j);
      if (j % 8 == 0) {
        bitChunk += " "; //separate each byte with a space for easier processing
        outfile.write(bitChunk);
        bitChunk = "";
      }
    }
  }
  outfile.flush();
  outfile.close();
  println("Wrote file " + fn + " !!");
}

void keyPressed() {
  //if (!scanning) {
  //  if (key == CODED) {
  //    if (keyCode == UP) {
  //      threshold += 5;
  //    } else if (keyCode == DOWN) {
  //      threshold -= 5;
  //    } else if (keyCode == LEFT) {
  //      trackHeight+=0.05;
  //    } else if (keyCode == RIGHT) {
  //      trackHeight-=0.05;
  //    }
  //  } else {
  //    if (key == ' ') {
  //      scanning = true;
  //    }
  //  }
  //} else {
  //  if (key == ' ') {
  //    scanning = false;
  //  }
  //}



  if (key == CODED) {
    if (keyCode == UP) {
      threshold += 5;
    } else if (keyCode == DOWN) {
      threshold -= 5;
    } else if (keyCode == LEFT) {
      trackHeight+=0.05;
    } else if (keyCode == RIGHT) {
      trackHeight-=0.05;
    }
  } else {
    if (key == ' ') {
      scanning = true;
    }
  }
  if (scanComplete) {
    if (key =='f') {
      writeFile();
    }
  }
}