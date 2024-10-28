// Required imports //<>// //<>//
import processing.serial.*;

PGraphics pg;

/******************

GAME OBJECTS

********************/
EnemySquadron enemySquadron;
PlayerShip player;
PlayerBullet[] playerBullets;
EnemyBullet[] enemyBullets;
Missile[] missiles;

int[][] startGameMessage1;
int[][] startGameMessage2;
int[][] startGameMessage3;
int[][] startGameMessage4;

/******************

MEDIA RESOURCES

********************/

int[][] gameOverMessage;
int[][] youWonMessage;

AlienFonts alienFonts;

/********************

GAME VARIABLES

**********************/
int frameThrottle = 0;
int scale = 3;
int shipDirection = 0;
boolean launchBullet = false;
ScoreBoard scoreBoard;
PFont font;

int gameMode = 0;
int gameOverTimer = 0;
int squadronSpeed = 40;

// Serial communication for joystick
Serial myPort; // Create object from Serial class
float joystickX;
int buttonZ;
final static int ANALOG_MAX = 4095; // Assuming 12-bit ADC for joystick values

void setup() {
  size(800, 600);
  pg = createGraphics(width, height);
  
  // Initialize serial communication
  println("Available serial ports:");
  printArray(Serial.list());
  
  String[] ports = Serial.list();
  // Automatically select the port that contains "COM" or "tty"
  String portName = Serial.list()[5];

  if (portName != null) {
    println("Connecting to serial port: " + portName);
    myPort = new Serial(this, portName, 115200);
  } else {
    println("Error: Serial port not found. Skipping serial initialization.");
  }

  // Initialize game objects
  enemySquadron = new EnemySquadron();
  player = new PlayerShip();
  playerBullets = new PlayerBullet[50];
  enemyBullets = new EnemyBullet[10];
  missiles = new Missile[5];

  for (int i = 0; i < playerBullets.length; i++) {
    playerBullets[i] = new PlayerBullet();
  }
  for (int i = 0; i < enemyBullets.length; i++) {
    enemyBullets[i] = new EnemyBullet();
  }

  // Initialize AlienFonts and game messages
  alienFonts = new AlienFonts();
  if (alienFonts == null) {
    println("Error: AlienFonts not initialized.");
    return;
  }

  startGameMessage1 = alienFonts.getSprite("towards front screw = left");
  startGameMessage2 = alienFonts.getSprite("towards back screw = right");
  startGameMessage3 = alienFonts.getSprite("button click = fire");
  startGameMessage4 = alienFonts.getSprite("keyboard click = start game");

  gameOverMessage = alienFonts.getSprite("you're dead... game over!!!!");
  youWonMessage = alienFonts.getSprite("you won!");

  // Initialize game state variables
  frameThrottle = 0;
  scoreBoard = new ScoreBoard();
  scoreBoard.X = -1;
  scoreBoard.Y = -2;
  font = createFont("courier new", 32);

  println("Setup complete without null exceptions.");

  // Set frame rate for smoother gameplay
  frameRate(60);
}

void draw() {
  // Read serial data from joystick and button
  if (myPort != null && myPort.available() > 0) {
    String val = myPort.readStringUntil('\n');
    if (val != null) {
      val = trim(val);
      println("Received data: " + val);

      String[] xyzStrings = split(val, ",");
      println(xyzStrings);
      if (xyzStrings.length >= 3) {
        try {
          int xVal = int(xyzStrings[0]);
          int yVal = int(xyzStrings[1]);
          int zVal = int(xyzStrings[3]);
          
          println("x-value:" + xVal);
          println("y-value:" + yVal);
          println("z-value:" + zVal);

          // Map joystick values to game logic
          joystickX = xVal;
          buttonZ = zVal; // Z-axis value for the button state

          // Implement dead zone for joystick
          int min_threshold = 1650;
          int max_threshold = 1900;
          if (abs(joystickX) < max_threshold && abs(joystickX) > min_threshold) {
            shipDirection = 0; // No movement
          } else if (abs(joystickX) < min_threshold && abs(joystickX) > 0) {
            shipDirection = 1; // Move left
          } else if (abs(joystickX) > max_threshold && abs(joystickX) < 4000) {
            shipDirection = 2; // Move right
          }
          println("direction: ", shipDirection);

          // Handle shooting based on button press (Z-axis)
          if (buttonZ == 0) { // Adjusted for INPUT_PULLUP (LOW when pressed)
            launchBullet = true;
          }

          // Debugging output (optional)
          // println("shipDirection: " + shipDirection + ", launchBullet: " + launchBullet);
        } catch (NumberFormatException e) {
          println("Error parsing serial data: " + e.getMessage());
        }
      } else {
        println("Invalid data received: " + val);
      }
    }
  }

  // Game mode handling
  switch (gameMode) {
    case 0:
      screenSaver();
      break;
    case 1:
      playGame();
      break;
    case 2:
      gameOver();
      break;
    case 3:
      youWon();
      break;
  }
}

