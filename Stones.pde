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