package;

import peote.view.PeoteGL;
import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Color;
import peote.view.UniformFloat;
import peote.view.PeoteGL.Version;
import peote.view.PeoteGL.GLBuffer;
import peote.view.PeoteGL.GLVertexArrayObject;
import peote.view.PeoteGL.GLProgram;
import peote.view.PeoteGL.GLShader;
import peote.view.intern.BufferBytes;
import peote.view.intern.GLBufferPointer;
import peote.view.intern.UniformBufferView;
import peote.view.intern.UniformBufferDisplay;
import peote.view.intern.GLTool;

@:access(peote.view)
class CustomDisplay extends Display 
{
	var bufferBytes:BufferBytes;
	var glBuffer:GLBuffer = null;
	var glVAO:GLVertexArrayObject = null;
	var glProgram:GLProgram = null;

	public function new(x:Int, y:Int, width:Int, height:Int, color:Color=0x00000000) 
	{
		// create empty buffer
		// bufferBytes = BufferBytes.alloc(sizeForOneTryangle * minSize);
		// bufferBytes.fill(0, sizeForOneTryangle * minSize, 0);
		// TODO: for testing only create one at now
		addTryangle();

		super(x, y, width, height, color);
	}

	public function addTryangle() {
		// define vertexes for a triangle; x,y and rgba
		var vertexData = [
		//  x     y     r    g    b    a
			20, 580,  1.0, 0.0, 0.0, 1.0, // left
			580,580,  0.0, 1.0, 0.0, 1.0, // right
			270, 20,  0.0, 0.0, 1.0, 1.0, // top
		];
		
		bufferBytes = BufferBytes.alloc(STRIDE * vertexData.length);

		var pos = 0;
		for (v in vertexData) {
			bufferBytes.setFloat(pos, v);
			pos += FLOAT;
		}
		
		// copy vertex data into buffer (TODO: do this later into update for some of the tryangles)
		// gl.bindBuffer(gl.ARRAY_BUFFER, glBuffer);
		// gl.bufferData(gl.ARRAY_BUFFER, bufferBytes.length, new GLBufferPointer(bufferBytes), gl.STATIC_DRAW);
		// gl.bindBuffer(gl.ARRAY_BUFFER, null);
	}

	override private function setNewGLContext(newGl:PeoteGL)
	{
		if (newGl != null && newGl != gl) // only if different GL - Context	
			{
				// clear old gl-context if there is one
				if (gl != null) { clearOldGLContext(); clearBufferVAO(); }
				#if peoteview_debug_display
				trace("Display setNewGLContext");
				#end
				gl = newGl;			
				if (Version.isUBO) {
					uniformBuffer.createGLBuffer(gl, x + xOffset, y + yOffset, xz, yz);
					uniformBufferFB.createGLBuffer(gl, xOffset, yOffset - height, xz, yz);
					uniformBufferViewFB.createGLBuffer(gl, width, -height, 0.0, 0.0, 1.0, 1.0);
				}
				
				// setNewGLContext for all programs
				for (program in programList) program.setNewGLContext(newGl);			
				// if (fbTexture != null) fbTexture.setNewGLContext(newGl);	
				
				createBufferVAO();
			}
	}

	function createBufferVAO()
	{
		// create buffer
		glBuffer = gl.createBuffer();

		// FOR TESTING NOW: copy bufferBytes into buffer
		gl.bindBuffer (gl.ARRAY_BUFFER, glBuffer);
		gl.bufferData (gl.ARRAY_BUFFER, bufferBytes.length, new GLBufferPointer(bufferBytes), gl.STREAM_DRAW); // STATIC_DRAW, DYNAMIC_DRAW, STREAM_DRAW 
		gl.bindBuffer (gl.ARRAY_BUFFER, null);

		// init vao
		if (Version.isVAO) {	
			glVAO = gl.createVertexArray();
			gl.bindVertexArray(glVAO);
			enableVertexAttrib();
			gl.bindVertexArray(null);
		}

		createProg();

	}
	
	function clearBufferVAO()
	{
		gl.deleteBuffer(glBuffer);
		if (peote.view.PeoteGL.Version.isVAO) gl.deleteVertexArray(glVAO);
	}

