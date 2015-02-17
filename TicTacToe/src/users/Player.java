package users;
import java.util.Random;

import util.Log;
import environment.Board;
import environment.Game;
import environment.Game.winner;


public class Player {
	
	public int winCount;
	protected Game game;
	protected char move;
	protected Random rand;
	protected String tag;
	
	public Player(Game game, char move){
		this.game = game;
		this.move = move;
		this.tag="Player";
		this.winCount= 0;
		rand = new Random();
	}
	
	public void chooseMove(){
		int i,j;
		Board board = this.game.getBoard();
		do{
			i = rand.nextInt(board.getN());
			j = rand.nextInt(board.getN());
			if(board.moveAllowed(i, j)){
				board.move(this.tag, i, j, this.move);
				break;
			}
		}
		while(true);
	}
	
	public void onGameCompletition(winner w){
		Log.d(this.tag+" wins: "+this.winCount);
	}
	
	public void reset(){	
		this.winCount=0;
	}
	
	public char getMove(){
		return this.move;
	}
	
	public String getTag(){
		return this.tag;
	}
	
	public String toString(){
		String output = "--------"+this.tag+"---------\n";
		output += "Win:\t"+this.winCount;
		return output;
	}
}
