import java.util.Map;

class TMASumoJumpController extends SumoJumpController {

  TMASumoJumpController() {
    super();
  }

  void act() {
    PVector  pos = (player.sensePositionInPixelWorld());
    SumoJumpProprioceptiveMeasurement proprio = player.senseProprioceptiveData();

    if (keyPressed) {
      if (keyCode == UP)
        player.jumpUp(100);
      else if (keyCode == RIGHT)
        player.moveSidewards(100);
      else if (keyCode == LEFT)
        player.moveSidewards(-100);
    }

    ArrayList<SumoJumpGoalMeasurement> goals = player.senseGoals();
    for (SumoJumpGoalMeasurement goal : goals) {
      if (goal.position.x < proprio.perceptionRadius && -goal.position.y < proprio.perceptionRadius) {
        noStroke();
        fill(255, 0, 255, 50);
        ellipseMode(RADIUS);
        ellipse(pos.x, pos.y, 70, 70);
        if (goal.position.x <= -20)
          player.moveSidewards(-100);
        if (goal.position.x >= 20)
          player.moveSidewards(100);
        if (goal.position.x > -20 && goal.position.x < 20)
          player.jumpUp(0);
        //println(proprio.perceptionRadius, goal.position.x, goal.position.y);
      }
    }

    
    ArrayList<SumoJumpPlatformMeasurement> platforms = player.sensePlatforms();
    strokeWeight(10);
    PVector desired = new PVector();
    PVector p_center = new PVector();
    for (SumoJumpPlatformMeasurement p : platforms) {
      fill(255);
      rect(p.left.x + pos.x, 0, 1, height);
      rect(p.right.x + pos.x, 0, 1, height);
      println("p_id: ", p.id);
      println("sorted: ", next_low_platform(pos.y));
      p_center.add((p.right.x-p.left.x)/2, p.left.y);
      if (p.id == next_low_platform(pos.y)) {
        println("sorted platform y: ", p.left.y);
        println("current player y: ", pos.y);
        stroke(20);
        line(p.left.x+pos.x, p.left.y+pos.y, p.right.x+pos.x, p.right.y+pos.y);
        
        if (p.left.x+pos.x-200 <= pos.x && p.right.x+pos.x+200 >= pos.x) {  //if player is inside of platform
          println("inside");
          if(PVector.dist(p.left, pos) >= PVector.dist(p.right, pos)) {  //if right end is closer than left end of platform
            //desired = p.right;
            player.moveSidewards(50);
          } else {
            //desired = p.left;
            player.moveSidewards(-50);
          }
          applyForce(desired);
        } else {   //if player is already outside of lowest platform
          println("outside");
          
          PVector tmp = PVector.sub(p_center, pos); 
          tmp.normalize();
          tmp.add(pos);
          pos= tmp.sub(pos);
          player.jumpUp(100);
          
        }
      }
      //if (pos.x > p.right.x && pos.x < p.left.x) {

      //  player.moveSidewards(-100);
      //} else {
      //  player.moveSidewards(100);
      //  //player.jumpUp(100);
      //}
    }
  }


  IntDict sorted_p_pair; 
  StringList sorted_p;
  int next_low_platform(float current_ground) {
    ArrayList<SumoJumpPlatformMeasurement> platforms = player.sensePlatforms();
    strokeWeight(10);
    for (SumoJumpPlatformMeasurement p : platforms) {
      if (p.left.y< current_ground) {
        sorted_p = new StringList();
        sorted_p.append(str(p.left.y));
        sorted_p_pair = new IntDict();
        sorted_p_pair.set(str(p.left.y), p.id);
      } 
    }
    if (sorted_p.size()>0) {
      sorted_p.sort();
      int lowest_pId = sorted_p_pair.get(sorted_p.get(sorted_p.size()-1));
      return lowest_pId;
    } else {
      println("no platforms.");
      return -1;
    }
  }
  
  void applyForce (PVector force) {
      player.sensePositionInPixelWorld().add(force);
      
    }


  String getName() {
    return "TMA";
  }

  char getLetter() {
    return 'T';
  }

  color getColor() {
    return color(0, 120, 255);
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
    stroke(0, 0, 0, 120);
    strokeWeight(6);
    line(0, 0, proprio.velocity.x, proprio.velocity.y);
  }
}
