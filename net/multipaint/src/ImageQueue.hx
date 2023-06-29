package ;

import haxe.io.Bytes;

import peote.io.PeoteBytesInput;
import peote.io.PeoteBytesOutput;
import peote.io.Byte;
import peote.io.UInt16;

class ImageQueue 
{
	var output:PeoteBytesOutput;
	
	public function new() {
		output = new PeoteBytesOutput();
	}
	
	
	public function sendToClient(serverRemote:ServerRemote) 
	{
		if (output.length == 0) return;
		
		var input:PeoteBytesInput = new PeoteBytesInput(output.getBytes());
		
		switch ( input.readByte() ) {
			case 0: serverRemote.client.addPen( input.readUInt16() );
			case 1: serverRemote.client.removePen( input.readUInt16() );
			case 2:
				serverRemote.client.penChange(
					input.readUInt16(),
					input.readByte(),
					input.readByte(),
					input.readByte(),
					input.readByte(),
					input.readByte(),
					input.readByte()
				);
			case 3:
				var userNr:UInt16 = input.readUInt16();
				var len:UInt16 = input.readUInt16();
				var drawQueue = new Array<UInt16>();
				for (i in 0...len) drawQueue.push( input.readUInt16() );
				serverRemote.client.penDraw(userNr, drawQueue);
			default:
				
		}
	}
	
	
	public function addPen(userNr:UInt16)
	{
		output.writeByte(0);
		output.writeUInt16(userNr);
	}
	
	public function removePen(userNr:UInt16)
	{
		output.writeByte(1);
		output.writeUInt16(userNr);
	}
	
	public function penChange(userNr:UInt16, w:Byte, h:Byte, r:Byte, g:Byte, b:Byte, a:Byte) 
	{
		output.writeByte(2);
		output.writeUInt16(userNr);
		output.writeByte(w);
		output.writeByte(h);
		output.writeByte(r);
		output.writeByte(g);
		output.writeByte(b);
		output.writeByte(a);

	}
	
	public function penDraw(userNr:UInt16, drawQueue:Array<UInt16>)
	{
		output.writeByte(3);
		output.writeUInt16(userNr);
		output.writeUInt16(drawQueue.length);
		
		for (v in drawQueue) output.writeUInt16(v);

	}
	
}