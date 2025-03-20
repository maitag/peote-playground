package;

import peote.view.*;
import peote.view.intern.Util;

class FullDisplayElement implements Element
{
	@posX @const var x:Int = 0;
	@posY @const var y:Int = 0;
	@sizeX var w:Int;
	@sizeY var h:Int;

	public function new(width:Int, height:Int) {
		w = width;
		h = height;
	}
}

class Multipass
{
	var peoteView:PeoteView;

	var displayPass1:Display;
	var displayPass2:Display;
	var displayPass3:Display;

	var displayView:Display;
	var programView1:Program;
	var programView2:Program;
	var programView3:Program;

	public function new(peoteView:PeoteView, fbTexturePass1:Texture, shader:String)
	{	
		this.peoteView = peoteView;
		
		var w = fbTexturePass1.width;
		var h = fbTexturePass1.height;

		// ---------------------------------------
		// ---------- CELL SIMMULATION -----------
		// ---------------------------------------
		
		// new texture for programPass2 and 3
		var fbTexturePass2 = new Texture(w, h, 1, {format:fbTexturePass1.format, powerOfTwo:false} );
		var fbTexturePass3 = new Texture(w, h, 1, {format:fbTexturePass1.format, powerOfTwo:false} );
		
		// ----- TWO Displays into Framebuffer-queue ---------

		displayPass1 = new Display(0, 0, w, h);
		displayPass1.setFramebuffer(fbTexturePass2, peoteView); // renders into texture of next Pass
		
		displayPass2 = new Display(0, 0, w, h);
		displayPass2.setFramebuffer(fbTexturePass3, peoteView); // renders into texture of next Pass

		displayPass3 = new Display(0, 0, w, h);
		displayPass3.setFramebuffer(fbTexturePass1, peoteView); // renders into texture of next Pass
				

		// -- ONE buffer and ONE element ONLY is need \o/ --

		var buffer = new Buffer<FullDisplayElement>(1);
		buffer.addElement(new FullDisplayElement(w, h));


		// ----- Programs per Display (shader and textures) ------

		var programPass1 = new Program(buffer);
		programPass1.setTexture(fbTexturePass1, "base", false);
		programPass1.setColorFormula("pass1(base_ID)", false);
		programPass1.injectIntoFragmentShader(shader, true);

		var programPass2 = new Program(buffer);
		programPass2.setTexture(fbTexturePass2, "base", false);
		programPass2.setColorFormula("pass2(base_ID)", false);
		programPass2.injectIntoFragmentShader(shader, true);

		var programPass3 = new Program(buffer);
		programPass3.setTexture(fbTexturePass3, "base", false);
		programPass3.setColorFormula("pass3(base_ID)", false);
		programPass3.injectIntoFragmentShader(shader, true);


		// knot the programs to its Displays!
		displayPass1.addProgram(programPass1);
		displayPass2.addProgram(programPass2);
		displayPass3.addProgram(programPass3);



		// ----------------------------------------------
		// ----- Viewer Displays of the cell state ------
		// ----------------------------------------------

		// displayView = new Display(0, 0, w, h);
		displayView = new Display(0, 0, 800, 600);
		displayView.zoom = 4.69;

		programView1 = new Program(buffer);
		programView1.setTexture(fbTexturePass3, "base", false); // use fbTexture where DisplayPass1 is render into
		programView1.setColorFormula("view(base_ID)", false);
		programView1.injectIntoFragmentShader(shader, true);
		
		programView2 = new Program(buffer);
		programView2.setTexture(fbTexturePass2, "base", false); // use fbTexture where DisplayPass2 is render into
		programView2.setColorFormula("view(base_ID)", false);
		programView2.injectIntoFragmentShader(shader, true);

		programView3 = new Program(buffer);
		programView3.setTexture(fbTexturePass1, "base", false); // use fbTexture where DisplayPass2 is render into
		programView3.setColorFormula("view(base_ID)", false);
		programView3.injectIntoFragmentShader(shader, true);

		// this "swap"s later by using renderStep() or switchDisplay()
		programView1.isVisible = false;
		programView2.isVisible = false;
		// programView3.isVisible = false;

		// knot the programs to the viewer display!
		displayView.addProgram(programView1);
		displayView.addProgram(programView2);
		displayView.addProgram(programView3);


		// ------- add only the Viewer Display to peoteView ---------
		peoteView.addDisplay(displayView);	
	}

	public function renderStart() {
		peoteView.addFramebufferDisplay(displayPass1);
		peoteView.addFramebufferDisplay(displayPass2);
		peoteView.addFramebufferDisplay(displayPass3);
	}

	public function renderStop() {
		peoteView.removeFramebufferDisplay(displayPass1);
		peoteView.removeFramebufferDisplay(displayPass2);
		peoteView.removeFramebufferDisplay(displayPass3);
	}

	// --------------------------------------------------------------
	// ----- buffer swapping and to render step by step -------------
	// --------------------------------------------------------------

	public var pass(default, null):Int = 0;

	public function renderStep() {
		pass++;
		// switch between rendering the Displays at each step
		switch(pass) {
			case 1:
				peoteView.renderToTexture(displayPass1);
				programView1.isVisible = true;
				programView2.isVisible = false;
				programView3.isVisible = false;
			case 2:
				peoteView.renderToTexture(displayPass2);
				programView1.isVisible = false;
				programView2.isVisible = true;
				programView3.isVisible = false;
			case 3:
				peoteView.renderToTexture(displayPass3);
				programView1.isVisible = false;
				programView2.isVisible = false;
				programView3.isVisible = true;
				pass = 0;
			default:
		}
	}

	// to use in onRender Event
	public function switchDisplay() {
		pass++;
		// switch between the FB-Display-Chain so that each time only one is rendering
		switch(pass) {
			case 1:
				displayPass1.renderFramebufferEnabled = true;  programView1.isVisible = true;
				displayPass2.renderFramebufferEnabled = false; programView2.isVisible = false;
				displayPass3.renderFramebufferEnabled = false; programView3.isVisible = false;
			case 2:
				displayPass1.renderFramebufferEnabled = false; programView1.isVisible = false;
				displayPass2.renderFramebufferEnabled = true;  programView2.isVisible = true;
				displayPass3.renderFramebufferEnabled = false; programView3.isVisible = false;
			case 3:
				displayPass1.renderFramebufferEnabled = false; programView1.isVisible = false;
				displayPass2.renderFramebufferEnabled = false; programView2.isVisible = false;
				displayPass3.renderFramebufferEnabled = true;  programView3.isVisible = true;
				pass = 0;
			default:
		}
	}


}
