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

	public Manager(boolean isOpponentBlack) {
		this();

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