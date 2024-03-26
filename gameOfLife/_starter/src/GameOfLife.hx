package;

import haxe.ds.Vector;
import peote.view.TextureData;

// coded by Sylvio Sell, 2024 rostock germany
// for algorithm look here: http://www.conwaylife.com/wiki/Cellular_automaton 
// simple Lime sample here: https://github.com/openfl/lime-samples/tree/master/demos/GameOfLife

class GameOfLife
{
	// some Rules
	public static var common = [
		'0/2',        // Live Free or Die
		'23/3',       // Conway's Game of Life :)
		'5/345',
		'23/36',      // HighLife
		'34/34',
		'023/3',
		'245/368',
		'245/368',
		'238/357',
		'1245/3',     // Mazetric
		'12345/3',    // Maze
		'1234/3',
		'1345/3',
		'1345/32',
		'45678/3',    // Coral
		'1358/357',	  // Amoeba
		'4567/345',
		'1357/1357',  // Replicator
		'2345/45678',
		'35678/4678',
		'34678/3678', // DayNight
		'02468/1357',
		'235678/378',
		'235678/3678'
	];
	
	public static var rule:Vector<Int>;

	public static function initDefaults()
	{
		rule = new Vector<Int>(common.length);
		for (i in 0...common.length) {
			rule.set(i, rulefromString( common[i] ) );
		}
	}
		
	public static function randomRule():Int
	{
		return rule.get( Std.int(Math.random() * rule.length) ); 
	}
	
	public static function rulefromString(s:String):Int
	{
		var survival_rule:Int = 0;
		var birth_rule:Int = 0;		
		for (c in s.split('/')[0].split('') ) survival_rule |= 1 << Std.parseInt(c);
		for (c in s.split('/')[1].split('') ) birth_rule |= 1 << Std.parseInt(c);
		return (survival_rule << 9) | birth_rule;
	}	
	
	public static function genRandomCells(textureData:TextureData, posX:Int, posY:Int, sizeX:Int = 10, sizeY:Int = 10):Void 
	{
		posX -= Std.int(sizeX/2);
		posY -= Std.int(sizeY/2);
		for (y in posY...posY+sizeY)
			for (x in posX...posX+sizeX)
					textureData.set_R(x, y, (Math.random() > 0.5) ? 255 : 0);
	}
	
	
	// ------------------------------------------------------------------------------
	// ----------------------- algorythm for cell automation ------------------------
	// ------------------------------------------------------------------------------
	
	public static function nextLifeGeneration( srcTextureData:TextureData, destTextureData:TextureData, rule:Int):Void
	{
		var survival_rule:UInt = rule >> 9;
		var birth_rule:UInt = 0x1ff & rule;

		var x:Int, y:Int, x_neg:Int, y_neg:Int, x_pos:Int, y_pos:Int;
		var sum:UInt;
		var w:Int = srcTextureData.width;
		var h:Int = srcTextureData.height;
		
		for (y in 0...h)
		{
			y_neg = (y - 1) % h; if (y_neg < 0) y_neg += h;
			y_pos = (y + 1) % h;
			
			for (x in 0...w)
			{	
				x_neg = (x - 1) % w; if (x_neg < 0) x_neg += w;
				x_pos = (x + 1) % w;
				sum = 0; // number of neighbours
				
				// +alife top neighbours
				sum += (srcTextureData.get_R(x_neg, y_neg) == 255) ? 1 : 0;
				sum += (srcTextureData.get_R(x    , y_neg) == 255) ? 1 : 0;
				sum += (srcTextureData.get_R(x_pos, y_neg) == 255) ? 1 : 0;
				
				// +alife middle neighbours
				sum += (srcTextureData.get_R(x_neg, y    ) == 255) ? 1 : 0;
				sum += (srcTextureData.get_R(x_pos, y    ) == 255) ? 1 : 0;
				
				// +alife bottom neighbours
				sum += (srcTextureData.get_R(x_neg, y_pos) == 255) ? 1 : 0;
				sum += (srcTextureData.get_R(x    , y_pos) == 255) ? 1 : 0;
				sum += (srcTextureData.get_R(x_pos, y_pos) == 255) ? 1 : 0;
				
				sum = 1 << sum;
				
				//trace(x,y,x_pos,y_pos,x_neg,y_neg,sum,s_rule,b_rule);
				if (srcTextureData.get_R(x, y) == 255) // --- old cell is alife ---
				{	
					if ( (survival_rule & sum) > 0 )
						destTextureData.set_R(x, y, 255); // life again
					else
						destTextureData.set_R(x, y, 0); // dead
				}
				else                                       // --- old cell is dead ---
				{	
					if ( (birth_rule & sum) > 0 )
						destTextureData.set_R(x, y, 255); // birthday
					else
						destTextureData.set_R(x, y, 0); // still dead
				}
			}
		}
		
	}


}