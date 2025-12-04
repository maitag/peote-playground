package;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;
import peote.view.Element;
import peote.view.Color;

import ui.Ui;
import ui.Ui.UiParam;
import ui.Ui.UiCallback;

import audio.SynthDisplay;
import audio.PeoteAudio;

class Main extends Application
{
	var peoteView:PeoteView;
	var ui:Ui;
	
	// var sampleRate:Int = 22050;
	var sampleRate:Int = 44100;
	var peoteAudio:PeoteAudio;


	override function onWindowCreate():Void
	{
		switch (window.context.type) {
			case WEBGL, OPENGL, OPENGLES:
				try init(window)
				catch (_) trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack()), _);
			default: throw("Sorry, only works with OpenGL.");
		}
	}

	var param: UiParam;
	var callback:UiCallback;

	public function init(window:Window)
	{
		// init audiowrapper
		peoteAudio = new PeoteAudio(sampleRate);

		peoteView = new PeoteView(window);

		var defaultFormula = "sin(x * PI * 2 * 300)";
		param = {
			instrumentSynthParam: {
				name: "Sinus",
				duration: 3, // seconds
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
		peoteView.addDisplay(synthDisplay, true); // test how it looks
		
		ui = new Ui(peoteView, param, callback);
	}
	
	var synthDisplay:SynthDisplay;

	public function onUiInit() 
	{
		trace("onUiInit");

	}	

	public function onPlay(formulaChanged:Bool):Void
	{
		// update formula
		if (formulaChanged) {
			synthDisplay.updateShader(
				sampleRate,
				param.instrumentSynthParam.mainFormula,
				param.instrumentSynthParam.duration
			);
		}

		// render and fetch texture data
		peoteView.renderToTexture(synthDisplay);
		
		// send data to audio
		peoteAudio.play(synthDisplay.getSynthData());
		
	}
		
}

