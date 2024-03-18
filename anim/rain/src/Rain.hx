package;

import peote.view.Element;
import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;
import peote.view.Color;
import peote.view.Texture;
import peote.view.intern.Util;

class Rain implements Element
{
	// size of the raindrop
	@sizeX public var w:Int = 8;
	@sizeY public var h:Int = 8;
	
	
	// ranges will be changed globally by program.setFormula()
	@custom @const var rangeLeft:Int = 0;
	@custom @const var rangeWidth:Int = 100;
	@custom @const var rangeTop:Int = 0;
	@custom @const var rangeHeight:Int = 100;

	@custom @const var splashOffset:Float = 0.8; // at what % of time it should start splashing
	
	@custom @constStart(0.0) @constEnd(1.0) @anim("repeat") var dropState:Float;
	
	//@custom public var seed:Int = 5;
	//@posX @const @formula("rangeLeft + fract( sin( (floor((uTime-aTime0.x)/aTime0.y)+1.0)*seed )*100000.0) * rangeWidth") var x:Int; 
	@posX @const @formula("rangeLeft + fract( sin( (floor((uTime-aTime0.x)/aTime0.y)+1.0)*aTime0.x )*100000.0) * rangeWidth") var x:Int; 
	@posY @const @formula("rangeTop + ((dropState < splashOffset) ? dropState*rangeHeight/splashOffset : rangeHeight)") var y:Int;
	
	@texTile @const @formula("(dropState < splashOffset) ? 0.0 : 1.0 + 3.0*(dropState - splashOffset)/(1.0-splashOffset)") var tile = 0;
	
	
	static public var duration = 2.0;
	
	function new(w:Int = 8, h:Int = 8 ) 
	{
		this.w = w;
		this.h = h;
		this.time(Math.random() * 100, duration + Math.random() * 0.25);
		//this.seed = Std.int(Math.random() * 0xfff);
	}

	// --------------------------------------------------------------------------
	
	static public var buffer:Buffer<Rain>;
	static public var program:Program;	
	
	static public function init(texture:Texture, rangeLeft:Int, rangeTop:Int, rangeWidth:Int, rangeHeight:Int, splashRangeHeight:Int)
	{	
		buffer = new Buffer<Rain>(512, 512);
		program = new Program(buffer);
		
		program.setTexture(texture, "custom");
		program.blendEnabled = true;
		
		program.setFormula("rangeLeft", Util.toFloatString(rangeLeft), false);
		program.setFormula("rangeTop", Util.toFloatString(rangeTop), false);
		program.setFormula("rangeWidth", Util.toFloatString(rangeWidth), false);
		program.setFormula("rangeHeight", Util.toFloatString(rangeHeight));
		
		// TODO: splashRangeHeight
		
	}
	
	static public function addDrops(amount:Int) {
		for (i in 0...amount) buffer.addElement( new Rain() );
	}
	
	@:access(peote.view)
	static public function removeDrops(amount:Int) {
		for (i in 0...Std.int(Math.min(amount,buffer._maxElements))) {
			buffer.removeElement( buffer._elements.get(buffer._maxElements-1) );
		}
	}
		

}
