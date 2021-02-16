import processing.sound.SoundFile;

// Parametros bolas
int cx, cy, incx, incy, rad, defaultIncX, defaultIncY, maxIncX, maxIncY, ballIncVelX;

// Parametros paletas
int px1, py1, px2, py2, sizeX, sizeY, inc1, inc2, playerVelocity;

int score1, score2;
int maxScore;
PFont f;

// Ultimo golpe
boolean hitPlayer1;
boolean hitPlayer2;

// Sonidos
SoundFile reboundSound;
SoundFile scoreSound;
SoundFile victorySound;

// Pantalla de inicio
boolean isInIntro;

void setup() {
  size(500,500);
  isInIntro = true;
  f = createFont("Arial",26,true); 
  maxScore = 3;
  
  // Maximos valores de incremeto
  maxIncX = 3;
  maxIncY = 6;
  
  // Caracteristicas bola
  ballIncVelX=1;
  rad = 15;
  
  // Caracteristicas de los jugadores
  px1 = 50;
  px2 = width -50;
  sizeX = 5;
  sizeY = 40;
  inc1 = 0;
  inc2 = 0;
  playerVelocity = 5;
  
  //Sonidos
  reboundSound = new SoundFile(this,"rebote.mp3");
  scoreSound = new SoundFile(this,"score.mp3");
  victorySound = new SoundFile(this,"victory.mp3");
  
  init();
}

void init() {
  score1 = 0;
  score2 = 0;
  hitPlayer1 = false;
  hitPlayer2 = false;

  // Inicializar bola
  cx=width/2;
  cy=height/2;

  calculateDefaultInc();
  incx = defaultIncX;
  incy = defaultIncY;
  
  //Inicializamos jugador
  py1 =height/2;
  py2 = height/2;
}

void calculateDefaultInc() {
  // Cambiamos el sentido con el 50% de probabilidad
  if (random(1) <0.5f) {
    defaultIncX = 1 + (int) random(maxIncX);
  } else
    defaultIncX = -1 -(int) random(maxIncX);

  // Cambiamos el sentido con el 50% de probabilidad
  if (random(1) <0.5f) {
    defaultIncY = 1 + (int) random(maxIncY);
  } else
    defaultIncY = -1 -(int) random(maxIncY);
 
  
}
int x;
void draw() {
  background(0);
  
  if (isInIntro)
    drawIntro();
  else if (score1 < maxScore && score2 < maxScore) {
    drawField();
  
    // Dibujamos la linea del centro
    checkRebound();
    drawPlayers();
    drawBall();
  } else
    drawEndScreen();
}

void drawIntro() {
  textAlign(CENTER);
  f = createFont("Arial",62,true); 
  textFont(f);
  text("Pong",width/2,height/5); 
  
  textAlign(LEFT);
  f = createFont("Arial",24,true); 
  textFont(f);
  text("Controles",width/20,height/3); 
  f = createFont("Arial",20, true); 
  textFont(f);
  text("Player 1:     Movimiento arriba/abajo: Teclas w/s",width/20,height/2.4);
  text("Player 2:     Movimiento arriba/abajo: Flechas",width/20,height/2.0);  

  textAlign(CENTER);
  f = createFont("Arial",16,true); 
  textFont(f);
  text("Pulsa enter para jugar",width/2,height/1.25); 
}

void drawEndScreen() {
  textAlign(CENTER);
  f = createFont("Arial",62,true); 
  textFont(f);
  if (score1 < score2)
    text("Jugador 2 gana",width/2,height/2); 
  else
    text("Jugador 1 gana",width/2,height/2); 
  f = createFont("Arial",32,true); 
  textFont(f);
  text(score1 + " - " + score2,width/2,height/1.5); 

  f = createFont("Arial",24,true); 
  textFont(f);
  text("Pulsa enter para continuar",width/2,height/1.25); 
}
void drawField () {
  stroke(255,255,255,100);
  strokeWeight(3);
  int lineSize = 12;
  for(int i=lineSize*3; i<height-lineSize*3; i= i +lineSize*2){
    line(width/2,i,width/2,i+lineSize);
  }
  
  // Score
  textFont(f);
  textAlign(LEFT);
  text(score1,width/5,40); 

  textAlign(RIGHT);
  text(score2,width-width/5,40); 
}
void drawPlayers() {
  if (inc1 < 0) py1 = max(py1+inc1,0);
  else py1 = min(py1+inc1,height-sizeY);
  
  if (inc2 < 0) py2 = max(py2+inc2,0);
  else py2 = min(py2+inc2,height-sizeY);
  
  rect(px1,py1,sizeX,sizeY);
  rect(px2,py2,sizeX,sizeY);
}

