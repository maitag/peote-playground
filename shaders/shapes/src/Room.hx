import lime.ui.KeyModifier;
import lime.ui.KeyCode;
import lime.ui.MouseWheelMode;
import peote.view.*;
import perspective.*;

class Room extends Display
{
	var back:Perspective;
	var left:Perspective;
	var right:Perspective;
	var up:Perspective;
	var down:Perspective;
	var scale:Float = 1.0;
	var offsetX:Float = 0;
	var offsetY:Float = 0;

	public function new(x:Int, y:Int, width:Int, height:Int, color:Color = 0x00000000)
	{
		super(x, y, width, height, color);

		Perspective.init(this, 5);
		back = new Perspective();
		left = new Perspective();
		right = new Perspective();
		up = new Perspective();
		down = new Perspective();
		draw();
	}

	override function addToPeoteView(peoteView:PeoteView, ?atDisplay:Display, addBefore:Bool = false)
	{
		super.addToPeoteView(peoteView, atDisplay, addBefore);

		peoteView.window.onMouseWheel.add(onMouseWheel);

		peoteView.window.onMouseMove.add(onMouseMove);

		peoteView.window.onKeyDown.add(onKeyDown);
	}

	function onMouseWheel(a:Float, b:Float, mode:MouseWheelMode):Void
	{
		trace('a $a b $b');
		var move = 0.05 * b;
		scale += move;
		draw();
	}

	function onKeyDown(code:KeyCode, modifier:KeyModifier):Void
	{
		switch code {
			case RIGHT:
				offsetX += 1;
			case LEFT:
				offsetX -= 1;
			case DOWN:
				offsetY += 1;
			case UP:
				offsetY -= 1;
			case NUMBER_0:
				offsetX = 0;
				offsetY = 0;
			case _:
		}

		draw();
	}

	function onMouseMove(x:Float, y:Float):Void
	{
		// todo
	}

	function draw():Void
	{
		var backX = (width / 2) + offsetX;
		var backY = (height / 2) + offsetY;
		var backWidth = width * scale;
		var backHeight = height * scale;
		var centerX = width / 2;
		var centerY = height / 2;

		var backLeft = backX - (backWidth / 2);
		var backRight = backX + (backWidth / 2);
		var backTop = backY - (backHeight / 2);
		var backBottom = backY + (backHeight / 2);

		var leftSpace = backLeft - 0;
		var rightSpace = width - backRight;
		var upSpace = backTop - 0;
		var downSpace = height - backBottom;

		var rotate = 0;
		var tipX = 0.5;
		var tipY = 1.0;
		back.draw(backX, backY, backWidth, backHeight, rotate, tipX, tipY);

		var rotate = 90;
		var tipX = offsetToTipX(offsetY, height, backHeight);
		var tipY = backWidth / width;
		left.draw(leftSpace / 2, centerY, height, leftSpace, rotate, tipX, tipY);

		var rotate = -90;
		var tipX = offsetToTipX(offsetY, height, backHeight);
		var tipY = backWidth / width;
		right.draw(width - rightSpace / 2, centerY, height, rightSpace, rotate, tipX, tipY);

		var rotate = -180;
		var tipX = offsetToTipX(offsetX, width, backWidth);
		var tipY = backHeight / height;
		up.draw(centerX, upSpace / 2, width, upSpace, rotate, tipX, tipY);

		var rotate = 0;
		var tipX = 0.5;
		var tipX = offsetToTipX(offsetX, width, backWidth);
		var tipY = backHeight / height;
		down.draw(centerX, backY + backHeight / 2 + downSpace / 2, width, downSpace, rotate, tipX, tipY);
	}

	inline function offsetToTipX(offset:Float, baseWidth:Float, topWidth:Float):Float{
		return 0.5 + offset / (baseWidth - topWidth);
	}
}
