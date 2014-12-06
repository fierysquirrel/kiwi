package com.fs.kiwi.animation;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * ...
 * @author Henry D. Fernández B.
 */

class Frame 
{
	var rectangle : Rectangle;
	
	var offset : Point;
	
	public function new(rectangle : Rectangle, offset : Point = null) 
	{
		this.rectangle = rectangle;
		if (offset != null)
			this.offset = offset;
		else
			this.offset = new Point();
	}
	
	public function GetRectangle() : Rectangle
	{
		return rectangle;
	}
	
	public function GetOffset() : Point
	{
		return offset;
	}
}