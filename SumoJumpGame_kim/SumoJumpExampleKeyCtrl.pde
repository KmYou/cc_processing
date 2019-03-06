class SumoJumpExampleKeyCtrl extends SumoJumpController {

  SumoJumpExampleKeyCtrl() {
    super();
  }

  void act() {
    if (keyPressed) {
      if (keyCode == UP)
        player.jumpUp(100);
      else if (keyCode == RIGHT)
        player.moveSidewards(100);
      else if (keyCode == LEFT)
        player.moveSidewards(-100);
    }
  }
  
  String getName() {
    return "Captain Key";
  }
  
  char getLetter() {
    return 'K';
  }
  
  color getColor() {
    return color(255,0,0);
  }

  void draw() {
    // Test drawing: sense the goals and draw lines to the goals:
    ArrayList<SumoJumpGoalMeasurement> goals = player.senseGoals();
    strokeWeight(5);
    stroke(255, 0, 0, 150);
    for (SumoJumpGoalMeasurement goal : goals) {
      line(0, 0, goal.position.x, goal.position.y);
    }

    // Test drawing visualize perception radius:
    SumoJumpProprioceptiveMeasurement proprio = player.senseProprioceptiveData();
    noStroke();
    fill(0, 0, 255, 50);
    ellipseMode(RADIUS);
    ellipse(0, 0, proprio.perceptionRadius, proprio.perceptionRadius);

    // Test drawing visualizing the perceived platforms:
    ArrayList<SumoJumpPlatformMeasurement> platforms = player.sensePlatforms();
    strokeWeight(10);
    for (SumoJumpPlatformMeasurement p : platforms) {
      if (p.standingOnThisPlatform)
        stroke(150, 255, 155, 200);
      else
        stroke(252, 60, 160, 200);
      line(p.left.x, p.left.y, p.right.x, p.right.y);
    }
    
    // Test drawing: Relative velocity
    stroke(0,0,0,120);
    strokeWeight(6);
    line(0,0,proprio.velocity.x, proprio.velocity.y);
  }
}
