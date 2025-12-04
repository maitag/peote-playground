package ui;

@:structInit @:publicFields
class InstrumentSynthParam {
	var name:String = "Sinus";
	var duration:Float = 1.0;
	var mainFormula:Formula = null;
	var mainFormulaValue:String = "sin(x)"; //-1/4*sin(3*pi*t)\n+1/4*sin(pi*t)\n+sqrt(3)/2*cos(pi*t)

	// TODO:
	// var subFormula:Array<Formula> = [];
	// var subFormulaValue:Array<String> = [];
}


@:structInit @:publicFields
class InstrumentSynthCallback {
	var onPlay:Bool->Void = function(_) {trace("onPlay");};
}


class InstrumentSynth extends UIAreaList
{
	var formulaChanged = false;

	public function new(x:Int, y:Int, w:Int, h:Int, z:Int = 0,
		?config:AreaListConfig,
		?param:InstrumentSynthParam,
		?callback:InstrumentSynthCallback
	)
	{
		super(x, y, w, h, 0, (config != null) ? config : StyleConf.areaListConfig);

		if (param == null) param = {};
		if (callback == null) callback = {};

		
		// name
		var inputLine_name = new TextLine(0, 0, 200, 0, 1, param.name,
			StyleConf.font, StyleConf.fontStyleInput, StyleConf.textInputConfig);

		inputLine_name.onPointerDown = function(t:TextLine, e:PointerEvent) {
			t.setInputFocus(e); t.startSelection(e);
		}
		inputLine_name.onPointerUp = function(t:TextLine, e:PointerEvent) {
			t.stopSelection(e);
		}
		addFixed(inputLine_name);

					
		// mainFormula
		var inputPage_mainFormula = new TextPage(0, 0, 300, 0, 1, param.mainFormulaValue,
			StyleConf.font, StyleConf.fontStyleInput, StyleConf.textInputConfig);

		inputPage_mainFormula.onPointerDown = function(t:TextPage, e:PointerEvent) {
			t.setInputFocus(e);
			t.startSelection(e);
		};
		inputPage_mainFormula.onPointerUp = function(t:TextPage, e:PointerEvent) {
			t.stopSelection(e);
		};
		inputPage_mainFormula.onInsertText =
		inputPage_mainFormula.onDeleteText = function(t:TextPage, _, _, _, _, s:String) {
			// TODO: only change mainFormula if term changed
			try {
				param.mainFormula = t.text;
				formulaChanged = true;
			} catch(e) trace("Error in formula:", e);
		};
		addResizable(inputPage_mainFormula);


		// play button
		var playButton = new TextLine(202, 0, 50, 20, 1, "play",
			StyleConf.font, StyleConf.fontStyleButton, StyleConf.buttonConfig);
		playButton.onPointerDown = function(t:TextLine, e:PointerEvent) {
			callback.onPlay(formulaChanged);
			formulaChanged = false;
		};
		addFixed(playButton);
		


		// ----------------------------------
		// --------- resize events ----------
		// ----------------------------------

		// onResizeInnerWidth = (_, width:Int, deltaWidth:Int) -> {trace("onResizeInnerWidth");}

		onResizeInnerHeight = (_, height:Int, deltaHeight:Int) -> {
			// trace("onResizeInnerHeight");
			this.height = height + maskSpace.top + maskSpace.bottom;
			updateLayout();
		}

		onResizeWidth = (_, width:Int, deltaWidth:Int) -> {			
		}		

	}

	
}
