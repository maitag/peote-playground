import justPath.SvgLinePath;
import peote.view.Color;
import justPath.ILinePathContext;

typedef QuadrilateralPos = {ax:Float, ay:Float, bx:Float, by:Float, cx:Float, cy:Float, dx:Float, dy:Float};
typedef TrianglePos = {ax:Float, ay:Float, bx:Float, by:Float, cx:Float, cy:Float};
typedef DrawLine = (x0:Float, y0:Float, x1:Float, y1:Float, thick:Float, color:Color) -> Void;
class Graphics {}

@:access(stone.graphics.implementation.Graphics)
class NanjizalDraw implements ILinePathContext {
	public var strokeWidth:Float;
	public var strokeColor:Color;
	public var translateX:Float;
	public var translateY:Float;
	public var scaleX:Float;
	public var scaleY:Float;

	var toggleDraw = true;
	var info:QuadrilateralPos; // { ax: Float, ay: Float, bx: Float, by: Float, cx: Float, cy: Float, dx: Float, dy: Float };
	var oldInfo:QuadrilateralPos;
	var x0:Float = 0.;
	var y0:Float = 0.;
	var svgLinePath:SvgLinePath;
	var drawLine:DrawLine;

	public function new(drawLine:DrawLine, strokeColor:Color = 0xff0000ff, strokeWidth = 1., translateX = 0., translateY = 0., scaleX = 1., scaleY = 1.) {
		svgLinePath = new SvgLinePath(this);
		this.drawLine = drawLine;
		this.strokeWidth = strokeWidth;
		this.strokeColor = strokeColor;
		this.translateX = translateX;
		this.translateY = translateY;
		this.scaleX = scaleX;
		this.scaleY = scaleY;
	}

	public function fillTriangle(ax:Float, ay:Float, bx:Float, by:Float, cx:Float, cy:Float, hasHit:Bool = true) {
		var adjustWinding = ((ax * by - bx * ay) + (bx * cy - cx * by) + (cx * ay - ax * cy)) > 0;
		if (!adjustWinding) {
			var bx_ = bx;
			var by_ = by;
			bx = cx;
			by = cy;
			cx = bx_;
			cy = by_;
		}
		return fillTriUnsafe(ax, ay, bx, by, cx, cy, hasHit);
	}

	function fillTriUnsafe(ax:Float, ay:Float, bx:Float, by:Float, cx:Float, cy:Float, hasHit:Bool = true):Null<TrianglePos> {
		trace('fillTriUnsafe ');
		var s0 = ay * cx - ax * cy;
		var sx = cy - ay;
		var sy = ax - cx;
		var t0 = ax * by - ay * bx;
		var tx = ay - by;
		var ty = bx - ax;
		var A = -by * cx + ay * (-bx + cx) + ax * (by - cy) + bx * cy;
		// var yIter3: IteratorRange = boundIterator3( ay, by, cy );
		var xIter3:IteratorRange = boundIterator3(ax, bx, cx);
		var foundX = false;
		var s = 0.;
		var t = 0.;
		var syy = 0.;
		var tyy = 0.;
		var startX:Int = 0;
		var count = 0;
		for (y in boundIterator3(ay, by, cy)) {
			syy = sy * y;
			tyy = ty * y;
			foundX = false;
			for (x in xIter3) {
				s = s0 + tx * x + syy;
				t = t0 + sx * x + tyy;
				if (s <= 0 || t <= 0) {
					// after filling break
					if (foundX) {
						graphicsLine(startX, y, x, y, 1, strokeColor);
						break;
					}
				} else {
					if ((s + t) < A) {
						// store first hit
						if (foundX == false) {
							startX = x;
							trace('startX ' + x);
						}
						foundX = true;
					} else {
						// after filling break
						if (foundX) {
							graphicsLine(startX, y, x, y, 1, strokeColor);
							break;
						}
					}
				}
			}
		}
		return if (hasHit == true) {
			var v:TrianglePos = {
				ax: ax,
				ay: ay,
				bx: bx,
				by: by,
				cx: cx,
				cy: cy
			};
			v;
		} else {
			null;
		}
	}

