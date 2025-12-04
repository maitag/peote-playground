package ui;

@:publicFields class StyleConf {

		// ------------------ F O N T ------------------------
		
		// will be set after Ui is initialized and the Font is loaded
		static var font:Fnt;

		// ---------------------------------------------------
		// ---------------- S T Y L E S ----------------------
		// ---------------------------------------------------

		// ---- background layer styles -----
		static var boxStyle  = BoxStyle.createById(0);
		static var roundStyle  = RoundBorderStyle.createById(0);
		
		static var selectStyle  = BoxStyle.createById(1, Color.GREY4);
		static var fontStyle = FontStyle.createById(0);
				
		// ---- foreground layer styles -----		
		static var boxStyle1 = BoxStyle.createById(2);
		static var fontStyle1 = FontStyle.createById(1);

		// how they are displayed in layer of depth
		static var Layer = [
			boxStyle,
			roundStyle,
			selectStyle,
			fontStyle,
			boxStyle1,
			fontStyle1
		];


		// ------ more custom styles --------

		static var fontStyleInput = fontStyle.copy();
		static var fontStyleHeader = fontStyle1.copy();
		static var fontStyleButton = fontStyle.copy(Color.RED2, 10, 16);


		// ---------------------------------------------------
		// --------------- C O N F I G S ---------------------
		// ---------------------------------------------------
		
		static var textConfig:TextConfig = {
			backgroundStyle:boxStyle.copy(Color.GREY5),
			textSpace: {left:10},
		};

		static var textInputConfig:TextConfig = {
			backgroundStyle:boxStyle.copy(Color.GREY5),
			selectionStyle: selectStyle,
			cursorStyle: boxStyle1.copy(Color.RED),
			textSpace: {left:10},
		};

		static var buttonConfig:TextConfig = {
			backgroundStyle:roundStyle.copy(Color.GREY5),
			hAlign:HAlign.CENTER
			// textSpace: {left:10},
		};

		static var sliderConfig:SliderConfig = {
			backgroundStyle: roundStyle.copy(Color.GREY2),
			draggerStyle: roundStyle.copy(Color.GREY3, Color.GREY2, 0.5),
			draggerSize:16,
			draggSpace:1,
		};

		static var areaListConfig:AreaListConfig = {
			backgroundStyle:boxStyle,
			resizeType:ResizeType.LEFT|ResizeType.RIGHT,
			hAlign:HAlign.LEFT,
			maskSpace: {
				top:25,
				right:5,
				left:5,
				bottom:5
			},
			backgroundSpace: {
				// right:-15
			}
		};
}