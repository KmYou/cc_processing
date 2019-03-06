//<>//
// A rectangular box
class SumoJumpGoal {

  private Body body;
  private float pixX;
  private float pixY;
  private float pixWidth;
  private float pixHeight;
  private int identifier;

  SumoJumpGoal(String[] params, int id) {
    // parameter 0 is skipped, contains element type information
    pixX = float(params[1]);
    pixY = float(params[2]);
    pixWidth = float(params[3]);
    pixHeight = float(params[4]);
    identifier = id;
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

  public void draw() {
    // We can simply use the stored pixel coordinates:
    rectMode(CORNER);
    noStroke();
    fill(200, 50, 200, 200);
    rect(pixX, pixY, pixWidth, pixHeight);
  }
  
  public PVector getCenterInPixelWorld() {
    return new PVector(pixX + pixWidth/2, pixY + pixHeight/2);
  }
  
  public int getIdentifier() {
    return identifier;
  }
}
