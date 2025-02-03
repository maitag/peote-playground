package;

import haxe.ds.Vector;
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

import Triangle as BufferElement;

/*
    o-o    o-o  o-o-o  o-o
   o   o  o        o      o
  o-o-o  o-o  \|/   o    o-o
 o      o     <O>    o      o
o      o-o    /|\     o    o-o

*/

/**
	A TriangleDisplay is a custom `Display` where `Triangle` elements can be added like in Buffer.  
**/
@:access(peote.view)
class TriangleDisplay extends Display 
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
	// -----------------------------------------------------
	
	var glBuffer:GLBuffer = null;
	var glVAO:GLVertexArrayObject = null;
	var glProgram:GLProgram = null;

	var bufferBytes:BufferBytes;
	var elements: Vector<BufferElement>;
	var maxElements:Int = 0; // amount of added elements (pos of last element)
	var elemBuffSize:Int;

	var minSize:Int;
	var growSize:Int = 0;
	var shrinkAtSize:Int = 0;

	// -----------------------------------------------------

	/**
		Creates a new `Display` instance.
		@param x x-position of the upper left corner
		@param y y-position of the upper left corner
		@param width horizontal size of the display
		@param height vertical size of the display
		@param color background color (by default the alpha value is fully transparent and so also no background is rendered)
		@param minSize how many elements a buffer should contain as a minimum
		@param growSize the size by which the buffer should grow when it is full
		@param autoShrink whether the buffer should also automatically shrink again (by the growsize)
	**/
	public function new(x:Int, y:Int, width:Int, height:Int, color:Color, minSize:Int, growSize:Int = 0, autoShrink:Bool = false) 
	{
		setDefaultBlendValues();

		// create empty BufferBytes
		if (minSize <= 0) throw("Error: Buffer need a minimum size of 1 to store an Element.");
		this.minSize = minSize;
		this.growSize = (growSize < 0) ? 0 : growSize;
		if (autoShrink) shrinkAtSize = this.growSize + Std.int(this.growSize/2);
				
		elements = new Vector<BufferElement>(minSize);		
		elemBuffSize = BufferElement.BYTES_PER_VERTEX * BufferElement.VERTEX_COUNT;
		
		#if peoteview_debug_buffer
		trace("create bytes for GLbuffer");
		#end
		bufferBytes = BufferBytes.alloc(elemBuffSize * minSize);
		bufferBytes.fill(0, elemBuffSize * minSize, 0);

		super(x, y, width, height, color);
	}

	// -----------------------------------------------------------
	// -------------- BUFFERING ----------------------------------
	// -----------------------------------------------------------

	override private function setNewGLContext(newGl:PeoteGL)
	{
		if (newGl != null && newGl != gl) // only if different GL - Context	
		{
			// clear old gl-context if there is one
			if (gl != null) { clearOldGLContext(); clearBufferVAOProgram(); }
			#if peoteview_debug_display
			trace("TriangleDisplay setNewGLContext");
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
		// -------- create buffer ----------
		#if peoteview_debug_buffer
		trace("create new GlBuffer");
		#end
		glBuffer = gl.createBuffer();

		gl.bindBuffer (gl.ARRAY_BUFFER, glBuffer);
		gl.bufferData (gl.ARRAY_BUFFER, bufferBytes.length, new GLBufferPointer(bufferBytes), gl.STREAM_DRAW); // STATIC_DRAW, DYNAMIC_DRAW, STREAM_DRAW 
		gl.bindBuffer (gl.ARRAY_BUFFER, null);
		

		// ----- init vertex attributes or VAO ------
		if (Version.isVAO) {	
			glVAO = gl.createVertexArray();
			gl.bindVertexArray(glVAO);

			gl.bindBuffer(gl.ARRAY_BUFFER, glBuffer);
			BufferElement.enableVertexAttrib(gl);
			gl.bindBuffer(gl.ARRAY_BUFFER, null);
			
			gl.bindVertexArray(null);
		}

		createShaderProgram();
	}
	
	function clearBufferVAOProgram()
	{
		#if peoteview_debug_buffer
		trace("delete GlBuffer");
		#end
		gl.deleteBuffer(glBuffer);
		if (peote.view.PeoteGL.Version.isVAO) gl.deleteVertexArray(glVAO);
		gl.deleteProgram(glProgram);
	}

	function updateGLBuffer():Void {
		gl.bindBuffer(gl.ARRAY_BUFFER, glBuffer);
		gl.bufferSubData(gl.ARRAY_BUFFER, 0, elemBuffSize*maxElements, new GLBufferPointer(bufferBytes) );		
		gl.bindBuffer(gl.ARRAY_BUFFER, null);
	}
	
	function changeBufferSize(newSize:Int):Void {
		var _newBytes = BufferBytes.alloc(elemBuffSize * newSize);
		_newBytes.blit(0, bufferBytes, 0, elemBuffSize * maxElements);
		bufferBytes = _newBytes;
		
		var _newElements = new Vector<BufferElement>(newSize);
		for (i in 0...maxElements) {
			var element = elements.get(i);
			element.bufferPointer = new GLBufferPointer(bufferBytes, element.bytePos, elemBuffSize);
			_newElements.set(i, element); 
		}
		elements = _newElements;

		if (gl != null) {
			gl.deleteBuffer(glBuffer);
			glBuffer = gl.createBuffer();
			gl.bindBuffer (gl.ARRAY_BUFFER, glBuffer);
			gl.bufferData (gl.ARRAY_BUFFER, bufferBytes.length, new GLBufferPointer(bufferBytes), gl.STREAM_DRAW); // STATIC_DRAW, DYNAMIC_DRAW, STREAM_DRAW 
			gl.bindBuffer (gl.ARRAY_BUFFER, null);
			if (Version.isVAO) { // rebind VAO	
				gl.bindVertexArray(glVAO);

				gl.bindBuffer(gl.ARRAY_BUFFER, glBuffer);
				BufferElement.enableVertexAttrib(gl);
				gl.bindBuffer(gl.ARRAY_BUFFER, null);

				gl.bindVertexArray(null);
			}
		}
	}

	/**
		The number of elements inside the buffer.
	**/
	public var length(get, never):Int;
	inline function get_length():Int return maxElements;
		
	/**
		Adds an element to the buffer for rendering and returns it.
		@param  element Element instance
	**/
	public function addElement(element: BufferElement):BufferElement
	{	
		if (element.bytePos == -1) {
			if (maxElements == elements.length) {
				if (growSize == 0) throw("Error: Can't add new Element. Buffer is full and automatic growing Buffersize is disabled.");
				#if peoteview_debug_buffer
				trace("grow up the Buffer to new size", maxElements + growSize);
				#end
				changeBufferSize(maxElements + growSize);
			}
			element.bytePos = maxElements * elemBuffSize;
			element.bufferPointer = new GLBufferPointer(bufferBytes, element.bytePos, elemBuffSize);
			elements.set(maxElements++, element);
			updateElement(element);
		} 
		else throw("Error: Element is already inside a Buffer");

		return element;
	}

	/**
		Updates the changes of an contained element to the rendering process.
		@param  element Element instance
	**/
	public function updateElement(element: BufferElement):Void {
		if (element.bytePos == -1) throw ("Error, Element is not added to Buffer");		
		element.writeBytes(bufferBytes);				
		if (gl != null) {
			// element.updateGLBuffer(_gl, _glBuffer, _elemBuffSize);
			gl.bindBuffer(gl.ARRAY_BUFFER, glBuffer);
			gl.bufferSubData(gl.ARRAY_BUFFER, element.bytePos, elemBuffSize, element.bufferPointer);
			gl.bindBuffer(gl.ARRAY_BUFFER, null);
		}
			
	}

	/**
		Updates the complete buffer, so the changes of all contained elements at once to the rendering process.
	**/
	public function update():Void {
		for (i in 0...maxElements) elements.get(i).writeBytes(bufferBytes);
		updateGLBuffer();
	}

	/**
		Removes an element from the buffer, so it will not be rendered anymore.
		@param  element Element instance
	**/
	public function removeElement(element: BufferElement):Void {	
		if (element.bytePos != -1) {
			if (maxElements > 1 && element.bytePos < (maxElements-1) * elemBuffSize ) {
				#if peoteview_debug_buffer
				trace("Buffer.removeElement", element.bytePos);
				#end
				var lastElement:BufferElement = elements.get(--maxElements);
				lastElement.bytePos = element.bytePos;
				lastElement.bufferPointer = new GLBufferPointer(bufferBytes, element.bytePos, elemBuffSize);
				updateElement(lastElement);
				elements.set( Std.int( element.bytePos / elemBuffSize ), lastElement);
			}
			else maxElements--;
			element.bytePos = -1;
			if (shrinkAtSize > 0 && elements.length - growSize >= minSize && maxElements <= elements.length - shrinkAtSize) {
				#if peoteview_debug_buffer
				trace("shrink Buffer to size", elements.length - growSize);
				#end
				changeBufferSize(elements.length - growSize);
			}			
		}
		else throw("Error: Element is not inside a Buffer");
	}

	/**
		Removes all elements from the buffer, so they will not be rendered anymore. 
		For GC you can use `clear(true)` to set all element references to `null` (a bit faster by `clear(true, true)`).
		@param  clearElementsRefs `true` to also set all element-references to null (false by default)
		@param  notUseElementsLater `true` a bit faster if you can not need to add the elements to a Buffer again (false by default)
	**/
	public function clear(clearElementsRefs:Bool = false, notUseElementsLater:Bool = false):Void {
		if (notUseElementsLater) clearElementsRefs = true;
		if (shrinkAtSize > 0) clearElementsRefs = false;
		if ( clearElementsRefs || (!notUseElementsLater) ) {
			for (i in 0...maxElements) {
				if (!notUseElementsLater) elements.get(i).bytePos = -1;
				if (clearElementsRefs) elements.set(i, null);
			}
		}
		maxElements = 0;
		if (shrinkAtSize > 0) {
			#if peoteview_debug_buffer
			trace("shrink Buffer to size", minSize);
			#end
			changeBufferSize(minSize);
		}	
	}

	/**
		Returns the element from buffer at index position.
		@param  elementIndex index of the element inside the buffer
	**/
	public function getElement(elementIndex:Int): BufferElement {
		return elements.get(elementIndex);
	}

	/**
		Returns the index position of an element inside the buffer.
		@param  element Element instance
	**/
	public function getElementIndex(element: BufferElement):Int {
		if (element.bytePos != -1) return Std.int(  element.bytePos / elemBuffSize );
		else throw("Error: Element is not inside a Buffer");
	}

	/**
		Swaps the order of two elements inside the buffer. This will change the drawing order if no z-index is used.
		@param  element1 first Element instance
		@param  element2 second Element instance
	**/
	public function swapElements(element1: BufferElement, element2: BufferElement):Void
	{	
		#if peoteview_debug_buffer
		trace("Buffer.swapElements", element.bytePos);
		#end
		
		if (element1.bytePos == -1) throw("Error: first Element is not inside a Buffer");
		if (element2.bytePos == -1) throw("Error: second Element is not inside a Buffer");
		
		var bytePos1 = element1.bytePos;
		var bufferPointer1 = element1.bufferPointer;
		
		element1.bufferPointer = element2.bufferPointer;
		element1.bytePos = element2.bytePos;
		element2.bufferPointer = bufferPointer1;
		element2.bytePos = bytePos1;
		
		elements.set( Std.int(  element1.bytePos / elemBuffSize ), element1);
		elements.set( Std.int(  element2.bytePos / elemBuffSize ), element2);
	}
	
	// ---------------------------------------------------------------
	// ---------------- SHADER PROGRAM -------------------------------
	// ---------------------------------------------------------------
	
	// view and display uniforms
	var uRESOLUTION:GLUniformLocation;
	var uZOOM:GLUniformLocation;
	var uOFFSET:GLUniformLocation;
	var uTIME:GLUniformLocation;
	
	function createShaderProgram():Void {
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
			${[for (a in BufferElement.attributes) ((Version.isES3) ? "in ":"attribute ")+a+";"].join("")}

			// varyings out
			${[for (v in BufferElement.varyings) ((Version.isES3) ? "out ":"varying ")+v+";"].join("")}

			void main()
			{   
				${Version.isUBO ? "
				float deltaX = (uOffset.x  + uViewOffset.x) / uZoom.x;
				float deltaY = (uOffset.y  + uViewOffset.y) / uZoom.y;
				vec2 zoom = uZoom * uViewZoom;
				" : "
				float deltaX = uOffset.x;
				float deltaY = uOffset.y;
				vec2 zoom = uZoom;
				"}

				${BufferElement.vertexShaderMain}
			}
		';

		// fragment shader
		var glsl_fragment = '${Version.isES3 ? "#version 300 es" : ""}
			precision mediump float;

			${[for (v in BufferElement.varyings) ((Version.isES3) ? "in ":"varying ")+v+";"].join("")}

			${Version.isES3 ? "out vec4 Color;" : ""}

			void main() 
			{	${BufferElement.fragmentShaderMain}
				${Version.isES3 ? "Color" : "gl_FragColor"} = col;				
			}
		';
		
		var vertex_shader:GLShader = GLTool.compileGLShader(gl, gl.VERTEX_SHADER,   glsl_vertex, true );
		var fragment_shader:GLShader = GLTool.compileGLShader(gl, gl.FRAGMENT_SHADER, glsl_fragment, true );
		
		glProgram = gl.createProgram();

		gl.attachShader(glProgram, vertex_shader);
		gl.attachShader(glProgram, fragment_shader);
	
		BufferElement.bindAttribLocations(gl, glProgram);

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

	// -------------------------------------------------
	// ----------------- RENDER ------------------------
	// -------------------------------------------------

	#if peoteview_customdisplay // needs compiler condition to enable override	
	override private function renderProgram(peoteView:PeoteView):Void
	{
		// super.renderProgram(peoteView); // renders added Programs
		
		gl.useProgram(glProgram);

		if (Version.isUBO) { // uniform block (ES3)
			gl.bindBufferBase(gl.UNIFORM_BUFFER, UniformBufferView.block, peoteView.uniformBuffer.uniformBuffer);
			gl.bindBufferBase(gl.UNIFORM_BUFFER, UniformBufferDisplay.block, uniformBuffer.uniformBuffer);
		}
		else { // simple uniforms (ES2)
			gl.uniform2f (uRESOLUTION, peoteView.width, peoteView.height);
			gl.uniform2f (uZOOM, peoteView.xz * xz, peoteView.yz * yz);
			gl.uniform2f (uOFFSET, (x + xOffset + peoteView.xOffset) / xz, (y + yOffset + peoteView.yOffset) / yz);
		}
				
		// -------- render modes  ----------------		
		peoteView.setColor(colorEnabled);
		peoteView.setGLDepth(zIndexEnabled);
		peoteView.setGLBlend(blendEnabled, blendSeparate, glBlendSrc, glBlendDst, glBlendSrcAlpha, glBlendDstAlpha, blendFuncSeparate, glBlendFunc, glBlendFuncAlpha, blendColor, useBlendColor, useBlendColorSeparate, glBlendR, glBlendG, glBlendB, glBlendA);			
		peoteView.setMask(mask, clearMask);
				
		// ------------- RENDER ----------------
		gl.bindBuffer(gl.ARRAY_BUFFER, glBuffer);

		if (Version.isVAO) gl.bindVertexArray( glVAO ) else BufferElement.enableVertexAttrib(gl);
		gl.drawArrays( gl.TRIANGLES, 0, BufferElement.VERTEX_COUNT * maxElements );
		if (Version.isVAO) gl.bindVertexArray(null); else BufferElement.disableVertexAttrib(gl);
		
		// unbind buffer and program		
		gl.bindBuffer (gl.ARRAY_BUFFER, null);				
		gl.useProgram (null);
	}	
	
	
	// if Display is rendered into texture this is called instead:	
	// override private function renderFramebufferProgram(peoteView:PeoteView):Void {}	
	
	#end
}