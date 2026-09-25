import peote.view.Color;

function randFloatRange(min:Float, max:Float):Float
{
	return Math.random() * (max - min) + min;
}

function randItem<T>(items:Array<T>):T
{
	return items[Std.random(items.length)];
}

function mixToWhite(color:Color, t:Float):Color
{
	var mix:Color = color;
	mix.r = Std.int(color.r + (255 - color.r) * t);
	mix.g = Std.int(color.g + (255 - color.g) * t);
	mix.b = Std.int(color.b + (255 - color.b) * t);
	return mix;
}

var flameColors:Array<Color> = [0xffffaaff, 0xffdd44ff, 0xffaa00ff, 0xff5500ff];
var coolColor:Color = 0xff220000;

function flame(pool:Particles, timeNow:Float, x:Float, y:Float, count:Int, amp:Float):Void
{
	for (n in 0...count)
	{
		var p = pool.get();

		// how long the particle lives
		var lifespan = randFloatRange(0.5, 0.9);

		// rotate particle 45 degrees
		p.degrees = 45;

		// size of particle (not animated)
		var size = Std.int(randFloatRange(6, 18) * (1 + amp * 1.2));
		p.w = size;
		p.h = size;

		// animate color of particle
		var flameColor = randItem(flameColors);
		var hotColor = mixToWhite(flameColor, amp * 0.5);
		// var coolColor:Color = 0xff220000;
		// coolColor.a = 0x00;
		p.tint = hotColor;
		p.animTint(hotColor, coolColor);
		p.timeTint(timeNow, lifespan);

		// animate position
		// randomised spread across a diamond shape
		// prefer particles in the center, thinned out to edges
		var spreadLimits = randFloatRange(-1, 1);
		var spread = spreadLimits * spreadLimits * spreadLimits * 40;
		var rise = randFloatRange(120, 200) * (1 + amp * 2.0);
		var drift = spread * 0.4;
		var startX = Std.int(x + spread);
		var startY = Std.int(y);
		var endX = Std.int(x + spread + drift);
		var endY = Std.int(y - rise);
		p.animPos(startX, startY, endX, endY);
		p.timePos(timeNow, lifespan);
	}
}

var smokeColors:Array<Color> = [0x555555ff, 0x444444ff, 0x666666ff, 0x3a3a3aff];

function smoke(pool:Particles, timeNow:Float, x:Float, y:Float, count:Int, amp:Float):Void
{
	for (n in 0...count)
	{
		var p = pool.get();

		// no rotation, all particles are constantly being reused so we have to set it back to 0
		p.degrees = 0;

		// how long the particle lives
		var lifespan = randFloatRange(1.8, 3.2) * (1 + amp);

		// animate size of particle
		var sizeStart = Std.int(randFloatRange(8, 20));
		var sizeEnd = Std.int(randFloatRange(80, 140) * (1 + amp * 0.6));
		p.animSize(sizeStart, sizeStart, sizeEnd, sizeEnd);
		p.timeSize(timeNow, lifespan);

		// animate position
		// randomised spread across an upside down kite shape
		// prefer particles in the center, thinned out to edges
		var kiteWidth = 60.0;
		var kiteUp = 150.0;
		var kiteDown = 120.0;
		var u = randFloatRange(-1, 1);
		var v = randFloatRange(-1, 1);
		var offsetX = (u + v) * 0.5 * kiteWidth;
		var offsetYpre = (u - v) * 0.5;
		var offsetY = offsetYpre < 0 ? offsetYpre * kiteUp : offsetYpre * kiteDown;
		var dist = randFloatRange(300, 420);
		// adds wind blowing in top left direction, with some jitter
		var dx = -dist + randFloatRange(-60, 60);
		var dy = -dist + randFloatRange(10, 60);
		var startX = Std.int(x + offsetX);
		var startY = Std.int(y + offsetY);
		var endX = Std.int(x + offsetX + dx);
		var endY = Std.int(y + offsetY + dy);
		p.animPos(startX, startY, endX, endY);
		p.timePos(timeNow, lifespan);

		// animate color
		var hot = randItem(smokeColors);
		hot.a = 0x10;
		p.tint = hot;
		p.animTint(hot, 0x10101000);
		p.timeTint(timeNow, lifespan);
	}
}
