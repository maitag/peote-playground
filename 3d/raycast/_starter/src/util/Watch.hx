package util;

import peote.view.text.TextProgram;
import peote.view.text.Text;

/**
 * Text with a callback for the content
 * Useful for watching variables to get quick debug info
 */
class Watch
{
	var line:Text;
	var refresh:() -> String;

	public function new(line:Text, refresh:() -> String)
	{
		this.line = line;
		this.refresh = refresh;
	}

	public function update(program:TextProgram)
	{
		line.text = refresh();
		program.updateText(line);
	}
}
