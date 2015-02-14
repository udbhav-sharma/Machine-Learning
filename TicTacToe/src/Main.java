import environment.Board;
import environment.Game;
import users.Computer;
import users.Human;
import users.Player;
import util.Log;


public class Main {
	public static void main(String args[]){
		Log.l("Training....");
		Game game = new Game();
		Player computer = new Computer(game, Board.cross);
		Player player = new Player(game, Board.zero);
		Player human = new Human(game, Board.zero);
		
		game.playN(computer, player, 5000, true);
		Log.d(computer);
		Log.d(player);
		Log.l("Training completed.");
		
		game.playN(computer, human, 10, false);
	}
}