	// -----------------------------------------------------------------------
	// -----------------------------------------------------------------------
	// -----------------------------------------------------------------------

	static var FLOAT = 4;
	static var VERTEX_STRIDE = 6;
	static var STRIDE = FLOAT * VERTEX_STRIDE;

	static inline var aPOS:Int = 0;
	static inline var aCOLOR:Int = 2;

	function enableVertexAttrib() {
		gl.bindBuffer(gl.ARRAY_BUFFER, glBuffer);

		// position attribute
		gl.enableVertexAttribArray(aPOS);
		gl.vertexAttribPointer(aPOS, 2, gl.FLOAT, false, STRIDE, 0);

		// color attribute
		gl.enableVertexAttribArray(aCOLOR);
		gl.vertexAttribPointer(aCOLOR, 4, gl.FLOAT, false, STRIDE, 2 * FLOAT);
	}

	function disableVertexAttrib() {
		gl.disableVertexAttribArray(aPOS);
		gl.disableVertexAttribArray(aCOLOR);
	}

	function bindAttribLocations() {
		gl.bindAttribLocation(glProgram, aPOS, "aPos");
		gl.bindAttribLocation(glProgram, aCOLOR, "aColor");
	}
	
	
	var uRESOLUTION:GLUniformLocation;
	var uZOOM:GLUniformLocation;
	var uOFFSET:GLUniformLocation;
	var uTIME:GLUniformLocation;
	
	// var uniformFloats:Array<UniformFloat> = new Array<UniformFloat>();
	// var uniformFloatLocations:Array<GLUniformLocation>;
	