void resetGame() {
  squadronSpeed = 40;
  enemySquadron = new EnemySquadron();
  scoreBoard.Lives = 3;
  scoreBoard.Score = 0;
  player.reset();
  gameMode = 1;
  player.X = 120;
  player.Y = 170;
}

// Commented out keyboard input to prevent conflicts with joystick
/*
void keyPressed() {
  if (gameMode == 0) {
    if (key == 's') {
      resetGame();
    }
  } else if (gameMode == 1) {
    if (key == 'j') {
      shipDirection = 1;
    }
    if (key == 'k') {
      shipDirection = 2;
    }
    if (key == 'f') {
      launchBullet = true;
    }
  }
}
j
void keyReleased() {
  shipDirection = 0;
}
*/

void mousePressed() {
  // Allow starting the game with a mouse click
  if (gameMode == 0) {
    resetGame();
  }
}

/***********************************************

   Screens

************************************************/
void playGame() {
  background(204);

  if (scoreBoard.X == -1) {
    scoreBoard.X = 40;
    scoreBoard.Y = height - 20;
  }
  if (pg != null) {
    pg.beginDraw();
    pg.clear();

    fill(0, 0, 0);
    stroke(0, 0, 0);
    rect(0, 0, width, height);

    // Update enemy squadron movement
    if (frameThrottle % squadronSpeed == 0) {
      enemySquadron.update(scale, width, 0, height);

      if (enemySquadron.DownSteps == 9) {
        squadronSpeed = 2;
      } else if (enemySquadron.DownSteps == 7) {
        squadronSpeed = 5;
      } else if (enemySquadron.DownSteps == 4) {
        squadronSpeed = 10;
      } else if (enemySquadron.DownSteps == 2) {
        squadronSpeed = 20;
      }
    }

    // Update player movement
    player.update(shipDirection, scale, width);

    // Handle user input for shooting
    checkUserInput();

    // Enemy shooting
    if (frameThrottle %  40 == 0 || frameThrottle %  60 == 0) {
      shootEnemyBullet();
    }

    // Update bullets
    updateBullets();

    // Collision detection
    detectAlienHits();
    detectPlayerHits();
    detectAlienPlayerCollision();

    // Drawing functions
    drawEnemySquadron();
    drawPlayer();
    drawBullets();
    drawEnemyBullets();
    drawScoreBoard();

    pg.endDraw();
  }

  if (scoreBoard.Lives == 0) {
    gameOverTimer = 200;
    gameMode = 2;
  } else if (enemySquadron.liveEnemiesCount() < 1) {
    gameOverTimer = 200;
    gameMode = 3;
  }

  frameThrottle++;
}

void screenSaver() {
  background(204);

  if (scoreBoard.X == -1) {
    scoreBoard.X = 40;
    scoreBoard.Y = height - 20;
  }
  if (pg != null) {
    pg.beginDraw();
    pg.clear();

    fill(0, 0, 0);
    stroke(0, 0, 0);
    rect(0, 0, width, height);

    drawEnemySquadron();
    drawPlayer();
    drawBullets();
    drawScoreBoard();

    fill(255, 255, 255);
    int x = (width / 5) / scale;
    int y = (height / 2) / scale;

    drawSprite(x, y + 20, startGameMessage1, 2);
    drawSprite(x, y + 40, startGameMessage2, 2);
    drawSprite(x, y + 60, startGameMessage3, 2);
    drawSprite(x, y + 80, startGameMessage4, 2);

    pg.endDraw();
  }

  frameThrottle++;
}

void gameOver() {
  background(204);

  if (pg != null) {
    pg.beginDraw();
    pg.clear();

    fill(0, 0, 0);
    stroke(0, 0, 0);
    rect(0, 0, width, height);

    noStroke();
    fill(0, 255, 0);
    int x = 5;
    int y = (height / 2) / scale;

    drawSprite(x, y, gameOverMessage, 4);
    pg.endDraw();
  }

  frameThrottle++;

  gameOverTimer--;

  if (gameOverTimer < 0) {
    gameMode = 0;
  }
}

void youWon() {
  background(204);

  if (pg != null) {
    pg.beginDraw();
    pg.clear();

    fill(0, 0, 0);
    stroke(0, 0, 0);
    rect(0, 0, width, height);

    noStroke();
    fill(0, 255, 0);
    int x = 5;
    int y = (height / 2) / scale;

    drawSprite(x, y, youWonMessage, 4);
    pg.endDraw();
  }

  frameThrottle++;

  gameOverTimer--;

  if (gameOverTimer < 0) {
    gameMode = 0;
  }
}
//*************End of screens

/***********************************************************

    Actions... shoot bullets, launch bullets, etc.

***********************************************************/

void checkUserInput() {
  if (launchBullet) {
    for (PlayerBullet bullet : playerBullets) {
      if (!bullet.isAlive()) {
        bullet.launch(player.X + player.Image[0][0].length / 2, player.Y + player.Image[0].length / 2);
        // Reset launchBullet to prevent continuous firing
        launchBullet = false;
        break;
      }
    }
  }
}

