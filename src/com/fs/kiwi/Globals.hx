package com.fs.kiwi;

/**
 * ...
 * @author Fiery Squirrel
 */
class Globals
{
	static public var SCREEN_WIDTH : Float = 700;
	static public var SCREEN_HEIGHT : Float = 700;
	static public var FIXED_SCREEN_HEIGHT : Float = 700;
	static public var FIXED_SCREEN_WIDTH : Float = 700;
	
	//Grid
	static public var NUMBER_GRID_SQUARES_X : Int = 28;
	static public var NUMBER_GRID_SQUARES_Y : Int = 28;
	static public var GRID_SEP_X : Float = SCREEN_WIDTH / NUMBER_GRID_SQUARES_X;
	static public var GRID_SEP_Y : Float = SCREEN_HEIGHT / NUMBER_GRID_SQUARES_Y;
	static public var GRID_LINE_THICK : Float = 1;
	static public var GRID_LINE_COLOR : Int = 0xffffff;
	static public var GRID_LINE_ALPHA : Float = 0.1;
	
	static public var FRAME_LINE_THICK : Float = 1;
	static public var FRAME_LINE_COLOR : Int = 0xff0000;
	static public var FRAME_LINE_ALPHA : Float = 1;
	
	//Rotation values
	static public var ROTATION_0 : String 	= "0";
	static public var ROTATION_90 : String 	= "1";
	static public var ROTATION_180 : String = "2";
	static public var ROTATION_270 : String = "3";
	
	static public var GRAVITY : Float = 1;
	static public var PLAYER_SPEED : Float = 2.5;
	static public var PLAYER_JUMP_IMP : Float = 10;
	
	static public var FPS : Float = 60;
	static public var MILLISECONDS : Int = 1000;
	static public var TIME_STEP : Float = (FPS / MILLISECONDS);
	
	//Paths
	static public var SPRITES_PATH : String = "assets/sprites/";
}