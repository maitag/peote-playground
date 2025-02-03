package;

import peote.view.Mask;
import peote.view.BlendFunc;
import peote.view.BlendFactor;
import peote.view.PeoteGL;
import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Color;
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
	public var colorEnabled:Bool = true;
	public var blendEnabled:Bool = false;
	public var blendSeparate:Bool = false;
	public var blendFuncSeparate:Bool = false;
	var blendValues:Int = 0;
	public var blendSrc(get, set):BlendFactor;
	public var blendDst(get, set):BlendFactor;
	public var blendSrcAlpha(get, set):BlendFactor;
	public var blendDstAlpha(get, set):BlendFactor;
	inline function get_blendSrc():BlendFactor return BlendFactor.getSrc(blendValues);
	inline function get_blendDst():BlendFactor return BlendFactor.getDst(blendValues);
	inline function get_blendSrcAlpha():BlendFactor return BlendFactor.getSrcAlpha(blendValues);
	inline function get_blendDstAlpha():BlendFactor return BlendFactor.getDstAlpha(blendValues);
	inline function set_blendSrc(v:BlendFactor):BlendFactor { setBlendUseColor(); if (gl != null) glBlendSrc = v.toGL(gl); blendValues = v.setSrc(blendValues); return v; }
	inline function set_blendDst(v:BlendFactor):BlendFactor { setBlendUseColor(); if (gl != null) glBlendDst = v.toGL(gl); blendValues = v.setDst(blendValues); return v; }
	inline function set_blendSrcAlpha(v:BlendFactor):BlendFactor { setBlendUseColor(); if (gl != null) glBlendSrcAlpha = v.toGL(gl); blendValues = v.setSrcAlpha(blendValues); return v; }
	inline function set_blendDstAlpha(v:BlendFactor):BlendFactor { setBlendUseColor(); if (gl != null) glBlendDstAlpha = v.toGL(gl); blendValues = v.setDstAlpha(blendValues); return v; }
	public var blendFunc(get, set):BlendFunc;
	public var blendFuncAlpha(get, set):BlendFunc;
	inline function get_blendFunc():BlendFunc return BlendFunc.getFunc(blendValues);
	inline function get_blendFuncAlpha():BlendFunc return BlendFunc.getFuncAlpha(blendValues);	
	inline function set_blendFunc(v:BlendFunc):BlendFunc { if (gl != null) glBlendFunc = v.toGL(gl); blendValues = v.setFunc(blendValues); return v; }
	inline function set_blendFuncAlpha(v:BlendFunc):BlendFunc { if (gl != null) glBlendFuncAlpha = v.toGL(gl); blendValues = v.setFuncAlpha(blendValues); return v; }
	inline function setBlendUseColor() {
		useBlendColor = (glBlendSrc > 10 || glBlendDst > 10) ? true : false;
		useBlendColorSeparate = (useBlendColor || glBlendSrcAlpha > 10 || glBlendDstAlpha > 10) ? true : false;
	}
	inline function setDefaultBlendValues() {
		blendSrc  = blendSrcAlpha  = BlendFactor.SRC_ALPHA;
		blendDst  = blendDstAlpha  = BlendFactor.ONE_MINUS_SRC_ALPHA;
		blendFunc = blendFuncAlpha = BlendFunc.ADD;
	}
	inline function updateBlendGLValues() {
		glBlendSrc = BlendFactor.getSrc(blendValues).toGL(gl);
		glBlendDst = BlendFactor.getDst(blendValues).toGL(gl);
		glBlendSrcAlpha = BlendFactor.getSrcAlpha(blendValues).toGL(gl);
		glBlendDstAlpha = BlendFactor.getDstAlpha(blendValues).toGL(gl);		
		glBlendFunc = BlendFunc.getFunc(blendValues).toGL(gl);
		glBlendFuncAlpha = BlendFunc.getFuncAlpha(blendValues).toGL(gl);
	}
	var glBlendSrc:Int = 0;
	var glBlendDst:Int = 0;
	var glBlendSrcAlpha:Int = 0;
	var glBlendDstAlpha:Int = 0;
	var glBlendFunc:Int = 0;
	var glBlendFuncAlpha:Int = 0;
	var useBlendColor:Bool = false;
	var useBlendColorSeparate:Bool = false;
	public var blendColor(default, set):Color = 0x7F7F7F7F;
	inline function set_blendColor(v:Color):Color {
		glBlendR = v.r / 255.0;
		glBlendG = v.g / 255.0;
		glBlendB = v.b / 255.0;
		glBlendA = v.a / 255.0;
		return blendColor = v;
	}
	var glBlendR:Float;
	var glBlendG:Float;
	var glBlendB:Float;
	var glBlendA:Float;

	public var zIndexEnabled:Bool = false;
	public var mask:Mask = Mask.OFF;
	public var clearMask:Bool = false;

	// -----------------------------------------------------

	var bufferBytes:BufferBytes;
	var glBuffer:GLBuffer = null;
	var glVAO:GLVertexArrayObject = null;
	var glProgram:GLProgram = null;

	public function new(x:Int, y:Int, width:Int, height:Int, color:Color=0x00000000) 
	{
		setDefaultBlendValues();

		// create empty buffer
		// bufferBytes = BufferBytes.alloc(sizeForOneTryangle * minSize);
		// bufferBytes.fill(0, sizeForOneTryangle * minSize, 0);
		// TODO: for testing only create one at now
		addTryangle();

		super(x, y, width, height, color);
	}

	public function addTryangle() {
		var vertexData:Array<Float> = [
		//  x     y     r    g    b    a
			20, 580,  1.0, 0.0, 0.0, 0.7, // left
			270, 20,  0.0, 0.0, 1.0, 1.0, // top
			580,580,  0.0, 1.0, 0.0, 1.0, // right
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
			if (gl != null) { clearOldGLContext(); clearBufferVAOProgram(); }
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
			updateBlendGLValues();
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
	
	function clearBufferVAOProgram()
	{
		gl.deleteBuffer(glBuffer);
		if (peote.view.PeoteGL.Version.isVAO) gl.deleteVertexArray(glVAO);
		gl.deleteProgram(glProgram);
	}

	// -----------------------------------------------------------------------
	// -----------------------------------------------------------------------
	// -----------------------------------------------------------------------

	static var FLOAT = 4;
	static var VERTEX_STRIDE = 6;
	static var STRIDE = FLOAT * VERTEX_STRIDE;

	static inline var aPOS:Int = 0;
	static inline var aCOLOR:Int = 1;

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
	
	// view and display default uniforms
	var uRESOLUTION:GLUniformLocation;
	var uZOOM:GLUniformLocation;
	var uOFFSET:GLUniformLocation;
	var uTIME:GLUniformLocation;
	

	// -------- CREATE SHADER PROGRAM ---------
	function createProg():Void
	{
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
	}


	// -----------------------------------------------------------------------
	// ------------------------- RENDER --------------------------------------
	// -----------------------------------------------------------------------

	#if peoteview_customdisplay // needs compiler condition to enable override	
	override private function renderProgram(peoteView:PeoteView):Void
	{
		// super.renderProgram(peoteView); // renders added Programs
		
		gl.useProgram(glProgram);

		// ------------------- UNIFORMS ------------------
		if (Version.isUBO) { // uniform block (ES3)
			gl.bindBufferBase(gl.UNIFORM_BUFFER, UniformBufferView.block, peoteView.uniformBuffer.uniformBuffer);
			gl.bindBufferBase(gl.UNIFORM_BUFFER, UniformBufferDisplay.block, uniformBuffer.uniformBuffer);
		}
		else { // simple uniforms (ES2)
			gl.uniform2f (uRESOLUTION, peoteView.width, peoteView.height);
			gl.uniform2f (uZOOM, peoteView.xz * xz, peoteView.yz * yz);
			gl.uniform2f (uOFFSET, (x + xOffset + peoteView.xOffset) / xz, 
			                       (y + yOffset + peoteView.yOffset) / yz);
		}
				
		// -------- render modes  ----------------		
		peoteView.setColor(colorEnabled);
		peoteView.setGLDepth(zIndexEnabled);
		peoteView.setGLBlend(blendEnabled, blendSeparate, glBlendSrc, glBlendDst, glBlendSrcAlpha, glBlendDstAlpha, blendFuncSeparate, glBlendFunc, glBlendFuncAlpha, blendColor, useBlendColor, useBlendColorSeparate, glBlendR, glBlendG, glBlendB, glBlendA);			
		peoteView.setMask(mask, clearMask);
				
		// ------------- RENDER ----------------
		gl.bindBuffer(gl.ARRAY_BUFFER, glBuffer);

		// bind vertex attributes
		if (Version.isVAO) gl.bindVertexArray( glVAO ) else enableVertexAttrib();

		// draw single tryangle 
		gl.drawArrays( gl.TRIANGLES, 0, Std.int(bufferBytes.length / STRIDE) );
		
		// unbind vertex attributes
		if (Version.isVAO) gl.bindVertexArray(null); else disableVertexAttrib();
		
		// unbind buffer and program		
		gl.bindBuffer (gl.ARRAY_BUFFER, null);				
		gl.useProgram (null);
	}	
	
	
	// if Display is rendered into texture this is called instead:	
	// override private function renderFramebufferProgram(peoteView:PeoteView):Void {}	
	
	#end
}