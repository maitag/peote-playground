package util;

import peote.view.Display;
import peote.view.text.*;

class Message
{
	static var program:TextProgram;
	static var texts:Array<Text> = [];
	static var top = 28;
	static var left = 18;
	static var glyphSize = 16;
	static var lineGap = 4;

	public static function writeMessage(display:Display, message:String)
	{
		if (program == null)
		{
			var options:TextOptions = {
				letterWidth: glyphSize,
				letterHeight: glyphSize,
			}
			program = new TextProgram(options);
			display.addProgram(program);
		}

		texts.push(program.add(new Text(left, top + Std.int(texts.length * (glyphSize + lineGap)), message)));
	}
}
