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
			SPIRAL, // type (formula)
			{
				steps: 630, // timesteps (how often particles spawns)

				// emitter position
				ex: emitterDisplay.width >>1,
				exFunc:(ex, step, index)->{return
					ex + 7 - Std.int(new mtprng.MT( index  ).random(7));
				},
				ey: emitterDisplay.height >>1,
				eyFunc:(ey, step, index)->{return
					ey + 5 - Std.int(new mtprng.MT( step  ).random(5));
				},
				

				// sx: RESOLUTION >>1, sy:RESOLUTION >>1, // how far the particles goes away over time
				sx: RESOLUTION, sy:RESOLUTION, // how far the particles goes away over time

				size:1,
				// to size spawn in depend of timestep
				sizeFunc:(size, step, index)->{return 
					// size+Std.random(3);
					size + new mtprng.MT( index*Std.random(0xffff)).random(3);
				},

				spawn:1, // amount of particles what spawn per time-step
				// to mod spawn in depend of timestep
				spawnFunc:(spawn, step)->{return Std.int(spawn * step* 1.2);},

				// time to start to make a COLOR by MT .) ->
				colorStartFunc:(spawn, step, index)->{return 
					Color.HSV( 
						new mtprng.MT( index*Std.random(0xffff)).randomFloat(),
						new mtprng.MT( step  ).randomFloat(), // saturation
						1.0 // <- SUN
					);
				},
				
				// for the -> FLIXEL -> f r e a k s .)
				colorEnd:0, // confetti \o/
				
				delay:10, // time before next spawn
				// delayFunc:(delay, step)->{return Std.int(delay - step);}, // to mod delay in depend of timestep

				duration:10000, // how long a particlespawn exist
				// durationFunc:(duration, step)->{return Std.int(duration - step);}, // to mod duration in depend of timestep
			}
		);
		
		// peoteView.FPS.hide();

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
