package;

@:structInit @:publicFields
class SpawnParam {

	var ex:Int = 0;

	var ey:Int = 0;

	var size:Int = 100; 

	var spawn:Int = 1; // how many new particles are spawn per timestep

	var delay:Int = 1000; // duration (in ms) before next timestep and new ones spawns

	var duration:Int = 3000; // lifetime (in ms) for particles wich spawned per timestep 

}