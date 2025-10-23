import peote.view.*;
import Raycaster;

/**
 * Textured element that always appears parallel to the view plane.
 * Supports trimming the left and right edge of the texture tile.
 */
class Billboard implements Element
{
	/**
		position on x axis
	**/
	@posX var x:Float;

	/**
		position on y axis
	**/
	@posY var y:Float;

	/**
		render order, greater numbers are nearer 
	 */
	@zIndex public var z:Int;

	/**
		width in pixels
	**/
	@varying @sizeX var width:Int;

	/**
		height in pixels
	**/
	@varying @sizeY var height:Int;

	/**
		rotation in degrees
	**/
	@rotation var angle:Float = 0.0;

	/**
		tint the color of the Element, compatible with RGBA Int
	**/
	@color public var tint:Color = 0xffffffFF;

	/**
	 * the texture slot to use (e.g. for having sprites from different angles in other slots)
	 */
	@texSlot public var slot:Int = 0;

	// extra tex attributes for clipping
	@texX var clipX:Int = 0;
	@texY var clipY:Int = 0;
	@texW var clipWidth:Int = 0;
	@texH var clipHeight:Int = 0;

	// extra tex attributes to adjust texture within the clip
	@texPosX var clipPosX:Int = 0;
	@texPosY var clipPosY:Int = 0;
	@texSizeX var clipSizeX:Int = 64;
	@texSizeY var clipSizeY:Int = 64;

	var OPTIONS = {texRepeatX: false, texRepeatY: false, blend: true};

	/**
	 * Change the size of the element based on it's real height and the distance to it
	 * @param actualHeight
	 * @param distance 
	 */
	public function setSize(actualHeight:Float, distance:Float)
	{
		var heightAtDistance = actualHeight / distance;
		height = Std.int(heightAtDistance);
		width = height;
	}

	/**
	 * Configures the element texture clipping such that an 
	 * indexable tile is displayed with trimmed sides (for wall occlusions)
	 * 
	 * @param tileIndex the index of the full tile as laid out on the texture
	 * @param tileSize the size of a full tile on the texture
	 * @param tilesX how many tiles fits on the texture x axis
	 * @param x left position of element in display space
	 * @param y top position of element in display space
	 * @param leftCut percentage of the element to hide on the left side
	 * @param rightCut percentage of the element to hide on the right side
	 */
	public function setTileAndTrim(tileIndex:Int, tileWidth:Int, tileHeight:Int, tilesX:Int, x:Float, y:Float, leftCut:Float, rightCut:Float)
	{
		var column = Std.int(tileIndex % tilesX);
		var row = Std.int(tileIndex / tilesX);
		var texX = (column * tileWidth);
		var texY = row * tileHeight;

		var xOffset = tileWidth * leftCut;
		clipX = Std.int(texX + xOffset);
		clipY = Std.int(texY);

		var visiblePercent = rightCut - leftCut;
		var croppedWidth = Std.int(tileWidth * visiblePercent);
		clipWidth = croppedWidth;
		clipHeight = tileHeight;
		clipSizeX = croppedWidth;
		clipSizeY = tileHeight;

		width = Std.int(height * visiblePercent);
		this.x = x + (leftCut * height);
		this.y = y;
	}

	public function new()
	{
		this.width = Std.int(width);
		this.height = Std.int(height);
		this.x = Std.int(x);
		this.y = Std.int(y);
		this.tint = 0xffffffFF;
	}
}

class Billboards
{
	var program(default, null):Program;
	var buffer:Buffer<Billboard>;
	var tilesX:Int;
	var tileWidth:Int;
	var tileHeight:Int;
	var resHeight:Int;

	public function new(bufferSize:Int, texture:Texture, tileWidth:Int, tileHeight:Int, tilesX:Int, resHeight:Int)
	{
		this.tileWidth = tileWidth;
		this.tileHeight = tileHeight;
		this.tilesX = tilesX;
		this.resHeight = resHeight;

		buffer = new Buffer<Billboard>(bufferSize, bufferSize);
		program = new Program(buffer);

		// prevent rendering elements with alpha less than 0.1
		// this is quick way to hide an element that the camera is passing through
		program.discardAtAlpha(0.1, false);

		program.addTexture(texture, true);
	}

	public function addToDisplay(display:Display)
	{
		program.addToDisplay(display);
	}

	public function updateElement(element:Billboard)
	{
		buffer.updateElement(element);
	}

	public function drawBillboard(sighting:Sighting<Billboard>)
	{
		var billboard = sighting.entity.element;

		if (sighting.entity.isVisible)
		{
			billboard.slot = sighting.angleSlot;
			billboard.z = sighting.z;
			billboard.tint = Color.WHITE;
			billboard.tint.aF = sighting.proximityAlpha;
			billboard.tint.valueHSV = sighting.lightFallOff;
			billboard.setSize(resHeight, sighting.distance);
			billboard.setTileAndTrim(
				sighting.entity.tileId,
				tileWidth,
				tileHeight,
				tilesX,
				sighting.x,
				sighting.y,
				sighting.visibleStart,
				sighting.visibleEnd
			);
		}
		else
		{
			// "hide" entity if not visible
			billboard.tint.aF = 0;
		}

		updateElement(billboard);
	}

	public function init():Billboard
	{
		return buffer.addElement(new Billboard());
	}
}
