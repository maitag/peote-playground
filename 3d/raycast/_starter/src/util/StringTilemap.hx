package util;

/*
 *	Simple tilemap where we expect
 * " " : empty
 * "#" : wall
 * anything else is configurable
**/
class StringTilemap
{
	var map:Array<String>;
	var idWall:Map<String, Int>;
	var idFloor:Map<String, Int>;
	var idEntity:Map<String, Int>;

	public var widthTiles(get, never):Int;
	function get_widthTiles():Int return map[0].length;

	public var heightTiles(get, never):Int;
	function get_heightTiles():Int return map.length;

	public var entityCount(get, never):Int;
	function get_entityCount():Int
	{
		var count = 0;
		for (row in map)
			for (col in 0...row.length)
				count += idEntity.exists(row.charAt(col)) ? 1 : 0;
		return count;
	};

	public function new(map:Array<String>, idWall:Map<String, Int>, idFloor:Map<String, Int>, idEntity:Map<String, Int>)
		{
			if (!idWall.exists("#") || !idWall.exists(" "))
			{
				throw 'idWall must have entry for "#" and " "';
			}
	
			if (!idFloor.exists(" "))
			{
				throw 'idFloor must have entry for " "';
			}
	
			this.map = map;
			this.idWall = idWall;
			this.idFloor = idFloor;
			this.idEntity = idEntity;
		}
	
		inline function isOutOfBounds(mapX:Int, mapY:Int):Bool
		{
			return mapX < 0 || mapY < 0 || widthTiles <= mapX || heightTiles <= mapY;
		}
	
		public function wallTileAt(mapX:Int, mapY:Int):Int
		{
			static var emptyId = " ";
			static var wallId = "#";
	
			if (isOutOfBounds(mapX, mapY))
			{
				return idWall[wallId];
			}
	
			var id = map[mapY].charAt(mapX);
			return idWall.exists(id) 
				? idWall[id] 
				: idWall[emptyId];
		}
	
		public function floorTileAt(mapX:Int, mapY:Int):Int
		{
			static var wallId = "#";
	
			if (isOutOfBounds(mapX, mapY))
			{
				return idFloor[wallId];
			}
	
			var id = map[mapY].charAt(mapX);
			return idFloor.exists(id) 
				? idFloor[id] 
				: idFloor[wallId];
		}
	
		public function getEntityPositions():Map<String, Array<Array<Int>>>
		{
			var entityPositions:Map<String, Array<Array<Int>>> = [];
			for (r in 0...map.length - 1)
			{
				var row = map[r];
				for (c in 0...row.length - 1)
				{
					var id = row.charAt(c);
					if (idEntity.exists(id))
					{
						var collection = entityPositions.exists(id) 
							? entityPositions[id] 
							: entityPositions[id] = [];
	
						collection.push([c, r]);
					}
				}
			}
			return entityPositions;
		}
	}
	