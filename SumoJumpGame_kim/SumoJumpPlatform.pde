//<>//
// A rectangular box
class SumoJumpPlatform {

  Body body;
  float pixX;
  float pixY;
  float pixWidth;
  float pixHeight;
  boolean isVisible;
  boolean collisionHandling;
  int identifier;

  SumoJumpPlatform(String[] params, int id) {
    // parameter 0 is skipped, contains element type information
    pixX = float(params[1]);
    pixY = float(params[2]);
    pixWidth = float(params[3]);
    pixHeight = float(params[4]);
    isVisible = true;
    identifier = id;
    collisionHandling = true;
    createBodyAndShape();
  }

  SumoJumpPlatform(float x, float y, float w, float h, boolean c) {
    pixX = x;
    pixY = y;
    pixWidth = w;
    pixHeight = h;
    isVisible = false;
    collisionHandling = c;
    createBodyAndShape();
  }

  private void createBodyAndShape() {
    BodyDef bd = new BodyDef();      
    bd.type = BodyType.STATIC;
    bd.position.set(box2d.coordPixelsToWorld(pixX + pixWidth/2, pixY + pixHeight/2));
    body = box2d.createBody(bd);

    // Define a polygon (this is what we use for a rectangle)
    PolygonShape ps = new PolygonShape();
    float box2dW = box2d.scalarPixelsToWorld(pixWidth/2);
    float box2dH = box2d.scalarPixelsToWorld(pixHeight/2);  
    ps.setAsBox(box2dW, box2dH);           
    // Create object           
    body.createFixture(ps, 1);
    body.setUserData(this);
  }

  public boolean upperLineIntersectsWithCircle(PVector circleCenter, float circleRadius) {
    if (!isVisible)
      return false;
    if (dist(pixX, pixY, circleCenter.x, circleCenter.y) < circleRadius)
      return true;
    if (dist(pixX+pixWidth, pixY, circleCenter.x, circleCenter.y) < circleRadius)
      return true;
    if (pixX < circleCenter.x && pixX+pixWidth > circleCenter.x && abs(circleCenter.y-pixY) < circleRadius)
      return true;
    return false;
  }

  public PVector getUpperLeftCorner() {
    return new PVector(pixX, pixY);
  }

  public PVector getUpperRightCorner() {
    return new PVector(pixX+pixWidth, pixY);
  }

  public int getIdentifier() {
    return identifier;
  }

  public void draw() {
    if (isVisible) {
      // We can simply use the stored pixel coordinates:
      rectMode(CORNER);
      noStroke();
      fill(90, 50, 0);
      rect(pixX, pixY, pixWidth, pixHeight);
    }
  }
}
