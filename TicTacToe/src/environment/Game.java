package environment;

import java.util.ArrayList;

import users.Computer;
import users.Player;
import util.Log;

public class Game {
	
	private Board board;
	private Computer computer=null;
	private Player player=null;
	
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
	
	public void playN(Computer computer, Player player, int N, boolean train){
		this.computer=computer;
		this.player=player;
		
		this.computer.reset();
		this.player.reset();
		
		for(int i=0;i<N;i++){
			Log.d("---------New Game-------");
			this.play(train);
			this.board.reset();
		}
	}
	
	private void play(boolean train){
	
		while(!this.complete(this.board)){
			if(!train)
				Log.l(this.board);
			this.computer.chooseMove();
			
			if(this.complete(this.board))
				break;
			if(!train)
				Log.l(this.board);
			this.player.chooseMove();
		}
		if(!train)
			Log.l(this.board);
		
		winner w = this.getWinner(this.board);
		String winnerName="";
		
		if(w==Game.winner.COMPUTER){
			this.computer.winCount++;
			winnerName = computer.getTag();
		}
		else if(w==Game.winner.PLAYER){
			this.player.winCount++;
			winnerName = player.getTag();
		}
		else if(w==Game.winner.DRAW){
			winnerName = "Nobody";
		}
		
		this.computer.onGameCompletition(w);
		this.player.onGameCompletition(w);
		
		if(!train)
			Log.l(winnerName+" wins");
	}
	
	public boolean complete( Board board ){
		winner w = this.getWinner(board);
		if(w == winner.NOTCOMPLETED)
			return false;
		return true;
	}
	
	public winner getWinner(Board board){
		if(this.checkWinner(board,this.computer.getMove()))
			return winner.COMPUTER;
		else if(this.checkWinner(board,this.player.getMove()))
			return winner.PLAYER;
		else if(board.isFill())
			return winner.DRAW;
		return winner.NOTCOMPLETED;
	}
	
	private boolean checkWinner( Board board, char move ){
		int n = this.board.getN();
		int count;
		
		ArrayList<char []> possibilities = this.getPossibilities(board);
		Log.d("---------Possibilities--");
		for(char possibility[] : possibilities){
			count = 0;
			String output="";
			for(int j=0;j<n;j++){
				if(possibility[j]==move)
					count++;
				output+=possibility[j]+", ";
			}

			Log.d(output);
			if(count == n)
				return true;
		}
		return false;
	}
	
	public ArrayList<char []> getPossibilities(Board board){
		char grid[][] =  board.getGrid();
		int n = board.getN();
		
		ArrayList<char []> possibilities = new ArrayList<char[]>();
		char possibility[] = null;
		
		//Row
		possibility =  new char[n];
		for(int i=0;i<n;i++){
			possibilities.add(grid[i]);
		}

		//column
		for(int j=0;j<n;j++){
			possibility =  new char[n];
			for(int i=0;i<n;i++){
				possibility[i]=grid[i][j];
			}
			possibilities.add(possibility);
		}

		//diagonal1
		possibility =  new char[n];
		for(int i=0;i<n;i++){
			possibility[i]=grid[i][i];
		}
		possibilities.add(possibility);

		//diagonal2
		possibility =  new char[n];
		for(int i=0;i<n;i++){
			possibility[i]=grid[i][n-i-1];
		}
		possibilities.add(possibility);
		
		return possibilities;
	}
	
}
