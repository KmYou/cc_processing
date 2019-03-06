abstract class SumoJumpController {
  
  SumoJumpPlayer player;
  
  SumoJumpController() {
  }
  
  abstract String getName();
  
  abstract char getLetter();
  
  abstract color getColor();
  
  abstract void act();
  
  void draw() {
  }
}
