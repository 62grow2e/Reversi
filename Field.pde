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
		rect(width*.1, height*.1, FIELD_WIDTH, FIELD_HEIGHT);
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
		float ele_red = 128.f*sin(global_t*.07)+128.f;
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