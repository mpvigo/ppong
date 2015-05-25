/********************************************************************
 Pong
 
 Todo:
 .add sounds

 *********************************************************************/

int SCREEN_Y_MARGIN = 2;
int SCREEN_X_MARGIN = 6;


class Paddle
{
  public static final int PADDLE_WIDTH = 8;
  public static final int PADDLE_HEIGHT = 32;

  Paddle(int _posX)
  {
    posX = _posX;
    posY = height / 2;
  }

  void move(int _y)
  {
    posY = _y;

    if (posY < SCREEN_Y_MARGIN + PADDLE_HEIGHT/2) posY = SCREEN_Y_MARGIN + PADDLE_HEIGHT/2;
    if (posY+PADDLE_HEIGHT/2 + SCREEN_Y_MARGIN > height) posY = height - PADDLE_HEIGHT/2 - SCREEN_Y_MARGIN;
  }

  boolean hit(Ball b)
  {
    boolean hitPaddle = false;

    int distX = abs(posX - b.posX);
    if (distX <= (PADDLE_WIDTH/2 + b.BALL_WIDTH/2))
    {
      int distY = abs(posY - b.posY);

      if (distY <= PADDLE_HEIGHT/2)
      {
        b.dirX = -b.dirX;
        b.speedX = b.speedX * 1.2; // increase speed
        if (b.speedX > 8.0) b.speedX = 8.0;
        hitPaddle = true;

        // change ball angle/speed based on where it hit the paddle
        if (distY == 0)
          b.dirY = 0;  
        else
          b.dirY = (distY/(b.posY - posY));

        if (distY <= PADDLE_HEIGHT/4)
          b.speedY = 1.5;
        else if (distY <= PADDLE_HEIGHT/3)
          b.speedY = 3;
        else if (distY <= PADDLE_HEIGHT/2)
          b.speedY = 4;
      }
    }

    return hitPaddle;
  }

  int posX;
  int posY = 0;
  int score = 0;
};


class Ball
{
  public static final int BALL_WIDTH = 8;
  public static final float BALL_START_SPEED = 2.8;

  Ball()
  {
    reset(1);
  }

  void move()
  {
    posX += (int)dirX*speedX;
    posY += (int)dirY*speedY;

    if (posX < BALL_WIDTH || posX > width - BALL_WIDTH) 
    {
      out = true;
      dirX = -dirX;
      posX += (int)dirX*speedX;
    }

    if (posY < BALL_WIDTH || posY > height - BALL_WIDTH) 
    { 
      dirY = -dirY; 
      posY += (int)dirY*speedY;
    }
  }

  void reset(int dir)
  {
    posX = width/2;
    posY = (int)random(BALL_WIDTH, height - BALL_WIDTH);

    dirX = dir;
    dirY = 1.0;
    speedX = speedY = BALL_START_SPEED;

    out = false;
  }

  int posX;
  int posY;

  float dirX;
  float dirY;

  float speedX;
  float speedY;

  boolean out;
};

Paddle leftPaddle;
Paddle rightPaddle;
Ball ball;

boolean start = true;
boolean P2cpu = true;

void setup()
{
  size(640, 480, P2D);  

  noSmooth();
  rectMode(CENTER);
  background(0);
  fill(255);
  noStroke();

  SCREEN_X_MARGIN = width / SCREEN_X_MARGIN;

  leftPaddle = new Paddle(SCREEN_X_MARGIN);
  rightPaddle = new Paddle(SCREEN_X_MARGIN * 5);
  ball = new Ball();

  // load font for scores
  PFont scoreFont = loadFont("DrifterFiveAl-48.vlw");
  textFont(scoreFont);
  textSize(36);
}

void draw() 
{
  handledKeys();

  if (start)
    title();
  else
    game();
}

int KEYSPEEDACC = 1;
int keySpeed = KEYSPEEDACC;

void handledKeys() 
{
  if (keyPressed) 
  {
    if (start)
    {
      if (key == '1') 
      {
        start = false;
        P2cpu = true;
      } 
      else if (key == '2') 
      {
        start = false;
        P2cpu = false;
      }
      leftPaddle.score = rightPaddle.score = 0;
      ball.reset(1);
    }
    else if (!P2cpu && key == CODED)
    {
      if (keyCode == UP)
      {
        rightPaddle.move(rightPaddle.posY -= keySpeed);
        keySpeed += KEYSPEEDACC;
      }
      else if (keyCode == DOWN)
      {
        rightPaddle.move(rightPaddle.posY += keySpeed);
        keySpeed += KEYSPEEDACC;
      }
    }
  }
}

void keyReleased() 
{
  if (!P2cpu && key == CODED)
  {
    if (keyCode == UP || keyCode == DOWN)
      keySpeed = KEYSPEEDACC;
  }
}

void title()
{
  ball.speedX = ball.speedY = 8.0;
  ball.move();

  background(0);
  textAlign(CENTER);
  text("Pong", width /2, height/2-38);
  text("Press 1 to play cpu", width /2, height/2);
  text("Press 2 to play P2", width /2, height/2+38);
  drawNet();  
  drawBall(ball);
  drawScores();
}

void game()
{
  // get updated movement and move paddles
  leftPaddle.move(mouseY);
  if (P2cpu) 
  {
    int computer_AI = rightPaddle.posY + (int)(((float)ball.posY - rightPaddle.posY) * random(0.1, 0.4));
    rightPaddle.move(computer_AI);
  }

  // move ball
  ball.move();
  if (ball.out)    
  {
    // update scores and reserve
    if (ball.dirX <0)
    {
      ball.reset(1);
      leftPaddle.score = leftPaddle.score + 1;
      if (leftPaddle.score == 11) start = true;
    } 
    else
    {
      ball.reset(-1);
      rightPaddle.score = rightPaddle.score + 1;
      if (rightPaddle.score == 11) start = true;
    }
  }
  else
  {
    // check collisions
    if (ball.dirX > 0)
      rightPaddle.hit(ball);
    else
      leftPaddle.hit(ball);
  }

  // draw everything
  background(0);
  drawPaddle(leftPaddle);
  drawPaddle(rightPaddle);
  drawNet();  
  drawBall(ball);
  drawScores();

  /*
   filter(DILATE);
   filter(BLUR);
   
   for (int sl = 0; sl < height-4; sl+=4) {
   stroke(32,32,32,32);
   strokeWeight(1);
   line(0, sl, width-1,sl);
   }
   */
}

/**********************
 * RENDER FUNCTIONS
 **********************/
void drawScores()
{
  text(leftPaddle.score, SCREEN_X_MARGIN * 2, 60);
  text(rightPaddle.score, SCREEN_X_MARGIN * 4, 60);
}

void drawPaddle(Paddle p)
{
  rect(p.posX, p.posY, p.PADDLE_WIDTH, p.PADDLE_HEIGHT);
}

void drawBall(Ball b)
{
  rect(b.posX, b.posY, b.BALL_WIDTH, b.BALL_WIDTH);
}

int NET_DASHES = 8;
int NET_SPACES = 8;

void drawNet()
{
  int step = NET_DASHES + NET_SPACES;
  for (int y = step; y < height - NET_DASHES; y+=step)
    rect(width / 2, y, NET_DASHES/2, NET_DASHES);
}

