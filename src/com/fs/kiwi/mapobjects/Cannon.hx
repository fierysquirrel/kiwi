package com.fs.kiwi.mapobjects;

/**
 * ...
 * @author Fiery Squirrel
 */
class Cannon extends MapObject
{
	public static var TYPE = "5";
	public static var SPRITE_NAME = "cannon-front";
	
	public function new(rotation:String, gridX:Int, gridY:Int) 
	{
		super(TYPE, rotation,SPRITE_NAME, gridX, gridY);
		
	}
	
}