package users;
import java.util.Random;

import util.Log;
import environment.Game;


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
		do{
			i = rand.nextInt(game.getN());
			j = rand.nextInt(game.getN());
			if(game.moveAllowed(i, j)){
				game.move(this.tag, i, j, this.move);
				break;
			}
		}
		while(true);
	}
	
	public void onGameCompletition(){
		Log.d(this.tag+" wins: "+this.winCount);
	}
	
	public void reset(){	
	}
	
	public String toString(){
		String output = "--------Player---------\n";
		output += "Win:\t"+this.winCount+"\n";
		return output;
	}
}
