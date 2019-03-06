class SumoJumpEngine {

  // A list for all of our platforms
  private ArrayList<SumoJumpPlatform> platforms;
  // A list for all goals (there might be multiple goals)
  private ArrayList<SumoJumpGoal> goals;
  // A list for all of our players
  private ArrayList<SumoJumpPlayer> players;
  // A list for all of our controllers
  private ArrayList<SumoJumpController> controllers;
  // A list for all start positions
  private ArrayList<PVector> startPositions;
  // Keep track of who is on the floor
  private HashMap<SumoJumpPlayer, Boolean> isOnFloor = new HashMap<SumoJumpPlayer, Boolean>();
  // Keep track of who has moved sidewards in the current execution cycle
  private HashMap<SumoJumpPlayer, Boolean> hasMoved = new HashMap<SumoJumpPlayer, Boolean>();
  int startPositionForNextPlayer = 0;

  private float maximumJumpForce = 14000;
  private float maximumSidewardsForce = 400;
  private float perceptionRadius = 250;
  private float playerBodyRadius = 24;

  private boolean drawAgentDebugInformation = false;
  private boolean drawAgentStatusInformation = false;
  SumoJumpPlayer winner = null;


  public SumoJumpEngine(String levelName) {
    // Create platforms and goals and start positions
    platforms = new ArrayList<SumoJumpPlatform>();
    goals = new ArrayList<SumoJumpGoal>();
    startPositions = new ArrayList<PVector>();
    String[] lines = loadStrings(levelName);
    int num = 0;
    for (String line : lines) {
      String[] params = split(line, ';');
      if (params[0].equals("P")) {
        SumoJumpPlatform p = new SumoJumpPlatform(params, num);
        platforms.add(p);
      } else if (params[0].equals("G")) {
        SumoJumpGoal g = new SumoJumpGoal(params, num);
        goals.add(g);
      } else if (params[0].equals("S")) {
        float x = float(params[1]);
        float y = float(params[2]);
        startPositions.add(new PVector(x, y));
      }
      num += 1;
    }
    Collections.shuffle(startPositions);
    // Add four invisible plaforms at the window borders
    SumoJumpPlatform top     = new SumoJumpPlatform(0, -1, width, 1, false);
    SumoJumpPlatform bottom  = new SumoJumpPlatform(0, height-10, width, 1, true); // Not at window border, looks better this way
    SumoJumpPlatform left    = new SumoJumpPlatform(-1, 0, 1, height, false);
    SumoJumpPlatform right   = new SumoJumpPlatform(width, 0, 1, height, false);
    platforms.add(top);
    platforms.add(bottom);
    platforms.add(left);
    platforms.add(right);

    // Create lists for players and their controllers
    players = new ArrayList<SumoJumpPlayer>();
    controllers = new ArrayList<SumoJumpController>();
  }

  public void addController(SumoJumpController newController) {
    if (startPositions.size() > startPositionForNextPlayer) {
      // Create a player object for the controller, if there is one more free start position:
      PVector startPos = startPositions.get(startPositionForNextPlayer);
      println("New player at " + startPos.x + "  " + startPos.y);
      SumoJumpPlayer newPlayer = new SumoJumpPlayer(startPos.x, startPos.y, this, startPositionForNextPlayer, newController);
      players.add(newPlayer);
      isOnFloor.put(newPlayer, false);
      hasMoved.put(newPlayer, false);
      startPositionForNextPlayer++;
      newController.player = newPlayer;
      controllers.add(newController);
    } else {
      println("MUH! No more start position left! Please change config file!");
    }
  }

  public void step() {
    // Reset all hasMoved flags:
    for (SumoJumpPlayer player : players) {
      hasMoved.put(player, false);
    }
    // Let all controllers perform a step
    for (SumoJumpController controller : controllers) {
      controller.act();
    }
  }

  public void draw() {
    // Display all the platforms
    for (SumoJumpPlatform platform : platforms) {
      platform.draw();
    }
    // Display all the goals
    for (SumoJumpGoal goal : goals) {
      goal.draw();
    }
    // Display all the players
    for (SumoJumpPlayer player : players) {
      player.draw(drawAgentStatusInformation);
    }
    if (drawAgentDebugInformation) {
      // Display all debug drawings created by the controllers
      for (SumoJumpController controller : controllers) {
        SumoJumpPlayer player = controller.player;
        PVector pos = player.sensePositionInPixelWorld();
        pushMatrix();
        translate(pos.x, pos.y);    // Using the Vec2 position 
        controller.draw();
        popMatrix();
      }
    }
  }

  void toggleAgentDebugDrawingDisplay() {
    drawAgentDebugInformation = !drawAgentDebugInformation;
  }

  void toggleAgentStatusDrawingDisplay() {
    drawAgentStatusInformation = !drawAgentStatusInformation;
  }

  public float getPlayerBodyRadius() {
    return playerBodyRadius;
  }

  public SumoJumpPlayer getWinner() {
    return winner;
  }

  public SumoJumpProprioceptiveMeasurement senseProprioceptiveData(SumoJumpPlayer player, Body b) {
    SumoJumpProprioceptiveMeasurement m = new SumoJumpProprioceptiveMeasurement();
    m.onFloor = isOnFloor.get(player);
    m.velocity = new PVector();
    Vec2 velWorld = b.getLinearVelocity();
    Vec2 velPixels = box2d.vectorWorldToPixels(velWorld);
    m.velocity.x = velPixels.x;
    m.velocity.y = velPixels.y;
    m.stamina = 100;
    m.bodyRadius = playerBodyRadius;
    m.perceptionRadius = perceptionRadius;
    return m;
  }

  public ArrayList<SumoJumpGoalMeasurement> senseGoalsRelativeToPlayer(SumoJumpPlayer player) {
    ArrayList<SumoJumpGoalMeasurement> list = new ArrayList<SumoJumpGoalMeasurement>();
    PVector playerPos = player.sensePositionInPixelWorld();
    for (SumoJumpGoal goal : goals) {
      PVector goalPos = goal.getCenterInPixelWorld();
      SumoJumpGoalMeasurement m = new SumoJumpGoalMeasurement();
      m.position = PVector.sub(goalPos, playerPos);
      m.distance = m.position.mag();
      m.id = goal.getIdentifier();
      list.add(m);
    }
    return list;
  }

  public ArrayList<SumoJumpOpponentMeasurement> senseOpponentsRelativeToPlayer(SumoJumpPlayer player) {
    ArrayList<SumoJumpOpponentMeasurement> list = new ArrayList<SumoJumpOpponentMeasurement>();
    PVector playerPos = player.sensePositionInPixelWorld();
    for (SumoJumpPlayer opponent : players) {
      if (opponent != player) {
        PVector oppPos = opponent.sensePositionInPixelWorld();
        SumoJumpOpponentMeasurement m = new SumoJumpOpponentMeasurement();
        m.position = PVector.sub(oppPos, playerPos);
        m.distance = m.position.mag();
        m.id = opponent.getIdentifier();
        list.add(m);
      }
    }
    return list;
  }

  public ArrayList<SumoJumpPlatformMeasurement> sensePlatformsRelativeToPlayer(SumoJumpPlayer player) {
    ArrayList<SumoJumpPlatformMeasurement> list = new ArrayList<SumoJumpPlatformMeasurement>();
    PVector playerPos = player.sensePositionInPixelWorld();
    for (SumoJumpPlatform platform : platforms) {
      if (platform.upperLineIntersectsWithCircle(playerPos, perceptionRadius)) {
        SumoJumpPlatformMeasurement m = new SumoJumpPlatformMeasurement();
        PVector left = platform.getUpperLeftCorner();
        PVector right = platform.getUpperRightCorner();
        m.left  = PVector.sub(left, playerPos);
        m.right = PVector.sub(right, playerPos);
        m.id = platform.getIdentifier();
        m.standingOnThisPlatform = m.left.x <= 0 && m.right.x >=0 && m.left.y > 0 && m.left.y < playerBodyRadius * 1.1;
        list.add(m);
      }
    }
    return list;
  }

  void beginContact(Contact cp) {
    // Get both fixtures
    Fixture f1 = cp.getFixtureA();
    Fixture f2 = cp.getFixtureB();
    // Get both bodies
    Body b1 = f1.getBody();
    Body b2 = f2.getBody();
    // Get our objects that reference these bodies
    Object o1 = b1.getUserData();
    Object o2 = b2.getUserData();

    // Check, if a player is involved:
    SumoJumpPlayer collidingPlayer = null;
    if (o1.getClass() == SumoJumpPlayer.class) {
      collidingPlayer = (SumoJumpPlayer) o1;
    } else if (o2.getClass() == SumoJumpPlayer.class) {
      collidingPlayer = (SumoJumpPlayer) o2;
    }

    // If a player is involved, check, if the other object is a platform or a goal:
    if (collidingPlayer != null) {
      SumoJumpPlatform platform = null;
      if (o1.getClass() == SumoJumpPlatform.class) 
        platform = (SumoJumpPlatform) o1;
      else if (o2.getClass() == SumoJumpPlatform.class) 
        platform = (SumoJumpPlatform) o2;
      if (platform != null) {
        handleCollisionOfPlayerWithPlatform(collidingPlayer, platform);
        return;
      }
      SumoJumpGoal goal = null;
      if (o1.getClass() == SumoJumpGoal.class) 
        goal = (SumoJumpGoal) o1;
      else if (o2.getClass() == SumoJumpGoal.class) 
        goal = (SumoJumpGoal) o2;
      if (goal != null) {
        winner = collidingPlayer;
      }
    }
  }

  void handleCollisionOfPlayerWithPlatform(SumoJumpPlayer player, SumoJumpPlatform platform) {
    if (platform.collisionHandling == false)
      return;
    PVector playerPos = player.sensePositionInPixelWorld();
    if (platform.pixY < playerPos.y)
      return;
    isOnFloor.put(player, true);
  }

  public boolean canJump(SumoJumpPlayer player) {
    return isOnFloor.get(player);
  }

  public void jumpBody(SumoJumpPlayer player, Body b, float power) {
    Vec2 pos = b.getWorldCenter();
    Vec2 force = new Vec2(0, (maximumJumpForce / 100.0) * power);
    b.applyLinearImpulse(force, pos, true);
    isOnFloor.put(player, false);
  }

  public void moveBodySidewards(SumoJumpPlayer player, Body b, float power) {
    if (hasMoved.get(player) == false) {
      Vec2 pos = b.getWorldCenter();
      Vec2 force = new Vec2((maximumSidewardsForce / 100.0) * power, 0);
      b.applyLinearImpulse(force, pos, true);
      hasMoved.put(player, true);
    }
  }
}
