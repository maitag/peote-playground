package;

@:structInit
class SpawnParam {

	var start:Int = 1; // amount of initial particles

	var spawn:Int = 2; // how many new are spawn per timestep

	var beat:Float = 1.5; // duration before next timestep and new ones spawns

	var time:Float = 3.0; // lifetime for particles wich spawned per timestep 

	var duration:Float = 5.0; // duration time (no more are spawned afterwards)

	// later "modifier" ->
	// var speed:Float = 1.0 // to slow down or speed all up ;)
}