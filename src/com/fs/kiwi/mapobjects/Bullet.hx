package com.fs.kiwi.mapobjects;
import aze.display.TileLayer;
import aze.display.TileSprite;
import com.fs.kiwi.characters.Player;
import com.fs.kiwi.GameObject;

/**
 * ...
 * @author Fiery Squirrel
 */
class Bullet extends GameObject
{
	public static var TYPE = "6";
	public static var SPRITE_NAME = "bullet";
	
	private var sprite : TileSprite;
	private var collided : Bool;
	private var velX : Float;
	private var velY : Float;
	private var cannon : Cannon;
	
	public function new(cannon : Cannon,gridX:Int, gridY:Int, velX : Float, velY : Float) 
	{
		super(TYPE, rotation, gridX, gridY);
		
		this.cannon = cannon;
		this.velX = velX;
		this.velY = velY;
		gridX = 0;
		gridY = 0;
	}
	
	override public function LoadContent(tileLayer:TileLayer) 
	{
		super.LoadContent(tileLayer);
		
		sprite = new TileSprite(tileLayer, SPRITE_NAME);
		sprite.x = x;
		sprite.y = y;
		
		tileLayer.addChild(sprite);
	}
	
	override public function Update(gameTime:Float):Void 
	{
		super.Update(gameTime);
		
		x += velX;
		y += velY;
		
		sprite.x = x;
		sprite.y = y;
		
		gridX = cast((x - Globals.GRID_SEP_X / 2) / Globals.GRID_SEP_X, Int);
		gridY = cast((y - Globals.GRID_SEP_Y / 2) / Globals.GRID_SEP_Y, Int);
	}
	
	public function CheckLevelCollision(player : Player,level : Array<Array<GameObject>>) : Void
	{	
		if (x > player.GetX() - player.GetW()/2 && x < player.GetX() + player.GetW()/2 && y > player.GetY() - player.GetH()/2 && y < player.GetY() + player.GetH()/2)
		{
			if(!player.IsHit())
				player.Hit();
				
			collided = true;
		}
		else if (level[gridX][gridY].GetType() == Platform.TYPE)// || (level[gridX][gridY].GetType() == Cannon.TYPE && level[gridX][gridY] != cannon))
		{
			if((x > level[gridX][gridY].GetX() - level[gridX][gridY].GetW()/2 && x < level[gridX][gridY].GetX() + level[gridX][gridY].GetW()/2 && y > level[gridX][gridY].GetY() - level[gridX][gridY].GetH()/2 && y < level[gridX][gridY].GetY() + level[gridX][gridY].GetH()/2))
				collided = true;
		}
	}
	
	public function Collided() : Bool
	{
		return collided;
	}
	
	public function GetSprite() : TileSprite
	{
		return sprite;
	}
}