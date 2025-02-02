package;

import peote.view.intern.BufferBytes;
import peote.view.*;
import peote.view.PeoteGL.Version;
import peote.view.intern.UniformBufferView;
import peote.view.intern.UniformBufferDisplay;

import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLShader;
import lime.graphics.opengl.GLVertexArrayObject;

@:access(peote.view)
class CustomDisplay extends Display 
{
	
	public function new(x:Int, y:Int, width:Int, height:Int, color:Color=0x00000000) 
	{
		super(x, y, width, height, color);
	}

	override private function setNewGLContext(newGl:PeoteGL)
	{
		super.setNewGLContext(newGl);
		if (newGl != null && newGl != gl) // only if different GL - Context	
		{
			// clear old gl-context if there is one
			if (gl != null) clear();
			
			// create buffer and program 

		}
	}

	inline function clear() 
	{
		// gl.deleteBuffer(glBuffer);
		
		// if (peote.view.PeoteGL.Version.isINSTANCED)	gl.deleteBuffer(glInstanceBuffer);
		// if (peote.view.PeoteGL.Version.isVAO) gl.deleteVertexArray(glVAO);
	}

	#if peoteview_customdisplay // needs compiler condition to enable override
	
	override private function renderProgram(peoteView:PeoteView):Void
	{

		// to also render the other added Programs
		// super.renderProgram(peoteView);
		
		// -----------------------------------------------
		// ---------------- SHADERPROGRAM ----------------
		// -----------------------------------------------

		// vertex shader
		var glsl_vertex = '${Version.isES3 ? "#version 300 es" : ""}

				// attributes
				${Version.isES3 ? "in" : "attribute"} vec2 aPos;
				${Version.isES3 ? "in" : "attribute"} vec4 aColor;

				// varyings out
				${Version.isES3 ? "out" : "varying"} vec4 vertexColor; 

				void main()
				{   
					vertexColor = aColor;
					//                  x     y    z
					gl_Position = vec4(aPos, 0.0, 1.0);
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
		
		var program = gl.createProgram();
		
		var vertex_shader:GLShader = gl.createShader(gl.VERTEX_SHADER);
		gl.shaderSource(vertex_shader, glsl_vertex);
		gl.attachShader(program, vertex_shader);
		gl.compileShader(vertex_shader);

		if(gl.getShaderParameter(vertex_shader, gl.COMPILE_STATUS) == 0)
		{
			throw(gl.getShaderInfoLog(vertex_shader));
		}

		var fragment_shader:GLShader = gl.createShader(gl.FRAGMENT_SHADER);
		gl.shaderSource(fragment_shader, glsl_fragment);
		gl.attachShader(program, fragment_shader);
		gl.compileShader(fragment_shader);

		if(gl.getShaderParameter(fragment_shader, gl.COMPILE_STATUS) == 0)
		{
			throw(gl.getShaderInfoLog(fragment_shader));
		}
	
		gl.linkProgram(program);
		gl.useProgram(program);

		
		if (gl.getProgramParameter(program, gl.LINK_STATUS) == 0)
		{
			var log = gl.getProgramInfoLog(program);
			log += "\nVALIDATE_STATUS: " + gl.getProgramParameter(program, gl.VALIDATE_STATUS);
			log += "\nERROR: " + gl.getError();
			throw(log);
		}
			
		gl.deleteShader(vertex_shader);
		gl.deleteShader(fragment_shader);

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
		
		// define vertexes for a triangle; x,y and rgba
		var vertexData = [
		//  x     y     r    g    b    a
			-0.5, -0.5,  1.0, 0.0, 0.0, 1.0, // left
			 0.5, -0.5,  0.0, 1.0, 0.0, 1.0, // right
			 0.0,  0.5,  0.0, 0.0, 1.0, 0.5, // top
		];
		
		static var FLOAT = 4;
		static var VERTEX_STRIDE = 6;
		var stride = FLOAT * VERTEX_STRIDE;

		var vertexBytes = BufferBytes.alloc(stride * vertexData.length);

		var pos = 0;
		for (v in vertexData) {
			vertexBytes.setFloat(pos, v);
			pos += FLOAT;
		}

		// create a vertex buffer object (VBO) and a vertex array object (VAO)
		var vbo:GLBuffer = gl.createBuffer();
		var vao:GLVertexArrayObject = gl.createVertexArray();

		// bind vao
		gl.bindVertexArray(vao);

		// bind vbo
		gl.bindBuffer(gl.ARRAY_BUFFER, vbo);

		// copy vertex data into buffer
		gl.bufferData(gl.ARRAY_BUFFER, vertexBytes.length, new peote.view.intern.GLBufferPointer(vertexBytes), gl.STATIC_DRAW);

		var attLocation = 0;
		// use vertex array object or not into binding your shader-attributes
		// if (Version.isVAO) {
			// gl.bindVertexArray( ... );
		// }
		// else {
			// enable Vertex Attributes (specify the vertex attribute layout)
			gl.bindAttribLocation(program, 0, "CustomProgram");

			// position attribute
			gl.vertexAttribPointer(attLocation, 2, gl.FLOAT, false, stride, 0);
			gl.enableVertexAttribArray(attLocation);

			// color attribute
			attLocation++;
			gl.vertexAttribPointer(attLocation, 4, gl.FLOAT, false, stride, 2 * FLOAT);
			gl.enableVertexAttribArray(attLocation);
		// }

		// draw by instanced array (ES3) or without (ES2)
		// if (Version.isINSTANCED) {
			// gl.drawArraysInstanced ( ... );
		// } else {
			gl.drawArrays( gl.TRIANGLES, 0, vertexData.length );
		// }
		

		// -----------------------------------------------------
		// ---- cleaning up VAO, Buffer and shaderprogram ------
		// -----------------------------------------------------
		
		// if (Version.isVAO) {
			// gl.bindVertexArray(null);
		// }
		// else {	
			for(i in 0...attLocation){
				gl.disableVertexAttribArray(i);
			}
		// }
		
		gl.bindBuffer (gl.ARRAY_BUFFER, null);		
		gl.useProgram (null);
	}	
	
	

	
	
	// if Display is rendered into texture this is called instead:	
	// override private function renderFramebufferProgram(peoteView:PeoteView):Void {}	
	
	
	#end
}