class SumoJumpProprioceptiveMeasurement {
  boolean onFloor;        // true, if he player currently touches the floor
  PVector velocity;       // Relative velocity in pixel/s
  float stamina;          // Remaining power (not implemented yet)
  float bodyRadius;       // Size of the main body part
  float perceptionRadius; // Platforms can only perceived over this distance
}

class SumoJumpPlatformMeasurement {
  PVector left;                   // Relative position of left upper corner (in pixels)
  PVector right;                  // Relative position of left upper corner (in pixels)
  boolean standingOnThisPlatform; // True, if this is the platform the player is currently standing on
  int id;                         // Every platform has an individual identifier
}

class SumoJumpOpponentMeasurement {
  PVector position;     // Position (in pixels) relative to player
  float distance;       // mag(position), for convenience
  int id;               // Every player has an individual identifier
}

class SumoJumpGoalMeasurement {
  PVector position;     // Position (in pixels) relative to player
  float distance;       // mag(position), for convenience
  int id;               // Every goal has an individual identifier
}
