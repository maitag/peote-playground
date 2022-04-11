package resources;

import components.Sprite;
import peote.view.Buffer;


class SpriteLayer 
{

	public var buffer:Buffer<Sprite>;
	
	public function new(buffer:Buffer<Sprite>) 
	{
		this.buffer = buffer;
	}
	
}