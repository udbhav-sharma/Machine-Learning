package users;

import java.util.ArrayList;

import util.Log;
import environment.Board;
import environment.Game;
import environment.Game.winner;

public class Computer extends Player {
	
	private double weight[];
	private final double winScore = 100;
	private final double lostScore = -100;
	private final double drawScore = 0;
	private final double u = 0.01; 			//learning rate
	private ArrayList<Board> history = null;
	
	public Computer(Game game, char move){
		super(game,move);
		this.tag="Computer";
		
		this.weight=new double[7];
		for(int i=0;i<7;i++){
			this.weight[i] = 0.5;
		}
		
		this.history = new ArrayList<Board>();
	}
	
	public void chooseMove() {
		Board board= this.game.getBoard().clone();
		int n = board.getN();
		
		double maxScore= Double.MAX_VALUE * ( -1),tempScore;
		
		int u=-1,v=-1;
		
		for(int i=0;i<n;i++){
			for(int j=0; j<n; j++){
				if(board.moveAllowed(i, j)){
					board.move(this.tag, i, j, this.move);
					tempScore = this.getScore(this.getFeatures(board));
					if(tempScore >= maxScore){
						u=i;
						v=j;
						maxScore = tempScore;
					}
					board.resetCell(i,j);
				}
			}
		}
		this.game.getBoard().move(this.tag, u, v, this.move);
		this.history.add(this.game.getBoard().clone());
	}
	
	public void onGameCompletition(winner w){
		
		//Reevaluate Weights
		double Vtrain;
		ArrayList<TrainPair> trainingData = new ArrayList<TrainPair>();
		int i;
		
		for(i=0;i<this.history.size()-1;i++){
			Vtrain = this.getScore(this.getFeatures(this.history.get(i+1)));
			trainingData.add(new TrainPair(Vtrain,this.getFeatures(history.get(i))));
		}
		
		Vtrain = this.getWinLostScore(w);
		trainingData.add(new TrainPair(Vtrain, this.getFeatures(history.get(i))));
		
		this.updateWeights(trainingData);
		this.clearHistory();
	}
	
	public String toString(){
		String output = super.toString();
		
		output += "\nWeights:\t";
		for(int i=0;i<this.weight.length;i++)
			output += this.weight[i]+", ";
		
		return output;
	}

	private void clearHistory(){
		this.history.clear();
	}
	
	private double getWinLostScore(winner w){
		if(w==winner.COMPUTER)
			return this.winScore;
		else if(w==winner.PLAYER)
			return this.lostScore;
		return this.drawScore;
	}
	
	private double getScore(int features[]){
		double score = 0;
		
		for(int i=0;i<7;i++) {
			score+=this.weight[i]*features[i];
		}
		
		return score;
	}
	
	private int[] getFeatures(Board board){
		int features[]=new int[7];
		for(int i=0;i<7;i++)
			features[i]=0;
		
		int n=board.getN();
		int cross, zero, defaultValue;
		char grid[][]=board.getGrid();
		char state;
		
		//Possibilities
		ArrayList<char []> possibilities = this.game.getPossibilities(board);
		
		//Evaluate
		features[0]=1;
		
		for(int i=0;i<n;i++)
			for(int j=0;j<n;j++){
				state = grid[i][j];
				if(state == Board.cross)
					features[1]++;
				else if(state == Board.zero)
					features[2]++;
			}
		
		for(char possibility[]:possibilities){
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
			if( cross == 2 && defaultValue == 1 )
                features[3] += 1;
			if( zero == 2 && defaultValue == 1 )
                features[4] += 1;
			if( cross == n )
                features[5] += 1;
            if( zero == n )
                features[6] += 1;
		}
		return features;
	}
	
	private void updateWeights(ArrayList<TrainPair> trainingData){
		Log.d("----Updating Weights-------");
		double Vestimate;
		String output;
		for( TrainPair tp : trainingData ){
			Vestimate = this.getScore(tp.features);
			
			for(int i=0;i<7;i++){
				weight[i] += this.u*tp.features[i]*(tp.Vtrain-Vestimate);
			}
			output = "Features:\t";
			for(int i=0;i<tp.features.length;i++)
				output += tp.features[i]+", ";
			Log.d("Features:"+output);
			Log.d("Vtrain:"+tp.Vtrain+" Vestimate:"+Vestimate);
		}
		
		output = "Weights:\t";
		for(int i=0;i<this.weight.length;i++)
			output += this.weight[i]+", ";
		Log.d(output);
	}
	
	private class TrainPair{
		double Vtrain;
		int features[];
		
		TrainPair( double Vtrain, int features[] ){
			this.Vtrain = Vtrain;
			this.features = features;
		}
	}
}
