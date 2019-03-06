
import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;
import java.util.Collections;


Box2DProcessing box2d;
SumoJumpEngine gameEngine;
PImage backgroundImage;


void setup() {
  size(1024, 700);
  backgroundImage = loadImage("background.png");
  initGame();
}


void initGame() {
  // Initialize and create the Box2D world
  box2d = new Box2DProcessing(this);  
  box2d.createWorld();
  box2d.setGravity(0, -98.1);
  // Turn on collision listening!
  box2d.listenForCollisions();

  // Create the engine
  gameEngine = new SumoJumpEngine("level1.csv");

  // Create a test player
  //SumoJumpExampleKeyCtrl testController = new SumoJumpExampleKeyCtrl();
  //gameEngine.addController(testController);
  
  TMASumoJumpController uuJumpController = new TMASumoJumpController();
  gameEngine.addController(uuJumpController);
}


void keyPressed() {
  if (keyCode == 'D') {
    gameEngine.toggleAgentDebugDrawingDisplay();
  } else if (keyCode == 'S') {
    gameEngine.toggleAgentStatusDrawingDisplay();
  } else if (keyCode == 'R') {
    initGame();
  }
}


void drawBackground() {
  // A blue sky:
  //background(74, 184, 237);
  // Some grass:
  //noStroke();
  //fill(44, 137, 23);
  //rectMode(CORNER);
  //rect(0, height-30, width, 30);
  imageMode(CORNER);
  image(backgroundImage,0,0);
}


void draw() {
  drawBackground();
  if (gameEngine.getWinner() == null) {
    box2d.step();
    // We must always step through time!
    gameEngine.step();
  }
  gameEngine.draw();
  if (gameEngine.getWinner() != null) {
    textAlign(CENTER);
    textSize(120);
    fill(255, 200, 100);
    text("WINNER!", width/2, height/2.5);
    text(gameEngine.getWinner().getName(), width/2, height/1.5);
    textSize(20);
    textAlign(LEFT);
    text("Press R for restart", 30, 30);
  }
}


// Collision event function
void beginContact(Contact cp) {
  gameEngine.beginContact(cp);
}


void endContact(Contact cp) {
  // empty...
}
