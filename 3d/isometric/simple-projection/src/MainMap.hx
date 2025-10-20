import haxe.CallStack;
import lime.app.Application;
import lime.graphics.Image;
import peote.view.*;
import peote.view.text.*;

class MainMap extends Application {
	var buffer:Buffer<TileWave>;
	var glyphs:TextProgram;

	var tiles:Array<TileWave>;
	var labels:Array<Text>;

	var mouseLocalX:Float = 0;
	var mouseLocalY:Float = 0;

	var mapColumns:Int;
	var mapRows:Int;
	var colorShift:Int;

	var tileWidth:Int;
	var tileHeight:Float;
	var tileScale:Int;

	var leftColumnInView:Int = 0;
	var topRowInView:Int = 0;
	var viewColumns:Int;
	var viewRows:Int;

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
		tileScale = 2;
		var screenTileSize = tileSize * tileScale;

		// the width of the tile on the display
		tileWidth = screenTileSize;
		// the height of the tileon the display
		// it is half the tile size, because the cube top only fills the top half of the tile
		tileHeight = screenTileSize / 2;

		// mid points for the tiles, used for offsetting in various places
		var tileWidthMid = Std.int(tileWidth / 2);
		var tileHeightMid = Std.int(tileHeight / 2);

		var viewWidth = window.width;
		var viewHeight = window.height;

		// init display
		var display = new Display(0, 0, viewWidth, viewHeight, 0x0a092fff);
		peoteView.addDisplay(display);

		var spanWidth = viewWidth / tileWidthMid;
		var spanHeight = viewHeight / tileHeightMid;
		var gridSpan = Math.ceil(Math.max(spanWidth, spanHeight));

		// element buffer for the TileWaves
		// todo calc this proper
		buffer = new Buffer<TileWave>(512, 512);
		var program = new Program(buffer);
		program.snapToPixel(1);

		var uAmp = new UniformFloat("u_amp", 4.0 * tileScale); // how many pixels to oscillate on z
		var uLeng = new UniformFloat("u_leng", gridSpan * tileScale); // how long is the wave
		var uTimeEnabled = true; // is time uniform enabled?
		program.injectIntoVertexShader(TileWave.fragment, uTimeEnabled, [uAmp, uLeng]);
		peoteView.start(); // start uTime
		// shader compilation will fail if we add the display before inititalising the UniformFloats
		// so add now
		program.addToDisplay(display);

