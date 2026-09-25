import haxe.CallStack;
import lime.app.Application;
import peote.view.*;
import util.Adsr;

using util.Message;

class Main extends Application
{
	var peoteView:PeoteView;
	var particles:Particles;
	var emitterX:Float;
	var emitterY:Int;
	var fireEnvelope:Adsr;
	var smokeEnvelope:Adsr;
	var smokeDelayMs:Float;
	var smokeGateTimer:Float = -1;
	var smokeGatePending:Bool = false;
	var isEnvelopeOpen:Bool = false;

	override function onWindowCreate() {
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				try
				{
					var backgroundColor = 0x0B0908ff;
					peoteView = new PeoteView(window, backgroundColor);
					setup();
					peoteView.start();
				}
				catch (_)
				{
					trace(CallStack.toString(CallStack.exceptionStack()), _);
				}
			case _:
				throw("Sorry, only works with OpenGL.");
		}
	}

	function setup()
	{
		var display = new Display(0, 0, window.width, window.height);
		peoteView.addDisplay(display);

		var bufferSize = 16384;
		#if js
		// allow override buffer size via query string e.g. add this this to the end of the url ?bufferSize=4096
		var queryString = new js.html.URLSearchParams(js.Browser.window.location.search).get("bufferSize");
		var bufferSizeSpecified = Std.parseInt(queryString);
		if (bufferSizeSpecified != null && bufferSizeSpecified > 0)
		{
			bufferSize = bufferSizeSpecified;
			trace('buffer size specified $bufferSizeSpecified');
		}
		#end
		particles = new Particles(bufferSize);
		particles.showOn(display);

		// anchor for the particle placement
		emitterX = window.width * 0.5;
		emitterY = window.height - 10;
		
		// envelopes for controlling the flow of particles 
		fireEnvelope = new Adsr(80, 200, 0.35, 600);
		smokeEnvelope = new Adsr(300, 400, 0.4, 1200);
		smokeDelayMs = 150;

		window.onKeyDown.add((code, modifier) -> open());
		window.onKeyUp.add((code, modifier) -> close());

		window.onMouseDown.add((x, y, button) -> open());
		window.onMouseUp.add((x, y, button) -> close());

		display.writeMessage("Press mouse or keyboard to put fuel on the fire!");
		#if js
		display.writeMessage("If it's laggy reduce buffer size by adding to url");
		display.writeMessage("e.g. ?bufferSize=4096");
		#end

		onUpdate.add(deltaTime ->
		{
			var fireAmp = fireEnvelope.step(deltaTime);

			if (smokeGateTimer >= 0)
			{
				smokeGateTimer -= deltaTime;
				if (smokeGateTimer < 0)
				{
					if (smokeGatePending)
					{
						smokeEnvelope.gateOn();
					}
					else
					{
						smokeEnvelope.gateOff();
					}
				}
			}
			var smokeAmp = smokeEnvelope.step(deltaTime);

			var flameCount = 1 + Std.int(fireAmp * 11);
			var smokeCount = 2 + Std.int(smokeAmp * 13);

			for (n in 0...6)
			{
				Fire.flame(particles, peoteView.time, emitterX, emitterY, flameCount, fireAmp);
				var smokeY = emitterY - 140 - smokeAmp * 120;
				Fire.smoke(particles, peoteView.time, emitterX, smokeY, smokeCount, smokeAmp);
			}

			particles.update();
		});
	}

	function open()
	{
		if (!isEnvelopeOpen)
		{
			isEnvelopeOpen = true;
			fireEnvelope.gateOn();
			smokeGateTimer = smokeDelayMs;
			smokeGatePending = true;
		}
	}

	function close()
	{
		fireEnvelope.gateOff();
		smokeGateTimer = smokeDelayMs;
		smokeGatePending = false;
		isEnvelopeOpen = false;
	}
}
