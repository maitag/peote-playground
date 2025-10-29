import assets.Pipeline;
import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;
import lime.utils.Assets;
import peote.view.*;
import peote.view.text.*;
import util.Quad;
import util.StringTilemap;
import util.Watch;
import Billboard;
import Raycaster;

class Main extends Application
{
	var turningDirection:Int = 0;
	var movingDirection:Int = 0;
	var strafingDirection:Int = 0;
	var distanceTraveled:Float = 0;

	var rays:Array<Ray> = [];

	var watchLines:TextProgram;
	var watching:Array<Watch> = [];

	override function onPreloadComplete():Void
	{
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				try
					startSample(window)
				catch (_)
					trace(CallStack.toString(CallStack.exceptionStack()), _);
			default:
				throw("Sorry, only works with OpenGL.");
		}
	}

	public function startSample(window:Window)
	{
		SemmisImgs.get(
			[
			"http://maitag.de/semmi/blender/mandelbulb",
			"http://maitag.de/semmi/blender/lyapunov/example_images/",
			"http://maitag.de/semmi/blender/circdots/example_images/",
			"http://maitag.de/semmi/stable-diffusion/space_01/",
			],
			100,  // min KB
			1024, // max KB
			(imgUrls:Array<String>,_) -> start(imgUrls)
		);
	}

	public function start(imgUrls:Array<String>)
	{	
		// hard coding the w/h of the resolution because html windows do not have a set size
		static var resWidth = 800;
		static var resHeight = 600;

		var peoteView = new PeoteView(window);
		var display = new Display(0, 0, resWidth, resHeight);
		peoteView.addDisplay(display);

		// tile map
		////////////

		var map:Array<String> = [
			"#ABCDEFGHIJKLMNOPF#",
			"LabcdefghijklmnopqB",
			"Hbcbc3mmtdcrisll7aF",
			"Ehikogntttlmbcda1bP",
			"Bhkoa7aatpmmmpAp2cN",
			"CsemmiqkrtJmpmes3dN",
			"IFEDqpon mMlkjih4fA",
			"BBBB#AC#MMI#Nprt5eG",
			"Bo0nmlkjihgfedcbagH",
			"#BBBKNNCCPKIHJGKLL#",
		];

		var wallIds:Map<String, Int> = [
			//////
			" " => -1, // empty (floor)
			"#" => 1,
			"A" => 3,
			"B" => 5,
			"C" => 29, "D" => 30, "E" => 31, "F" => 32, "G" => 33, "H" => 34, "I" => 35, "J" => 36, "K" => 37, "L" => 38, "M" => 39, "N" => 40, "O" => 41, "P" => 42,
		];

		var floorIds:Map<String, Int> = [
			//////
			"#" => -1, // empty (wall)
			" " => 0,
			"0" => 11,
			"1" => 1,
			"2" => 2,
			"3" => 3,
			"4" => 4,
			"5" => 5,
			"6" => 6,
			"7" => 7,
			"8" => 8,
			"a" => 9, "b" => 10, "c" => 11, "d" => 12, "e" => 13, "f" => 14, "g" => 15, "h" => 16, "i" => 17, "j" => 18, "k" => 19, "l" => 20, "m" => 21, "n" => 22, "o" => 23, "p" => 24, "q" => 25, "r" => 26, "s" => 27, "t" => 28,
		];

		var entityIds:Map<String, Int> = [
			//////
			"0" => Pipeline.Cube,
			"1" => Pipeline.Icosphere,
			"2" => Pipeline.Cone,
			"3" => Pipeline.Suzanne,
			"4" => Pipeline.Gem,
			"5" => Pipeline.Brilliant,
			"6" => Pipeline.Diamond,
			"7" => Pipeline.Human,
			"8" => Pipeline.CubeBorder,
		];

		var tilemap = new StringTilemap(map, wallIds, floorIds, entityIds);

		var visibleMapSize = 16;
		// var visibleMapSize = Std.int(Math.max(tilemap.widthTiles, tilemap.heightTiles)) + 8; // for debug

		var tileSize = 512; // much more would not make more sense (really*lol:;)

		// load some images into the great texture atlas
		// ---------------------------------------------
		// var textureData = Assets.getImage("assets/test-128.png");
		// var generatedTexture = Texture.fromData( Assets.getImage("assets/test-128.png") ); generatedTexture.tilesX = 8; generatedTexture.tilesY = 8;
		var generatedTexture = TextureAtlasTool.generate(peoteView, tileSize*8, tileSize*8, 8, 8, SemmisImgs.pickRandom(imgUrls, 43));

		// floor graphics
		/////////////////

		// var floor = new Floor(peoteView, tileSize, textureData, visibleMapSize, resWidth, resHeight);
		var floor = new Floor(peoteView, tileSize, null, generatedTexture, visibleMapSize, resWidth, resHeight);
		floor.addToDisplay(display);

		// wall graphics
		////////////////

		// to increase performance, increase this number (use factor of 2)
		// e.g. 1 will be 1 stripe for every pixel in the resWidth, 4 will be 1 stripe for every 4 pixels, etc
		var performance = 2;
		#if html5
		var parts = js.Browser.location.search.split("?");
		if (parts.length == 2)
		{
			var num = Std.parseInt(parts[1]);
			performance = num;
		}
		#end
		var numStripes = Std.int(resWidth / performance);
		var wallTilesHigh = 2.5;
		// var walls = new Walls(numStripes, textureData, tileSize, wallTilesHigh);
		var walls = new Walls(numStripes, null, generatedTexture, tileSize, wallTilesHigh);
		walls.addToDisplay(display);

		// billboard graphics
		/////////////////////

		var numBillboards = tilemap.entityCount;
		var angles = Pipeline.degrees;
		var texture = new Texture(Pipeline.width, Pipeline.height, angles);
		for (slot in 0...angles)
		{
			texture.setData(Assets.getImage('assets/pipeline$slot.png'), slot);
		}
		var billboards = new Billboards(numBillboards, texture, Pipeline.tileWidth, Pipeline.tileHeight, Pipeline.tilesX, resHeight);
		billboards.addToDisplay(display);

		// ray casting
		//////////////

		var rayCast:RayCast;
		rayCast = {
			x: 1.5,
			y: 1.5,
			angle: 0.5,
			fov: Math.PI / 3, // 60 degrees
			litBefore: 0.5,
			darkAfter: visibleMapSize,
			verticalOffset: 0
		}

		var rayView:RayViewConfig;
		rayView = {
			resWidth: resWidth,
			resHeight: resHeight,
			tileSize: tileSize,
			verticalCenter: resHeight / 2,
			totalRays: numStripes,
			rayStep: Std.int(resWidth / numStripes),
			centerRayIndex: Std.int(numStripes / 2),
			wallTilesHigh: wallTilesHigh
		}

		var hitTest:HitTest = mapId ->
		{
			return mapId >= 0;
		}

		// controls
		///////////

		window.onKeyDown.add((code, modifier) -> switch code
		{
			case RIGHT:
				turningDirection = 1;
			case LEFT:
				turningDirection = -1;
			case D:
				strafingDirection = 1;
			case A:
				strafingDirection = -1;
			case DOWN | S:
				movingDirection = -1;
			case UP | W:
				movingDirection = 1;
			case NUMBER_0:
				// center in map cell
				rayCast.x = Math.ceil(rayCast.x / 0.5) * 0.5;
				rayCast.y = Math.ceil(rayCast.y / 0.5) * 0.5;
			case NUMBER_1:
				// face North
				rayCast.angle = -Math.PI / 2;
			case NUMBER_8:
				// step West a little
				rayCast.x -= 0.2;
			case NUMBER_9:
				// step East a little
				rayCast.x += 0.2;
			case _:
		});

		window.onKeyUp.add((code, modifier) -> switch code
		{
			case RIGHT:
				turningDirection = 0;
			case LEFT:
				turningDirection = 0;
			case D:
				strafingDirection = 0;
			case A:
				strafingDirection = 0;
			case DOWN | S:
				movingDirection = 0;
			case UP | W:
				movingDirection = 0;
			case _:
		});

		// window resize
		////////////////

		var resize = (width:Int, height:Int) ->
		{
			// determine scale factors for x and y
			var scaleX = (width / resWidth);
			var scaleY = (height / resHeight);

			// use smallest scale factor to ensure the view stays inside the window
			peoteView.zoom = Math.min(scaleX, scaleY);

			// offset the display to keep in the center of window
			var wMid = resWidth / 2;
			var hMid = resHeight / 2;
			var scaledWidthMid = (width / peoteView.zoom) / 2;
			var scaledHeightMid = (height / peoteView.zoom) / 2;
			display.x = Std.int(scaledWidthMid - wMid);
			display.y = Std.int(scaledHeightMid - hMid);
		}

		window.onResize.add(resize);

		#if html5
		// in browser we may need to center the display
		resize(window.width, window.height);
		#end

		// debugging
		////////////

		watchLines = new TextProgram();
		display.addProgram(watchLines);
		var addWatch:(getText:() -> String) -> Void = getText ->
		{
			static var watchX = 10;
			static var watchY = 10;
			static var lineHeight = 10;
			var lineCount = watching.length;
			var line = new Text(watchX, watchY + (lineHeight * lineCount), getText());
			watchLines.add(line);
			watching.push(new Watch(line, getText));
		}

		addWatch(() -> 'ray x: ${rayCast.x}');
		addWatch(() -> 'ray y: ${rayCast.y}');
		addWatch(() -> 'ray rotation: ${rayCast.angle}');
		addWatch(() -> 'ray dir x: ${rays[rayView.centerRayIndex]?.vectorX}');
		addWatch(() -> 'ray dir y: ${rays[rayView.centerRayIndex]?.vectorY}');
		addWatch(() -> 'focus id: ${rays[rayView.centerRayIndex]?.mapId}');
		addWatch(() -> 'focus facing: ${rays[rayView.centerRayIndex]?.facing}');
		addWatch(() -> 'focus axis: ${rays[rayView.centerRayIndex]?.axis}');

		// for rendering the floor framebuffer without the perspective shader
		var debugFloor = true;
		if (debugFloor)
		{
			var debugBuffer = new QuadBuffer(1);
			debugBuffer.program.addToDisplay(display);

			debugBuffer.program.addTexture(floor.fbTexture);
			var size = visibleMapSize * 16;
			debugBuffer.addElement(new Quad(size, size, display.width - size - 10.0, 10.0));
		}

		// init entities
		////////////////

		var entities:Array<Entity<Billboard>> = [];
		for (key => positions in tilemap.getEntityPositions())
		{
			for (xy in positions)
			{
				if (entityIds.exists(key))
				{
					entities.push({
						worldX: xy[0] + 0.5, // add 0.5 to center in map cell
						worldY: xy[1] + 0.5,
						tileId: entityIds[key],
						angleSlots: Pipeline.degrees,
						facingAngle: 3 * (Math.PI / 2), // entity facing South
						element: billboards.init()
					});
				}
			}
		}

		// game loop
		////////////

		onUpdate.add(i ->
		{
			var deltaTime = i / 1000;

			// movement
			///////////

			// calculate turning
			static var turnSpeed = 2;
			var rotationDelta = (turnSpeed * turningDirection) * deltaTime;
			rayCast.angle = normalizePI(rayCast.angle + rotationDelta);

			// calculate movement
			static var moveSpeed = 2.5;

			var movementDelta = (moveSpeed * movingDirection) * deltaTime;
			var forwardX = Math.cos(rayCast.angle);
			var forwardY = Math.sin(rayCast.angle);

			var strafeDelta = (moveSpeed * strafingDirection) * deltaTime;
			static var PImid = Math.PI / 2;
			var strafeX = Math.cos(rayCast.angle + PImid);
			var strafeY = Math.sin(rayCast.angle + PImid);

			var vectorX = forwardX * movementDelta + strafeX * strafeDelta;
			var vectorY = forwardY * movementDelta + strafeY * strafeDelta;

			// if there is movement
			if (vectorX != 0 || vectorY != 0)
			{
				var distance = Math.sqrt(vectorX * vectorX + vectorY * vectorY);

				// cap movement speed to prevent diagonal speed increase
				var maxDistance = moveSpeed * deltaTime;
				if (distance > maxDistance)
				{
					vectorX = (vectorX / distance) * maxDistance;
					vectorY = (vectorY / distance) * maxDistance;
					distance = maxDistance;
				}

				// check collision
				static var collisionPadding = 0.3;
				var nextX = Math.floor(rayCast.x + vectorX + (vectorX / distance) * collisionPadding);
				var nextY = Math.floor(rayCast.y + vectorY + (vectorY / distance) * collisionPadding);
				var tileAtNextPosition = tilemap.wallTileAt(nextX, nextY);

				// update position if there is no collision
				if (!hitTest(tileAtNextPosition))
				{
					rayCast.x += vectorX;
					rayCast.y += vectorY;
					distanceTraveled += Math.abs(distance);
				}
			}

			// graphics
			///////////

			// head bob triangle oscillator
			static var headBobFrequency = 6.5;
			static var headBobHeight = 10;
			var cycle = (headBobFrequency * distanceTraveled / (2 * Math.PI)) % 1;
			var osc = cycle < 0.5 ? cycle * 2 : 2 - cycle * 2;
			rayCast.verticalOffset = osc * headBobHeight;

			// cast rays while rendering walls
			rays = renderWalls(rayCast, rayView, tilemap.wallTileAt, hitTest, walls.drawStripe);

			// use rays to determine billboard rendering
			renderBillboards(rayCast, rayView, rays, entities, billboards.drawBillboard);

			// sync floor with perspective
			floor.renderTiles(rayCast, vectorX, vectorY, tilemap.widthTiles, tilemap.heightTiles, tilemap.floorTileAt);

			// update debug watches
			for (watch in watching)
			{
				watch.update(watchLines);
			}
		});
	}
}
