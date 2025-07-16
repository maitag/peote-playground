import haxe.CallStack;
import lime.app.Application;
import lime.graphics.Image;
import peote.view.*;
import utils.Loader;

class Main extends Application {
	var buffer:Buffer<Tile>;

	override function onWindowCreate() {
		switch (window.context.type) {
			case WEBGL, OPENGL, OPENGLES:
				try {
					start();
				} catch (_) {
					trace(CallStack.toString(CallStack.exceptionStack()), _);
				}
			default:
				throw("Sorry, only works with OpenGL.");
		}
	}

	function start() {
		var peoteView = new PeoteView(window);

		var tileSize = 48;
		var rhombusWidth = tileSize;
		var rhombusHeight = 24;

		var rows = 5;
		var columns = 5;

		// init display
		var display = new Display(0, 0, window.width, window.height, Color.GREY1);
		peoteView.addDisplay(display);

		// offset display so that the grid of tiles will be centered
		var displayWidthMid = display.width / 2;
		var rhombusWidthMid = (rhombusWidth / 2);
		display.xOffset = displayWidthMid - rhombusWidthMid;

		var displayHeightMid = display.height / 2;
		var gridHeight = rhombusHeight * rows;
		var gridHeightMid = gridHeight / 2;
		display.yOffset = displayHeightMid - gridHeightMid;

		// element buffer for the Tiles
		var bufferSize = 128;
		buffer = new Buffer<Tile>(bufferSize);

		// load tiles asset and set up the demo
		Loader.image("assets/48.png", (textureData:Image) -> {
			var texture = Texture.fromData(textureData);
			texture.tilesX = Std.int(textureData.width / tileSize);
			texture.tilesY = Std.int(textureData.height / tileSize);

			var program = new Program(buffer);
			program.snapToPixel(1);
			program.addTexture(texture);
			program.addToDisplay(display);

			// init IsoPoint for offsetting tiles
			var point = new IsoPoint(rhombusWidth, rhombusHeight);

			// init tiles for the grid
			var cells:Array<Tile> = [];
			var cubeId = 1;
			var colorShift = Math.floor(256 / 6);
			for (r in 0...columns) {
				for (c in 0...rows) {
					point.changeGrid(c, r);
					var t = new Tile(point.x, point.y, tileSize, tileSize, cubeId);
					t.tint.r = (r * colorShift);
					t.tint.g = (c * colorShift);
					cells.push(buffer.addElement(t));
				}
			}

			// init IsoPoint for tracking mouse cursor
			var cursorPoint = new IsoPoint(rhombusWidth, rhombusHeight);

			// init tile for the cursor
			var cursorId = 0;
			var cursorTile = new Tile(cursorPoint.x, cursorPoint.y, tileSize, tileSize, cursorId);
			cursorTile.tint = 0xf01010b0;
			buffer.addElement(cursorTile);

			// bind mouse movement to update cursor
			window.onMouseMove.add((x, y) -> {
				// offset mouse x y
				// use display.localX and display.localY to offset the mouse position by the display offset and zoom
				var localX = display.localX(x) - cursorPoint.halfWidth;
				var localY = display.localY(y) - cursorPoint.halfHeight;

				// update the IsoPoint with offset mouse positions
				cursorPoint.changeScreen(localX, localY);

				// quantise to grid
				cursorPoint.changeGrid(cursorPoint.column, cursorPoint.row);

				// update tile position to reflect cursor
				cursorTile.x = Math.round(cursorPoint.x);
				cursorTile.y = Math.round(cursorPoint.y);

				trace(' xy ${cursorTile.x} ${cursorTile.y} cr ${cursorPoint.column} ${cursorPoint.row}');
			});

			// bind mouse wheel to zoom center in or out
			var zoomIncrement = 0.5;
			window.onMouseWheel.add((dx, dy, mode) -> {
				// cache previous zoom variables
				var previousZoom = display.zoom;
				var previousOffsetX = display.xOffset;
				var previousOffsetY = display.yOffset;

				// determine new zoom from scroll delta y (either -1 or 1)
				var newZoom = previousZoom + (zoomIncrement * dy);
				if (newZoom < 0.5)
					newZoom = 0.5; // clamp minimum zoom
				var windowWidthHalf = window.width / 2;
				var windowHeightHalf = window.height / 2;

				// calculate new zoom variables
				var offset = (newZoom / previousZoom);
				display.zoom = newZoom;
				display.xOffset = windowWidthHalf - (windowWidthHalf - previousOffsetX) * offset;
				display.yOffset = windowHeightHalf - (windowHeightHalf - previousOffsetY) * offset;
			});

			// bind mouse buttons
			window.onMouseDown.add((x, y, button) -> {
				if (button == LEFT) {
					// left button click a grid cell
					var column = cursorPoint.column;
					var row = cursorPoint.row;
					if (column >= 0 && column <= columns - 1 && row >= 0 && row <= rows - 1) {
						var elemIndex = column + columns * row;
						trace('elemIndex $elemIndex');
						var tile = cells[elemIndex];
						tile.tint = 0xf0f0a4c0;
					}

				} else {
					// else reset all cells
					for (col in 0...columns) {
						for (row in 0...rows) {
							var elemIndex = col + columns * row;
							var tile = cells[elemIndex];
							tile.tint.r = (row * colorShift);
							tile.tint.g = (col * colorShift);
							tile.tint.b = 0xff;
							tile.tint.a = 0xff;
						}
					}
				}
			});

			// bind app update for "game loop"
			onUpdate.add(i -> {
				// send tile element changes to GPU
				buffer.update();
			});
		});
	}
}
