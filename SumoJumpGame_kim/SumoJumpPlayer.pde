//<>//
// A circular object
class SumoJumpPlayer {

  private Body body;      
  private float r;
  private float weight = 180;
  private SumoJumpEngine gameEngine;
  private int identifier;
  private SumoJumpController controller;

  SumoJumpPlayer(float x, float y, SumoJumpEngine engine, int id, SumoJumpController controller) {
    identifier = id;
    gameEngine = engine;
    this.controller = controller;
    r = gameEngine.getPlayerBodyRadius();
    BodyDef bd = new BodyDef();      
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(x, y));
    bd.linearDamping = 0.9;
    body = box2d.createBody(bd);

    // Define a shape
    CircleShape cs = new CircleShape();
    float radius = box2d.scalarPixelsToWorld(r);
    cs.m_radius = radius;

    // Define a fixture
    FixtureDef fd = new FixtureDef();
    fd.shape = cs;
    // Parameters that affect physics
    float playerSize = radius*radius*(float)(Math.PI);
    fd.density = weight / playerSize;
    fd.friction = 0.8;
    fd.restitution = 0.1;  // <- Not very bouncy!
    // Attach Fixture to Body						   
    body.createFixture(fd);
    body.setUserData(this);
  }

  void draw(boolean drawStatus) {
    // We need the Circle’s position 
    Vec2 pos = box2d.getBodyPixelCoord(body);		

    noStroke();
    pushMatrix();
    translate(pos.x, pos.y);		// Using the Vec2 position 
    fill(controller.getColor());
    ellipseMode(RADIUS);
    ellipse(0, 0, r, r);
    textAlign(CENTER, CENTER);
    fill(255);
    textSize(30);
    text(controller.getLetter(), 0,0);
    noStroke();
    translate(0, -40);
    fill(250, 250, 220);
    ellipse(0, 0, 16, 16);
    if (drawStatus) {
      translate(r, 0);
      textAlign(LEFT, CENTER);
      textSize(16);
      fill(255);
      text(controller.getName(), 0, 0);
    }
    popMatrix();
  }

  public int getIdentifier() {
    return identifier;
  }
  
  public String getName() {
    return controller.getName();
  }

  // Functions for sensing and acting. These function can be called by the controller


  public PVector sensePositionInPixelWorld() {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    return new PVector(pos.x, pos.y);
  }

  public SumoJumpProprioceptiveMeasurement senseProprioceptiveData() {
    return gameEngine.senseProprioceptiveData(this, body);
  }

  public ArrayList<SumoJumpOpponentMeasurement> senseOpponents() {
    return gameEngine.senseOpponentsRelativeToPlayer(this);
  }

  public ArrayList<SumoJumpGoalMeasurement> senseGoals() {
    return gameEngine.senseGoalsRelativeToPlayer(this);
  }

  public ArrayList<SumoJumpPlatformMeasurement> sensePlatforms() {
    return gameEngine.sensePlatformsRelativeToPlayer(this);
  }

  public void powerMove() {
    // TODO ...
  }

  public void jumpUp(float power) {
    float p = constrain(power, 0, 100);
    if (gameEngine.canJump(this)) {
      gameEngine.jumpBody(this, body, p);
    }
  }

  public void moveSidewards(float power) {
    float p = constrain(power, -100, 100);
    gameEngine.moveBodySidewards(this, body, p);
  }
}
