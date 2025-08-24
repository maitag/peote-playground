package;

import peote.view.PeoteView;
import peote.view.Color;

import mtprng.MT;

class MainStar extends lime.app.Application
{
	static inline var RESOLUTION = 512;

	var peoteView:PeoteView;
	var emitterDisplay:EmitterDisplay;

	override function onWindowCreate():Void
	{
		if (switch (window.context.type) {case WEBGL, OPENGL, OPENGLES: false; default: true;})
			throw("Sorry, only works with OpenGL.");

		peoteView = new PeoteView(window, 0x000020ff);

		peoteView.xZoom = window.width/RESOLUTION;
		peoteView.yZoom = window.height/RESOLUTION;

		emitterDisplay = new EmitterDisplay(0, 0, RESOLUTION, RESOLUTION, Color.BLUE1);
		peoteView.addDisplay(emitterDisplay);
		
		emitterDisplay.spawn( 
			SUNRAYS, // type (formula)
			{
				steps: 230, // timesteps (how often particles spawns)

				ex: emitterDisplay.width >>1, ey: emitterDisplay.height >>1, // emitter position
				exFunc:(ex, step, index)->{return
					ex +  Std.int(new mtprng.MT( step  ).random(100));
				},


				// sx: RESOLUTION >>1, sy:RESOLUTION >>1, // how far the particles goes away over time
				sx: RESOLUTION, sy:RESOLUTION, // how far the particles goes away over time

				size:1,

				spawn:4, // amount of particles what spawn per time-step
				spawnFunc:(spawn, step)->{return Std.int(spawn * step* .8);}, // to mod spawn in depend of timestep

				// 4.44 now -> time to start to make a COLOR by MT .) ->
				colorStartFunc:(spawn, step, index)->{return 
					Color.HSV( 
						new mtprng.MT( index*Std.random(0xffff)).randomFloat(),
						new mtprng.MT( step  ).randomFloat(), // saturn .,)
						1.0 // <- SUN
					);
				},
				
				// for the -> FLIXEL -> f r e a k s .)
				colorEnd:0, // confetti \o/
				
				delay:20, // time before next spawn
				// delayFunc:(delay, step)->{return Std.int(delay - step);}, // to mod delay in depend of timestep

				duration:1200, // how long a particlespawn exist
				// durationFunc:(duration, step)->{return Std.int(duration - step);}, // to mod duration in depend of timestep
			}
		);

		// time to s t a r t:
		peoteView.start();
	}
	
	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	// -------------- other WINDOWS EVENTS ----------------------------
	override function onWindowResize (width:Int, height:Int):Void {
		// trace("onWindowResize", width, height);
		peoteView.xZoom = width/RESOLUTION;
		peoteView.yZoom = height/RESOLUTION;
	}
	
}
