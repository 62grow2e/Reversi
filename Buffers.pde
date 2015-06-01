public class Buffers  {
	ArrayList<PhaseBuffer> buffers;
	int tempPhase = 0;
	public Buffers () {
		buffers = new ArrayList<PhaseBuffer>();
	}

	public void save(int[][] tField, int tPut_x, int tPut_y, boolean tBlack, int phase) {
		println("called:", phase);
		this.tempPhase = phase;
		this.buffers.add(new PhaseBuffer(tField, new PVector(tPut_x, tPut_y), tBlack));
	}
	public void save(PhaseBuffer tempStatus, int phase) {
		println("tempStatus: "+tempStatus);
		println("saved-phase: "+phase);
		this.tempPhase = phase;
		this.buffers.add(tempStatus);
		//this.buffers[phase].save(tempStatus);
		//this.buffers[phase] = new PhaseBuffer(tempStatus.fieldBuffer, tempStatus.putPosBuffer, tempStatus.turnColor);
	}
	public void optimize() {
		println("buffers.size()", buffers.size());
		for(int i = this.buffers.size()-1; i > this.tempPhase; i--){
			this.buffers.remove(i);
		}
	}
	public PhaseBuffer get(int phase) {
		return buffers.get(phase);
	}
	public PhaseBuffer get(int phase, boolean bPhaseSync) {
		if(bPhaseSync)this.tempPhase = phase;
		int[][] rField = new int[NUM_SIDE][NUM_SIDE];
		for(int i = 0; i < NUM_SIDE; i++){
			for(int j = 0; j < NUM_SIDE; j++){
				rField[i][j] = this.buffers.get(phase).fieldBuffer[i][j];
			}
		}
		PVector rPutPos = this.buffers.get(phase).putPosBuffer;
		int rColor = this.buffers.get(phase).turnColor;
		PhaseBuffer result = new PhaseBuffer(rField, rPutPos, rColor);// buffers.get(phase);
		this.optimize();
		return result;
	}
	public void printPhase() {
		println("print all phase buffers");
		for(int phase = 0; phase <= this.tempPhase; phase++){
			println("-------------------");
			println("phase: "+phase);
			println("turnColor(black-1, white-2): "+this.buffers.get(phase).turnColor);
			for(int i = 0; i < NUM_SIDE; i++){
				for(int j = 0; j < NUM_SIDE; j++){
					print(this.buffers.get(phase).fieldBuffer[j][i]+" ");
					if(j==NUM_SIDE-1)println("");
				}
			}
		}
	}
}