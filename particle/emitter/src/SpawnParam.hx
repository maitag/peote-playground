package;

@:structInit @:publicFields
class SpawnParam {

	var steps:Int = 3;

	// spawn point of where particles are emitting
	var ex:Int = 0;
	var ey:Int = 0;

	// sizes (how far particle goes away from spawn point and into time->duration) 
	var sx:Int = 100;
	var sy:Int = 100;

	var spawn:Int = 1; // how many new particles are spawn per timestep
	var spawnFunc:Int->Int = null; // to mod per step

	var delay:Int = 1000; // duration (in ms) before next timestep and new ones spawns
	var delayFunc:Int->Int = null; // to mod per step

	var duration:Int = 3000; // lifetime (in ms) for particles wich spawned per timestep 
	var durationFunc:Int->Int = null; // to mod per step

}