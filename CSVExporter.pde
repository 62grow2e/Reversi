//coded by Yota Odaka

import java.util.Date;

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