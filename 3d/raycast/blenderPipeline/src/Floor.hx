import peote.view.*;
import peote.view.intern.Util;
import util.FramebufferDisplay;
import util.Quad;
import Raycaster;

/**
 * Renders a top down tilemap to texture.
 * The texture is then rendered by another program with a shader that distorts the perspective.
 */
class Floor
{
	var visibleMapSize:Int;
	var drawDistance:Int;

	var tilemapBuffer:QuadBuffer;
	var tileRows:Array<Array<Quad>> = [];
	
	var fbBuffer:QuadBuffer;
	var frameBuffer:FramebufferDisplay;
	public var fbTexture(get, never):Texture;
	function get_fbTexture():Texture return frameBuffer.fbTexture;

	public var uCameraAngle:UniformFloat;
	public var uCameraPosX:UniformFloat;
	public var uCameraPosY:UniformFloat;
	public var uMapOffsetX:UniformFloat;
	public var uMapOffsetY:UniformFloat;
	public var uFov:UniformFloat;
	public var uVerticalOffset:UniformFloat;
	public var uTilemapSize:UniformFloat;
	public var uLitBefore:UniformFloat;
	public var uDarkAfter:UniformFloat;

	public function new(peoteView:PeoteView, texTileSize:Int, tileTextureData:TextureData, ?tileTexture:Texture, visibleMapSize:Int, resWidth:Int, resHeight:Int)
	{
		this.visibleMapSize = visibleMapSize;
		drawDistance = Std.int(visibleMapSize / 2);

		var numTiles = visibleMapSize * visibleMapSize;
		tilemapBuffer = new QuadBuffer(numTiles, tileTextureData, tileTexture, texTileSize, texTileSize);

		var fbSize = texTileSize * visibleMapSize;
		frameBuffer = new FramebufferDisplay(peoteView, fbSize, fbSize);
		tilemapBuffer.program.addToDisplay(frameBuffer);

		fbBuffer = new QuadBuffer(1);
		fbBuffer.program.setTexture(frameBuffer.fbTexture);

		var ResWidth = Util.toFloatString(resWidth);
		var ResHeight = Util.toFloatString(resWidth);
		var VisibleMapSize = Util.toFloatString(visibleMapSize);
		fbBuffer.program.injectIntoFragmentShader('
		vec2 uResolution = vec2($ResWidth, $ResHeight);

		vec3 transform(int texId)
		{
			// vec2 from some uniform floats
			vec2 uCameraPos = vec2(uCameraPosX, uCameraPosY);
			vec2 uMapOffset = vec2(uMapOffsetX, uMapOffsetY);
			
			// convert texture coordinates to screen space
			vec2 screenPos = vTexCoord * uResolution;
			float horizon = uResolution.y * 0.5;
			float offsetHorizon = horizon + uVerticalOffset;

			if (screenPos.y < horizon) {
				discard; // do not render above the horizon
			}
			
			// ray parameters
			float row = screenPos.y - offsetHorizon;
			float col = screenPos.x / uResolution.x;
			float rayAngle = uCameraAngle + (col - 0.5) * uFov;
			
			// depth with perspective and fisheye correction
			float depth = offsetHorizon / row;
			depth /= cos(rayAngle - uCameraAngle);
			
			// world positions
			vec2 rayDir = vec2(cos(rayAngle), sin(rayAngle));
			vec2 worldPos = uCameraPos + depth * rayDir;
			
			// distance-based "lighting"
			float distanceFromCamera = depth;
			float lightIntensity = 1.0 - smoothstep(uLitBefore, uDarkAfter, distanceFromCamera);
			
			vec2 texCoord = (worldPos - uMapOffset) / $VisibleMapSize;
			return getTextureColor(texId, texCoord).rgb * lightIntensity;
		}', [
			uCameraPosX = new UniformFloat("uCameraPosX", 0.0),
			uCameraPosY = new UniformFloat("uCameraPosY", 0.0),
			uMapOffsetX = new UniformFloat("uMapOffsetX", 0.0),
			uMapOffsetY = new UniformFloat("uMapOffsetY", 0.0),
			uCameraAngle = new UniformFloat("uCameraAngle", 0.0),
			uFov = new UniformFloat("uFov", 0.0),
			uVerticalOffset = new UniformFloat("uVerticalOffset", 0.0),
			uLitBefore = new UniformFloat("uLitBefore", 0.0),
			uDarkAfter = new UniformFloat("uDarkAfter", 0.0)
		]);
		fbBuffer.program.setColorFormula('vec4(transform(default_ID), tint.a)');
		fbBuffer.addElement(new Quad(resWidth, resHeight));

		// initiliase the tilemap tiles
		for (row in 0...visibleMapSize)
		{
			var tileRow:Array<Quad> = [];
			for (col in 0...visibleMapSize)
			{
				var x = col * texTileSize;
				var y = row * texTileSize;
				var tile = new Quad(texTileSize, texTileSize);
				tile.x = x;
				tile.y = y;
				tileRow.push(tilemapBuffer.addElement(tile));
			}
			tileRows.push(tileRow);
		}
	}

	public function addToDisplay(display:Display)
	{
		fbBuffer.program.addToDisplay(display);
	}

	public function setTile(col:Int, row:Int, tileIndex:Int, isUnderPlayer:Bool = false)
	{
		if (row >= 0 && row <= tileRows.length - 1)
		{
			var tileRow = tileRows[row];
			if (col >= 0 && col <= tileRow.length - 1)
			{
				var tile = tileRow == null ? null : tileRow[col];

				if (tile != null)
				{
					if (tileIndex >= 0)
					{
						tile.tile = tileIndex;
						tile.tint.aF = 1.0;
					}
					else
					{
						tile.tint = 0xffffff00;
					}

					// to show where player is
					tile.tint.aF = isUnderPlayer ? 0.8 : tile.tint.aF;

					tilemapBuffer.updateElement(tile);
				};
			}
		}
	}

	public function renderTiles(rayCast:RayCast, vectorX:Float, vectorY:Float, widthTiles:Int, heightTiles:Int, getFloorTile:TileMap)
	{
		// update floor tile from portion of tilemap
		var offsetX = Std.int(vectorX * drawDistance);
		var offsetY = Std.int(vectorY * drawDistance);
		var startCol = rayCast.x - drawDistance + offsetX;
		var startRow = rayCast.y - drawDistance + offsetY;
		// clamp so the visible area stays within map bounds
		startCol = Std.int(Math.max(0, Math.min(startCol, widthTiles - visibleMapSize)));
		startRow = Std.int(Math.max(0, Math.min(startRow, heightTiles - visibleMapSize)));
		var rayCol = Std.int(rayCast.x);
		var rayRow = Std.int(rayCast.y);

		for (row in 0...visibleMapSize)
		{
			for (col in 0...visibleMapSize)
			{
				var mapCol = Std.int(startCol + col);
				var mapRow = Std.int(startRow + row);

				var tileIndex = getFloorTile(mapCol, mapRow);
				var isUnderPlayer = (mapCol == rayCol && mapRow == rayRow);
				setTile(col, row, tileIndex, isUnderPlayer);
			}
		}

		// sync floor uniforms
		uFov.value = rayCast.fov;
		uVerticalOffset.value = rayCast.verticalOffset;
		uLitBefore.value = rayCast.litBefore;
		uDarkAfter.value = rayCast.darkAfter;
		uCameraPosX.value = rayCast.x;
		uCameraPosY.value = rayCast.y;
		uCameraAngle.value = rayCast.angle;
		uMapOffsetX.value = startCol;
		uMapOffsetY.value = startRow;
	}
}