package;

import peote.view.*;

class FramebufferDisplay extends Display {
	var buffer:Buffer<PixelElement>;
	var program:Program;
	var frame:PixelElement;

	public function new(peoteView:PeoteView, width:Int, height:Int, color:Color = 0x00000000) {
		super(0, 0, width, height, color);
		
		// tell peote view to use this display as a framebuffer
		peoteView.addFramebufferDisplay(this);

		// set a texture that the framebuffer will be rendered to
		setFramebuffer(new Texture(width, height));
		
		// buffer/program/element for rendering the texture
		buffer = new Buffer<PixelElement>(1);
		program = new Program(buffer);
		program.addTexture(fbTexture);
		frame = buffer.addElement(new PixelElement(0, 0, width, height));

		// set up pivot and offset position so the rotate is around the center
		frame.pivot_x = 0.5;
		frame.pivot_y = 0.5;
		frame.x += (frame.width * 0.5);
		frame.y += (frame.height * 0.5);
	}

	/** render the program that uses the texture to a display **/
	public function render_to(display:Display) {
		program.addToDisplay(display);
	}

	/** rotate the element to rotate the display **/
	public function rotate(angle:Float) {
		frame.angle = angle;
		buffer.updateElement(frame);
	}

	/** helper function for setting shader **/
	public function inject_glsl_program(glsl:String, color_formula:String) {
		program.injectIntoFragmentShader(glsl);
		program.setColorFormula(color_formula);
	}
}


