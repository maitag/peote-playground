package;

import peote.view.PeoteView;
import peote.view.Color;
import peote.view.Display;
import peote.view.PeoteGL.Version;
import peote.view.UniformBufferView;
import peote.view.UniformBufferDisplay;


@:access(peote.view)
class CustomDisplay extends Display 
{
	
	public function new(x:Int, y:Int, width:Int, height:Int, color:Color=0x00000000) 
	{
		super(x, y, width, height, color);
	}
	
	#if peoteview_customdisplay // needs compiler condition to enable override
	
	override private function renderProgram(peoteView:PeoteView):Void
	{
		// to also render the other added Programs
		// super.renderProgram(peoteView);
		
		// -----------------------------------------------
		// ----------- ---- SHADERPROGRAM ----------------
		// -----------------------------------------------
		
		//  gl.useProgram(glProgram);
		
		//  if (Version.isUBO)...
		
		// -----------------------------------------------
		// ------------------- TEXTURES ------------------
		// -----------------------------------------------
		// ... (better later!)
		
		// -----------------------------------------------
		// ------------------- UNIFORMS ------------------
		// -----------------------------------------------
		
		if (Version.isUBO) // ------------- uniform block (ES3) -------------
		{	
			gl.bindBufferBase(gl.UNIFORM_BUFFER, UniformBufferView.block, peoteView.uniformBuffer.uniformBuffer);
			gl.bindBufferBase(gl.UNIFORM_BUFFER, UniformBufferDisplay.block, uniformBuffer.uniformBuffer);
		}
		else // ------------- simple uniforms (ES2) -------------
		{
			//gl.uniform2f (uRESOLUTION, peoteView.width, peoteView.height);
			//gl.uniform2f (uZOOM, peoteView.xz * display.xz, peoteView.yz * display.yz);
			//gl.uniform2f (uOFFSET, (display.x + display.xOffset + peoteView.xOffset) / display.xz, 
								   //(display.y + display.yOffset + peoteView.yOffset) / display.yz);
		}
		
		//gl.uniform1f (uTIME, peoteView.time);
		
		// ---------------------------------------
		// --------------- FLAGS -----------------
		// ---------------------------------------
		
		//peoteView.setColor(colorEnabled);
		//peoteView.setGLDepth(zIndexEnabled);
		//peoteView.setGLAlpha(alphaEnabled);
		//peoteView.setMask(mask, clearMask);
		
		
		// --------------------------------------------------
		// -------------  VERTEX BUFFER DATA ----------------
		// --------------------------------------------------
		
		// use vertex array object or not into binding your shader-attributes		
		if (Version.isVAO) {
			// gl.bindVertexArray( ... );
		}
		else {
			// enable Vertex Attributes
		}

		// draw by instanced array (ES3) or without (ES2)
		if (Version.isINSTANCED)
		{
			// gl.drawArraysInstanced ( ... );
		}
		else
		{
			// gl.drawArrays ( ... );
		}
		

		// -----------------------------------------------------
		// ---- cleaning up VAO, Buffer and shaderprogram ------
		// -----------------------------------------------------
		
		if (Version.isVAO) {
			// gl.bindVertexArray(null);
		}
		else {
			// disable Vertex Attributes
		}
		
		gl.bindBuffer (gl.ARRAY_BUFFER, null);		
		gl.useProgram (null);
	}	
	
	

	
	
	// if Display is rendered into texture this is called instead:	
	// override private function renderFramebufferProgram(peoteView:PeoteView):Void {}	
	
	
	#end
}