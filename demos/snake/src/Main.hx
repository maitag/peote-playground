import haxe.Timer;
import haxe.CallStack;
import lime.app.Application;
import peote.view.*;
import peote.view.text.*;
import Segment;
import Snake;
import Util;

/**
 * A minimal implementation of Snake on Peote View - James Fisher, 21 May 2025
 * Core logic is ported from the haxeflixel rewrite of FlxSnake by Gama11
 */
class Main extends Application
{
	var resWidth:Int = 896;
	var resHeight:Int = 504;

	var peoteView:PeoteView;
	var display:Display;
	var buffer:SegmentBuffer;
	var textProgram:TextProgram;

	var snakeOptions:SnakeOptions;
	var snake:Snake;

	var fruit:Segment;
	var scoreText:Text;
	var score:Int = 0;

	var countDownMs:Int = 0;
	var durationMs:Int = 0;
	var minimumDurationMs:Int;
	var isGameEnded:Bool = false;

	override function onWindowCreate():Void
	{
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				try
				{
					init();
					startGame();
				}
				catch (_)
				{
					trace(CallStack.toString(CallStack.exceptionStack()), _);
				}
			default:
				throw("Sorry, only works with OpenGL.");
		}
	}

	/**
	 * Initialise the graphics and controls
	 */
	function init()
	{
		peoteView = new PeoteView(window);

		// set up the snake options
		var gridQuantise = 24;
		var margin = 32;
		var playWidth = resWidth - (margin * 2);
		var playHeight = resHeight - (margin * 2);
		snakeOptions = {
			gridQuantise: gridQuantise,
			columns: Std.int(playWidth / gridQuantise),
			rows: Std.int(playHeight / gridQuantise),
			initialSegments: 3,
			headColor: 0xa0f000,
			bodyColor: 0x30f030,
		}

		// init graphics for the snake segments and fruit
		display = new Display(margin, margin, Std.int(playWidth), Std.int(playHeight), Color.GREY1);
		peoteView.addDisplay(display);
		buffer = new SegmentBuffer(256);
		buffer.addToDisplay(display);

		// init graphics for text
		var hudDisplay = new Display(0, 0, resWidth, resHeight);
		peoteView.addDisplay(hudDisplay);
		var textColor:RGB = 0xf0f080;
		var textOptions:TextOptions = {
			fgColor: textColor,
			letterWidth: 16,
			letterHeight: 16,
		}
		textProgram = new TextProgram(textOptions);
		textProgram.addToDisplay(hudDisplay);
		scoreText = textProgram.add(new Text(8, 8, score + ""));

		// scale the game size and position to the window
		fitToWindow(window.width, window.height, hudDisplay, margin);

		// register call back to fit window when it is resized
		window.onResize.add((windowWidth, windowHeight) ->
		{
			fitToWindow(windowWidth, windowHeight, hudDisplay, margin);
		});

		// init controls
		window.onKeyDown.add((code, modifier) ->
		{
			if (snake?.isAlive)
			{
				switch code
				{
					case RIGHT: snake.steerHead(RIGHT);
					case LEFT: snake.steerHead(LEFT);
					case DOWN: snake.steerHead(DOWN);
					case UP: snake.steerHead(UP);
					case _: return;
				}
			}
			else if (isGameEnded)
			{
				startGame();
			}
		});
	}

	/**
	 * [Description]
	 * @param windowWidth 
	 * @param windowHeight 
	 * @param hudDisplay 
	 * @param margin 
	 */
	function fitToWindow(windowWidth:Int, windowHeight:Int, hudDisplay:Display, margin:Int):Void
	{
		// determine scale factors for x and y
		var scaleX = windowWidth / resWidth;
		var scaleY = windowHeight / resHeight;

		// we want the smallest scale factor to ensure the view stays inside the window
		var scale = Math.min(scaleX, scaleY);

		// scale peoteView
		peoteView.zoom = scale;

		// offset the displays to keep in the center of window
		var offsetX = Std.int(((windowWidth / scale) / 2) - (resWidth / 2));
		var offsetY = Std.int(((windowHeight / scale) / 2) - (resHeight / 2));
		hudDisplay.x = offsetX;
		hudDisplay.y = offsetY;
		display.x = hudDisplay.x + margin;
		display.y = hudDisplay.y + margin;
	}

	/**
	 * Set up the snake and fruit to start the game
	 */
	function startGame()
	{
		isGameEnded = false;

		// if snake is not alive it must be game over
		if (!snake?.isAlive)
		{
			// clear the old elements and reset the score
			buffer.clear();
			changeScore(0);
		}

		// time between snake updates
		durationMs = 208;
		minimumDurationMs = Std.int(1 / window.frameRate) * 1000;

		// init fruit off screen (will be positioned later)
		var fruitColor:RGB = 0xf06060;
		var fruit = new Segment(snakeOptions.gridQuantise, snakeOptions.gridQuantise, fruitColor, -200, -200, true);
		fruit.angle = 45;
		this.fruit = buffer.addElement(fruit);

		// init snake
		var centerColumn = Std.int(snakeOptions.columns / 2);
		var x = centerColumn * snakeOptions.gridQuantise;

		var centerRow = Std.int(snakeOptions.rows / 2);
		var y = centerRow * snakeOptions.gridQuantise;

		snake = new Snake(x, y, snakeOptions, buffer);

		moveFruit();
	}

	override function update(deltaTime:Int)
	{
		// only update gameplay when snake is alive
		if (snake?.isAlive)
		{
			countDownMs -= deltaTime;
			if (countDownMs <= 0)
			{
				snake.move();

				if (fruit != null)
				{
					// did snake eat the fruit ?
					if (snake.isHeadOverlap(fruit.x, fruit.y))
					{
						changeScore(score + 10);
						snake.addBodySegment();

						// reduce time between updates (cap at minimum)
						durationMs -= 10;

						if (durationMs < minimumDurationMs)
						{
							durationMs = minimumDurationMs;
						}

						// the fruit was eaten so move it to look like a new one
						moveFruit();
					}
				}

				// did snake eat itself ?
				for (segment in snake.body)
				{
					if (snake.isHeadOverlap(segment.x, segment.y))
					{
						gameOver();
					}
				}

				// reset countDown
				countDownMs = durationMs;
			}
		}

		// send changes to GPU
		buffer.update();
		textProgram.updateAll();
	}

	/**
	 * Randomise fruit x and y
	 * @param fruit the element to change
	 * @param boundary limit the x and y range
	 * @param gridQuantise for quantizing the position on grid
	 */
	function randomiseFruitPosition(fruit:Segment, columns:Int, rows:Int, gridQuantise:Int)
	{
		var col = randomInt(1, columns - 1);
		var row = randomInt(1, rows - 1);
		fruit.x = col * gridQuantise;
		fruit.y = row * gridQuantise;
	}

	/**
	 * Move the fruit to a random position.
	 * Will not place fruit at snake's head.
	 */
	function moveFruit():Void
	{
		randomiseFruitPosition(fruit, snake.options.columns, snake.options.rows, snake.options.gridQuantise);

		// if fruit is overlapping head it needs a new position
		while (snake.isHeadOverlap(fruit.x, fruit.y))
		{
			randomiseFruitPosition(fruit, snake.options.columns, snake.options.rows, snake.options.gridQuantise);
		}
	}

	/**
	 * Update the current score and score text
	 * @param nextScore the score to show
	 */
	function changeScore(nextScore:Int):Void
	{
		score = nextScore;
		scoreText.text = score + "";
	}

	/**
	 * Unalive the snake and display game over message
	 */
	function gameOver()
	{
		// set isAlive to false to stop gameplay
		snake.isAlive = false;
		scoreText.text = score + " : GAME OVER !";

		// wait for some time and then allow game to be reset
		var timer = new Timer(2000);
		timer.run = () ->
		{
			scoreText.text = scoreText.text + " PRESS ANY KEY TO RESET";
			isGameEnded = true;
			timer.stop();
		}
	}
}