		// load tiles asset and set up the demo
		Load.image("assets/48.png", (textureData:Image) -> {
			var texture = Texture.fromData(textureData);
			texture.tilesX = Std.int(textureData.width / tileSize);
			texture.tilesY = Std.int(textureData.height / tileSize);
			program.addTexture(texture);

			glyphs = new TextProgram({fgColor: 0x006a82ff});
			display.addProgram(glyphs);
			glyphs.hide();

			// calculate how many tiles can fit in the view
			viewColumns = Math.ceil((viewWidth) / tileWidth);
			// row count is doubled because twice as many tiles fit vertically from the overlap
			viewRows = 2 * Math.ceil((viewHeight) / (tileHeight));

			// the sizes of the map
			mapColumns = map[0].length;
			mapRows = map.length;
			var mapDiagonal = Math.sqrt(mapColumns * mapColumns + mapRows * mapRows);
			colorShift = Math.floor(256 / mapDiagonal);

			trace(' map cells $mapColumns : $mapRows');
			trace(' view cells $viewColumns : $viewRows ');

			// the top left cells of the map which are in view
			topRowInView = 0;
			leftColumnInView = 0;

			// initialise the cell labels
			labels = [
				for (n in 0...(viewColumns * viewRows))
					glyphs.add(new Text(-999, -999, '000000'))
			];

			// initialise the cells
			tiles = [];
			var point = new IsoPoint(tileWidth, tileHeight);
			var cubeId = 1;
			var i = 0;
			for (r in 0...viewRows) {
				var rowOffset = (r % 2);
				var colOffset = (r - topRowInView - rowOffset) / 2;

				for (c_ in 0...viewColumns) {
					var c = c_ + colOffset;
					var isoCol = Std.int(c + rowOffset);
					var isoRow = Std.int(r - c - rowOffset);

					point.changeGrid(isoCol, isoRow);
					var tile = buffer.addElement(new TileWave(point.x, point.y, tileWidth, tileWidth, cubeId));
					tile.tint.a = 0x30;
					tiles.push(tile);

					var label = labels[i];
					label.x = Std.int(tile.x + (tileWidth / 2) - 24);
					label.y = Std.int(tile.y + (tileHeight / 2));
					label.text = '${point.column},${point.row}:$i';

					glyphs.updateText(label);
					i++;
				}
			}

			// init IsoPoint for tracking mouse cursor
			var cursorPoint = new IsoPoint(tileWidth, tileHeight);
			// init tile for the cursor
			var cursorId = 0;
			var cursorTile = new TileWave(cursorPoint.x, cursorPoint.y, tileWidth, tileWidth, cursorId);
			cursorTile.amp = 0.0;
			cursorTile.tint = 0xf01010b0;
			buffer.addElement(cursorTile);

			// bind mouse movement to update cursor
			window.onMouseMove.add((x, y) -> {
				// offset mouse x y
				// use display.localX and display.localY to offset the mouse position by the display offset and zoom
				mouseLocalX = display.localX(x) - cursorPoint.widthMid;
				mouseLocalY = display.localY(y) - cursorPoint.heightMid;

				// update the IsoPoint with offset mouse positions
				cursorPoint.changeScreen(mouseLocalX, mouseLocalY);

				// quantise to grid
				cursorPoint.changeGrid(cursorPoint.column, cursorPoint.row);

				cursorTile.x = Math.round(cursorPoint.x);
				cursorTile.y = Math.round(cursorPoint.y);
			});

			// bind mouse wheel to zoom center in or out
			var zoomIncrement = 0.25;
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
					var isoColumn = cursorPoint.column;
					var isoRow = cursorPoint.row;

					var viewRow = isoColumn + isoRow;
					var rowOffset = viewRow % 2;
					var colOffset = Math.floor(viewRow / 2);
					var viewCol = isoColumn - colOffset - rowOffset;
					var elemIndex = Std.int(viewRow * viewColumns + viewCol);
					trace('clicked $viewCol $viewRow $elemIndex');

					var tile = tiles[elemIndex];
					var isCursorInDisplay = cursorPoint.x >= 0 && cursorPoint.y >= 0 && display.width >= cursorPoint.x - tileWidth && display.height >= cursorPoint.y - tileHeight;
					if (isCursorInDisplay) {
						// if the clicked cell is red then it's out of bounds (todo... clamp to boundary with math)
						if (tile != null && tile.tint != 0x6a0e0030) {
							tile.tint = 0xf0f0a4ff;
							tile.z = 0; // return to baseline z
							tile.amp = 0.0; // this stops the element from moving
						}
					}
				}
			});

			// bind keys
			window.onKeyDown.add((code, modifier) -> {
				switch code {
					case W | UP: scrollY(-1);
					case S | DOWN: scrollY(1);
					case A | LEFT: scrollX(-1);
					case D | RIGHT: scrollX(1);
					case NUMPAD_1:
					case NUMPAD_2:
					case NUMPAD_3:
					case NUMPAD_4:
					case NUMPAD_5: tweakUniform(uLeng, 25, -1);
					case NUMPAD_6: tweakUniform(uLeng, 25, 1);
					case NUMPAD_7:
					case NUMPAD_8: tweakUniform(uAmp, 1, -1);
					case NUMPAD_9: tweakUniform(uAmp, 1, 1);
					case NUMPAD_0: toggleLabels();
					case _:
				}
			});

			// bind app update for "game loop"
			onUpdate.add(i -> {
				// send tile element changes to GPU
				buffer.update();
			});

			showMap();
		});
	}

	function showMap() {
		var point = new IsoPoint(tileWidth, tileHeight);
		var rowEnd = topRowInView + viewRows;
		var colEnd = leftColumnInView + viewColumns;
		trace(' $leftColumnInView $topRowInView to $colEnd $rowEnd');

		var i = 0;
		for (r in topRowInView...rowEnd) {
			var rowOffset = (r % 2);
			var colOffset = (r - topRowInView - rowOffset) / 2;

			for (c_ in leftColumnInView...colEnd) {
				var c = c_ + colOffset;
				var isoCol = Std.int(c + rowOffset);
				var isoRow = Std.int(r - c - rowOffset);

				// update the label
				point.changeGrid(isoCol, isoRow);
				var text = labels[i];
				text.text = '${point.column},${point.row}:$i';
				glyphs.updateText(text);

				// update the tile
				var tile = tiles[i];
				tile.tint.r = 0x00;
				tile.tint.g = 0x00;
				tile.tint.b = 0xff - (isoRow * colorShift);
				tile.tint.a = 0xa0;
				// enable wave movement
				tile.amp = 1.0;
				// push these lower in height the land tiles, which are at 0
				tile.z = 10 * tileScale;
				// adjust phase so the wave starts at iso grid 0,0
				tile.phase = isoCol + mapColumns * isoRow;
				i++;

				// the out of bounds tiles
				if (isoRow < 0 || isoCol < 0 || isoRow > mapRows || isoCol > mapColumns) {
					tile.tint = 0x6a0e0030; // color them red
					tile.amp = 0.0; // prevent wave
				}

				// set tiles which are mapped
				var mapEntry = map[isoRow]?.charAt(isoCol);
				if (mapEntry != " ") {
					if (mapEntry == "#") {
						tile.tint = 0xf0f0a4ff;
						tile.z = 0;
						tile.amp = 0.0;
					}
				}
			}
		}
	}

	function toggleLabels() {
		if (glyphs.isVisible) {
			glyphs.hide();
		} else {
			glyphs.show();
		}
	}

	function scrollX(direction:Int) {
		leftColumnInView += 1 * direction;
		showMap();
	}

	function scrollY(direction:Int) {
		topRowInView += 2 * direction;
		leftColumnInView += 1 * direction;
		showMap();
	}

	function tweakUniform(u:UniformFloat, amount:Float, direction:Int) {
		u.value += ((amount * tileScale) * direction);
	}
}

