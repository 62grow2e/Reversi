import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.Date; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Reversi extends PApplet {

//coded by Yota Odaka

//othello program

final int SIZE = 50; // width and height size of a square
final int NUM_SIDE = 8; // the number of squares in a row or column
final int FIELD_WIDTH = SIZE*NUM_SIDE; // width of board size
final int FIELD_HEIGHT = SIZE*NUM_SIDE; // height of board size
final int STONE_SIZE = (int)(SIZE*0.7f); // diameter of stone
final int NONE = 0; // indicate empty square
final int BLACK = 1; // indicate square where black stone put or winner is black
final int WHITE = 2; // indicate square where white stone put or winner is white
final int DRAW = -1; // indicate this game ended in a draw
final int OTHELLO_WHITE = color(230); // white color
final int OTHELLO_BLACK = color(10); // black color
final int OTHELLO_GREEN = color(0, 128, 0); // green color


Manager manager;

int global_t = 0; // this value will show frame count

// prepare this program
public void setup(){
  	size(10*SIZE, 10*SIZE);
  	//manager = new Manager();
	manager = new Manager(false);
}

// main program
public void draw(){
  	background(40);
  	manager.update(global_t);
  	global_t++;
}

//mouse event
public void mousePressed(){
  	manager.mousePressed(mouseX, mouseY);
}



// caded by Yota Odaka

// class of AI
public class Ai  {
	Manager manager;
	private boolean isBlack;
	private boolean isMyTurn;

	// constructor
	public Ai (boolean amIBlack, Manager manager) {
		this.manager = manager;
		this.isBlack = amIBlack;
		this.isMyTurn = (amIBlack)?true: false;
	}

	// boot up AI
	public void run() {
		// for a rainy day
		if(this.manager.isGameOver)return;
		if(this.manager.isPass)return;
		this.isMyTurn = (this.manager.black_turn==this.isBlack)?true:false;
		if(!this.isMyTurn)return;
		if(this.manager.indicator.bPlayerFrameAnimation)return;
		// decide AI stone position
		PVector newStonePos = decideStonePos();
		// put stone by AI, and change turn when this method is finished
		this.manager.putStone((int)newStonePos.x, (int)newStonePos.y);
		// finish AI trun
		this.isMyTurn = false;
	}

	// decide next stone position based on evaluation value
	public PVector decideStonePos() {
		PVector bestStep = new PVector(-1, -1, -1); // stone position x,y, evalucation value z 
		int num_criteria = 3; // the number of criteria
		float[] coefficients = {0.5f, 0.2f, 0.3f}; // weighting
		float evaluationValue[][][] = new float[NUM_SIDE][NUM_SIDE][num_criteria+1]; // 1st, 2nd indexes, 3rd each values
		// initialize 
		for(float[][] eValues: evaluationValue){
			for (float[] eValues2 : eValues) {
				for(float eValue: eValues2){
					eValue = 0;
				}
			}
		}
		// evaluate
		for(int i = 0; i < NUM_SIDE; i++){
			for(int j = 0; j < NUM_SIDE; j++){
				if(!this.manager.field.isOpen[i][j])continue;
				evaluationValue[i][j][0] += this.valueOfStandardMovesToEvaluationValue(i, j);
				evaluationValue[i][j][1] += this.valueOfStonesYouCanGetToEvaluationValue(i, j);
				evaluationValue[i][j][2] += this.valueOfTheoryOfDegreeOfOpenToEvaluationValue(i, j);
			}
		}
		// integrate each evaluation values into a evaluation value 
		for(int i = 0; i < NUM_SIDE; i++){
			for(int j = 0; j < NUM_SIDE; j++){
				if(!this.manager.field.isOpen[i][j])continue;
				for(int k = 0; k < num_criteria; k++){
					evaluationValue[i][j][num_criteria] += coefficients[k]*evaluationValue[i][j][k];
				}			
			}
		}
		// compare values of all spaces, and decide best move
		for(int i = 0; i< NUM_SIDE; i++){
			for(int j = 0; j < NUM_SIDE; j++){
				if(!this.manager.field.isOpen[i][j])continue;
				// find max of evaluation values
				if(evaluationValue[i][j][num_criteria]>bestStep.z){
					bestStep.x = i;
					bestStep.y = j;
					bestStep.z = evaluationValue[i][j][num_criteria];
				}
			}
		}
		return new PVector((int)bestStep.x, (int)bestStep.y);
	}

	// evaluate efficiency of standard moves
	private float valueOfStandardMovesToEvaluationValue(int x, int y) {
		// corner
		if(x+y==0 || x*y==(NUM_SIDE-1)*(NUM_SIDE-1) || (x==0&&y==NUM_SIDE-1) || (x==NUM_SIDE-1&&y==0))return 1.0f; 
		// edge
		if(x==0 || y==0 || x==NUM_SIDE-1 || y==NUM_SIDE-1)return 0.8f;
		// inside of corner
		if(x*y==1 || (x==1&&y==NUM_SIDE-2) || (x==NUM_SIDE-2&&y==1) || (x==NUM_SIDE-2&&y==NUM_SIDE-2))return 0.0f;
		// next to edge
		if(x==1 || x==NUM_SIDE-2 || y==1 || y==NUM_SIDE-2)return 0.1f;
		// else
		return 0.5f;
	}

	// evaluate based on the number of stones which you can get at once
	private float valueOfStonesYouCanGetToEvaluationValue(int x, int y) {
		int num_stonesYouCanGet = 0;
		float evaluationValueHere = 0; // evaluation value which will return 
		// check all direction around myself
		for(int i = -1; i < 2; i++){
			for(int j = -1; j < 2; j++){
				if(i == 0 && j == 0)continue;
				if(!this.manager.field.isOpenDir[x][y][i+1][j+1])continue;
				// add the number of stones which will reverse if a stone put here(x, y)
				num_stonesYouCanGet += stonesYouCanGet(x+i, y+j, i, j, this.isBlack);
			}
		}
		// normalize the number of stones which you could reverse
		evaluationValueHere = (float)num_stonesYouCanGet/18.f; // max stones which are returned at once is 18
		return evaluationValueHere;
	}

	// recursion method that is called in addValueOfStonesYouCanGetToEvaluationValue()
	private int stonesYouCanGet(int x, int y, int dir_x, int dir_y, boolean isMyColorBlack) {
		int myColor = (isMyColorBlack)?BLACK: WHITE;
		// end of counting stones
		if(this.manager.field.field[x][y] == myColor)return 0;
		//recursion
		return 1+stonesYouCanGet(x+dir_x, y+dir_y, dir_x, dir_y, isMyColorBlack);
	}
	
	// evaluate based on the theory of a degree of open
	private float valueOfTheoryOfDegreeOfOpenToEvaluationValue(int x, int y) {
		if(x < 0 || NUM_SIDE-1 < x || y < 0 || NUM_SIDE-1 < y)return 0;
		float[][] tempDegreesOfOpen = calculateDegreesOfOpenFromField(this.manager.field, this.isBlack);
		float max = 0.f;
		for(float[] vals: tempDegreesOfOpen){
			for(float val: vals){
				max = (val>max)?val: max;
			}
		}
		for(float[] vals: tempDegreesOfOpen){
			for(float val: vals){
				val /= max;
			}
		}
		return tempDegreesOfOpen[x][y];
	}

	// theory of a degree of open
	//ArrayList<PVector> buffer_openIndex = new ArrayList<PVector>(); // buffer for overlap of indexes of open space,  
	private float[][] calculateDegreesOfOpenFromField(Field fieldObj, boolean isBlackTurn) {
		float[][] valuesOfAll = new float[NUM_SIDE][NUM_SIDE];
		for(float[] vals: valuesOfAll){
			for (float val : vals) {
				val = 0;
			}
		}
		if(fieldObj.field.length != NUM_SIDE || fieldObj.field[0].length != NUM_SIDE)return valuesOfAll;
		
		for(int i = 0; i < NUM_SIDE; i++){
			for (int j = 0; j < NUM_SIDE; j++) {
				if(!fieldObj.isOpen[i][j])continue;
				// initialize buffer
				ArrayList<PVector> buffer_openIndex = new ArrayList<PVector>();
				// check all direction
				for(int _i = -1; _i < 2; _i++){
					for(int _j = -1; _j < 2; _j++){
						if(!fieldObj.isOpenDir[i][j][_i+1][_j+1])continue;
						this.countTheNumberOfSpaceOpen(i+_i, j+_j, _i, _j, isBlackTurn, fieldObj, buffer_openIndex);
					}
				}
				valuesOfAll[i][j] = buffer_openIndex.size();
			}
		}
		return valuesOfAll;
	}

	private void countTheNumberOfSpaceOpen(int x, int y, int dir_x, int dir_y, boolean isMyColorBlack, Field fieldObj, ArrayList<PVector> buffer) {
		int myColor = (isMyColorBlack)?BLACK: WHITE;
		if(myColor == fieldObj.field[x][y])return;
		for(int i = -1; i < 2; i++){
			for(int j = -1; j < 2; j++){
				int target_x = x+i;
				int target_y = y+j;
				if(target_x<0 || NUM_SIDE-1<target_x || target_y<0 || NUM_SIDE-1<target_y)continue;
				if(fieldObj.field[target_x][target_y] != NONE)continue;
				boolean bValid = true;
				for(PVector buff: buffer){
					if(!bValid)break;
					if(buff.x==target_x && buff.y==target_y)bValid &= false;
				}
				if(bValid)buffer.add(new PVector(target_x, target_y));
			}
		}
		this.countTheNumberOfSpaceOpen(x+dir_x, y+dir_y, dir_x, dir_y, isMyColorBlack, fieldObj, buffer);
	}

}
//coded by Yota Odaka



class CSVExporter{
	String[] keys = {"id","player1", "player2", "winner"};
	String header = "";
	Table table = loadTable("gamedata.csv", "header");

	public CSVExporter () {
	}

	public void addValues(int p1, int p2, int winner) {
		TableRow newRow = this.table.addRow();
		newRow.setInt(this.keys[0], this.table.getRowCount()-1);
		newRow.setInt(this.keys[1], p1);
		newRow.setInt(this.keys[2], p2);
		String winnerName = "none";
		switch (winner) {
			case BLACK:
				winnerName = "black";
				break;
			case WHITE:
				winnerName = "white";
				break;
			case DRAW :
				winnerName = "draw";
				break;
			default :
				winnerName = "none";
				break;	
		}
		newRow.setString(this.keys[3], winnerName);
		saveTable(this.table, "data/gamedata.csv");
	}

	public void save() {
		String filename = "data/"+String.format("%1$tY%1$tm%1$td-%1$tH%1$tM%1$tS%1$tL", new Date())+".csv";
		saveTable(this.table, filename);
	}
}
//coded by Yota Odaka

// this class return value of process of each easing motions
public class Easing {
	public Easing () {
	}

	public float easeIn(float t, float begin, float end, float duration) {
		t /= duration;
		return end*t*t+begin;
	}

	public float easeOut(float t, float begin, float end, float duration) {
		t /= duration;
		return -end*t*(t-2.0f) + begin;
	}

	public float easeInOut(float t, float begin, float end, float duration) {
		t /= duration/2.f;
		if(t < 1)return end/2.0f*t*t + begin;
		t--;
		return -end/2.f*(t*(t-2.f)-1.f) + begin;
	}
}
//coded by Yota Odaka

// this class will show board graphics
public class Field{

	Stones stones;

	int[][] field;
	PVector[][] fieldPos;
	boolean[][] isOpen;
	boolean[][][][] isOpenDir; //1st,2nd are indexes, 3rd,4th are direction vector

	boolean bTurningAnimation = false;

	// constructor
	public Field () {
		stones = new Stones(this);

		this.field = new int[NUM_SIDE][NUM_SIDE];
		this.fieldPos = new PVector[NUM_SIDE][NUM_SIDE];
		this.isOpen = new boolean[NUM_SIDE][NUM_SIDE];
		this.isOpenDir = new boolean[NUM_SIDE][NUM_SIDE][3][3];
		for(int i=0; i<NUM_SIDE; ++i){
			for(int j=0; j<NUM_SIDE; ++j){
				this.field[i][j] = NONE;
				this.fieldPos[i][j] = new PVector((i*2+1)*SIZE/2+SIZE,(j*2+1)*SIZE/2+SIZE);
				this.isOpen[i][j] = false;
			}
		}
		// set initial stones
		this.field[NUM_SIDE/2-1][NUM_SIDE/2-1] = WHITE;
		this.field[NUM_SIDE/2][NUM_SIDE/2] = WHITE;
		this.field[NUM_SIDE/2-1][NUM_SIDE/2] = BLACK;
		this.field[NUM_SIDE/2][NUM_SIDE/2-1] = BLACK;
	}

	// draw all field visuals
	public void draw() {
		// draw board
		rectMode(CORNER);
		colorMode(RGB);
		stroke(0);
		strokeWeight(1);
		fill(OTHELLO_GREEN);
		rect(width*.1f, height*.1f, FIELD_WIDTH, FIELD_HEIGHT);
 		// draw board lines
 		stroke(30);
 		strokeWeight(2);
 		for(int i=1; i<NUM_SIDE; i++){
 			line(i*SIZE+SIZE,SIZE,i*SIZE+SIZE,height-SIZE);
 			line(SIZE, i*SIZE+SIZE, width-SIZE, i*SIZE+SIZE);
 		}
 		// indicate which squares you can put stones
        this.blinkOpenSpace();
    }

    // indicate which squares you can put stones
    private void blinkOpenSpace(){
		rectMode(CENTER);
		//blink color
		float ele_red = 128.f*sin(global_t*.07f)+128.f;
		stroke(128, 0, 0, 255);
		strokeWeight(2);
		fill((int)ele_red, 0, 0, 80);
		// if a square is available, blink
		for(int i = 0; i < NUM_SIDE; i++){
			for(int j = 0; j < NUM_SIDE; j++){
				if(this.isOpen[i][j]){
					rect(fieldPos[i][j].x, fieldPos[i][j].y, SIZE, SIZE);
				}
			}
		}
	}

}
//coded by Yota Odaka

// this class will show status view and so on
public class Indicator {

	Manager manager;
	Easing easing;

	// to slide a frame over players 
	boolean isTargetTurnBlack;
	float frameAnimation_t = 0;
	float frameAnimationDuration = 30;
	boolean bPlayerFrameAnimation = false;
	final int frameWidth = 120;
	final int frameHeight = 45;
	PVector playerFramePos;
	// frosted cover background color
	final int frostedCoverColor = color(180, 150);
	
	// constructor
	public Indicator (Manager manager) {
		this.manager = manager;
		this.easing = new Easing();

		if(this.manager.black_turn)this.playerFramePos = new PVector(frameWidth/2, frameHeight/2+3);
		else this.playerFramePos = new PVector(width-this.frameWidth/2, this.frameHeight/2+3);
	}

 	// draw visuals
	public void draw() {
		this.drawPlayer();
		this.drawResult();
	}

	// draw player colors and a frame
	private void drawPlayer() {	
		// color
		textSize(SIZE*.6f);
		textAlign(LEFT, TOP);
		fill(OTHELLO_WHITE);
		text("BLACK", 10, 5);
		textAlign(RIGHT, TOP);
		fill(OTHELLO_WHITE);
		text("WHITE", width-10, 5);
		// frame
		drawPlayerFrame();
	}

	// draw a frame over player colors
	private void drawPlayerFrame() {
		// trigger frame animation when this turn have to pass
		if(this.manager.isPass)this.bPlayerFrameAnimation = true;
		// animate frame transition
		if(this.bPlayerFrameAnimation)this.animatePlayerTransition(this.isTargetTurnBlack);
		// frame
		rectMode(CENTER);
		stroke(0xffff0000);
		strokeWeight(2);
		fill(0xffff0000, 30);
		rect(this.playerFramePos.x, this.playerFramePos.y, this.frameWidth, frameHeight);
		// if this turn have to pass, announce this
		if(this.manager.isPass){
			// frost background
			rectMode(CENTER);
			fill(frostedCoverColor);
			noStroke();
			rect(width/2, height/2, width, height/2);
			// text
			textAlign(CENTER);
			textSize(50);
			fill(0xff000088);
			stroke(0);
			strokeWeight(2);
			text("Pass", width/2, height/2);
		}
	}

	// animate frame transition
	private void animatePlayerTransition(boolean isNextBlack) {
		// for a rainy day
		if(!this.bPlayerFrameAnimation)return;
		// when next player is black
		if(isNextBlack){
			// easing
			float newFrameX = this.easing.easeInOut(this.frameAnimation_t, (float)width-(float)this.frameWidth/2, -(float)width+(float)this.frameWidth, this.frameAnimationDuration);
			this.playerFramePos.x = newFrameX;
		}
		// when next player is white
		else if(!isNextBlack){
			//easing
			float newFrameX = this.easing.easeInOut(this.frameAnimation_t, (float)this.frameWidth/2, (float)width-(float)this.frameWidth, this.frameAnimationDuration);
			this.playerFramePos.x = newFrameX;
		}
		// finish easing
		if(this.frameAnimationDuration <= this.frameAnimation_t){
			this.frameAnimation_t = 0.f;
			this.bPlayerFrameAnimation = false;
			this.manager.isPass = false;
		}
		// update parameter
		else this.frameAnimation_t++;
	}

	// draw result view
	private void drawResult() {
		// for a rainy day
		if(!this.manager.isGameOver)return;
		if(!this.bPlayerFrameAnimation){
			String resultWinner = "winner: ";
			// set color of the winner
			if(this.manager.winner == BLACK)resultWinner += "BLACK";
			else if(this.manager.winner == WHITE)resultWinner += "WHITE";
			else if(this.manager.winner == DRAW)resultWinner += "DRAW";
			// frost background
			rectMode(CENTER);
			fill(frostedCoverColor);
			noStroke();
			rect(width/2, height/2, width, height/2);
			// draw winner
			textAlign(CENTER);
			textSize(50);
			fill(0xff880000);
			text(resultWinner, width/2, height/2);
			//draw scores
			textSize(40);
			if(this.manager.winner==BLACK)textSize(50);
			else textSize(40);
			textAlign(LEFT);
			fill(0);
			text((int)this.manager.getScores().x, width/3, height/2+100);
			if(this.manager.winner == WHITE)textSize(50);
			else textSize(40);
			textAlign(RIGHT);
			fill(255);
			text((int)this.manager.getScores().y, 2*width/3, height/2+100);
		}
	}

}
//coded by Yota Odaka

// this class take all management of the game
public class Manager  {
	int t;

	Field field;
	Stones stones;
	Indicator indicator;
	Ai ai;
	CSVExporter csv;

	boolean isOpponentAi = false;
	boolean isOpponentBlack = false;

	boolean black_turn = true;
	boolean isGameOver = false;
	boolean isPass = false;
	boolean isSaved = false;

	int winner = NONE; // decide at end of the game

	// constructor
	public Manager () {
		t = 0;

		this.field = new Field();
		this.stones = new Stones(field);
		this.indicator = new Indicator(this);
		this.csv = new CSVExporter();

		this.detectSpaceOpen(this.black_turn); // initialize which square you can put
		
		this.isOpponentAi = false;
	}

	// constructor for playing with AI opponent
	public Manager(boolean isOpponentBlack) {
		this();
		// AI part
		this.isOpponentAi = true;
		this.isOpponentBlack = isOpponentBlack;
		this.ai = new Ai(this.isOpponentBlack, this);
	}

	//this method have to called in main draw()
	public void update(int global_t) {
		this.t = global_t;
		this.field.draw();
		this.stones.draw();
		this.indicator.draw();
		if(isOpponentAi)this.ai.run();

		if(this.isGameOver && !this.isSaved){
			this.csv.addValues((int)this.getScores().x, (int)this.getScores().y, winner);
			this.isSaved = true;
		}
	}

	//if at least one square is available, return true
	public boolean isThereOpen() {
		for(boolean[] b_array: this.field.isOpen){
			for(boolean b: b_array){
				if(b)return true;
			}
		}
		return false; // if no square is available
	}

	//return the number of squares where is stones put
	public int getStonePut() {
		int stoneCount = 0;
		for(int i = 0; i < NUM_SIDE; i++){
			for(int j = 0; j < NUM_SIDE; j++){
				if(this.field.field[i][j] != NONE)stoneCount++;
			}
		}
		return stoneCount;
	}

	//return now score
	public PVector getScores() {
		//x element is black score, another is white score
		int blackCount = 0;
		int whiteCount = 0;
		for(int i = 0; i < NUM_SIDE; i++){
			for(int j = 0; j < NUM_SIDE; j++){
				if(this.field.field[i][j] == BLACK)blackCount++;
				else if(this.field.field[i][j] == WHITE)whiteCount++;
			}
		}
		return new PVector(blackCount, whiteCount);
	}

	//put stone
	public void putStone(int x, int y) {
		// you cannot play if animation is run
		if(this.indicator.bPlayerFrameAnimation)return;
		
		if(this.field.field[x][y]==NONE){
			// black turn
			if(this.black_turn && this.field.isOpen[x][y]){
				// set stone
				this.field.field[x][y] = BLACK;
				//reverse stones
				this.returnStones(x, y);
				// change turn
				this.black_turn = !this.black_turn;
				// set direction of animation of frame
				this.indicator.isTargetTurnBlack = this.black_turn;
			}
			//white turn
			else if(!this.black_turn && this.field.isOpen[x][y]){
				this.field.field[x][y] = WHITE;
				// reverse stones
				this.returnStones(x, y);
				// change turn
				this.black_turn = !this.black_turn;
				// set direction of animation of frame
				this.indicator.isTargetTurnBlack = this.black_turn;
			}
			if(this.field.isOpen[x][y]){
				// trigger a animation of frame
				this.indicator.bPlayerFrameAnimation = true;
			}
		}
		// find available squares
		this.detectSpaceOpen(this.black_turn);

		// judge whether game is over or not.
		// if all square is filled.
		if(this.getStonePut() == NUM_SIDE*NUM_SIDE){
			// decide which player is the winner
			if(this.getScores().x>this.getScores().y)winner = BLACK;
			else if(this.getScores().x<this.getScores().y)winner = WHITE;
			else winner = DRAW;
			// trigger of event of gameover 
			this.isGameOver = true;
		}
		// if not all square is filled.
		else if(this.getScores().x*this.getScores().y==0 && this.getScores().mag()!=0){
			// judge which player is the winner
			if(this.getScores().x>this.getScores().y)winner = BLACK;
			else if(this.getScores().x<this.getScores().y)winner = WHITE;
			else winner = DRAW;
			// trigger of event of gameover
			this.isGameOver = true;
		}
		// judge whether this turn have to pass
		else{
			if(!this.isThereOpen()){
				this.isPass = true;
				this.black_turn = !this.black_turn;
				this.indicator.isTargetTurnBlack = this.black_turn;
				this.detectSpaceOpen(this.black_turn);
			}		
		}
		// trigger for processing of AI
		if(isOpponentAi)this.ai.isMyTurn = (this.ai.isBlack==this.black_turn)?true: false;
	}

	//mouse event
	public void mousePressed(int mx, int my){
		if(this.isOpponentAi && this.ai.isMyTurn)return;
		// put stones on the field
		// whether mouse click is in valid area 
		if(this.field.fieldPos[0][0].x-SIZE/2 < mx 
			&& mx < this.field.fieldPos[NUM_SIDE-1][0].x+SIZE/2
			&& this.field.fieldPos[0][0].y-SIZE/2 < my
			&& my < this.field.fieldPos[0][NUM_SIDE-1].y+SIZE/2){
			
			// convert mouse position to index of square
			int x = (mouseX-SIZE)/SIZE;
			int y = (mouseY-SIZE)/SIZE;

			// put stone on x, y
			this.putStone(x, y);
		}
	}

	// reverse stones
	private void returnStones(int _x, int _y){
		// check all direction
		for(int i = -1; i < 2; i++){
			for(int j = -1; j < 2; j++){
				if(i == 0 && j==0)continue;
				if(this.field.isOpenDir[_x][_y][i+1][j+1])this.returnStones(_x, _y, this.black_turn, i, j, true);
			}
		}
	}

	// recursion method to reverse stones
	private void returnStones(int _x, int _y, boolean _bBlackTrun, int i, int j, boolean isFirstDetect){
		boolean bBlackTrun = _bBlackTrun;
		int myColor = (_bBlackTrun)?BLACK:WHITE;
		int hisColor = (_bBlackTrun)?WHITE:BLACK;
		if(!isFirstDetect && this.field.field[_x][_y] == hisColor){
			// put stone
			this.field.field[_x][_y] = myColor;
			// trigger reverse animation
			this.stones.bAnimation[_x][_y] = true;
		}
		// if this stone is the same color as this player's color, end this method
		else if(!isFirstDetect && this.field.field[_x][_y] == myColor)return;
		// else, call myself again
		this.returnStones(_x+i, _y+j, _bBlackTrun, i, j, false);
	}

	// check whether each directions of all squares are available
	public void detectSpaceOpen(boolean black_turn){
		boolean bBlackTrun = black_turn;
		for(int i = 0; i < NUM_SIDE; i++){
			for (int j = 0; j < NUM_SIDE; j++) {
				this.field.isOpen[i][j] = this.detectSpaceOpen(i, j, bBlackTrun);
			}
		}
	}

	// check whether each directions of a square are available
	private boolean detectSpaceOpen(int _x, int _y, boolean _bBlackTrun){
		//if this square is empty, return false
		if(this.field.field[_x][_y] != NONE)return false;
		boolean bBlackTrun = _bBlackTrun;
		boolean bValid = false;
		// check all directions
		for(int i = -1; i < 2; i++){
			for(int j = -1; j < 2; j++){
				if(i==0 && j==0)continue;
				boolean bTemp = this.detectSpaceOpen(_x, _y, bBlackTrun, i, j, true);
				this.field.isOpenDir[_x][_y][i+1][j+1] = false;
				if(bTemp)this.field.isOpenDir[_x][_y][1+i][1+j] = true;
				bValid |=  bTemp;
			}
		}
		return bValid;
	}

	// recursion method to find directions that stones can reverse
	private boolean detectSpaceOpen(int _x, int _y, boolean _bBlackTrun, int dir_x, int dir_y, boolean isFirstDetect){
		// which color this turn is now
		int tempColor = (_bBlackTrun)?BLACK:WHITE;
		// target index
		_x += dir_x;
		_y += dir_y;
		// if this target is out of board, return false
		if(_x<0 || NUM_SIDE-1<_x || _y<0 || NUM_SIDE-1<_y)return false;
		//if this target is empty, return false
		if(this.field.field[_x][_y] == NONE)return false;
		//if color whose is next to start stone is same, return false
		if(isFirstDetect && this.field.field[_x][_y]  == tempColor)return false;
		//if there is/are a/some stone/stones between stones which is same color, return true
		if(!isFirstDetect && this.field.field[_x][_y] == tempColor)return true;
		//if color of stone which is checked now is same color, call myself(recursion)
		return this.detectSpaceOpen(_x, _y, _bBlackTrun, dir_x, dir_y, false);
	}
}
//coded by Yota Odaka

// this class will show stones graphics 
public class Stones  {
	Field field;

	boolean[][] bAnimation = new boolean[NUM_SIDE][NUM_SIDE];
	int[][] animationTime = new int[NUM_SIDE][NUM_SIDE]; // process time of animation
	final int animationEndTime = 20; // duration of animation

	// constructor
	public Stones (Field field) {
		this.field = field;
		//initialize process time
		for (int[] at_1 : animationTime) {
			for (int at_2 : at_1) {
				at_2 = 0;	
			}
		}
	}

	// draw visuals
	public void draw() {
		// draw stones
		noStroke();
		// draw stones with gradation
		for(int i=0; i<NUM_SIDE; i++){
			for(int j=0; j<NUM_SIDE; j++){
				// animate reversing stones
				if(bAnimation[i][j])animateTuring(i, j);
				else {
					if(this.field.field[i][j]==BLACK){
    	    			fill(0,30);
    	    		}else if(this.field.field[i][j]==WHITE){
        				fill(255,30);
        			}
        			for(int k = 1; k < STONE_SIZE; k++){
        				if(this.field.field[i][j]!=NONE)ellipse(this.field.fieldPos[i][j].x, this.field.fieldPos[i][j].y, k, k);
        			}
        		}
        	}
        }
	}

	//animate a stone turning
	private void animateTuring(int _i, int _j){
		// for a rainy day
		if(!bAnimation[_i][_j])return;
		// return false, if empty
		if(this.field.field[_i][_j] == NONE)return;
		boolean isNextBlack = (this.field.field[_i][_j]==BLACK)?true:false;

		noStroke();
		// change color 
		if(isNextBlack){
			if(animationTime[_i][_j] < animationEndTime/2)fill(OTHELLO_WHITE, 30);
			else fill(OTHELLO_BLACK, 30);	
		}
		else if(!isNextBlack){
			if(animationTime[_i][_j] < animationEndTime/2)fill(OTHELLO_BLACK, 30);
			else fill(OTHELLO_WHITE, 30);
		}
		// draw turn
		for(int k = 0; k < STONE_SIZE; k++){
			pushMatrix();
			translate(this.field.fieldPos[_i][_j].x, this.field.fieldPos[_i][_j].y);
			rotate(-PI/6);
			ellipse(0, 0, (float)k*cos(PI*(float)animationTime[_i][_j]/(float)animationEndTime), k);	
			popMatrix();
		}
		// forward time
		animationTime[_i][_j]++;
		// finish animation when time is over
		if (animationTime[_i][_j] >= animationEndTime)endAnimation(_i, _j);
	}

	//end up turning animation, and this function called in only animateTurning()
	private void endAnimation(int _i, int _j){
		bAnimation[_i][_j] = false;
		animationTime[_i][_j] = 0;
	}
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Reversi" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
