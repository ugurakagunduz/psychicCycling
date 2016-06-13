class Player
{
  public Player(float startX, float startY, Tileset map)
  {
    bicycle = new Bicycle(2);
    angle = 0;
    this.map = map;
    currentTile = map.outOfBoundaries;
    neighbours = new Tile[8];
    bicycle.setPosition(startX,startY);
    lookatVector = new PVector(0,0,0);
  }
  
  private void sendOscToMax()
  {
    OscMessage messageToRemoteTileData = new OscMessage("tileData");
    OscMessage messageToRemoteCurrentTile = new OscMessage("currentTile");
    OscMessage messageToRemotePosition = new OscMessage("position_");
    
    for(int i = 0; i<8; i++)
    messageToRemoteTileData.add(neighbours[i].getSafety());
    informant.send(messageToRemoteTileData, remoteTileData);
    
    messageToRemoteCurrentTile.add(currentTile.getSafety());
    messageToRemoteCurrentTile.add(tileChange);
    informant.send(messageToRemoteCurrentTile,remoteCurrentTile);
    
    messageToRemotePosition.add(bicycle.getShaftAngle() + angle);
    messageToRemotePosition.add((bicycle.getPosition().x - map.getTileXFromID(currentTile.ID)*map.getTileWidth())/map.getTileWidth());
    messageToRemotePosition.add((bicycle.getPosition().y - map.getTileYFromID(currentTile.ID)*map.getTileHeight())/map.getTileHeight());
    messageToRemotePosition.add(bicycle.mpfToKmh(bicycle.getMagnitude()));
    informant.send(messageToRemotePosition,remotePosition);
  }
  
  public void update()
  {
    checkTile();
    getNeighbours();
    bicycle.update();
    if(currentTile!=null)
    {
      if(lastTile != null) 
      {
        if(lastTile!=currentTile) tileChange = 1;
        else tileChange = 0;
      }
      if(lastTile !=null && lastTile != currentTile && lastTile != map.outOfBoundaries) 
      {
        lastTile.setSafety(lastTile.getSafety()-1);
        map.outOfBoundaries.setSafety(map.outOfBoundaries.getSafety()-1);
      }
      lastTile = currentTile;
    }   
    sendOscToMax();
    if(tileChange == 1)println("tileChange =" + tileChange);
  }
  
  public void render()
  {
    bicycle.render();
  }
  
  private void getNeighbours()
  {
    int x = map.getTileXFromID(currentTile.ID);
    int y = map.getTileYFromID(currentTile.ID);

    for(int i = 0; i<8 ; i++)
    {
       if(x-1 < 0)
        {
          neighbours[0] = map.outOfBoundaries;
          neighbours[3] = map.outOfBoundaries;
          neighbours[5] = map.outOfBoundaries;
        }
        if(x+1 >= map.getWidth())
        {
          neighbours[2] = map.outOfBoundaries;
          neighbours[4] = map.outOfBoundaries;
          neighbours[7] = map.outOfBoundaries;
        }
        if(y-1 < 0) 
        {
          neighbours[0] = map.outOfBoundaries;
          neighbours[1] = map.outOfBoundaries;
          neighbours[2] = map.outOfBoundaries;
        }
        if(y+1 >= map.getHeight()) 
        {
          neighbours[5] = map.outOfBoundaries;
          neighbours[6] = map.outOfBoundaries;
          neighbours[7] = map.outOfBoundaries;
        }
        
        if(i<3 && x+i-1 >=0 && x+i-1 < map.getWidth() && y-1 >= 0)neighbours[i] = map.getTile(x+i-1,y-1);
        else if (i == 3 && x-1>=0) neighbours[i] = map.getTile(x-1,y);
        else if (i == 4 && x+1 <map.getWidth()) neighbours[i] = map.getTile(x+1,y);
        else if (x-6+i < map.getWidth() && x-6+i >=0 && y+1<map.getHeight())neighbours[i] = map.getTile(x-6+i,y+1);   
    } 
  }
    
  public void calibrate()
  {
    angleOffset = dmp2[2];
    bicycle.calibrate();
  }
  public void rotateTo(float angle)
  {
    this.angle = angle - angleOffset;
    this.angle = this.angle % 360;
    if(this.angle < 0) this.angle = 360 + angle;
  }
  
  public void rotateBy(float angle)
  {
    this.angle += angle;
    this.angle = this.angle % 360;
    if(this.angle < 0) this.angle = 360 + angle;
  }
  
  public void calculateLookatVector()
  {
    lookatVector.x = bicycle.getPosition().x + lookatVectorDistance * cos(radians(bicycle.getShaftAngle()));
    lookatVector.y = 0;
    lookatVector.z = bicycle.getPosition().y + lookatVectorDistance * sin(radians(bicycle.getShaftAngle()));
  }
  
  private void checkTile()
  {
    for(int i = 0; i<map.tiles.length;i++) 
    {
      if(isInTile(i))
      {
        currentTile = map.tiles[i];
        return;
      }
    }
    currentTile = map.outOfBoundaries;
  }
  
  private boolean isInTile(int index)
  {
    if(bicycle.getPosition().x > map.getTileXFromID(index)*map.getTileWidth() + map.getTileWidth()) return false;
    if(bicycle.getPosition().x < map.getTileXFromID(index)*map.getTileWidth()) return false;
    if(bicycle.getPosition().y > map.getTileYFromID(index)*map.getTileHeight() + map.getTileHeight()) return false;
    if(bicycle.getPosition().y < map.getTileYFromID(index)*map.getTileHeight()) return false;
    return true;
  }
  

  
  public  PVector getPosition()
  {
    return bicycle.getPosition();
  }
  public PVector getVelocity()
  {
    return bicycle.getVelocity();
  }
  
  public Tile getCurrentTile()
  {
    return currentTile;
  }
  public float angleOffset;
  public Bicycle bicycle;
  private float magnitude;
  public float angle;
  public PVector lookatVector;
  public float   lookatVectorDistance = 2.0;
  private Tileset map;
  private Tile currentTile;
  private Tile lastTile;
  private int tileChange;
  public Tile[] neighbours;
}
