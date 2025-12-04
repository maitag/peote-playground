package ui;

import ui.InstrumentSynth.InstrumentSynthParam;
import ui.InstrumentSynth.InstrumentSynthCallback;

@:structInit @:publicFields
class UiParam {
	var instrumentSynthParam:InstrumentSynthParam;
}

@:structInit @:publicFields
class UiCallback {
	var onInit:Void->Void;
	var instrumentSynthCallback:InstrumentSynthCallback;
}

class Ui
{
	var peoteView:PeoteView;
	var peoteUiDisplay:PeoteUIDisplay;
	var param:UiParam;
	var callback:UiCallback;

	public function new(peoteView:PeoteView, param:UiParam, callback:UiCallback)
	{
		this.peoteView = peoteView;
		this.param = param;
		this.callback = callback;
		new Fnt("assets/fonts/tiled/hack_ascii.json").load( onFontLoaded );
	}
	
	public function onFontLoaded(font:Fnt)
	{		
		// setup the font globally into StyleConf to use more easy inside the widgets
		StyleConf.font = font;

		// -------------------------------------------------------
		// --- PeoteUIDisplay with styles in Layer-Depth-Order ---
		// -------------------------------------------------------
		
		peoteUiDisplay = new PeoteUIDisplay(0, 0, peoteView.width, peoteView.height, StyleConf.Layer);
		peoteView.addDisplay(peoteUiDisplay);
		

		// ------------------------------------------
		// ---- creating Instrument-UIAreaList ------
		// ------------------------------------------
		
		// now the F U N will _start :;)
		var myInstrument = new InstrumentSynth(200, 20, 400, 300,
			param.instrumentSynthParam, callback.instrumentSynthCallback);
		peoteUiDisplay.add(myInstrument);
		
		// let it drag for testing
		myInstrument.onPointerDown = (_, e:PointerEvent)-> myInstrument.startDragging(e);
		myInstrument.onPointerUp = (_, e:PointerEvent)-> myInstrument.stopDragging(e);




		// ---------------------------------------------------------
		PeoteUIDisplay.registerEvents(peoteView.window);

		callback.onInit();
	}
}

