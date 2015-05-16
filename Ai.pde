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
		float[] coefficients = {0.5, 0.2, 0.3}; // weighting
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
		// max of the values of the a degree of open
		float max = 0.f;
		for(float[] vals: tempDegreesOfOpen){
			for(float val: vals){
				max = (val>max)?val: max;
			}
		}
		// map values between the range from 0 to 1
		for(int i = 0; i < NUM_SIDE; i++){
			for(int j = 0; j < NUM_SIDE; j++){
				tempDegreesOfOpen[i][j] /= max;
			}
		}
		return tempDegreesOfOpen[x][y];
	}

	// theory of a degree of open
	//ArrayList<PVector> buffer_openIndex = new ArrayList<PVector>(); // buffer for overlap of indexes of open space,  
	private float[][] calculateDegreesOfOpenFromField(Field fieldObj, boolean isBlackTurn) {
		// values of all space
		float[][] valuesOfAll = new float[NUM_SIDE][NUM_SIDE];
		// initialize
		for(float[] vals: valuesOfAll){
			for (float val : vals) {
				val = 0;
			}
		}
		// end recursion
		if(fieldObj.field.length != NUM_SIDE || fieldObj.field[0].length != NUM_SIDE)return valuesOfAll;
		// continue recursion
		for(int i = 0; i < NUM_SIDE; i++){
			for (int j = 0; j < NUM_SIDE; j++) {
				if(!fieldObj.isOpen[i][j])continue;
				// initialize buffer
				ArrayList<PVector> buffer_openIndex = new ArrayList<PVector>();
				// check all direction
				for(int _i = -1; _i < 2; _i++){
					for(int _j = -1; _j < 2; _j++){
						if(!fieldObj.isOpenDir[i][j][_i+1][_j+1])continue;
						// check next to here(i, j)
						this.countTheNumberOfSpaceOpen(i+_i, j+_j, _i, _j, isBlackTurn, fieldObj, buffer_openIndex);
					}
				}
				// get raw data of a degree of open
				valuesOfAll[i][j] = buffer_openIndex.size();
			}
		}
		return valuesOfAll;
	}

	// this method will called as recursion in function calculateDegreesOfOpenFromField()
	private void countTheNumberOfSpaceOpen(int x, int y, int dir_x, int dir_y, boolean isMyColorBlack, Field fieldObj, ArrayList<PVector> buffer) {
		int myColor = (isMyColorBlack)?BLACK: WHITE;
		// if this stone color is same as mine, end
		if(myColor == fieldObj.field[x][y])return;
		// check around here(x, y)
		for(int i = -1; i < 2; i++){
			for(int j = -1; j < 2; j++){
				int target_x = x+i;
				int target_y = y+j;
				if(target_x<0 || NUM_SIDE-1<target_x || target_y<0 || NUM_SIDE-1<target_y)continue;
				if(fieldObj.field[target_x][target_y] != NONE)continue;
				boolean bValid = true;
				// check whether or not an overlap is exist
				for(PVector buff: buffer){
					// if there are overlaps, don't count 
					if(!bValid)break;
					if(buff.x==target_x && buff.y==target_y)bValid &= false;
				}
				// count
				if(bValid)buffer.add(new PVector(target_x, target_y));
			}
		}
		// recursion 
		this.countTheNumberOfSpaceOpen(x+dir_x, y+dir_y, dir_x, dir_y, isMyColorBlack, fieldObj, buffer);
	}
}