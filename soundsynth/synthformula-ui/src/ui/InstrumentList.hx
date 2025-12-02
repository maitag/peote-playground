package ui;

class InstrumentList extends UIAreaList
{
	public function new(x:Int, y:Int, w:Int, h:Int, z:Int = 0, ?config:AreaListConfig)
	{
		super(10, 10, 200, 300, 0, (config != null) ? config : StyleConf.areaListConfig);

		
		// add some fixed Element for the header
		var header = new TextLine(0, 0, 0, 0, 2, "--- INSTRUMENTS ---", StyleConf.font, StyleConf.fontStyleHeader, StyleConf.textInputConfig);
		header.onPointerDown = (_, e:PointerEvent)-> this.startDragging(e);
		header.onPointerUp = (_, e:PointerEvent)-> this.stopDragging(e);
		this.addFixed(header);
		
		// ---- add content ----
		
		// TODO

		// ------------------------------------
		// ---- Sliders to scroll the Area ----		
		// ------------------------------------

		// var hSlider = new UISlider(0, this.height-20, this.width-20, 20, sliderConfig);
		// hSlider.onMouseWheel = (_, e:WheelEvent) -> hSlider.setWheelDelta( e.deltaY );
		// this.addFixed(hSlider);		
		
		var vSlider = new UISlider(this.width-20, 0, 20, this.height, StyleConf.sliderConfig);
		vSlider.onMouseWheel = (_, e:WheelEvent) -> vSlider.setWheelDelta( e.deltaY );
		this.addFixed(vSlider);
		
		// bindings for sliders
		// this.bindHSlider(hSlider);
		this.bindVSlider(vSlider, false);

		this.onResizeWidth = (_, width:Int, deltaWidth:Int) -> {
			vSlider.right = this.right;
			// hSlider.rightSize = vSlider.left;
		}

		this.onResizeHeight = (_, height:Int, deltaHeight:Int) -> {
			vSlider.bottomSize = this.bottom;
			// hSlider.bottom = this.bottom;
		}


		// scroll to bottom (have to be after "add" because of text-elements!)
		// this.setYOffset(this.yOffsetEnd, true, true);
		

	}	

	
}
