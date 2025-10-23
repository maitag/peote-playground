/**
 * Huge source of inspiration for the code -> https://lodev.org/cgtutor/raycasting.html
 * The page lots of nice diagrams and explanations about how these algorithms work!
 */
@:structInit
@:publicFields
class RayCast
{
	/**
	 * x position in world space
	 */
	var x:Float;

	/**
	 * y position in world space
	 */
	var y:Float;

	/**
	 * angle of rotation (radians)
	 */
	var angle:Float;

	/**
	 * field of vision (radians)
	 */
	var fov:Float;

	/**
	 * fully lit up to here in world space
	 */
	var litBefore:Float;

	/**
	 * fully dark after here in world space
	 */
	var darkAfter:Float;

	/**
	 * how much to shift the walls on the vertical axis (e.g. to simulate head bob)
	 */
	var verticalOffset:Float;
}

@:structInit
@:publicFields
class RayViewConfig
{
	/**
	 * width of resolution in pixels
	 */
	var resWidth:Int;

	/**
	 * height of resolution in pixels
	 */
	var resHeight:Int;

	/**
	 * how many tiles the walls go up towards the ceiling
	 */
	var wallTilesHigh:Float;

	/**
	 *  floor and wall texture tile size in pixels
	 */
	var tileSize:Int;

	/**
	 * center of the screen vertically (y axis)
	 */
	var verticalCenter:Float;

	/**
	 * how many rays in total to cast, e.g. resWidth or some equal division of
	 */
	var totalRays:Int;

	/**
	 * the width of each ray step, e.g. resWidth divided by totalRays
	 */
	var rayStep:Int;

	/**
	 * the index number of the central ray in the buffer
	 */
	var centerRayIndex:Int;
}

@:structInit
@:publicFields
class Sighting<E>
{
	/**
	 * the entity that was "seen" by the ray
	 */
	var entity:Entity<E>;

	/**
	 * distance to entity, in world/map space
	 */
	var distance:Float;

	/**
	 * which texture slot to use, when each slot is a different angle
	 */
	var angleSlot:Int;

	/**
	 * percentage to start trimming at (for wall occlusion)
	 */
	var visibleStart:Float;

	/**
	 * percentage to stop trimming at (for wall occlusion)
	 */
	var visibleEnd:Float;

	/**
	 * left pixel of element, relative to display
	 */
	var x:Float;

	/**
	 * top pixel of element, relative to display
	 */
	var y:Float;

	/**
	 * alpha reduction based on proximity (transparent when camera is passing through)
	 */
	var proximityAlpha:Float;

	/**
	 * how lit is the entity
	 */
	var lightFallOff:Float;

	/**
	 * for z index/sort order
	 */
	var z:Int = 0;
}

@:structInit
@:publicFields
class Entity<E>
{
	/**
	 * x position in world/map
	 */
	var worldX:Float;

	/**
	 * y position in world/map
	 */
	var worldY:Float;

	/**
	 * index of tile on texture
	 */
	var tileId:Int;

	/**
	 * angle the entity is facing, in radians
	 */
	var facingAngle:Float;

	/**
	 * how many texture slots are available for different angles
	 */
	var angleSlots:Int;

	/**
	 * is entity visible or hiding?
	 */
	var isVisible:Bool = false;

	/**
	 * type parameter for the graphic Element
	 */
	var element:E;
}

enum Axis
{
	VERTICAL;
	HORIZONTAL;
}

enum Cardinal
{
	NORTH;
	EAST;
	SOUTH;
	WEST;
}

@:structInit
@:publicFields
class Ray
{
	var distance:Float;
	var angle:Float;
	var vectorX:Float;
	var vectorY:Float;
	var axis:Axis;
	var facing:Cardinal;
	var mapX:Float;
	var mapY:Float;
	var mapId:Int;
	var wallX:Float;
}

