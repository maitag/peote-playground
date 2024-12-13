package;

import haxe.CallStack;
import haxe.Timer;
import lime.app.Application;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.Window;
import peote.ui.event.PointerEvent;
import peote.ui.interactive.UIElement;
import peote.view.Buffer;
import peote.view.Color;
import peote.view.Display;
import peote.view.PeoteView;
import peote.view.Program;
import peote.view.text.Text;
import peote.view.text.TextProgram;

using Lambda;

class Main extends Application {
	static var ball:Circle;
	static var player:Sprite;
	static var collided:Bool = false;
	static var angle:Float = 20.0;
	static var display:Display;
	static var buffer:Buffer<Sprite>;
	static var score:Int = 0;
	static var textProgram:TextProgram;
	static var text:Text;

	static var playerWidth:Int = 20;
	static var playerHeight:Int = 20;

	override function onWindowCreate():Void {
		switch (window.context.type) {
			case WEBGL, OPENGL, OPENGLES:
				try
					startSample(window)
				catch (_)
					trace(CallStack.toString(CallStack.exceptionStack()), _);
			default:
				throw("Sorry, only works with OpenGL.");
		}
	}

	public function startSample(window:Window) {
		var peoteView = new PeoteView(window);
		peoteView.start();


		buffer = new Buffer<Sprite>(1, 1, true);

		display = new Display(0, 0, window.width, window.height, Color.BLACK);
		display.hide();
		var program = new Program(buffer);

		Menu.init(peoteView, window, display);


		Circle.init(display);
		ball = new Circle(display.width / 2, display.height / 2, 20, Color.WHITE);
		ball.vx = 100; 
		ball.vy = -100;

		playerWidth = 200;
		playerHeight = 20;
		player = new Sprite((display.width - playerWidth) / 2, display.height - playerHeight, playerWidth, playerHeight, 0, 0, 0, 0, Color.WHITE);
		player.speed = 1.2;
		
		peoteView.addDisplay(display);
		display.addProgram(program);

		textProgram = new TextProgram();
		display.addProgram(textProgram);
		text = new Text(display.width, 20, '$score', {letterWidth: 50, letterHeight: 50});
		text.x = display.width - (text.letterWidth * text.text.length) - 15;
		textProgram.add(text);

		buffer.addElement(player);

	}


	override function update(dt:Float):Void {
		ball.update(dt);

		// paddle/player update 
		if (player.isMovingRight) player.x += (player.speed * dt);
		if (player.isMovingLeft) player.x -= (player.speed * dt);

		if (player.x <= 0) player.x = display.width;
		else if (player.x >= display.width) player.x = 0; 

		buffer.update();

		// bounce ball on the edges
		if ((ball.x <= ball.radius && ball.vx <= 0 ) || ((ball.x >= display.width - ball.radius) && ball.vx >= 0)) {
			ball.vx = -ball.vx; 
			score += 13;
		}
		else if (ball.y <= ball.radius && ball.vy >= 0) {
			score += 13;
			ball.vy = -ball.vy; 
		}
		
		if (ball.y >= display.height - ball.radius && ball.vy <= 0) {
			resetGame();
		}

		updateText(text, score);

		// collision w/ the paddle
		if((ball.x < player.x + player.w &&
			ball.x + ball.radius > player.x &&
			ball.y < player.y + player.h &&
			ball.y + ball.radius > player.y) && ball.vy <= 0) {
			
			ball.vy *= -1;
		}
	}

	override function onKeyDown(keyCode:KeyCode, modifier:KeyModifier) {
		if (keyCode == KeyCode.RIGHT) {
			player.isMovingRight = true;
		} else if (keyCode == KeyCode.LEFT) {
			player.isMovingLeft = true;
		}
	}

	override function onKeyUp(keyCode:KeyCode, modifier:KeyModifier) {
		if (keyCode == KeyCode.RIGHT) {
			player.isMovingRight = false; 
		} else if (keyCode == KeyCode.LEFT) {
			player.isMovingLeft = false;
		}
	}

	function updateText(text:Text, data:Int) {
		text.text = '$data';
		text.x = display.width - (text.letterWidth * text.text.length) - 15;
		textProgram.update(text, true);
	}

	function resetGame() {
		score = 0;
		updateText(text, score);

		ball.x = (display.width - ball.radius) / 2;
		ball.y = (display.height - ball.radius) - 20;

		player.x = (display.width - playerWidth) / 2;

		buffer.update();
	}
}
