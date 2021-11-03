package;

import peote.view.Element;
import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;

class Egg implements Element
{
	@posX public var x:Int;
	@posY public var y:Int;
	
	// size in pixel
	@sizeX @varying public var w:Int;
	@sizeY @varying public var h:Int;
		

	static public var buffer:Buffer<Egg>;
	static public var program:Program;

	// -----------------------------------------------
	
	static public function init(formula:String, display:Display)
	{	
		buffer = new Buffer<Egg>(1, 1, true);
		program = new Program(buffer);
		
		program.injectIntoFragmentShader(
		'
			float egg( )
			{
					float x = vTexCoord.x;
					float y = vTexCoord.y;
					float c;
					
					// if ( y > sin(x*2.0*3.14) ) {gl_FragColor = vec4(1.0, 1.0, 0.0, 1.0);}
					
					if ( $formula < 1.0 ) {
						c = 1.0;
					}
					else {
						c = 0.0;
					}
					return c;
			}			
		');
		
		program.setColorFormula( 'vec4(1.0)*egg()' );
		
		program.alphaEnabled = true;
		program.discardAtAlpha(0.0);
		
		display.addProgram(program);
	}
	
	
	
	public function new(x:Int = 0, y:Int = 0, w:Int = 100, h:Int = 100) 
	{
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
		buffer.addElement(this);
	}

}
