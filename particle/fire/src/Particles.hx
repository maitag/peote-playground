import peote.view.*;

class Particles
{
	var program:Program;
	var buffer:Buffer<Particle>;
	var head:Int = 0;

	public function new(size:Int)
	{
		buffer = new Buffer<Particle>(size);
		program = new Program(buffer);
		for (i in 0...size)
		{
			buffer.addElement(new Particle());
		}
	}

	public function showOn(display:Display)
	{
		display.addProgram(program);
	}

	public function get():Particle
	{
		// cycle through the buffer and give back the next element
		head = (head + 1) % buffer.length;
		return buffer.getElement(head);
	}

	public function update():Void
	{
		buffer.update();
	}
}

class Particle implements Element
{
	@posX @anim("pos") public var x:Int = 0;
	@posY @anim("pos") public var y:Int = 0;

	@sizeX @anim("size") public var w:Int = 0;
	@sizeY @anim("size") public var h:Int = 0;

	@color @varying @anim("tint") public var tint:Color = 0x00000000;

	@rotation public var degrees:Float = 0.0;

	var OPTIONS = {blend: true};
}