typedef TileMap = (mapX:Int, mapY:Int) -> Int;
typedef HitTest = Int->Bool;
typedef DrawStripe = (x:Int, y:Float, width:Int, height:Float, stripeIndex:Int, tileIndex:Int, fallOff:Float) -> Void;
typedef DrawBillboard<E> = Sighting<E>->Void;

function renderWalls(rayCast:RayCast, display:RayViewConfig, map:TileMap, isHit:HitTest, drawStripe:DrawStripe):Array<Ray>
{
	var rayBuffer:Array<Ray> = [];

	for (rayNumber in 0...display.totalRays)
	{
		var ray = castRay(rayCast.x, rayCast.y, rayCast.angle, rayCast.fov, display.totalRays, rayNumber, map, isHit);
		rayBuffer.push(ray);

		// calculate wall size
		var heightAtDistance = (display.resHeight / ray.distance);
		var midHeightAtDistance = heightAtDistance / 2;
		var wallBottom = display.verticalCenter + midHeightAtDistance;
		var wallTop = wallBottom - (heightAtDistance * display.wallTilesHigh);

		// head bob
		wallTop += rayCast.verticalOffset;
		wallBottom += rayCast.verticalOffset;

		// determine stripe arguments (for the sprite that displays what the ray hit)
		var stripeX = rayNumber * display.rayStep;
		var stripeY = wallTop;
		var stripeWidth = display.rayStep;
		var stripeHeight = wallBottom - wallTop;
		// flip textureX to prevent the texture being reversed
		var textureX = ray.wallX;
		if ((ray.axis == VERTICAL && ray.vectorX < 0) || (ray.axis == HORIZONTAL && ray.vectorY > 0))
		{
			textureX = 1.0 - textureX;
		}
		// determine which stripe tile index to use
		var stripeIndex = Math.floor(textureX * display.tileSize) % display.tileSize;

		// calculate lighting falloff from distance (0.0 = invisible, 1.0 = fully visible)
		var fallOff = 1.0;
		if (ray.distance > rayCast.litBefore)
		{
			fallOff = 1.0 - Math.min(1.0, (ray.distance - rayCast.litBefore) / (rayCast.darkAfter - rayCast.litBefore));
			fallOff = fallOff * fallOff; // quadratic easing for smoother fall off
		}

		drawStripe(stripeX, stripeY, stripeWidth, stripeHeight, stripeIndex, ray.mapId, fallOff);
	}

	return rayBuffer;
}

