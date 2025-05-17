package view.ui;

@:publicFields
@:allow(view, view.ui)
@:forward @:forwardStatics
abstract Ui(PeoteUIDisplay) from PeoteUIDisplay to PeoteUIDisplay
{
	static var font:Fnt;

	// ---- background layer styles -----
	static var styleLayer_0 = RoundBorderStyle.createById(0);
	static var styleLayer_1 = BoxStyle.createById(0);

	// ---- middle layer styles -----
	static var styleLayer_2 = RoundBorderStyle.createById(1);
	static var styleLayer_3 = BoxStyle.createById(1);
	
	// ---- foreground layer styles -----
	static var styleLayer_4 = RoundBorderStyle.createById(2);
	static var styleLayer_5 = BoxStyle.createById(2);

	// ---- layers for fontstyle -----
	static var fontstyleLayer_0 = FontStyleTiled.createById(0);
	static var fontstyleLayer_1 = FontStyleTiled.createById(1);

	
	// -------------------------------------------------------
	// ----- styles and configs for specific ui elements -----
	// -------------------------------------------------------
	static var logAreaConfig:AreaConfig = {
		backgroundStyle: styleLayer_0.copy(0x0a230cff, null, 0, 11),
		// maskSpace:Space = {},
	}

	static var logAreaFontStyle = fontstyleLayer_0.copy(0x69b03cff, 9, 16);

	static var logAreaTextConfig:TextConfig = {
		backgroundStyle: null,
		selectionStyle: styleLayer_1.copy(0x104127ff),
		cursorStyle: styleLayer_1.copy(Color.RED2),
		textSpace: { left:5, right:3, top:3, bottom:3 }
	}

	static var logAreaSliderConfig:SliderConfig = {
		backgroundStyle: styleLayer_0.copy(0x071808ff, 0x071808ff, 0, 16),
		draggerStyle: styleLayer_0.copy(0x16321aff, 0, 0),
		draggerSize: 12,
		draggSpace: 1,
	};


	// -------------------------------------------------------
	// ----------------- CONSTRUCTOR -------------------------
	// -------------------------------------------------------
	public function new(x:Int, y:Int, width:Int, height:Int)
	{
		this = new PeoteUIDisplay(x, y, width, height, [
			styleLayer_0, styleLayer_1,
			fontstyleLayer_0, // font layer background
			styleLayer_2, styleLayer_3,
			fontstyleLayer_1, // font layer foreground
			styleLayer_4, styleLayer_5
		]);
	}


	// -------------------------------------------------------
	// ------------- static INIT to load font ---------------- 
	// -------------------------------------------------------
	public static function init(onInit:Void->Void)
	{
		new Fnt("assets/fonts/tiled/hack_ascii_small.json").load( 
			(f:Fnt) -> {
				font = f;
				onInit();
			}
		);
	}

	
}
