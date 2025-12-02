package ui;

class Ui
{
	var peoteView:PeoteView;
	var peoteUiDisplay:PeoteUIDisplay;
	var onInit:Void->Void;

	public function new(peoteView:PeoteView, onInit:Void->Void)
	{
		this.peoteView = peoteView;
		this.onInit = onInit;
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
		var myInstrument = new InstrumentSynth(10, 20, 400, 300);
		peoteUiDisplay.add(myInstrument);
		
		// let it drag for testing
		myInstrument.onPointerDown = (_, e:PointerEvent)-> myInstrument.startDragging(e);
		myInstrument.onPointerUp = (_, e:PointerEvent)-> myInstrument.stopDragging(e);




		// ---------------------------------------------------------
		PeoteUIDisplay.registerEvents(peoteView.window);

		onInit();
	}
}

