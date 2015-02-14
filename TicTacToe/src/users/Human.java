package users;

import java.util.Scanner;

import util.Log;
import environment.Game;

public class Human extends Player {
	private Scanner in;
	public Human(Game game, char move){
		super(game,move);
		this.in=new Scanner(System.in);
		this.tag="You";
	}
	
	public void chooseMove(){
		int i,j;
		do{
			Log.l("X:\t");
			i = in.nextInt();
			Log.l("Y:\t");
			j = in.nextInt();
		}
		while(!this.game.moveAllowed(i, j));
		this.game.move(tag, i, j, move);
	}

}
