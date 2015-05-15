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
		// put stone by AI
		this.manager.putStone((int)newStonePos.x, (int)newStonePos.y);
		// finish AI trun
		this.isMyTurn = false;
	}

	// decide next stone position based on evaluation value
	public PVector decideStonePos() {
		PVector bestStep = new PVector(-1, -1, -1); // stone position x,y, evalucation value z 
		int num_criteria = 2; // the number of criteria
		float[] coefficients = {0.5, 0.5}; // weighting
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
				evaluationValue[i][j][0] += this.addValueOfStandardMovesToEvaluationValue(i, j);
				evaluationValue[i][j][1] += this.addValueOfStonesYouCanGetToEvaluationValue(i, j);
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
	private float addValueOfStandardMovesToEvaluationValue(int x, int y) {
		// corner
		if(x+y==0 || x*y==(NUM_SIDE-1)*(NUM_SIDE-1) || (x==0&&y==NUM_SIDE-1) || (x==NUM_SIDE-1&&y==0))return 1.0; 
		// edge
		if(x==0 || y==0 || x==NUM_SIDE-1 || y==NUM_SIDE-1)return 0.8;
		// inside of corner
		if(x*y==1 || (x==1&&y==NUM_SIDE-2) || (x==NUM_SIDE-2&&y==1) || (x==NUM_SIDE-2&&y==NUM_SIDE-2))return 0.0;
		// next to edge
		if(x==1 || x==NUM_SIDE-2 || y==1 || y==NUM_SIDE-2)return 0.1;
		// else
		return 0.5;
	}

	// evaluate based on the number of stones which you can get at once
	private float addValueOfStonesYouCanGetToEvaluationValue(int x, int y) {
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
}