function castRay(rayX:Float, rayY:Float, rayAngle:Float, fov:Float, totalRays:Int, rayNumber:Int, map:TileMap, isHit:HitTest):Ray
{
	// determine the angle of the ray  (the first ray on the left is the left edge of the field of vision)
	var fovSegment = (rayNumber / totalRays) * fov;
	var fovMid = fov / 2;
	var angle = rayAngle - fovMid + fovSegment;

	// tilemap co-ordinates
	var mapX = Math.floor(rayX);
	var mapY = Math.floor(rayY);

	// direction of ray
	var vectorX = Math.cos(angle);
	var vectorY = Math.sin(angle);

	// lengths of ray from from one side to next side
	var deltaDistX = Math.abs(1 / vectorX);
	var deltaDistY = Math.abs(1 / vectorY);

	// lengths of ray from current position to next side
	var sideDistX, sideDistY = 0.0;

	// directions for stepping through the tilemap
	var dirX, dirY = 0;

	// initialize sideDists and dirs for the DDA
	if (vectorX < 0)
	{
		dirX = -1;
		sideDistX = (rayX - mapX) * deltaDistX;
	}
	else
	{
		dirX = 1;
		sideDistX = (mapX + 1.0 - rayX) * deltaDistX;
	}

	if (vectorY < 0)
	{
		dirY = -1;
		sideDistY = (rayY - mapY) * deltaDistY;
	}
	else
	{
		dirY = 1;
		sideDistY = (mapY + 1.0 - rayY) * deltaDistY;
	}

	// traverse tilemap with DDA until something is hit or there are no more rays to check
	var hit = false;
	var axis = VERTICAL;
	var mapId = -1;
	var totalCast = -1;
	var finalCast = totalRays - 1;
	while (!hit && totalCast++ < finalCast)
	{
		if (sideDistX < sideDistY)
		{
			sideDistX += deltaDistX;
			mapX += dirX;
			axis = VERTICAL;
		}
		else
		{
			sideDistY += deltaDistY;
			mapY += dirY;
			axis = HORIZONTAL;
		}

		mapId = map(mapX, mapY);
		if (isHit(mapId))
		{
			// hit a wall, stop casting
			hit = true;
		}
	}

	// determine perpendicular distance to wall
	var perpWallDist, wallX = 0.0;
	if (axis == VERTICAL)
	{
		// hit vertical wall, use y coord
		perpWallDist = (mapX - rayX + (1 - dirX) / 2) / vectorX;
		wallX = rayY + perpWallDist * vectorY;
	}
	else
	{
		// hit horizontal wall, use x coord
		perpWallDist = (mapY - rayY + (1 - dirY) / 2) / vectorY;
		wallX = rayX + perpWallDist * vectorX;
	}

	// get fractional part for texture coord
	wallX = wallX - Math.floor(wallX);

	// compass side of wall when facing it
	var cardinal = axis == HORIZONTAL ? vectorY < 0 ? NORTH : SOUTH : vectorX > 0 ? WEST : EAST;

	return {
		distance: perpWallDist * Math.cos(angle - rayAngle),
		angle: angle,
		vectorX: vectorX,
		vectorY: vectorY,
		axis: axis,
		facing: cardinal,
		mapX: mapX,
		mapY: mapY,
		mapId: mapId,
		wallX: wallX
	};
}

function renderBillboards<E>(raycast:RayCast, display:RayViewConfig, rayBuffer:Array<Ray>, entities:Array<Entity<E>>, drawBillboard:DrawBillboard<E>)
{
	// all entities sighted will be returned
	var sightings:Array<Sighting<E>> = [];

	for (entity in entities)
	{
		// quick distance check first
		var dx = entity.worldX - raycast.x;
		var dy = entity.worldY - raycast.y;
		var worldDistance = Math.sqrt(dx * dx + dy * dy);

		// skip if too far away
		if (worldDistance > (raycast.darkAfter + 0.5))
		{
			entity.isVisible = false;
			continue; // too far, don't need to render
		}

		// fov
		var angleToEntity = Math.atan2(dy, dx);
		// determine angle relative to ray, normalized between -PI and PI
		var relativeAngle = normalizePI(angleToEntity - raycast.angle);
		
		// determine angle relative to view, normalised between -PI and PI
		var entityAngleToCamera = angleToEntity + Math.PI;
		var viewAngle = normalizePI(entityAngleToCamera - entity.facingAngle);
		
		// determine slot to use for angle
		var angleNormalized = (viewAngle + Math.PI) / PI2; // normalize to range 0-1 instead of 0-4
		var angleSlot = Math.round(angleNormalized * entity.angleSlots) % entity.angleSlots;
		// trace(angleSlot);

		// used to fade an entity when passing through it
		var proximityAlpha = 1.0;
		static var fadeStartDistance = 1.0; // distance to start fading
		static var fadeEndDistance = 0.3;   // distance where it is fully transparent

		// fish eye correction
		var distance = worldDistance * Math.cos(relativeAngle);
		if (distance < fadeStartDistance)
		{
			if (distance < fadeEndDistance)
			{
				entity.isVisible = false;
				continue; // too close, don't need to render
			}
			// fade
			proximityAlpha = (distance - fadeEndDistance) / (fadeStartDistance - fadeEndDistance);
		}

		// distance fall off for "lighting" (0.0 = dark, 1.0 = light)
		var fallOff = 1.0;
		if (distance > raycast.litBefore)
		{
			fallOff = 1.0 - Math.min(1.0, (distance - raycast.litBefore) / (raycast.darkAfter - raycast.litBefore));
		}

		var wallHeightAtDistance = display.resHeight / distance;
		var entityHeight = wallHeightAtDistance;
		var entityWidth = entityHeight;
		var angularWidth = Math.atan2(entityWidth / 2, distance);

		if (Math.abs(relativeAngle) - angularWidth > raycast.fov / 2)
		{
			entity.isVisible = false;
			continue; // completely outside of fov, don't need to render
		}

		// entity position on screen
		entity.isVisible = true;
		var screenX = (relativeAngle / raycast.fov + 0.5) * display.resWidth;
		var entityScreenY = display.verticalCenter - entityHeight / 2 + raycast.verticalOffset;
		var entityStartX = screenX - entityWidth / 2; // center horizontally
		var entityEndX = screenX + entityWidth / 2; // center vertically

		var sighting:Sighting<E> = {
			entity: entity,
			angleSlot: angleSlot,
			distance: distance,
			proximityAlpha: proximityAlpha,
			lightFallOff: fallOff,
			visibleStart: 0,
			visibleEnd: 0,
			x: screenX - entityWidth / 2,
			y: entityScreenY
		}

		// determine where to clip the billboard tile edges
		occlude(rayBuffer, sighting, display, raycast, entityStartX, entityEndX, entityWidth);

		sightings.push(sighting);
	}

	// sort billboards by distance (far to near) for z indexing
	haxe.ds.ArraySort.sort(sightings, (a, b) -> a.distance > b.distance ? -1 : 1);

	for (z => sighting in sightings)
	{
		sighting.z = z;
		// trace('id: ${sighting.entity.tileId} dist: ${sighting.distance} z: ${sighting.z} ');
		drawBillboard(sighting);
	}

	return sightings;
}

