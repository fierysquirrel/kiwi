package com.fs.kiwi.items;
import aze.display.TileLayer;

/**
 * ...
 * @author Fiery Squirrel
 */
class Kiwi extends Item
{
	public static var TYPE = "2";
	public static var SPRITE_NAME = "kiwi-item";
	
	public function new(rotation : String,gridX:Int, gridY:Int) 
	{
		super(TYPE,rotation,SPRITE_NAME, gridX, gridY);
	}
}