void keyPressed() {
  if (inc1 == 0)
    if (key == 'w' || key == 'W') inc1 = -playerVelocity;
    else if (key == 's' || key == 'S') inc1 = playerVelocity;
  
  if (inc2 == 0)
    if (keyCode == UP) inc2 = -playerVelocity;
    else if (keyCode == DOWN) inc2 = playerVelocity;
    
  if (keyCode == ENTER) {
    if (isInIntro) isInIntro = false;
    else if (score1 == maxScore || score2 == maxScore)
      init();
  }
}

void keyReleased() {
  if (key == 'w' || key == 's' || key == 'W' || key == 'S') inc1 = 0;
  
  if (keyCode == UP || keyCode == DOWN) inc2 = 0;
}

void drawBall() {  
  cx=cx+incx;
  cy=cy+incy;
  circle(cx,cy,rad);  
}

void checkRebound() {
  // Miramos los limites del tablero
  if ((cx + rad/2 >width || cx-rad/2<0) || 
    (cy + rad/2 >height || cy-rad/2<0)) checkPoint();
  
  // Solo miramos a los jugadores si no fueron los ultimos en golpear
  if (!hitPlayer1) checkPlayer1();
  if (!hitPlayer2) checkPlayer2();
}

void checkPoint() {
  if (cy + rad/2 >height || cy-rad/2<0) {
    incy=-incy;
    reboundSound.play();
  }
  
  if (cx + rad/2 >width || cx-rad/2<0) {
    if (cx < width/2) score2++;
    else score1++;
    
    // Recalculamos valores por defecto
    calculateDefaultInc();
    
    // Devolvemos valores por defecto
    hitPlayer2 = false;
    hitPlayer1 = false;
    incx = defaultIncX;
    incy = defaultIncY;
    
    cx = width/2;
    cy = height/2;
    if (score1 < maxScore && score2 < maxScore) scoreSound.play();
    else victorySound.play(); 
  }
  

}

void checkPlayer1() {
  // Guardamos las posiciones para calcular si tocamos la bola
  float testX = cx;
  float testY = cy;

  // Calculamos que lado esta más cerca
  if (cx < px1)         testX = px1;     
  else if (cx > px1+sizeX) testX = px1+sizeX;
  if (cy < py1)         testY = py1; 
  else if (cy > py1+sizeY) testY = py1+sizeY;   
  
  // Calculamos la distancia entre cx y cy y los puntos guardados
  float distX = cx-testX;
  float distY = cy-testY;
  float distance = sqrt((distX*distX) + (distY*distY));
  
  // Si la distancia es menor al radio de la esfera es que estamos dentro
  if (distance<rad){
    reboundSound.play();
    // Si la esfera se encuentra por debajo del jugador
    if (py1 + sizeY*0.2 > cy) // Si el centro del circulo se encuentra por encima del 20% de la paleta
      incy = -defaultIncY; // Se moverá para arriba siempre
    
    // Si la esfera se encuentra a la derecha o izquierda del jugador
    else if (py1 + sizeY*0.8 > cy)
      incy = 0;
    else incy = defaultIncY; // Siempre se moverá para abajo
    
    // La direccion de X cambian en cualquier caso, tambien incrementará su velocidad
    if (incx>0)
      incx = -incx-ballIncVelX; 
    else
      incx = -incx+ballIncVelX;

    hitPlayer2 = false;
    hitPlayer1 = true;
  }
  
}

void checkPlayer2() {
  // Guardamos las posiciones para calcular si tocamos la bola
  float testX = cx;
  float testY = cy;

  // Calculamos que lado esta más cerca
  if (cx < px2)         testX = px2;     
  else if (cx > px2+sizeX) testX = px2+sizeX;
  if (cy < py2)         testY = py2; 
  else if (cy > py2+sizeY) testY = py2+sizeY;   
  
  // Calculamos la distancia entre cx y cy y los puntos guardados
  float distX = cx-testX;
  float distY = cy-testY;
  float distance = sqrt((distX*distX) + (distY*distY));
  
  // Si la distancia es menor al radio de la esfera es que estamos dentro
  if (distance<=rad){
    reboundSound.play();
    // Si la esfera se encuentra por debajo del jugador
    if (py2 + sizeY*0.2> cy) // Si el centro del circulo se encuentra por encima del 20% de la paleta
      incy = -defaultIncY; // Se moverá para arriba siempre
    
    // Si la esfera se encuentra a la derecha o izquierda del jugador
    else if (py2 + sizeY*0.8 > cy)
      incy = 0;
    else
      incy = defaultIncY; // Siempre se moverá para abajo
    
    // La direccion de X cambian en cualquier caso, tambien incrementará su velocidad
    if (incx>0)
      incx = -incx-ballIncVelX; 
    else
      incx = -incx+ballIncVelX;
      

    hitPlayer1 = false;
    hitPlayer2 = true;
  }
}