var map:Array<String> = [
	"                                                                     #",
	"                                                                     #",
	"     #         #        #        #        #        #        #        #",
	"    ###       ###      ###      ###      ###      ###      ###       #",
	"   #####     #####    #####    #####    #####    #####    #####      #",
	"                                                                     #",
	"   #####     #####    #####    #####    #####    #####    #####      #",
	"    ###       ###      ###      ###      ###      ###      ###       #",
	"     #         #        #        #        #        #        #        #",
	"                                                                     #",
	"                                                                     #",
	"  ####   ####     #######     ####   ####   ###########   ####       #",
	"  ####   ####    #########    ####   ####   ###########   ####       #",
	"  ####   ####   ###########   ##### #####   ####          ####       #",
	"  ###########   ##### #####    #########    ###########   ####       #",
	"  ###########   ####   ####     #######     ###########   ####       #",
	"  ###########   ###########    #########    ####          ####       #",
	"  ####   ####   ###########   ###########   ####                     #",
	"  ####   ####   ####   ####   ##### #####   ###########   ####       #",
	"  ####   ####   ####   ####   ####   ####   ###########   ####       #",
	"                                                                     #",
	"                                                                     #",
	"     #         #        #        #        #        #        #        #",
	"    ###       ###      ###      ###      ###      ###      ###       #",
	"   #####     #####    #####    #####    #####    #####    #####      #",
	"  #######   #######  #######  #######  #######  #######  #######     #",
	"   #####     #####    #####    #####    #####    #####    #####      #",
	"    ###       ###      ###      ###      ###      ###      ###       #",
	"     #         #        #        #        #        #        #        #",
	"                                                                     #",
	"                                                                     #",
	"######################################################################",
];
