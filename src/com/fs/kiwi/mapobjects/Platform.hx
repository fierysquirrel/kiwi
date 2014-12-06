package com.fs.kiwi.mapobjects;

/**
 * ...
 * @author Fiery Squirrel
 */
class Platform extends MapObject
{
	public static var TYPE = "3";
	public static var SPRITE_NAME = "floor";
	
	public function new(rotation:String, gridX:Int, gridY:Int) 
	{
		super(TYPE, rotation,SPRITE_NAME, gridX, gridY);
		
	}
	
}