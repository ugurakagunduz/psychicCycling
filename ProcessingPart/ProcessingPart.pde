
import oscP5.*;
import netP5.*;
import processing.serial.*;

//the map and the player
Tileset map;
Player player;

float startX;
float startY;
//font for displaying the map (mainly for debug purposes)
PFont f;

boolean calibrating = false;
boolean dead = false;
float  deathCounter;
final float DEATHTIME = 30.0 * 53.0;

public float zoomFactor = 2;        //zoom in and out the map
public float scaleFactor = 50;       //scaling for 3d world (1 m = 50 units);

//---------------------------------------------------------------------------------------------
//communication ports with two arduinos 
//one arduino provides steering and speed data
//the other one provides the rotation of the player's head
//one MPU6050 is used for the head and another one for the bicycle's guidon.
Serial     myPort;                    
Serial     port2;
//---------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------
//grass texture
PImage   tex ;
//death texture
PImage   deathTex;
PImage   deathTex2;
//---------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------

short   portIndex = 0; // Index of serial port in list (varies by computer)
short   portIndex2 = 1;
int     lf = 10;       //ASCII linefeed
String  inString;      //String for testing serial communication
//---------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------
//yaw pitch and roll values from the two MPU6050's
float dmp[] = new float[3];        //steer
float dmp2[] = new float[3];       //head

//---------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------
//OSC messages 
OscP5 informant;
NetAddress remoteTileData;
NetAddress remoteCurrentTile;
NetAddress remotePosition;
//---------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------
//if M is played, a map is displayed in order to see where we are. Only for debug purposes.
boolean displayMap = false;

//---------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------
//--------------------------------------SETUP--------------------------------------------------
//---------------------------------------------------------------------------------------------
void setup()
{
  textAlign(CENTER);
  size(1320,768,OPENGL);
  textureMode(NORMAL);

  tex = loadImage("texGrass2.jpg");
  deathTex = loadImage("youAreDead.jpg");
  deathTex2 = loadImage("oldBike.jpg");
  map = new Tileset("map.txt",25,25);

  f = createFont("Arial",16,true);
  textFont(f,30);
  player = new Player(0,0,map);

    informant = new OscP5(this, 5000);
    remoteTileData = new NetAddress("127.0.0.1", 6000);
    remoteCurrentTile = new NetAddress("127.0.0.1", 6001);
    remotePosition = new NetAddress("127.0.0.1", 6002);
    
    
  if(Serial.list().length > 0)    //if first arduino connected
  {
    String portName = Serial.list()[portIndex];
    myPort = new Serial(this, portName, 57600);
    println("port name 1 = " + portName);
    myPort.clear();
    myPort.bufferUntil(lf);
    if(Serial.list().length > 1)
    {
      portName = Serial.list()[portIndex2]; //if second arduino connected
      println("port name 2 = " + portName);
      port2 = new Serial(this, portName, 57600);
      port2.clear();
      port2.bufferUntil(lf);
    }
  }
  startX = map.getTileWidth()/2;
  startY = 4*map.getTileHeight() + map.getTileHeight()/2;
  player.bicycle.setPosition(startX,startY);
}
//---------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------
//--------------------------------------DRAW---------------------------------------------------
//---------------------------------------------------------------------------------------------
void draw()
{
  if(dead)
  {
    youAreDead();
    return;
  }
  //do game logic
  if(Serial.list().length > 0)player.bicycle.steer(dmp[2]);
  if(Serial.list().length > 1) player.angle = dmp2[2] +player.angleOffset;
  player.update();
  //reset background
  background(255);
  hint(ENABLE_DEPTH_TEST);
  // draw 3D stuff
   draw3DWorld();
   
  // draw 2D stuff
  camera();
  hint(DISABLE_DEPTH_TEST);
  if(displayMap) displayMapAndPlayer(); 
  if(calibrating) player.calibrate();
}

