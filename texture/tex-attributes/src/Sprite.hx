package;

import peote.view.Element;
import peote.view.Color;

class Sprite implements Element
{
	// position in pixel (relative to upper left corner of Display)
	@posX public var x:Int=0;
	@posY public var y:Int=0;
	
	// size in pixel
	@sizeX public var w:Int=100;
	@sizeY public var h:Int=100;
	
	// extra tex attributes for clipping
	@texX public var clipX:Int = 0;
	@texY public var clipY:Int = 0;
	@texW public var clipWidth:Int = 0;
	@texH public var clipHeight:Int = 0;
	
	// extra tex attributes to adjust texture within the clip
	@texPosX  public var clipPosX:Int = 0;
	@texPosY  public var clipPosY:Int = 0;
	@texSizeX public var clipSizeX:Int = 0;
	@texSizeY public var clipSizeY:Int = 0;
	
	var OPTIONS = { texRepeatX: false, texRepeatY: false, blend: true };

	public function new() {}
}