	inline public function fillQuadrilateral(ax:Float, ay:Float, bx:Float, by:Float, cx:Float, cy:Float, dx:Float, dy:Float,
			hasHit:Bool = true):Null<QuadrilateralPos> {
		// tri e - a b d
		// tri f - b c d
		fillTriangle(ax, ay, bx, by, dx, dy, hasHit);
		fillTriangle(bx, by, cx, cy, dx, dy, hasHit);
		return if (hasHit == true) {
			var v:QuadrilateralPos = {
				ax: ax,
				ay: ay,
				bx: bx,
				by: by,
				cx: cx,
				cy: cy,
				dx: dx,
				dy: dy
			};
			v;
		} else {
			null;
		}
	}

	function graphicsLine(x0:Float, y0:Float, x1:Float, y1:Float, thick:Float, color:Color):QuadrilateralPos {
		drawLine(x0, y0, x1, y1, thick, color);
		return getInfo(x0, y0, x1, y1, thick);
	}

	inline function getInfo(px:Float, py:Float, qx:Float, qy:Float, thick:Float):QuadrilateralPos {
		var o = qy - py;
		var a = qx - px;
		var x = px;
		var y = py;
		var h = Math.pow(o * o + a * a, 0.5);
		var theta = Math.atan2(o, a);
		var sin = Math.sin(theta);
		var cos = Math.cos(theta);
		var radius = thick / 2;
		var dx = 0.1;
		var dy = radius;
		var cx = h;
		var cy = radius;
		var bx = h;
		var by = -radius;
		var ax = 0.1;
		var ay = -radius;
		var temp = 0.;
		temp = x + rotX(ax, ay, sin, cos);
		ay = y + rotY(ax, ay, sin, cos);
		ax = temp;

		temp = x + rotX(bx, by, sin, cos);
		by = y + rotY(bx, by, sin, cos);
		bx = temp;

		temp = x + rotX(cx, cy, sin, cos);
		cy = y + rotY(cx, cy, sin, cos);
		cx = temp;

		temp = x + rotX(dx, dy, sin, cos);
		dy = y + rotY(dx, dy, sin, cos);
		dx = temp;
		return {
			ax: ax,
			ay: ay,
			bx: bx,
			by: by,
			cx: cx,
			cy: cy,
			dx: dx,
			dy: dy
		};
	}

	public function drawPath(pathData:String) {
		if (pathData != '')
			svgLinePath.parse(pathData);
	}

	public function lineSegmentTo(x2:Float, y2:Float) {
		if (toggleDraw) {
			oldInfo = info;
			info = graphicsLine(x0 * scaleX + translateX, y0 * scaleY + translateY, x2 * scaleX + translateX, y2 * scaleY + translateY, strokeWidth,
				strokeColor);
			if (info != null && oldInfo != null) {
				var xA = (oldInfo.bx + oldInfo.cx) / 2;
				var yA = (oldInfo.by + oldInfo.cy) / 2;
				// var yA = ( info.ax + info.dx )/2; <----!!!
				// var xB = ( oldInfo.bx + oldInfo.cx )/2;
				// var yB = ( info.ax + info.dx )/2;
				graphicsLine(xA * scaleX + translateX, yA * scaleY + translateY, x0 * scaleX + translateX, y0 * scaleY + translateY, strokeWidth, strokeColor);
				// Can try fillQuadrilateral here!
				// fillQuadrilateral( oldInfo.bx*scaleX + translateX, oldInfo.by*scaleY + translateY, info.ax*scaleX + translateX, info.ay*scaleY + translateY, info.dx*scaleX + translateX, info.dy*scaleY + translateY, oldInfo.cx*scaleX + translateX, oldInfo.cy*scaleY + translateY, strokeColor );
			}
		} else {}
		toggleDraw = !toggleDraw;
		x0 = x2;
		y0 = y2;
	}

	public function lineTo(x2:Float, y2:Float) {
		oldInfo = info;
		info = graphicsLine(x0 * scaleX + translateX, y0 * scaleY + translateY, x2 * scaleX + translateX, y2 * scaleY + translateY, strokeWidth, strokeColor);
		if (info != null && oldInfo != null) {
			var xA = (oldInfo.bx + oldInfo.cx) / 2;
			var yA = (oldInfo.by + oldInfo.cy) / 2;
			// var yA = ( info.ax + info.dx )/2; <--!!
			// var xB = ( oldInfo.bx + oldInfo.cx )/2;
			// var yB = ( info.ax + info.dx )/2;
			graphicsLine(xA * scaleX + translateX, yA * scaleY + translateY, x0 * scaleX + translateX, y0 * scaleY + translateY, strokeWidth, strokeColor);
			// Can try fillQuadrilateral here!
			// fillQuadrilateral( oldInfo.bx*scaleX + translateX, oldInfo.by*scaleY + translateY, info.ax*scaleX + translateX, info.ay*scaleY + translateY, info.dx*scaleX + translateX, info.dy*scaleY + translateY, oldInfo.cx*scaleX + translateX, oldInfo.cy*scaleY + translateY, strokeColor );
		}
		x0 = x2;
		y0 = y2;
		toggleDraw = true;
	}

