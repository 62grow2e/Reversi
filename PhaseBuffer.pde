public class PhaseBuffer  {
	int phase;
	boolean isPushed;
	int fieldBuffer[][];
	PVector putPosBuffer;
	int turnColor;
	public PhaseBuffer () {
		this.isPushed = false;
		this.fieldBuffer = new int[NUM_SIDE][NUM_SIDE];
		for(int i = 0; i < NUM_SIDE; i++){
			for(int j = 0; j < NUM_SIDE; j++){
				this.fieldBuffer[i][j] = -1;
			}
		}
		this.putPosBuffer = new PVector(-1, -1);
		this.turnColor = NONE;
	}

	public PhaseBuffer(int[][] tempField, PVector lastPutPos, int tempColor) {
		this.fieldBuffer = tempField;
		this.putPosBuffer = lastPutPos;
		this.turnColor = tempColor;
	}

	public PhaseBuffer(int[][] tempField, PVector lastPutPos, boolean isBlackTurn) {
		int tempColor = (isBlackTurn)? BLACK: WHITE;
		
		this.fieldBuffer = tempField;
		this.putPosBuffer = lastPutPos;
		this.turnColor = tempColor;
	}
	public void save(int[][] tempField, int temp_x, int temp_y, boolean tempBlack) {
		this.fieldBuffer = tempField;
		putPosBuffer.set(temp_x, temp_y);
		this.turnColor = (tempBlack)? BLACK: WHITE;
		
	}
	public void save(PhaseBuffer tempStatus) {
		this.isPushed = true;
		this.fieldBuffer = tempStatus.fieldBuffer;
		this.putPosBuffer = tempStatus.putPosBuffer;
		this.turnColor = tempStatus.turnColor;
	}
	public void clear() {
		this.isPushed = false;
		for(int i = 0; i < NUM_SIDE; i++){
			for(int j = 0; j < NUM_SIDE; j++){
				this.fieldBuffer[i][j] = NONE;
			}
		}
		this.putPosBuffer.set(-1, -1);
		this.turnColor = NONE;
	}
	public void setField(int field[][]) {
		this.fieldBuffer = field;
	}
	public void setPutPos(PVector pos) {
		this.putPosBuffer.set(pos);
	}

	public int[][] getField() {
		return this.fieldBuffer;
	}
	public PVector getPutPos() {
		return this.putPosBuffer;
	}

}