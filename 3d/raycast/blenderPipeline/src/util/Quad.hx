package util;

import peote.view.*;

/**
 * General purpose Element
 */
@:publicFields
class Quad implements Element
{
	/**
		position on x axis
	**/
	@posX public var x:Float;

	/**
		position on y axis
	**/
	@posY public var y:Float;

	/**
		width in pixels
	**/
	@varying @sizeX public var width:Int;

	/**
		height in pixels
	**/
	@varying @sizeY public var height:Int;

	/**
		pivot point of the element on x axis, e.g. 0.5 is the center
	**/
	@pivotX @formula("width * pivotX") var pivotX:Float = 0.0;

	/**
		pivot point of the element on y axis, e.g. 0.5 is the center
	**/
	@pivotY @formula("height * pivotY") var pivotY:Float = 0.0;

	/**
		rotation in degrees
	**/
	@rotation public var angle:Float = 0.0;

	/**
		tint the color of the Element, compatible with RGBA Int
	**/
	@color public var tint:Color;

	@texTile public var tile:Int = 0;

	var OPTIONS = {texRepeatX: true, texRepeatY: true, blend: true};

	public function new(width:Float, height:Float, tint:Color = 0xffffffFF, x:Float = 0, y:Float = 0, isCenterPivot:Bool = false)
	{
		this.width = Std.int(width);
		this.height = Std.int(height);

		this.x = Std.int(x);
		this.y = Std.int(y);

		this.tint = tint;

		if (isCenterPivot)
		{
			this.pivotX = 0.5;
			this.pivotY = 0.5;
		}
	}
}

class QuadBuffer extends Buffer<Quad>
{
	public var program(default, null):Program;

	public function new(size:Int, textureData:TextureData = null, texture:Texture = null, tileWidth:Null<Int> = null, tileHeight:Null<Int> = null)
	{
		super(size, size);
		this.program = new Program(this);
		this.program.discardAtAlpha(0.0, false);

		if (texture != null)
		{
			this.program.addTexture(texture, true);
		}
		else if (textureData != null)
		{
			var texture = Texture.fromData(textureData);
			texture.setSmooth(true, true, true);

			if (tileWidth != null)
			{
				texture.tilesX = Std.int(textureData.width / tileWidth);
			}

			if (tileHeight != null)
			{
				texture.tilesY = Std.int(textureData.height / tileHeight);
			}

			this.program.addTexture(texture, true);
		}
	}
}

class QuadRingBuffer extends QuadBuffer
{
	public function new(size:Int, textureData:TextureData = null, texture:Texture = null, tileWidth:Null<Int> = null, tileHeight:Null<Int> = null, isCenterPivot:Bool = false)
	{
		super(size, textureData, texture, tileWidth, tileHeight);

		for (n in 0...size)
		{
			addElement(new Quad(tileWidth, tileHeight, isCenterPivot));
		}
	}

	var head:Int = -1;
	public function get()
	{
		head = (head + 1) % length;
		return getElement(head);
	}
}
