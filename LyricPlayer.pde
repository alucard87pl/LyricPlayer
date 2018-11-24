import controlP5.*;
import java.util.concurrent.TimeUnit ;
import jorgecardoso.processing.id3.*;
import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;
AudioPlayer player;
FFT fft;
int volume = 50;

ControlP5 cp5;
    Button pp;
    Button st;
    Button ld;
    Knob vl;
    Slider pb;


File f;

PFont NexaL;
PFont NexaLS;
PFont NexaB;

String song = "TESTSONGTITLE";
String artist = "TESTARTISTNAME";

ID3 id3;
void setup() {
    size(1280, 720);
    smooth(2);
    NexaL = createFont("NexaL.ttf", 45);
    NexaB = createFont("NexaB.ttf", 50);
    NexaLS = createFont("NexaL.ttf", 16);
    id3 = new ID3(this);
    cp5 = new ControlP5(this);
    minim = new Minim(this);
    
    Group controlGroup = cp5.addGroup("controlGroup");
    controlGroup.setLabel("CONTROLS");

    pp = cp5.addButton("PLAY/PAUSE")
        .setId(1)
        .setSwitch(false)
        .lock()
        .setColorBackground(127)
        .setPosition(0,10)
        .setGroup(controlGroup);

    st = cp5.addButton("STOP")
        .setId(2)
        .setSwitch(false)
        .lock()
        .setColorBackground(127)
        .setPosition(0,35)
        .setGroup(controlGroup);

    ld = cp5.addButton("LOAD")
        .setId(3)
        .setSwitch(false)
        .setPosition(0,60)
        .setGroup(controlGroup);

    vl = cp5.addKnob("knob")
        .setId(4)
        .setLabel("VOLUME")
        .setRange(0,100)
        .setColorBackground(0xff000000)
        .setValue(50)
        .setPosition(80,10)
        .setRadius(30)
        .snapToTickMarks(true)
        .setNumberOfTickMarks(20)
        .setDragDirection(Knob.VERTICAL)
        .setGroup(controlGroup)
        ;
    pb = cp5.addSlider("progress")
     .setId(999)
     .setPosition(1120,27)
     .setSize(150, 6)
     .setLabelVisible(false)
     .setVisible(false)
     .setColorForeground(0xffffffff)
     .setColorBackground(0xff303030)
     .setColorActive(0xff303030)
     .setRange(0,255)
     ;

    controlGroup.setPosition(10, 20);
}

void draw() {
    background(0);        
    textAlign(LEFT, BOTTOM);
    textFont(NexaB);
    text(artist.toUpperCase(), 20, height -50);
    textFont(NexaL);
    text(song.toUpperCase(), 20, height - 5);
    textAlign(CENTER, CENTER);
    text("https://www.musixmatch.com/lyrics/"+ artist + "/"+ song, width/2, height/2);
    //text("volume: " + volume, width/2, height/2);
    stroke(255);
    strokeWeight(4);
    if (player!=null) {
        player.setGain((volume-50)/2);
        fft.forward(player.mix);
        for(int i = 0; i < fft.specSize(); i++)
            {
            // draw the line for frequency band i, scaling it up a bit so we can see it
            line( i+10, height-110, i+10, height - fft.getBand(i)*0.5 -110 );
            }
        
        textAlign(RIGHT, TOP);
        textFont(NexaLS);
        text(hms(player.position()) + " / "+ hms(player.length()), width -10, 10);
        cp5.getController("progress").setMax(player.length());
        cp5.getController("progress").setValue(player.position());
        cp5.getController("progress").setVisible(true);
        }
    
}

public void controlEvent(ControlEvent theEvent) {
  switch (theEvent.getController().getId()) {
      case 1:
      if (!player.isPlaying()) {
          player.play();
      } else {
          player.pause();
      }
      break;
      case 2 :
          player.pause();
          player.rewind();
      break;	
      case 3:
        selectInput("Select a file to process:", "fileSelected");
      break;
      case 4 :
          volume = (int)theEvent.getController().getValue();
          println("value: "+volume);
      break;	
  }
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    cp5.getController("PLAY/PAUSE").unlock();
    cp5.getController("STOP").unlock();
    f = selection;
    player = minim.loadFile(f.getAbsolutePath(), 2048);
    fft = new FFT( player.bufferSize(), player.sampleRate() );
    id3.readID3(f.getAbsolutePath());
    artist = id3.artist;
    song = id3.songTitle;
  }
}

void stop() {
    minim.dispose();
} 

String hms(int millis){
    String hms = String.format("%02d:%02d:%02d", TimeUnit.MILLISECONDS.toHours(millis),
    TimeUnit.MILLISECONDS.toMinutes(millis) % TimeUnit.HOURS.toMinutes(1),
    TimeUnit.MILLISECONDS.toSeconds(millis) % TimeUnit.MINUTES.toSeconds(1));
    return hms;
}