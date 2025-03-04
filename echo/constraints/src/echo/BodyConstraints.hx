package echo;

import echo.math.Vector2;
import echo.Body;
import echo.data.Types.ForceType; 

using echo.util.ext.FloatExt;

class BodyConstraints {
	public var constraints:Array<BodyConstraint> = [];

	public function new() {}

	public function add(constraint:BodyConstraint):BodyConstraint {
		constraints.push(constraint);
		return constraint;
	}

	public inline function remove(constraint:BodyConstraint):Bool {
		return constraints.remove(constraint);
	}

	public function step(fdt:Float) {
		for (c in constraints) {
			if (c.active) c.step(fdt);
		}
	}

	public inline function clear() {
		constraints.resize(0);
	}
}

// ---------------------------------------------------------
// ---------------------------------------------------------
// ---------------------------------------------------------

abstract class BodyConstraint {
	public var active:Bool = true;
	public abstract function step(dt:Float):Void;
}


class DistanceElastic extends BodyConstraint {
	public var a:Body;
	public var b:Body;
	public var stiffness:Float;
	public var swingdamping:Float;
	public var distance:Float;

	public function new(a:Body, b:Body, stiffness:Float, swingdamping:Float, ?distance:Float) {
		if (a == b) {
			trace("Can't constrain a body to itself!");
			return;
		}
		this.a = a;
		this.b = b;
		this.stiffness = stiffness * 1000;
		this.swingdamping = Math.min(1.0, Math.max(0.0, swingdamping));
		if (distance != null) this.distance = distance;
		else this.distance = a.get_position().distance(b.get_position());
	}

	var old_n = Vector2.zero;

	public function step(fdt:Float) {
		var ap:Vector2 = a.get_position();
		var bp:Vector2 = b.get_position();
		if (ap == bp) return;
		var normal = ap - bp;
		var m = normal.length_sq;
		var n = normal * (((distance * distance - m) / m) * stiffness * fdt);
		
		old_n *= swingdamping;
		a.push(n.x - old_n.x, n.y - old_n.y, ForceType.VELOCITY);
		b.push(-n.x + old_n.x, -n.y + old_n.y, ForceType.VELOCITY);
		old_n = n;
	}
}

class DistanceConstant extends BodyConstraint {
	public var a:Body;
	public var b:Body;
	public var distance:Float;

	public function new(a:Body, b:Body, ?distance:Float) {
		if (a == b) {
			trace("Can't constrain a body to itself!");
			return;
		}
		this.a = a;
		this.b = b;
		if (distance != null) this.distance = distance;
		else this.distance = a.get_position().distance(b.get_position());
	}

	public function step(fdt:Float) {
		// TODO: change velocity vectors to keep distance the same
	}
}

class PinElastic extends BodyConstraint {
	public var a:Body;
	public var bp:Vector2;
	public var stiffness:Float;
	public var swingdamping:Float;
	public var distance:Float;

	public function new( x:Float, y:Float, a:Body, stiffness:Float, swingdamping:Float, ?distance:Float) {
		this.a = a;
		this.bp = new Vector2(x, y);
		this.stiffness = stiffness * 1000 * 2;
		this.swingdamping = Math.min(1.0, Math.max(0.0, swingdamping));
		if (distance != null) this.distance = distance;
		else this.distance = a.get_position().distance(bp);
	}

	var old_n = Vector2.zero;

	public function step(fdt:Float) {
		var ap:Vector2 = a.get_position();
		if (ap == bp) return;
		var normal = ap - bp;
		var m = normal.length_sq;
		var n = normal * (((distance * distance - m) / m) * stiffness * fdt);
		old_n *= swingdamping;
		a.push(n.x - old_n.x, n.y - old_n.y, ForceType.VELOCITY);
		old_n = n;
	}
}

/*


class AngleElastic extends BodyConstraint {
	public var a:Dot;
	public var b:Dot;
	public var c:Dot;
	public var radians:Float;
	public var stiffness:Float;

	public function new(a:Dot, b:Dot, c:Dot, stiffness:Float) {
		this.a = a;
		this.b = b;
		this.c = c;
		this.stiffness = stiffness;
		radians = b.get_position().radians_between(a.get_position(), c.get_position());
	}

	public function step(dt:Float) {
		var a_pos = a.get_position();
		var b_pos = b.get_position();
		var c_pos = c.get_position();
		var angle_between = b_pos.radians_between(a_pos, c_pos);
		var diff = angle_between - radians;

		if (diff <= -Math.PI) diff += 2 * Math.PI;
		else if (diff >= Math.PI) diff -= 2 * Math.PI;

		diff *= dt * stiffness;

		a.set_position((a_pos - b_pos).rotate(diff) + b_pos);
		c.set_position((c_pos - b_pos).rotate(-diff) + b_pos);
		a_pos.set(a.x, a.y);
		c_pos.set(c.x, c.y);
		b.set_position((b_pos - a_pos).rotate(diff) + a_pos);
		b.set_position((b.get_position() - c_pos).rotate(-diff) + c_pos);
	}
	
}
*/

