//coded by Yota Odaka

//othello program

final int SIZE = 50; // width and height size of a square
final int NUM_SIDE = 8; // the number of squares in a row or column
final int NUM_GAME_PHASE  = NUM_SIDE*NUM_SIDE-3;
final int FIELD_WIDTH = SIZE*NUM_SIDE; // width of board size
final int FIELD_HEIGHT = SIZE*NUM_SIDE; // height of board size
final int STONE_SIZE = (int)(SIZE*0.7); // diameter of stone
final int NONE = 0; // indicate empty square
final int BLACK = 1; // indicate square where black stone put or winner is black
final int WHITE = 2; // indicate square where white stone put or winner is white
final int DRAW = -1; // indicate this game ended in a draw
final color OTHELLO_WHITE = color(230); // white color
final color OTHELLO_BLACK = color(10); // black color
final color OTHELLO_GREEN = color(0, 128, 0); // green color


Manager manager;

int global_t = 0; // this value will show frame count

// prepare this program
void setup(){
  	size(10*SIZE, 10*SIZE);
  	//manager = new Manager();
	manager = new Manager(false);
}

// main program
void draw(){
  	background(40);
  	manager.update(global_t);
  	global_t++;
}

//mouse event
void mousePressed(){
  	manager.mousePressed(mouseX, mouseY);
}

void keyPressed(){
	manager.keyPressed(key);
}
