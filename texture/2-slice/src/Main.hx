package;

import peote.view.*;
import lime.graphics.Image;
import lime.app.Application;

class Main extends Application {
	var buffer:Buffer<TwoSliceElement>;
	var isReady:Bool = false;
	var mouse_y:Float;
	var sprites:Array<Sprite> = [];

	override function onWindowCreate():Void {
		var peoteView = new PeoteView(window);
		var display = new Display(0, 0, window.width, window.height, Color.GREY3);
		peoteView.addDisplay(display);

		Load.image('assets/tail.png', (image:Image) -> {
			buffer = new Buffer<TwoSliceElement>(256, 256);

			var tilesX = 10;
			var tilesY = 2;
			var tileHeight = 64;
			var sustainWidth = 50;

			var program:Program = TwoSliceElement.makeProgram(Texture.fromData(image), tilesX, tilesY, buffer, "sliced");
			program.addToDisplay(display);

			var sustainHeights = [64, 70, 90, 128, 150, 200, 321, 404, 505, 600,];

			for (n => sustainHeight in sustainHeights) {
				var x = (n * 70) + 15;
				var y = 0;
				var sprite = new Sprite(x, y, n, sustainWidth, sustainHeight, tileHeight, tilesX);
				sprites.push(sprite);
				sprite.addTo(buffer);
			}

			window.onMouseMove.add((x, y) -> mouse_y = y);

			isReady = true;
		});
	}

	override function update(deltaTime:Int) {
		if(!isReady) return;

		sprites[5].height = mouse_y;
		buffer.update();
	}
}