	function createProg():Void
	{
		// -----------------------------------------------
		// ---------------- SHADERPROGRAM ----------------
		// -----------------------------------------------

		// vertex shader
		var glsl_vertex = '${Version.isES3 ? "#version 300 es" : ""}
			${Version.isUBO ? "
				uniform uboView {
					vec2 uResolution;
					vec2 uViewOffset;
					vec2 uViewZoom;
				};
				uniform uboDisplay {
					vec2 uOffset;
					vec2 uZoom;
				};
				":"
				uniform vec2 uResolution;
				uniform vec2 uOffset;
				uniform vec2 uZoom;
				"
			}
			
			// attributes
			${Version.isES3 ? "in" : "attribute"} vec2 aPos;
			${Version.isES3 ? "in" : "attribute"} vec4 aColor;

			// varyings out
			${Version.isES3 ? "out" : "varying"} vec4 vertexColor; 

			void main()
			{   
				vertexColor = aColor;

				float width = uResolution.x;
				float height = uResolution.y;

				${Version.isUBO ? "
				float deltaX = (uOffset.x  + uViewOffset.x) / uZoom.x;
				float deltaY = (uOffset.y  + uViewOffset.y) / uZoom.y;
				vec2 zoom = uZoom * uViewZoom;
				" : "
				float deltaX = uOffset.x;
				float deltaY = uOffset.y;
				vec2 zoom = uZoom;
				"}

				gl_Position = vec4 (
					2.0 * zoom.x/width  * (aPos.x + deltaX) - 1.0,
					-2.0 * zoom.y/height * (aPos.y + deltaY) + 1.0,
					- 0.0, // Z-INDEX
					1.0
				);		

			}
		';

		



		// fragment shader
		var glsl_fragment = '${Version.isES3 ? "#version 300 es" : ""}
			precision mediump float;

			${Version.isES3 ? "in" : "varying"} vec4 vertexColor;

			${Version.isES3 ? "out vec4 Color;" : ""}

			void main() 
			{
				vec4 col = vertexColor;

				${Version.isES3 ? "Color" : "gl_FragColor"} = col;
				
			}
		';
		
		var vertex_shader:GLShader = GLTool.compileGLShader(gl, gl.VERTEX_SHADER,   glsl_vertex, true );
		var fragment_shader:GLShader = GLTool.compileGLShader(gl, gl.FRAGMENT_SHADER, glsl_fragment, true );
		
		glProgram = gl.createProgram();

		gl.attachShader(glProgram, vertex_shader);
		gl.attachShader(glProgram, fragment_shader);
	
		bindAttribLocations();

		GLTool.linkGLProgram(gl, glProgram);

		gl.deleteShader(vertex_shader);
		gl.deleteShader(fragment_shader);

		// ----- UNIFORMS -----

		if (Version.isUBO) {
			var index:Int = gl.getUniformBlockIndex(glProgram, "uboView");
			if (index != gl.INVALID_INDEX) gl.uniformBlockBinding(glProgram, index, UniformBufferView.block);
			index = gl.getUniformBlockIndex(glProgram, "uboDisplay");
			if (index != gl.INVALID_INDEX) gl.uniformBlockBinding(glProgram, index, UniformBufferDisplay.block);
		}
		else {	
			uRESOLUTION = gl.getUniformLocation(glProgram, "uResolution");
			uZOOM = gl.getUniformLocation(glProgram, "uZoom");
			uOFFSET = gl.getUniformLocation(glProgram, "uOffset");
		}
		
		// uTIME = gl.getUniformLocation(glProgram, "uTime");
		// uniformFloatLocations = new Array<GLUniformLocation>();
		// for (u in uniformFloats) uniformFloatLocations.push( gl.getUniformLocation(glProgram, u.name) );
		
	}


	// -----------------------------------------------------------------------
	// ------------------------- RENDER --------------------------------------
	// -----------------------------------------------------------------------

	#if peoteview_customdisplay // needs compiler condition to enable override	
	override private function renderProgram(peoteView:PeoteView):Void
	{
		// to also render the other added Programs
		// super.renderProgram(peoteView);
		
		gl.useProgram(glProgram);

		// ------------------- UNIFORMS ------------------		

		if (Version.isUBO) // ------------- uniform block (ES3) -------------
		{
			gl.bindBufferBase(gl.UNIFORM_BUFFER, UniformBufferView.block, peoteView.uniformBuffer.uniformBuffer);
			gl.bindBufferBase(gl.UNIFORM_BUFFER, UniformBufferDisplay.block, uniformBuffer.uniformBuffer);
		}
		else // ------------- simple uniforms (ES2) -------------
		{
			gl.uniform2f (uRESOLUTION, peoteView.width, peoteView.height);
			gl.uniform2f (uZOOM, peoteView.xz * xz, peoteView.yz * yz);
			gl.uniform2f (uOFFSET, (x + xOffset + peoteView.xOffset) / xz, 
			                       (y + yOffset + peoteView.yOffset) / yz);
		}
		
		// gl.uniform1f (uTIME, peoteView.time);
		// for (i in 0...uniformFloats.length) gl.uniform1f (uniformFloatLocations[i], uniformFloats[i].value);
		
		// --------------- FLAGS -----------------		
		//peoteView.setColor(colorEnabled);
		//peoteView.setGLDepth(zIndexEnabled);
		//peoteView.setGLBlend(blendEnabled, blendSeparate, glBlendSrc, glBlendDst, glBlendSrcAlpha, glBlendDstAlpha, blendFuncSeparate, glBlendFunc, glBlendFuncAlpha, blendColor, useBlendColor, useBlendColorSeparate, glBlendR, glBlendG, glBlendB, glBlendA);			
		//peoteView.setMask(mask, clearMask);
		
		
		// -------------  RENDER BUFFER ----------------

		gl.bindBuffer(gl.ARRAY_BUFFER, glBuffer);

		// use vertex array object or not into binding your shader-attributes
		if (Version.isVAO) gl.bindVertexArray( glVAO ) else enableVertexAttrib();

		// try that single tryangle 
		gl.drawArrays( gl.TRIANGLES, 0, Std.int(bufferBytes.length / STRIDE) );
		
		if (Version.isVAO) gl.bindVertexArray(null);
		else disableVertexAttrib();
		
		
		gl.bindBuffer (gl.ARRAY_BUFFER, null);				
		gl.useProgram (null);
	}	
	
	

	// if Display is rendered into texture this is called instead:	
	// override private function renderFramebufferProgram(peoteView:PeoteView):Void {}	
	
	#end
}