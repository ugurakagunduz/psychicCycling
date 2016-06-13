class Bicycle
{
  private float shaftAngle;
  private float guidonAngle;
  private PVector velocity;
  private PVector position;
 
  private float bicycleSize;
  private float magnitude;
  private float steerFactor = 0.5;
  private float steeringOffset = 0;
  
  public Bicycle(float size)
  {
    bicycleSize = size;
    velocity = new PVector(0,0);
    position = new PVector(0,0);
  }
  
  public void update()
  {
    rotateShaft();
    move();
  }
  public void renderOnlyBicycle()
  {
    rectMode(CENTER);
    fill(255,200,100);
    pushMatrix();
    translate(position.x * zoomFactor, position.y * zoomFactor);
    rotate(radians(shaftAngle));

    rect(0, 0, bicycleSize*zoomFactor, bicycleSize/5*zoomFactor);
          translate(bicycleSize/2*zoomFactor, 0);
          rotate(radians( guidonAngle));
          rect(0, 0, bicycleSize/8*zoomFactor, bicycleSize/3*zoomFactor);
    popMatrix();
    rectMode(CORNER);
    fill(255);
  }
  public void render()
  {
    rectMode(CENTER);
    fill(255,200,100);
    pushMatrix();
    translate(position.x * zoomFactor, position.y * zoomFactor);
    rotate(radians(shaftAngle));

    rect(0, 0, bicycleSize*zoomFactor, bicycleSize/5*zoomFactor);
          translate(bicycleSize/2*zoomFactor, 0);
          rotate(radians( guidonAngle));
          rect(0, 0, bicycleSize/8*zoomFactor, bicycleSize/3*zoomFactor);
    popMatrix();
    rectMode(CORNER);
    fill(255);
  }
  public void steerBy(float angle)
  {
    guidonAngle = setAngle(guidonAngle + angle - steeringOffset);
  }
  
  public void calibrate()
  {
      pushMatrix();
      lights();
      fill(255);     
      text("CALIBRATING...\n PLEASE HOLD THE GUIDON STRAIGHT \nAND LOOK AT THE  CENTER OF THE SCREEN", width/2,height/2);
      println("calibrating");
      noLights();
      popMatrix();
    steeringOffset = dmp[2];
  }
  
   public void steer(float angle)
  {
    guidonAngle = setAngle(angle-steeringOffset);
  }
  public void accelerate(float value)
  {
    magnitude+=value;
  }
  
  public void setMagnitude(float value)
  {
    magnitude = value;
  }
  private void rotateShaft()
  {
     float adjacent = 0;
     if(guidonAngle != 0)adjacent = bicycleSize / tan(radians(guidonAngle));
     adjacent = adjacent;
     
     float arcAngle = 0;
     arcAngle = (180 * magnitude)/ (PI * adjacent);
     if(guidonAngle != 0)shaftAngle = setAngle(shaftAngle + arcAngle);
//     println("adjacent = " + adjacent+  " arc angle " + arcAngle);
  }
  
  private float setAngle(float value)
  {
    float angle = value % 360;
    return angle;
  }
  
  public PVector getPosition()
  {
    return position;
  }
  public PVector getVelocity()
  {
    return velocity;
  }
  
  public float getShaftAngle()
  {
    return shaftAngle;
  }
  
  public float getMagnitude()
  {
    return magnitude;
  }
  
  public void setPosition(float x, float y)
  {
    position.x = x; 
    position.y = y;
  }
  
  private void move()
  {
    velocity.x = magnitude * cos(radians(shaftAngle));
    velocity.y = magnitude * sin(radians(shaftAngle));
    position.x+=velocity.x;
    position.y+=velocity.y;
  }
  public float kmhToMpf(float kmh)
  {
    float meterPerHour = kmh * 1000.0;
    float hour  = 3600 * 30.0;
    return meterPerHour / hour;
    
  }
  public float mpfToKmh(float mpf)
  {
    float kilometerPerFrame = mpf / 1000.0;
    float hour = 3600 * 30.0;
    return kilometerPerFrame*hour;
  }
}
