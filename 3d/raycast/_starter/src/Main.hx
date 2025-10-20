/**
 * todo... 
 * - whitespace
 */

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
		// hard coding the w/h of the resolution because html windows do not have a set size
		static var resWidth = 800;
		static var resHeight = 600;

		var peoteView = new PeoteView(window);
		var display = new Display(0, 0, resWidth, resHeight);
		peoteView.addDisplay(display);

		// tile map
		////////////

		var map:Array<String> = [
			"###################",
			"#       #      #  #",
			"#       #         #",
			"#               1 #",
			"#     A       # 2 #",
			"#         #   # 3 #",
			"####      #     4 #",
			"BBBB#########   5 #",
			"B 0               #",
			"BBBB###############",
		];

		var wallIds:Map<String, Int> = [
			//////
			" " => -1, // empty (floor)
			"#" => 1,
			"A" => 33,
			"B" => 35,
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
		];

		var entityIds:Map<String, Int> = [
			//////
			"0" => 10,
			"1" => 1,
			"2" => 17,
			"3" => 2,
			"4" => 13,
			"5" => 7,
		];

		var tilemap = new StringTilemap(map, wallIds, floorIds, entityIds);

		var visibleMapSize = 16;
		// var visibleMapSize = Std.int(Math.max(tilemap.widthTiles, tilemap.heightTiles)) + 8; // for debug

		// floor graphics
		/////////////////

		var tileSize = 128;
		var textureData = Assets.getImage("assets/test-128.png");
		var floor = new Floor(peoteView, tileSize, textureData, visibleMapSize, resWidth, resHeight);
		floor.addToDisplay(display);

		// wall graphics
		////////////////

		// to increase performance, increase this number (use factor of 2)
		// e.g. 1 will be 1 stripe for every pixel in the resWidth, 4 will be 1 stripe for every 4 pixels, etc
		var performance = 1;
		var numStripes = Std.int(resWidth / performance);
		var wallTilesHigh = 2.5;
		var walls = new Walls(numStripes, textureData, tileSize, wallTilesHigh);
		walls.addToDisplay(display);

		// billboard graphics
		/////////////////////

		var tileSize = 32;
		var tilesX = 16;
		var numBillboards = tilemap.entityCount;
		var textureData = Assets.getImage("assets/peote_tiles_bunnys.png");
		var billboards = new Billboards(numBillboards, textureData, tilesX, tileSize, resHeight);
		billboards.addToDisplay(display);

		// ray casting
		//////////////

		var rayCast:RayCast;
		rayCast = {
			x: 1.5,
			y: 1.5,
			angle: 0.5,
			fov: Math.PI / 3, // 60 degrees,
			litBefore: 0.5,
			darkAfter: visibleMapSize,
			verticalOffset: 0
		}

		var rayDisplay:RayDisplay;
		rayDisplay = {
			resWidth: resWidth,
			resHeight: resHeight,
			tileSize: 128,
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
			case DOWN:
				movingDirection = -1;
			case UP:
				movingDirection = 1;
			case _:
		});

		window.onKeyUp.add((code, modifier) -> switch code
		{
			case RIGHT:
				turningDirection = 0;
			case LEFT:
				turningDirection = 0;
			case DOWN:
				movingDirection = 0;
			case UP:
				movingDirection = 0;
			case _:
		});

		// window resize
		////////////////

		var centerDisplay = (width:Int, height:Int) ->
		{
			var wMid = resWidth / 2;
			var hMid = resHeight / 2;
			var scaledWidthMid = (width / peoteView.zoom) / 2;
			var scaledHeightMid = (height / peoteView.zoom) / 2;
			display.x = Std.int(scaledWidthMid - wMid);
			display.y = Std.int(scaledHeightMid - hMid);
		}

		window.onResize.add((width, height) ->
		{
			// determine scale factors for x and y
			var scaleX = (width / resWidth);
			var scaleY = (height / resHeight);

			// use smallest scale factor to ensure the view stays inside the window
			peoteView.zoom = Math.min(scaleX, scaleY);

			// offset the display to keep in the center of window
			centerDisplay(width, height);
		});

		#if html5
		// in browser we may need to center the display
		centerDisplay(window.width, window.height);
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
		addWatch(() -> 'ray dir x: ${rays[rayDisplay.centerRayIndex]?.vectorX}');
		addWatch(() -> 'ray dir y: ${rays[rayDisplay.centerRayIndex]?.vectorY}');
		addWatch(() -> 'focus id: ${rays[rayDisplay.centerRayIndex]?.mapId}');
		addWatch(() -> 'focus facing: ${rays[rayDisplay.centerRayIndex]?.facing}');
		addWatch(() -> 'focus axis: ${rays[rayDisplay.centerRayIndex]?.axis}');

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
			rayCast.angle += rotationDelta;
			// normalise angle to keep things sane
			static var PI2 = Math.PI * 2;
			rayCast.angle = ((rayCast.angle + Math.PI) % PI2 + PI2) % PI2 - Math.PI;

			// calculate movement
			var vectorX = Math.cos(rayCast.angle);
			var vectorY = Math.sin(rayCast.angle);
			static var moveSpeed = 3;
			var movementDelta = (moveSpeed * movingDirection) * deltaTime;

			// check collision
			var collisionPadding = 0.3 * movingDirection;
			var overReach = movementDelta + collisionPadding;
			var nextX = rayCast.x + vectorX * overReach;
			var nextY = rayCast.y + vectorY * overReach;
			var tileAtNextPosition = tilemap.wallTileAt(Math.floor(nextX), Math.floor(nextY));

			// update position if there is no collision
			if (!hitTest(tileAtNextPosition))
			{
				rayCast.x += Math.cos(rayCast.angle) * movementDelta;
				rayCast.y += Math.sin(rayCast.angle) * movementDelta;
				distanceTraveled += movementDelta;
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
			rays = renderWalls(rayCast, rayDisplay, tilemap.wallTileAt, hitTest, walls.drawStripe);

			// use rays to determine billboard rendering
			renderBillboards(rayCast, rayDisplay, rays, entities, billboards.drawBillboard);

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
