package environment;

import users.Player;
import util.Log;

public class Game {
	
	private Board board;
	public enum winner{
		COMPUTER,PLAYER,DRAW,NOTCOMPLETED
	}
	
	public Game(){
		board = new Board();
	}
	
	public Game(int n){
		board = new Board(n);
	}
	
	public Board getBoard(){
		return this.board;
	}

	public boolean moveAllowed(int i, int j){
		return board.moveAllowed(i, j);
	}
	
	public void move(String playerTag, int i, int j, char move){
		board.move(playerTag, i, j, move);
	}
	
	public void playN(Player computer, Player player,int N, boolean train){
		for(int i=0;i<N;i++){
			if(!train){
				Log.l("-------New Game------");
			}
			this.board.reset();
			//computer.reset();
			//player.reset();
			this.play(computer, player, train);
		}
	}
	
	public void play(Player computer, Player player, boolean train){
		while(!this.complete()){
			computer.chooseMove();
			if(!train)
				Log.l(board);
			if(this.complete())
				break;
			player.chooseMove();
		}
		if(!train){
			winner w = this.getWinner(this.board);
			if(w==Game.winner.COMPUTER){
				Log.l("Computer wins");
			}
			else if(w==Game.winner.PLAYER){
				Log.l("Player wins");
			}
			else if(w==Game.winner.DRAW){
				Log.l("Match is draw");
			}
		}
		computer.onGameCompletition();
		player.onGameCompletition();
	}
	
	public int getN(){
		return this.board.getN();
	}
	
	public boolean complete(){
		winner w =this.getWinner(this.board);
		if(w == winner.NOTCOMPLETED)
			return false;
		return true;
	}
	
	public winner getWinner(Board board){
		if(this.checkWinner(board,Board.cross))
			return winner.COMPUTER;
		else if(this.checkWinner(board,Board.zero))
			return winner.PLAYER;
		else if(board.fill())
			return winner.DRAW;
		return winner.NOTCOMPLETED;
	}
	
	private boolean checkWinner(Board board,char move){
		int n = this.board.getN();
		char grid[][] = board.getGrid();
		int count;

		//Checking for columns
		for(int j=0;j<n;j++){
			count=0;
			for(int i=0;i<n;i++){
				if(grid[i][j]==move){
					count++;
				}
			}
			if(count==n)
				return true;
		}
		
		//Checking for rows
		for(int i=0;i<n;i++){
			count=0;
			for(int j=0;j<n;j++){
				if(grid[i][j]==move){
					count++;
				}
			}
			if(count==n)
				return true;
		}
		
		//Checking Diagonal1
		count=0;
		for(int i=0;i<n;i++){
			if(grid[i][i]==move){
				count++;
			}
		}
		if(count==n)
			return true;
		
		//Checking Diagonal2
		count=0;
		for(int i=0;i<n;i++){
			if(grid[i][n-i-1]==move){
				count++;
			}
		}
		if(count==n)
			return true;
		return false;
	}
}