void detectAlienHits() {
  EnemyShip[] enemies = enemySquadron.getSprites();

  for (EnemyShip s : enemies) {
    for (PlayerBullet pb : playerBullets) {
      if (!pb.isAlive() || !s.isAlive())
        continue;

      if (pb.hitAlien(s.X, s.top(), s.Image[0][0].length, s.Image[0].length)) {
        pb.killBullet();
        s.takeHit();
        scoreBoard.Score += 100;
      }
    }
  }
}

void detectAlienPlayerCollision() {
  EnemyShip[] enemies = enemySquadron.getSprites();

  for (EnemyShip s : enemies) {
    if (!s.isAlive())
      continue;

    if (abs(s.X - player.X) < s.Image[0][0].length + player.Image[0][0].length) {
      if (abs(s.Y - player.Y) < s.Image[0].length + player.Image[0].length) {
        s.takeHit();
        player.takeHit();
        scoreBoard.Lives--;
        scoreBoard.Score += 100;
        break;
      }
    }
  }
}

void detectPlayerHits() {
  for (EnemyBullet eb : enemyBullets) {
    if (!eb.isAlive(width) || !player.isAlive())
      continue;

    if (eb.hitAlien(player.X, player.Y, player.Image[0][0].length, player.Image[0].length)) {
      eb.killBullet();
      player.takeHit();
      scoreBoard.Lives--;
    }
  }
}

void shootEnemyBullet() {
  int randomEnemy = (int) random(enemySquadron.liveEnemiesCount());
  EnemyShip[] enemies = enemySquadron.getSprites();
  int count = -1;
  boolean shotFired = false;
  for (int i = 0; i < enemies.length; i++) {
    if (enemies[i].isAlive()) {
      count++;
      if (randomEnemy == count) {
        for (EnemyBullet bullet : enemyBullets) {
          if (!bullet.isAlive(800)) {
            bullet.launch(enemies[i].X, enemies[i].Y);
            shotFired = true;
            break;
          }
        }
      }
    }

    if (shotFired)
      break;
  }
}

void updateBullets() {
  for (PlayerBullet pb : playerBullets) {
    pb.update();
  }

  for (EnemyBullet eb : enemyBullets) {
    eb.update();
  }
}

//**************** End of actions

/***********************************************************

    Drawing Functions

***********************************************************/

void drawBullets() {
  Sprite first = playerBullets[0];
  fill(first.R, first.G, first.B);
  stroke(first.R, first.G, first.B);
  for (Sprite s : playerBullets) {
    drawSprite(s.X, s.Y, s.Image[0]);
  }
}

void drawEnemyBullets() {
  Sprite first = enemyBullets[0];
  fill(first.R, first.G, first.B);
  stroke(first.R, first.G, first.B);
  for (Sprite s : enemyBullets) {
    drawSprite(s.X, s.Y, s.Image[0]);
  }
}

void drawEnemySquadron() {
  EnemyShip[] enemies = enemySquadron.getSprites();

  EnemyShip first = enemies[0];
  fill(first.R, first.G, first.B);
  stroke(first.R, first.G, first.B);

  int i = 0;
  for (EnemyShip s : enemies) {
    if (!s.isAlive()) {
      i++;
      continue;
    }

    int row = i / 8;
    switch (row) {
      case 0:
      case 2:
        stroke(255, 255, 255);
        fill(255, 255, 255);
        break;
      case 1:
      case 3:
        stroke(80, 255, 80);
        fill(80, 255, 80);
        break;
    }
    drawSprite(s.X, s.Y, s.Image[s.currentImage]);
    i++;
  }
}

void drawGameOverText(int x, int y) {
  textFont(font);

  fill(100, 100, 200);
  text("Game Over!", x, y);
}

void drawPlayer() {
  if (player.isAlive()) {
    fill(player.R, player.G, player.B);
    stroke(player.R, player.G, player.B);
    drawSprite(player.X, player.Y, player.Image[0]);
  }
}

void drawSprite(int x, int y, int[][] image) {
  for (int i = 0; i < image.length; i++) {
    for (int j = 0; j < image[i].length; j++) {
      if (image[i][j] == 1) {
        int newX = x * scale + j * scale + 3 * scale;
        int newY = y * scale + i * scale + 3 * scale;
        rect(newX, newY, scale, scale);
      }
    }
  }
}

void drawScoreBoard() {
  noStroke();
  fill(100, 100, 200);
  int x = 20;
  int y = (height - 50) / 4;
  for (String line : scoreBoard.getLines()) {
    int[][] message = alienFonts.getSprite(line);
    drawSprite(x, y, message, 4);
    x += 80;
  }
}

void drawSprite(int x, int y, int[][] image, int scale) {
  for (int i = 0; i < image.length; i++) {
    for (int j = 0; j < image[i].length; j++) {
      if (image[i][j] == 1) {
        int newX = x * scale + j * scale;
        int newY = y * scale + i * scale;
        rect(newX, newY, scale, scale);
      }
    }
  }
}

void drawStartScreenText(int x, int y) {
  textFont(font);
  fill(100, 100, 200);

  text("Press s to start", x, y);
  text("use j and k to move left and right", x, y + 30);
  text("use f to fire", x, y + 60);
}
