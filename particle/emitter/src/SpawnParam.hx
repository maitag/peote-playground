package;

import peote.view.Color;

@:structInit @:publicFields
class SpawnParam {

	var steps:Int = 3;

	// spawn point of where particles are emitting
	var ex:Int = 0;
	var ey:Int = 0;
	// to mod per step and particle-index
	var exFunc:Int->Int->Int->Int = null;
	var eyFunc:Int->Int->Int->Int = null;

	// the overall size of a particle
	var size:Int = 10;
	// to mod per step and particle-index
	var sizeFunc:Int->Int->Int->Int = null;

	// how far particle goes away from spawn point and into time->duration
	var sx:Int = 100;
	var sy:Int = 100;
	// to mod per step and particle-index
	var sxFunc:Int->Int->Int->Int = null;
	var syFunc:Int->Int->Int->Int = null;

	// color at start and end of movement for spawned particles
	var colorStart:Color = Color.RED;
	var colorEnd:Color = Color.BLUE;
	// to mod per step and particle-index
	var colorStartFunc:Color->Int->Int->Color = null;
	var colorEndFunc:Color->Int->Int->Color = null;

	var spawn:Int = 1; // how many new particles are spawn per timestep
	var spawnFunc:Int->Int->Int = null; // to mod per step

	var delay:Int = 1000; // duration (in ms) before next timestep and new ones spawns
	var delayFunc:Int->Int->Int = null; // to mod per step

	var duration:Int = 3000; // lifetime (in ms) for particles wich spawned per timestep 
	var durationFunc:Int->Int->Int = null; // to mod per step

}