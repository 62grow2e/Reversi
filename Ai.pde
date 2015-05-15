public class Ai  {
	Manager manager;

	private boolean isBlack;
	private boolean isMyTurn;
	public Ai (boolean amIBlack, Manager manager) {
		this.isBlack = amIBlack;
		this.manager = manager;
		this.isMyTurn = (amIBlack)?true: false;
	}

	public void run() {
		if(this.manager.isGameOver)return;
		if(this.manager.isPass)return;
		this.isMyTurn = (this.manager.black_turn==this.isBlack)?true:false;
		if(!this.isMyTurn)return;
		if(this.manager.indicator.bPlayerFrameAnimation)return;

		PVector newStonePos = decideStonePos();
		this.manager.putStone((int)newStonePos.x, (int)newStonePos.y);

		this.isMyTurn = false;
	}

	public PVector decideStonePos() {
		PVector bestStep = new PVector(-1, -1, -1);
		int num_citeria = 2;
		float[] coefficients = {0.5, 0.5};
		float evaluationValue[][][] = new float[NUM_SIDE][NUM_SIDE][num_citeria+1];
		for(float[][] eValues: evaluationValue){
			for (float[] eValues2 : eValues) {
				for(float eValue: eValues2){
					eValue = 0;
				}
			}
		}

		for(int i = 0; i < NUM_SIDE; i++){
			for(int j = 0; j < NUM_SIDE; j++){
				if(!this.manager.field.isOpen[i][j])continue;
				evaluationValue[i][j][0] += this.addValueOfStandardMovesToEvaluationValue(i, j);
				evaluationValue[i][j][1] += this.addValueOfStonesYouCanGetToEvaluationValue(i, j);
			}
		}

		for(int i = 0; i < NUM_SIDE; i++){
			for(int j = 0; j < NUM_SIDE; j++){
				if(!this.manager.field.isOpen[i][j])continue;
				for(int k = 0; k < num_citeria; k++){
					evaluationValue[i][j][num_citeria] += coefficients[k]*evaluationValue[i][j][k];
				}			
			}
		}

		for(int i = 0; i< NUM_SIDE; i++){
			for(int j = 0; j < NUM_SIDE; j++){
				if(!this.manager.field.isOpen[i][j])continue;
				if(evaluationValue[i][j][num_citeria]>bestStep.z){
					bestStep.x = i;
					bestStep.y = j;
					bestStep.z = evaluationValue[i][j][num_citeria];
				}
			}
		}
		return new PVector((int)bestStep.x, (int)bestStep.y);
	}

	private float addValueOfStandardMovesToEvaluationValue(int x, int y) {
		if(x+y==0 || x*y==(NUM_SIDE-1)*(NUM_SIDE-1) || (x==0&&y==NUM_SIDE-1) || (x==NUM_SIDE-1&&y==0))return 1.0; 
		if(x==0 || y==0 || x==NUM_SIDE-1 || y==NUM_SIDE-1)return 0.8;
		if(x*y==1 || (x==1&&y==NUM_SIDE-2) || (x==NUM_SIDE-2&&y==1) || (x==NUM_SIDE-2&&y==NUM_SIDE-2))return 0.0;
		if(x==1 || x==NUM_SIDE-2 || y==1 || y==NUM_SIDE-2)return 0.1;
		return 0.5;
	}

	private float addValueOfStonesYouCanGetToEvaluationValue(int x, int y) {
		int num_stonesYouCanGet = 0;
		float evaluationValueHere = 0;
		for(int i = -1; i < 2; i++){
			for(int j = -1; j < 2; j++){
				if(i == 0 && j == 0)continue;
				if(!this.manager.field.isOpenDir[x][y][i+1][j+1])continue;
				num_stonesYouCanGet += stonesYouCanGet(x+i, y+j, i, j, this.isBlack);
			}
		}
		evaluationValueHere = (float)num_stonesYouCanGet/18.f;
		return evaluationValueHere;
	}
	private int stonesYouCanGet(int x, int y, int dir_x, int dir_y, boolean isMyColorBlack) {
		int myColor = (isMyColorBlack)?BLACK: WHITE;
		if(this.manager.field.field[x][y] == myColor)return 0;
		return 1+stonesYouCanGet(x+dir_x, y+dir_y, dir_x, dir_y, isMyColorBlack);
	}
}