function occlude<E>(rayBuffer:Array<Ray>, sighting:Sighting<E>, display:RayViewConfig, raycast:RayCast, entityStartX:Float, entityEndX:Float, entityWidth:Float)
{
	// convert to column indices
	var startColumn = Math.floor(entityStartX / display.rayStep);
	var endColumn = Math.ceil(entityEndX / display.rayStep);

	// check if any part of the entity is visible
	var hasAnyVisible = false;
	for (col in startColumn...endColumn + 1)
	{
		if (col >= 0 && col < rayBuffer.length && sighting.distance < rayBuffer[col].distance)
		{
			hasAnyVisible = true;
			break;
		}
	}

	// there are no visible columns so entity is completely hidden
	if (!hasAnyVisible)
	{
		sighting.entity.isVisible = false;
		return;
	}

	// scan from left to find left edge
	var leftEdge = startColumn;
	for (col in startColumn...endColumn + 1)
	{
		if (col >= 0 && col < rayBuffer.length && sighting.distance < rayBuffer[col].distance)
		{
			leftEdge = col;
			break;
		}
	}

	// scan from right to left to find right edge
	var col = endColumn;
	var rightEdge = endColumn;
	while (col >= startColumn)
	{
		if (col >= 0 && col < rayBuffer.length && sighting.distance < rayBuffer[col].distance)
		{
			rightEdge = col;
			break;
		}
		col--;
	}

	// determine where to trim
	var visibleStartX = (leftEdge) * display.rayStep;
	var visibleEndX = (rightEdge + display.rayStep) * display.rayStep;
	// convert to percentage
	var leftClip = Math.max((visibleStartX - entityStartX) / entityWidth, 0);
	var rightClip = Math.max((entityEndX - visibleEndX) / entityWidth, 0);
	// clamp to 1.0
	sighting.visibleStart = Math.min(leftClip, 1);
	sighting.visibleEnd = 1 - Math.min(rightClip, 1);
}

var PI2 = Math.PI * 2;

/**
 * normalize to range -PI to PI
 */
function normalizePI(v:Float):Float{
	return ((v + Math.PI) % PI2 + PI2) % PI2 - Math.PI;	
}