package;

import peote.view.Color;
import peote.view.PeoteGL;
import peote.view.PeoteGL.GLProgram;
import peote.view.intern.GLBufferPointer;
import peote.view.intern.BufferBytes;

@:allow(TriangleDisplay)
class Triangle 
{	
	static var attributes = ["vec2 aPos", "vec4 aColor"];
	static var varyings   = ["vec4 vertexColor"];

	static var vertexShaderMain = "
		// vertexColor = aColor;
		vertexColor = aColor.wzyx;

		gl_Position = vec4 (
			2.0 * zoom.x/uResolution.x  * (aPos.x + deltaX) - 1.0,
			-2.0 * zoom.y/uResolution.y * (aPos.y + deltaY) + 1.0,
			- 0.0, // Z-INDEX
			1.0
		);
	";
	
	static var fragmentShaderMain = "
	vec4 col = vertexColor;
	";

	static inline var VERTEX_COUNT:Int = 3;
	static inline var BYTES_PER_VERTEX:Int = 12; // aPOS: 2*4 bytes, aCOLOR: 4*1 bytes
	
	static inline var aPOS: Int = 0;
	static inline var aCOLOR: Int = 1;
	// static inline var aZINDEX: Int = 2;
	
	inline static function enableVertexAttrib(gl:PeoteGL) {
		gl.enableVertexAttribArray(aPOS);
		gl.vertexAttribPointer(aPOS, 2, gl.FLOAT, false, BYTES_PER_VERTEX, 0);

		gl.enableVertexAttribArray(aCOLOR);
		gl.vertexAttribPointer(aCOLOR, 4, gl.UNSIGNED_BYTE, true, BYTES_PER_VERTEX, 8);
	}

	inline static function disableVertexAttrib(gl:PeoteGL) {
		gl.disableVertexAttribArray(aPOS);
		gl.disableVertexAttribArray(aCOLOR);
	}

	inline static function bindAttribLocations(gl:PeoteGL, glProgram:GLProgram) {
		gl.bindAttribLocation(glProgram, aPOS, "aPos");
		gl.bindAttribLocation(glProgram, aCOLOR, "aColor");
	}

	// -------------------------------------------------	
	var bytePos:Int = -1;
	var bufferPointer:GLBufferPointer;

	inline function writeBytes(b:BufferBytes) {
		b.setFloat(bytePos +  0, x1);
		b.setFloat(bytePos +  4, y1);
		b.setInt32(bytePos +  8, c1);

		b.setFloat(bytePos + 12, x2);
		b.setFloat(bytePos + 16, y2);
		b.setInt32(bytePos + 20, c2);
		
		b.setFloat(bytePos + 24, x3);
		b.setFloat(bytePos + 28, y3);
		b.setInt32(bytePos + 32, c3);
	}


	// -------------------------------------------------	
	// -------------------------------------------------	
	// -------------------------------------------------

	// vertex 1
	public var x1:Float;
	public var y1:Float;
	public var c1:Color = 0xff0000ff;
	
	// vertex 2
	public var x2:Float;
	public var y2:Float;
	public var c2:Color = 0x00ff00ff;
	
	// vertex 3
	public var x3:Float;
	public var y3:Float;
	public var c3:Color = 0x0000ffff;
	
	// z-index
	// public var z:Int = 0;

	// -------------------------------------------------
	public function new(
		x1:Float, y1:Float, c1:Color,
		x2:Float, y2:Float, c2:Color,
		x3:Float, y3:Float, c3:Color //,z:Int = 0
	)
	{
		this.x1 = x1; this.y1 = y1;	this.c1 = c1;
		this.x2 = x2; this.y2 = y2;	this.c2 = c2;
		this.x3 = x3; this.y3 = y3;	this.c3 = c3;
		//this.z = z;
	}
}