	public function moveTo(x1:Float, y1:Float) {
		x0 = x1;
		y0 = y1;
		info = null;
		toggleDraw = true;
	}

	public function quadTo(x2:Float, y2:Float, x3:Float, y3:Float) {
		svgLinePath.quadTo(x2, y2, x3, y3);
	}

	public function curveTo(x2:Float, y2:Float, x3:Float, y3:Float, x4:Float, y4:Float) {
		svgLinePath.curveTo(x2, y2, x3, y3, x4, y4);
	}

	public function quadThru(x2:Float, y2:Float, x3:Float, y3:Float) {
		svgLinePath.quadThru(x2, y2, x3, y3);
	}
}

inline function rotX(x:Float, y:Float, sin:Float, cos:Float) {
	return x * cos - y * sin;
}

inline function rotY(x:Float, y:Float, sin:Float, cos:Float) {
	return y * cos + x * sin;
}

// for triangle iteration ( module level functions need recent haxe compiler )

inline function boundIterator3(a:Float, b:Float, c:Float):IteratorRange {
	return if (a > b) {
		if (a > c) { // a,b a,c
			((b > c) ? Math.floor(c) : Math.floor(b))...Math.ceil(a);
		} else { // c,a,b
			Math.floor(b)...Math.ceil(c);
		}
	} else {
		if (b > c) { // b,a, b,c
			((a > c) ? Math.floor(c) : Math.ceil(a))...Math.ceil(b);
		} else { // c,b,a
			Math.floor(a)...Math.ceil(c);
		}
	}
}

@:access(IntIterator.min, IntIterator.max)
class IntIterStart {
	public var start:Int;
	public var max:Int;

	public function new(min_:Int, max_:Int) {
		start = min_;
		max = max_;
	}
}

@:transitive
@:access(IntIterator.min, IntIterator.max)
@:forward
abstract IteratorRange(IntIterStart) from IntIterStart {
	public static inline function startLength(min:Int, len:Int):IteratorRange {
		return new IteratorRange(min, min + len - 1);
	}

	public inline function new(min:Int, max:Int) {
		this = new IntIterStart(min, max);
	}

	@:from
	static inline public function fromIterator(ii:IntIterator):IteratorRange {
		return new IteratorRange(ii.min, ii.max);
	}

	@:to
	function toIterStart():IteratorRange {
		return new IteratorRange(this.start, this.max);
	}

	public inline function iterator() {
		return this.start...this.max;
	}

	@:op(A + B) public static inline function adding(a:IteratorRange, b:IteratorRange):IteratorRange {
		return a.add(b);
	}

	public inline function add(b:IteratorRange):IteratorRange {
		var begin:Int = Std.int(Math.min(this.start, b.max));
		var end = (begin == this.start) ? b.max : this.max;
		return new IteratorRange(begin, end);
	}

	public var length(get, set):Int;

	inline function get_length():Int {
		return this.max - this.start + 1;
	}

	inline function set_length(l:Int):Int {
		this.max = l - 1;
		return l;
	}

	inline public function contains(v:Int):Bool {
		return (v > (this.start - 1) && (v < this.max + 1));
	}

	inline public function containsF(v:Float):Bool {
		return (v > (this.start - 1) && (v < this.max + 1));
	}

	inline public function isWithin(ir:IteratorRange):Bool {
		return contains(ir.start) && contains(ir.max);
	}

	inline public function moveRange(v:Int) {
		this.start += v;
		this.max += v;
	}

	@:op(A += B)
	public inline static function addAssign(a:IteratorRange, v:Int) {
		a.moveRange(v);
		return a;
	}

	@:op(A -= B)
	public inline static function minusAssign(a:IteratorRange, v:Int) {
		return a += -v;
	}

	inline public function ifContainMove(v:Int, amount:Int):Bool {
		var ifHas = contains(v);
		if (ifHas)
			moveRange(amount);
		return ifHas;
	}
}
