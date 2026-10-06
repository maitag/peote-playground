package;

import peote.view.intern.Ease;
import lime.app.Application;
import lime.graphics.Image;

import peote.view.*;

class SemmiSpiral implements Element
{
	// OK HALFWHEAT .-.> all is RUN .)-> N O W \o/
	
	@posX var x:Int;
	@posY var y:Int;

	@rotation @time("R", "pingpong") @constStart(0.0) @constEnd(1490.0) var r:Float;

	@pivotX @formula("r*0.2") var px:Int; // so it is "relative" to r <- now
	
	// here maybe is need to fix for point-SYMMETRY
	// @pivotY var py:Int;

	@color var c:Color = 0x5e5733ff;

	public function new(x:Int, y:Int) {
		this.x = x;
		this.y = y;
	}

}

class Spiral extends Application
{	
	override function onWindowCreate():Void {
		Load.image("assets/semmi_colors_by_yenoPenn.png", true, startByImage);				
	}

	function startByImage(image:Image) 
	{
		var peoteView = new PeoteView(window);
		var display = new Display(0, 0, 800, 600);				
		var buffer = new Buffer<SemmiSpiral>(4, 4, true);
		var program = new Program(buffer);
		
		var texture = new Texture(image.width, image.height);
		texture.setData(image);
		
		program.addTexture(texture, "custom");
		program.blendEnabled = true;				
		program.snapToPixel(1); // for smooth animation

		program.setEaseFormula("r", Ease.InOut(QUART));

		peoteView.addDisplay(display);
		display.addProgram(program);
		
		var semmi = new SemmiSpiral((display.width>>1)-50, (display.height>>1)-50);

		semmi.timeRDuration = 15.0;

		buffer.addElement(semmi);
		
		peoteView.start();
	}

}
