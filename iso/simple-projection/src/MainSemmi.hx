import haxe.CallStack;
import lime.app.Application;
import lime.graphics.Image;
import peote.view.*;
import peote.view.text.*;
import utils.Loader;

class MainSemmi extends Application {
	var buffer:Buffer<Tile>;
	var glyphs:TextProgram;

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
		var columns = 6;

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
		Loader.image("assets/tilesRhomb.png", (textureData:Image) -> {
			var texture = Texture.fromData(textureData);
			texture.tilesX = Std.int(textureData.width / tileSize);
			texture.tilesY = Std.int(textureData.height / tileSize);
			
			var program = new Program(buffer);
			program.snapToPixel(1);
			program.addTexture(texture);
			program.addToDisplay(display);


			glyphs = new TextProgram({fgColor: 0x006a82ff});
			display.addProgram(glyphs);
			glyphs.hide();
			
			// init IsoPoint for offsetting tiles
			var point = new IsoPoint(rhombusWidth, rhombusHeight);

			// init tiles for the grid
			var cells:Array<Tile> = [];
			var cubeId = 1;
			var colorShift = Math.floor(256 / 6);
			var i = 0;
			for (row in 0...rows) {
				for (col in 0...columns) {
					point.changeGrid(col, row);
					var t = new Tile(point.x, point.y, tileSize, tileSize, cubeId);
					t.tint.r = (row * colorShift);
					t.tint.g = (col * colorShift);
					cells.push(buffer.addElement(t));
					var tX = Std.int(t.x + rhombusWidthMid - 24);
					var tY = Std.int(t.y + (rhombusHeight / 2));
					glyphs.add(new Text(tX, tY, '${point.column},${point.row}:$i'));
					i++;
				}
			}

			// init IsoPoint for tracking mouse cursor
			var cursorPoint = new IsoPoint(rhombusWidth, rhombusHeight);

			// init tile for the cursor
			var cursorId = 0;
			var cursorTile = new Tile(cursorPoint.x, cursorPoint.y, tileSize, tileSize, cursorId);
			cursorTile.tint = 0xf01010b0;
			buffer.addElement(cursorTile);

			// ------ render peote :)
			var z = 1;
			for (row in 0...5) {
				point.changeGrid(1 - z, 4-row - z);
				var t = new Tile(point.x, point.y, tileSize, tileSize, (row<4) ? 4+row : 5);
				t.tint.r = (3 * colorShift);
				t.tint.g = (3 * colorShift);
				cells.push(buffer.addElement(t));
			}
			
			
			// bind mouse movement to update cursor
			window.onMouseMove.add((x, y) -> {
				// offset mouse x y
				// use display.localX and display.localY to offset the mouse position by the display offset and zoom
				var localX = display.localX(x) - cursorPoint.widthMid;
				var localY = display.localY(y) - cursorPoint.heightMid;

				// update the IsoPoint with offset mouse positions
				cursorPoint.changeScreen(localX, localY);

				// clamp to grid boundary
				var c = Math.min(columns - 1, Math.max(0, cursorPoint.column));
				var r = Math.min(rows - 1, Math.max(0, cursorPoint.row));

				// quantise to grid
				cursorPoint.changeGrid(Math.round(c), Math.round(r));


				// update tile position to reflect cursor
				cursorTile.x = Math.round(cursorPoint.x);
				cursorTile.y = Math.round(cursorPoint.y);

				// trace(' xy ${cursorTile.x} ${cursorTile.y} cr ${cursorPoint.column} ${cursorPoint.row}');
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
				var windowWidthMid = window.width / 2;
				var windowHeightMid = window.height / 2;

				// calculate new zoom variables
				var offset = (newZoom / previousZoom);
				display.zoom = newZoom;
				display.xOffset = windowWidthMid - (windowWidthMid - previousOffsetX) * offset;
				display.yOffset = windowHeightMid - (windowHeightMid - previousOffsetY) * offset;
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
					for (row in 0...rows) {
						for (col in 0...columns) {
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

			// bind keys
			window.onKeyDown.add((code, modifier) -> {
				switch code {
					case NUMPAD_1:
					case NUMPAD_2:
					case NUMPAD_3:
					case NUMPAD_4:
					case NUMPAD_5:
					case NUMPAD_6:
					case NUMPAD_7:
					case NUMPAD_8:
					case NUMPAD_9:
					case NUMPAD_0: toggleLabels();
					case _:
				}
			});

			// bind app update for "game loop"
			onUpdate.add(i -> {
				// send tile element changes to GPU
				buffer.update();
			});
		});
	}

	function toggleLabels() {
		if (glyphs.isVisible) {
			glyphs.hide();
		} else {
			glyphs.show();
		}
	}
}
