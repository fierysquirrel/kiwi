package com.fs.kiwi.mapobjects;

/**
 * ...
 * @author Fiery Squirrel
 */
class Spike extends MapObject
{
	public static var TYPE = "4";
	public static var SPRITE_NAME = "spikes";
	
	public function new(rotation:String, gridX:Int, gridY:Int) 
	{
		super(TYPE, rotation,SPRITE_NAME, gridX, gridY);
		
	}
	
}