package;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;

import ui.Ui;
import ui.Ui.*;

import audio.SynthDisplay;
import audio.PeoteAudio;
import audio.PeoteAudio.AudioBuffer;
import audio.PeoteAudio.AudioSource;

class Main extends Application
{
	override function onWindowCreate():Void {
		switch (window.context.type) {
			case WEBGL, OPENGL, OPENGLES:
				try init(window) catch (_) trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack()), _);
			default: throw("Sorry, only works with OpenGL.");
		}
	}

	var peoteView:PeoteView;
	var ui:Ui;
	
	// var sampleRate:Int = 22050;
	var sampleRate:Int = 44100;

	var param: UiParam;
	var callback:UiCallback;

	var synthDisplay:SynthDisplay;
	var audioBuffer:AudioBuffer;

	public function init(window:Window)
	{
		// init audiowrapper
		PeoteAudio.init(sampleRate);

		peoteView = new PeoteView(window);

		// simple SINUS
		// var defaultFormula = "sin(x * PI * 2 * 300)";

		// first a bit playing around with SPACE (^_^): 
		var defaultFormula = "cos(x * PI * 2 * 300) * sin(x*x*7222)";

		// for organ or piano:
		// var defaultFormula = "-1/4*sin(3*PI*x*600)\n+1/4*sin(PI*x*600)\n+(3^0.5)/2*cos(PI*x*600)";

		// by Zanzlanz:
		// var defaultFormula = "((x*x*1000 * 9301 + 49297)%233280)/233280";

		param = {
			instrumentSynthParam: {
				name: "Space",
				duration: 7, // seconds
				mainFormulaValue: defaultFormula,
				mainFormula: defaultFormula
			}
		};

		callback = {
			onInit: onUiInit,
			instrumentSynthCallback: {
				onPlay: onPlay
			}
		};
		
		synthDisplay = new SynthDisplay(peoteView,
			sampleRate,
			param.instrumentSynthParam.mainFormula,
			param.instrumentSynthParam.duration
		);
		// to see how the synthDisplay->fbTexture is looking
		peoteView.addDisplay(synthDisplay, true);

		// create new audio buffer from synthDisplay
		audioBuffer = new AudioBuffer(param.instrumentSynthParam.duration);
		audioBuffer.setData( synthDisplay.getSynthData() );

		ui = new Ui(peoteView, param, callback);
	}
	
	public function onUiInit() 
	{
		trace("onUiInit");
	}	

	// glitch on hl-target:
	// if the source var is local inside the onPlay() function,
	// after a buffer-change it stops previous playing sources
	var source:AudioSource;
	public function onPlay(formulaChanged:Bool):Void
	{
		// update formula
		if (formulaChanged) {
			trace("onPlay: formula was updated");

			// update synthDisplay for new formula and params
			synthDisplay.updateSynthData(
				sampleRate,
				param.instrumentSynthParam.mainFormula,
				param.instrumentSynthParam.duration
			);

			// create new audio buffer from synthDisplay
			audioBuffer = new AudioBuffer(param.instrumentSynthParam.duration);
			audioBuffer.setData( synthDisplay.getSynthData() );
		}

		source = new AudioSource(audioBuffer);
		source.play();

		// old:
		// PeoteAudio.play( synthDisplay.getSynthData() );		
	}
		
}

