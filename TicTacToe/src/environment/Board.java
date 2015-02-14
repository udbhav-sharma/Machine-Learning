package environment;
import util.Log;


public class Board {
	private int N;
	private char grid[][];
	public static final char defaultValue = ' ';
	public static final char cross = 'X';
	public static final char zero = '0';
	
	public Board(){
		this.N=3;
		this.formBoard();
	}
	
	public Board(int N){
		this.N=N;
		this.formBoard();
	}
	
	private void formBoard(){
		this.grid = new char[this.N][];
		
		for(int i=0;i<this.N;i++){
			this.grid[i] = new char[this.N]; 
		}
		
		for(int i=0;i<this.N;i++){
			for(int j=0;j<this.N;j++){
				this.grid[i][j]=Board.defaultValue;
			}
		}
	}
	
	public void reset(){
		this.formBoard();
	}
	
	public void move(String playerTag, int i, int j, char move){
		if(this.moveAllowed(i, j))
			this.grid[i][j]=move;
		else{
			Log.e(playerTag + " invalid Move ("+i+", "+j+")");
			System.exit(0);
		}
	}
	
	public boolean moveAllowed(int i, int j){
		return (i>=this.N || i<0 || j>=this.N || j<0 || this.grid[i][j]!=Board.defaultValue)?false:true;
	}
	
	public void hardMove(int i,int j, char move){
		if(i>=this.N || i<0 || j>=this.N || j<0){
			Log.e("Invalid move");
		}
		else{
			this.grid[i][j]=move;
		}
	}
	
	public char getState(int i, int j){
		return this.grid[i][j];
	}
	
	public int getN(){
		return this.N;
	}
	
	public char[][] getGrid(){
		return this.grid;
	}
	
	public boolean fill(){
		for(int i=0;i<this.N;i++){
			for(int j=0;j<this.N;j++){
				if(this.grid[i][j]==Board.defaultValue)
					return false;
			}
		}
		return true;
	}
	
	public String toString(){
		int i,j;
		String output="-------Board-------\n";
		
		for(i=0;i<this.N-1;i++){
			for(j=0;j<this.N-1;j++){
				output+=" "+this.grid[i][j]+" |";
			}
			output+=" "+this.grid[i][j]+" \n";
			
			for(j=0;j<this.N-1;j++){
				output+="--- ";
			}
			output+="---\n";
		}
		for(j=0;j<this.N-1;j++){
			output+=" "+this.grid[i][j]+" |";
		}
		output+=" "+this.grid[i][j]+" \n";
		
		return output;
	}
	
	public Board clone(){
		Board cloneBoard = new Board(this.N);
		cloneBoard.N=this.N;
		for(int i=0;i<this.N;i++){
			for(int j=0;j<this.N;j++){
				cloneBoard.grid[i][j] = this.grid[i][j]; 
			}
		}
		return cloneBoard;
	}
}
