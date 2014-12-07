package com.fs.kiwi;
import aze.display.TileLayer;
import com.fs.kiwi.characters.Player;

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
	private var iniX : Float;
	private var iniY : Float;
	private var width : Float;
	private var height : Float;
	private var hidden : Bool;
	
	public function new(type : String,rotation : String,gridX : Int,gridY : Int) 
	{
		this.type = type;
		this.rotation = rotation;
		this.gridX = gridX;
		this.gridY = gridY;
		width = Globals.GRID_SEP_X;
		height = Globals.GRID_SEP_Y;
		
		hidden = true;
		
		x = Globals.GRID_SEP_X/2 + Globals.GRID_SEP_X * gridX;
		y = Globals.GRID_SEP_Y / 2 + Globals.GRID_SEP_Y * gridY;
		iniX = x;
		iniY = y;
	}
	
	public function HandlePhysics(level : Array<Array<GameObject>>) : Void
	{
	}
	
	public function Reset() : Void
	{
		x = iniX;
		y = iniY;
	}
	
	public function LoadContent(tileLayer : TileLayer)
	{
	}
	
	public function Update(gameTime : Float) : Void
	{}
	
	public function GetGridX() : Int
	{
		return gridX;
	}
	
	public function GetGridY() : Int
	{
		return gridY;
	}
	
	public function GetX() : Float
	{
		return x;
	}
	
	public function GetY() : Float
	{
		return y;
	}
	
	public function GetW() : Float
	{
		return width;
	}
	
	public function GetH() : Float
	{
		return height;
	}
	
	public function GetType() : String
	{
		return type;
	}
}