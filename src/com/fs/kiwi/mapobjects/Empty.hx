package com.fs.kiwi.mapobjects;
import aze.display.TileLayer;

/**
 * ...
 * @author Fiery Squirrel
 */
class Empty extends MapObject
{
	public static var TYPE = "0";
	public static var SPRITE_NAME = "empty";
	
	public function new(rotation:String, gridX:Int, gridY:Int) 
	{
		super(TYPE, rotation,SPRITE_NAME, gridX, gridY);
	}
	
	override public function LoadContent(tileLayer:TileLayer) 
	{
		//super.LoadContent(tileLayer);
	}
}