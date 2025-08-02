package;

import arcade.Body;
import peote.view.Color;
import peote.view.Element;

class PhysicsElem implements Element {
	public var body: Body;

	@posX @set("Pos")
	public var x = 0;
	@posY @set("Pos")
	public var y = 0;

	@sizeX @set("Size")
	public var w = 100;
	@sizeY @set("Size")
	public var h = 100;
	
	@rotation @set("Rotation")
	public var r = 0.;

	@color @set("Color")
	public var c: Color = 0xef7d57ff;

	public function new() {
		body = new Body(x, y, w, h, r);
		body.collideWorldBounds = true;
	}

	public function updatePhysics() {
		setPos(Std.int(body.x), Std.int(body.y));
		setRotation(body.rotation);
	}
}
