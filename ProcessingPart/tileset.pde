class Tile
{
  public Tile(int safetyLevel, float w, float h, int ID)
  {
    setSafety(safetyLevel);
    tileWidth = w;
    tileHeight = h;
    this.ID = ID;
  }
  public void setWidth(float w)
  {
    tileWidth = w;
  }
  public void setHeight(float h)
  {
    tileHeight = h;
  }
  
  public void setSafety(int safety)
  {
    safetyLevel = safety;
    if(safetyLevel < -8) safetyLevel = -8;
    if(safetyLevel > 1) safetyLevel *= -1;
  }
  
  public int getSafety()
  {
    return safetyLevel;
  }
  
  public float getWidth()
  {
    return tileWidth;
  }
  
  public float getHeight()
  {
    return tileHeight;
  }
  
  public int getID()
  {
    return ID;
  }

  private float tileWidth;
  private float tileHeight;
  private int safetyLevel = 0;
  private int ID;
}

//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||\\
//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||\\
//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||\\
//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||\\
//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||\\
//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||\\
//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||\\
//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||\\
//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||\\
class Tileset
{
  public Tileset(int w, int h, float tileW, float tileH)
  {
    tilesetWidth = w;
    tilesetHeight = h;
    tileNumber = w*h;
    tiles = new Tile[tileNumber];
    for(int i = 0; i<tileNumber;i++) tiles[i] = new Tile(0,tileW,tileH,i);
  }
  
  public Tileset(String filename, float tileW, float tileH)
  {
    tileWidth = tileW;
    tileHeight = tileH;
    generateFromTxtFile(filename);
  }
  
  public void generateFromTxtFile(String filename)
  {    
    String[] dataString = loadStrings(filename);
    minimum = 0;
    
    tilesetHeight = dataString.length;
    tilesetWidth = 0;
    
    for(int i = 0; i<tilesetHeight; i++)
    {
      int[] data;
      data = int(split(dataString[i], ':'));
      
      if(tilesetWidth == 0)
      {
        tilesetWidth = data.length;
        tileNumber = tilesetWidth * tilesetHeight;
        tiles = new Tile[tileNumber];
      }
      
      for(int j = 0; j<tilesetWidth;j++)
      {
        if(data[j]<minimum) minimum = data[j];
        tiles[tilesetWidth *i + j] = new Tile(data[j],tileWidth,tileHeight,tilesetWidth* i + j);
      }
    } 
    minimum--;
    outOfBoundaries = new Tile(minimum, tileWidth, tileHeight,-1);
  }
  
  public int getTileXFromID(int index)
  {
    return index % tilesetWidth;
  }
  
  public int getTileYFromID(int index)
  {
    return index / tilesetWidth;
  }
  
  public Tile getTile(int x, int y)
  {
    return tiles[tilesetWidth * y + x];
  }
  
  public int getWidth()
  {
    return tilesetWidth;
  }
  public int getHeight()
  {
    return tilesetHeight;
  }
  
  public float getTileWidth()
  {
    return tileWidth;
  }
  
  public float getTileHeight()
  {
    return tileHeight;
  }
  private int tilesetWidth;
  private int tilesetHeight;
  private int tileNumber;
  private int minimum;
  private float tileWidth;
  private float tileHeight;
  public  Tile[] tiles;
  public Tile    outOfBoundaries;
}

