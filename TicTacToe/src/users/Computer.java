package users;
import java.util.ArrayList;

import environment.Board;
import environment.Game;
import environment.Game.winner;

public class Computer extends Player {
	
	private double weight[];
	private final double winScore = 100;
	private final double lostScore = -100;
	private final double drawScore = 0;
	private final double u = 0.02; 			//learning rate
	private ArrayList<Board> history;		//Board states history
	
	public Computer(Game game, char move){
		super(game,move);
		this.tag="Computer";
		
		this.weight=new double[7];
		for(int i=0;i<7;i++){
			this.weight[i] = 0.5;
		}
		
		this.history = new ArrayList<Board>();
	}
	
	public void reset(){
		this.history.clear();
	}
	
	public void chooseMove() {
		Board board= this.game.getBoard();
		int n = board.getN();
		char prevMove;
		double maxScore=-1000000,tempScore;
		boolean maxScoreFlag=true;
		int u=0,v=0;
		
		for(int i=0;i<n;i++){
			for(int j=0; j<n; j++){
				if(board.moveAllowed(i, j)){
					prevMove = board.getState(i, j);
					board.move(this.tag, i, j, Board.cross);
					tempScore = getScore(board);
					if(maxScoreFlag || tempScore > maxScore){
						u=i;
						v=j;
						maxScore = tempScore;
						maxScoreFlag = false;
					}
					board.hardMove(i,j,prevMove);
				}
			}
		}
		this.history.add(board.clone());
		game.move(this.tag, u, v, this.move);
	}
	
	public void onGameCompletition(){
		this.history.add(this.game.getBoard().clone());
		
		//Reevaluate Weights
		double Vtrain;
		
		for(int i=this.history.size()-1;i>0;i--){
			winner w =  this.game.getWinner(history.get(i));
			if(w==winner.NOTCOMPLETED){
				Vtrain = this.getScore(history.get(i));
				this.updateWeights(history.get(i-1),Vtrain);
			}
			else{
				Vtrain = this.getWinLostScore(w);
				this.updateWeights(history.get(i),Vtrain);
			}
		}
	}
	
	private double getWinLostScore(winner w){
		if(w==winner.COMPUTER)
			return this.winScore;
		else if(w==winner.PLAYER)
			return this.lostScore;
		return this.drawScore;
	}
	
	private double getScore(Board board){
		int features[];
		double score = 0;
		features = this.getFeatures(board);
		
		for(int i=0;i<7;i++) {
			score+=this.weight[i]*features[i];
		}
		
		return score;
	}
	
	private int[] getFeatures(Board board){
		int features[]=new int[7];
		features[0]=1;
		for(int i=1;i<7;i++)
			features[i]=0;
		
		int n=board.getN();
		
		int cross, zero, defaultValue;
		char state;
		char grid[][] = board.getGrid();
		
		//Possibilities
		ArrayList<char []> possibilities = new ArrayList<char[]>();
		char possibility[] = new char[n];
		//Row
		for(int i=0;i<n;i++){
			possibilities.add(grid[i]);
		}

		//column
		for(int i=0;i<n;i++){
			for(int j=0;j<n;j++){
				possibility[j]=grid[j][i];
				if(grid[j][i]==Board.cross)
					features[1]++;
				else if(grid[j][i]==Board.zero)
					features[2]++;
			}
			possibilities.add(possibility);
		}

		//diagonal1
		for(int i=0;i<n;i++){
			possibility[i]=grid[i][i];
		}
		possibilities.add(possibility);

		//diagonal2
		for(int i=0;i<n;i++){
			possibility[i]=grid[i][n-i-1];
		}
		possibilities.add(possibility);
		
		//Evaluate
		for(int i=0;i<n;i++){
			possibility = possibilities.get(i);
			cross=zero=defaultValue=0;
			
			for(int j=0;j<n;j++){
				state = possibility[j];
				if(state == Board.cross)
					cross++;
				else if(state == Board.zero)
					zero++;
				else
					defaultValue++;
			}
            if( cross == n-1 )
                features[3] += 1;
            if( zero == n-1 )
                features[4] += 1;
            if( cross == n-1 && defaultValue == 1 )
                features[5] += 1;
            if( zero == n-1 && defaultValue == 1 )
                features[6] += 1;
		}
		return features;
	}
	
	private void updateWeights(Board board, double score){
		int features[] = this.getFeatures(board);
		double estimate = this.getScore(board);
		for(int i=0;i<this.weight.length;i++){
			weight[i] += this.u*features[i]*(score-estimate);
		}
	}
	
	public String toString(){
		String output = "--------Computer---------\n";
		
		output += "Win:\t"+this.winCount+"\n";
		
		output += "Weights:\t";
		for(int i=0;i<this.weight.length;i++)
			output += this.weight[i]+", ";
		
		return output;
	}
	
}