//variables that control the creepiness of the atmosphere and immersion
   float playerY = -100;        //player's vision height
   boolean playerBump = false;  //does the bicycle bump?
   float R = 255;               //red value of the light
   float G = 255;               //green value of the light
   float B = 255;               //blue value of the light
   float lightHeight = -200;    //height of the light
   float lightPower = 20;       //intensity of the light
   float lightCone = 40;        //cone of the light
   
   
   //some randomized functions: bumping according to speed, and changing the light's properties
 void bump()
 {
    float blink = random(100);
    float lowerBumpThreshold = 10 - player.bicycle.getMagnitude()*500;
    if(lowerBumpThreshold < -10) lowerBumpThreshold = -10;
    if(blink>90 + lowerBumpThreshold)
    {
      playerBump = true;
    }
    
    if(playerBump)
    {
      playerY-=0.2;
      if(playerY < -102) 
      {
         playerY = -101.2;
         playerBump = false;
      }
    }
    else playerY+=0.2;
    if(playerY >= -100) playerY = -100;     
    if(player.bicycle.getMagnitude() <= 0) playerY = -100;
 }
 
 void changeLights()
 {
   float blink = random(100);
   if(blink>95)
   {
     R = random(150,151);
     G = random(150,170);
     B = random(150,155);
   }
   blink = (int)random(0,100);
   if(blink>95)
     lightHeight = -random(75,300);
     
   blink = (int)random(0,100);
   if(blink>95)
     lightPower = random(0,20);
     
      blink = (int)random(0,100);
   if(blink>95)
     lightCone = random(10,40);

     spotLight(R,G,B,player.lookatVector.x*scaleFactor,lightHeight,player.lookatVector.z*scaleFactor,0,1,0,lightCone,lightPower);
 }
 
// render world
void draw3DWorld()
{  
   background(0); 
   noStroke();
   player.calculateLookatVector(); 
   bump();
   camera(player.bicycle.getPosition().x*scaleFactor, playerY, player.bicycle.getPosition().y*scaleFactor, player.lookatVector.x*scaleFactor, playerY ,player.lookatVector.z*scaleFactor,0.0,1.0,0.0);
   changeLights();
   makeTileSet();
}

//render tileset
void makeTileSet()
{
     pushMatrix();
         float x = map.getTileXFromID(player.getCurrentTile().getID())*map.getTileWidth()*scaleFactor;
         float z = map.getTileYFromID(player.getCurrentTile().getID())*map.getTileHeight()*scaleFactor;
         translate(x,0,z);
         
         x = map.getTileWidth()*scaleFactor;
         z =map.getTileHeight()*scaleFactor;
  
         makeTile(x,z);
      popMatrix();
     for(int i = 0; i<player.neighbours.length;i++)
     {
       pushMatrix();
         fill(255);
         x = map.getTileXFromID(player.neighbours[i].getID())*map.getTileWidth()*scaleFactor;
         z = map.getTileYFromID(player.neighbours[i].getID())*map.getTileHeight()*scaleFactor;
         translate(x,0,z);
         
         x = map.getTileWidth()*scaleFactor;
         z =map.getTileHeight()*scaleFactor;
  
         makeTile(x,z);
         
       popMatrix();
     }
}

//render one tile
void makeTile(float x, float z)
{
    
    pushMatrix();
           beginShape(QUADS);
           float b = random(50);          
           texture(tex);         
           normal(0,1,0);
            float coefficient = 8.0;
           for(int i = 0; i< coefficient; i++)
           {
             for(int j= 0; j<coefficient; j++)
             {
               vertex(i*x/coefficient,-55,j*z/coefficient,0,0);
               j++;
               vertex(i*x/coefficient,-55,j*z/coefficient,1,0);
               i++;
               vertex(i*x/coefficient,-55,j*z/coefficient,1,1);
               j--;
               vertex(i*x/coefficient,-55,j*z/coefficient,0,1);
               i--;
             }
           }
           endShape(CLOSE);         
          popMatrix();
}

//display minimap
void displayMapAndPlayer()
{
  
  pushMatrix();
  {
   
    stroke(0);
    lights();
    fill(255,255,255,127);
    camera(player.bicycle.getPosition().x * zoomFactor,player.bicycle.getPosition().y *zoomFactor, 100, player.bicycle.getPosition().x * zoomFactor,player.bicycle.getPosition().y *zoomFactor ,0,0,1,0);
    for(int i = 0; i<map.getHeight(); i++)
    {
      for(int j = 0; j<map.getWidth();j++)
      {
        rectMode(CORNER);
        if(map.getTile(j,i) == player.getCurrentTile()) fill(100,100,100,127);
        for(int k = 0; k<8; k++) if(map.getTile(j,i) == player.neighbours[k]) fill(100,0,100,127); 
        rect(j*map.getTileWidth()*zoomFactor,i*map.getTileHeight()*zoomFactor,map.getTileWidth()*zoomFactor,map.getTileHeight()*zoomFactor);
        
        if(map.getTile(j,i).getSafety() == 0) fill(255,0,0,127);
        else if(map.getTile(j,i).getSafety() == 1) fill(0,255,0,127);
        else fill(0);
        text(map.getTile(j,i).getSafety(),j*map.getTileWidth()*zoomFactor+map.getTileWidth()*zoomFactor/2.0,i*map.getTileHeight()*zoomFactor+map.getTileHeight()/2.0*zoomFactor);
        fill(255,255,255,127); 
 
      }
  } 
  player.render();
  noLights();
  popMatrix();
  }
}

