package com.fs.kiwi;
import aze.display.TileLayer;

/**
 * ...
 * @author Fiery Squirrel
 */
class GameObject
{
	private var type : String;
	private var rotation : String;
	private var gridX: Int;
	private var gridY: Int;
	private var x : Float;
	private var y : Float;
	private var hidden : Bool;
	
	public function new(type : String,rotation : String,gridX : Int,gridY : Int) 
	{
		var gridBlockXSize, gridBlockYSize : Float;
		this.type = type;
		this.rotation = rotation;
		this.gridX = gridX;
		this.gridY = gridY;
		
		hidden = true;
		
		gridBlockXSize = (Globals.SCREEN_WIDTH / Globals.NUMBER_GRID_SQUARES_X);
		gridBlockYSize = (Globals.SCREEN_HEIGHT / Globals.NUMBER_GRID_SQUARES_Y);
		x = gridBlockXSize/2 + gridBlockXSize * gridX;
		y = gridBlockYSize/2 + gridBlockYSize * gridY;
	}
	
	public function LoadContent(tileLayer : TileLayer)
	{
	}
	
	public function Update(gameTime : Float) : Void
	{}
	
}