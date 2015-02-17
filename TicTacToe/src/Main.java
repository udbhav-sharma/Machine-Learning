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
		Computer computer = new Computer(game, Board.cross);
		Player player = new Player(game, Board.zero);
		
		game.playN(computer, player, 5000, true);
		Log.l(computer);
		Log.l(player);
		
		player = new Human(game, Board.zero);
		game.playN(computer, player, 10, false);
		
		Log.l("Training completed.");
	}
}