//key presses for debugging and calibration purposes

void keyPressed() 
{
  if (key == CODED) 
  {
    if (keyCode == LEFT) 
    {
      player.bicycle.steerBy(-2);
    } 
    else if (keyCode == RIGHT) 
    {
      player.bicycle.steerBy(2);
    } 
    else if(keyCode == UP)
    {
      player.bicycle.accelerate(0.02);
    }
    else if(keyCode == DOWN)
    {
      player.bicycle.accelerate(-0.02);
      if(player.bicycle.getMagnitude() < 0) player.bicycle.setMagnitude(0);
    }
   
  } 
  if(key == 'A' || key == 'a')
  {
    zoomFactor*=1.2;
  }
  if(key == 's' || key == 's')
  {
    zoomFactor *= 0.8;
  }
  
  if(key == 'm' || key == 'M')
  {
    displayMap = !displayMap;
  }
  if(key == 'r' || key == 'R')
  {
      resetGame();
  }
  if(key == 'c' || key == 'C')
  {
    calibrating = true;
  }
}

void keyReleased()
{
  if (key == CODED) 
  {
    if (keyCode == LEFT) 
    {
    } 
    else if (keyCode == RIGHT) 
    {
    } 
  } 
  if(key == 'c' || key == 'C')
  {
    calibrating = false;
  }
}

//receive osc events
void oscEvent(OscMessage theOscMessage) 
{  
   dead = true;
   println("KILLED");
}

void youAreDead()
{
  println(deathCounter/30.0);
  camera();
  hint(DISABLE_DEPTH_TEST);
  pushMatrix();
    lights();
    beginShape(QUADS);
      if(deathCounter < 30.0 * 5)texture(deathTex);
      else texture(deathTex2);
      
     
      vertex(0,0,0,0,0);
      vertex(0,height,0,0,1);
      vertex(width,height,0,1,1);
      vertex(width, 0,0,1,0);
      
       if(deathCounter > 20 * 30.0 ) text("ANYONE ELSE?", width/2,height/2);

      
    endShape();
    noLights();
  popMatrix();
  deathCounter++;
  if(deathCounter > DEATHTIME)
  {
    deathCounter = 0;
    resetGame();
    dead = false;
  }
}

// reset the game

void resetGame()
{
  map.generateFromTxtFile("map.txt");
  player.bicycle.setPosition(startX,startY);
  player.bicycle.setMagnitude(0);
}
//parsing arduino data
void serialEvent(Serial p) 
  {
    inString = p.readString();
    
    try 
    {

      String[] dataStrings = split(inString, ':');


      {
        if (dataStrings.length == 4) 
        {
          if (dataStrings[0].equals("BICYCLE")) 
          {
            for (int i = 0; i < dataStrings.length - 1; i++) 
            {
              dmp[i] = float(dataStrings[i+1]);
            }        
          } 
          else 
          {
             //println(inString);
          }
        }
        else if(dataStrings.length == 2)
        {
          if (dataStrings[0].equals("BICYCLE"))
          {
           println(dataStrings[1]);
            player.bicycle.setMagnitude(player.bicycle.kmhToMpf(float(dataStrings[1])));
          }
        }
      }

      {
          if (dataStrings.length == 4) 
        {
          if (dataStrings[0].equals("DMP")) 
          {
            for (int i = 0; i < dataStrings.length - 1; i++) 
            {
              dmp2[i] = float(dataStrings[i+1]);
            }        
          } 
          else 
          {
             //println(inString);
          }
        }
      }
    } 
    catch (Exception e) 
    {
  //    println("Caught Exception");
    } 
  }
