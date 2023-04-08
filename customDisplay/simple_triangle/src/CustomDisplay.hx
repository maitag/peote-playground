package;

import peote.view.PeoteGL.Version;
import peote.view.PeoteGL.Precision;
import peote.view.PeoteGL.GLUniformLocation;

import peote.view.utils.GLTool;

import peote.view.PeoteView;
import peote.view.Color;
import peote.view.Display;
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
	
	// for non UBO
	var uRESOLUTION:GLUniformLocation;
	var uZOOM:GLUniformLocation;
	var uOFFSET:GLUniformLocation;
	
	private function createShaderProgram():Void
	{
		var glShaderConfig = {
			isES3: Version.isES3,
			isINSTANCED: Version.isINSTANCED,
			isUBO: Version.isUBO,
			IN: (Version.isES3) ? "in" : "attribute",
			VARIN: (Version.isES3) ? "in" : "varying",
			VAROUT: (Version.isES3) ? "out" : "varying",
			VERTEX_FLOAT_PRECISION : Precision.availFragmentFloat("lowp"), // mediump, highp
			VERTEX_INT_PRECISION : null,
			VERTEX_SAMPLER_PRECISION : null,
			FRAGMENT_FLOAT_PRECISION : null,
			FRAGMENT_INT_PRECISION : null,
			FRAGMENT_SAMPLER_PRECISION : null,
			FRAGMENT_EXTENSIONS: [],
		};
		var vertexShader:String =		
		"
		::if isES3::#version 300 es::end::
		::if VERTEX_INT_PRECISION::precision ::VERTEX_INT_PRECISION:: int; ::end::
		::if VERTEX_FLOAT_PRECISION::precision ::VERTEX_FLOAT_PRECISION:: float; ::end::
		::if VERTEX_SAMPLER_PRECISION::precision ::VERTEX_SAMPLER_PRECISION:: sampler2D; ::end::
		
		// Uniforms -------------------------
		::if (isUBO)::
		uniform uboView {
			vec2 uResolution;
			vec2 uViewOffset;
			vec2 uViewZoom;
		};
		uniform uboDisplay {
			vec2 uOffset;
			vec2 uZoom;
		};
		::else::
		uniform vec2 uResolution;
		uniform vec2 uOffset;
		uniform vec2 uZoom;
		::end::
		
		// Attributes -------------------------
		::IN:: vec2 aPosition;
		
		//::ATTRIB_POS::	
		//::ATTRIB_COLOR::
			
		// Varyings ---------------------------	
		//::OUT_COLOR::
		
		// --------- vertex main --------------
		void main(void)
		{
			//TODO: calculate pos
			
			float width = uResolution.x;
			float height = uResolution.y;
			
			::if (isUBO)::
			float deltaX = (uOffset.x  + uViewOffset.x) / uZoom.x;
			float deltaY = (uOffset.y  + uViewOffset.y) / uZoom.y;
			vec2 zoom = uZoom * uViewZoom;
			::else::
			float deltaX = uOffset.x;
			float deltaY = uOffset.y;
			vec2 zoom = uZoom;
			::end::
						
			gl_Position = vec4 (
				 2.0 * zoom.x/width  * (pos.x + deltaX) - 1.0,
				-2.0 * zoom.y/height * (pos.y + deltaY) + 1.0,
				- ::ZINDEX::,
				1.0
			);		
			
		}
		";
		
/*		
		var glVShader = GLTool.compileGLShader(gl, gl.VERTEX_SHADER,   GLTool.parseShader(vertexShader,   glShaderConfig), true );
		var glFShader = GLTool.compileGLShader(gl, gl.FRAGMENT_SHADER, GLTool.parseShader(fragmentShader, glShaderConfig), true );

		var glProg = gl.createProgram();

		gl.attachShader(glProg, glVShader);
		gl.attachShader(glProg, glFShader);
		
		//buffer.bindAttribLocations(gl, glProg);
		
		GLTool.linkGLProgram(gl, glProg);
		
		if ( PeoteGL.Version.isUBO)
		{
			var index:Int = gl.getUniformBlockIndex(glProg, "uboView");
			if (index != gl.INVALID_INDEX) gl.uniformBlockBinding(glProg, index, UniformBufferView.block);
			index = gl.getUniformBlockIndex(glProg, "uboDisplay");
			if (index != gl.INVALID_INDEX) gl.uniformBlockBinding(glProg, index, UniformBufferDisplay.block);
		}
		else
		{	
			uRESOLUTION = gl.getUniformLocation(glProg, "uResolution");
			uZOOM = gl.getUniformLocation(glProg, "uZoom");
			uOFFSET = gl.getUniformLocation(glProg, "uOffset");
		}
		
		uTIME = gl.getUniformLocation(glProg, "uTime");
*/		
		
	}
	
	override private function renderProgram(peoteView:PeoteView):Void
	{
		// to also render the other added Programs
		// super.renderProgram(peoteView);
		
		// -----------------------------------------------
		// ----------- ---- SHADERPROGRAM ----------------
		// -----------------------------------------------

		//  gl.useProgram(glProgram);
		
		
		
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