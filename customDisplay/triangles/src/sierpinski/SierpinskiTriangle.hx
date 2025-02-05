package sierpinski;

import peote.view.Color;

class SierpinskiTriangle extends Triangle {

	public function new(
		x1:Float, y1:Float, c1:Color,
		x2:Float, y2:Float, c2:Color,
		x3:Float, y3:Float, c3:Color //,z:Int = 0
	) {
		super(x1,y1,c1, x2,y2,c2, x3,y3,c3);
	}

	// lengths between the vertex points:
	inline function len(xa:Float,ya:Float,xb:Float,yb:Float):Float {
		return Math.sqrt( (xa-xb)*(xa-xb) + (ya-yb)*(ya-yb) );
	}
	public var len1(get,never):Float; inline function get_len1():Float return len(x1,y1,x2,y2);
	public var len2(get,never):Float; inline function get_len2():Float return len(x2,y2,x3,y3);
	public var len3(get,never):Float; inline function get_len3():Float return len(x3,y3,x1,y1);

	// mids between the vertex points:
	inline function mid(a:Float,b:Float,delta:Float=0.5):Float return a + (b-a)*delta;

	public var mid1x(get,never):Float; inline function get_mid1x():Float return mid(x1,x2);
	public var mid2x(get,never):Float; inline function get_mid2x():Float return mid(x2,x3);
	public var mid3x(get,never):Float; inline function get_mid3x():Float return mid(x3,x1);

	public var mid1y(get,never):Float; inline function get_mid1y():Float return mid(y1,y2);
	public var mid2y(get,never):Float; inline function get_mid2y():Float return mid(y2,y3);
	public var mid3y(get,never):Float; inline function get_mid3y():Float return mid(y3,y1);

	// position on a side with delta (0.5 is middle!)
	public inline function delta1x(delta:Float):Float return mid(x1,x2,delta);
	public inline function delta2x(delta:Float):Float return mid(x2,x3,delta);
	public inline function delta3x(delta:Float):Float return mid(x3,x1,delta);

	public inline function delta1y(delta:Float):Float return mid(y1,y2,delta);
	public inline function delta2y(delta:Float):Float return mid(y2,y3,delta);
	public inline function delta3y(delta:Float):Float return mid(y3,y1,delta);

	// wing area
	public var area(get,never):Float; inline function get_area():Float return 0.5*Math.abs( (x2-x1)*(y3-y1) - (x3-x1)*(y2-y1) );


}