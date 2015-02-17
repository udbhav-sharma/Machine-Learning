package users;

import java.util.Scanner;

import util.Log;
import environment.Board;
import environment.Game;

public class Human extends Player {
	private Scanner in;
	public Human(Game game, char move){
		super(game,move);
		this.in=new Scanner(System.in);
		this.tag="Human";
	}
	
	public void chooseMove(){
		int i,j;
		Board board = this.game.getBoard();
		do{
			Log.l("X:\t");
			i = in.nextInt();
			Log.l("Y:\t");
			j = in.nextInt();
		}
		while(!board.moveAllowed(i, j));
		board.move(tag, i, j, move);
	}

}
