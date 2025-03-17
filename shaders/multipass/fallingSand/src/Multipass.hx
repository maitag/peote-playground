package;

import haxe.Resource; // to include "shaderPasses.glsl" file

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
	public function new(peoteView:PeoteView, fbTextureB:Texture)
	{	
		var w = fbTextureB.width;
		var h = fbTextureB.height;
		
		// displayA will render INTO "fbTextureA" (but its Program is using the last ONE into QUEUE!)
		var fbTextureA = new Texture(w, h, 1, {format:fbTextureB.format} );
		
		// ----- TWO Displays into FB-queue ---------
		var displayA = new Display(0, 0, w, h);
		displayA.setFramebuffer(fbTextureA, peoteView);
		displayA.addToPeoteViewFramebuffer(peoteView);
		
		var displayB = new Display(0, 0, w, h);
		displayB.setFramebuffer(fbTextureB, peoteView);
		displayB.addToPeoteViewFramebuffer(peoteView);
		
		// to render "B" also into VIEW (to see what happens)
		displayB.addToPeoteView(peoteView);


		// -- ONE buffer and ONE element ONLY is need \o/ --
		var buffer = new Buffer<FullDisplayElement>(1);
		buffer.addElement(new FullDisplayElement(w, h));


		// --- Programs per Display and its SHADER SRC -----
		var shader = Resource.getString("shaderPasses.glsl");

		var programA = new Program(buffer);			
		programA.setTexture(fbTextureB, "base", false);
		programA.injectIntoFragmentShader( shader, true);
		programA.setColorFormula( "pass1(base_ID)" );
		
		var programB = new Program(buffer);
		programB.setTexture(fbTextureA, "base", false);
		programB.injectIntoFragmentShader( shader, true);
		programB.setColorFormula( "pass2(base_ID)" );
		

		// knot the programs to its Displays!
		displayA.addProgram(programA);
		displayB.addProgram(programB);
	}

}
