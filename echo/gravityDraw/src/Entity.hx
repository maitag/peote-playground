package;

import peote.view.Color;

interface Entity 
{
  public var color:Color;
  public var radius:Float;
  public var intersected:Int;
  
  public function update(x:Float, y:Float):Void;
}