package com.fs.kiwi.items;

import aze.display.TileLayer;
import aze.display.TileSprite;
import com.fs.kiwi.GameObject;

/**
 * ...
 * @author Fiery Squirrel
 */
class Item extends GameObject
{
	private var sprite : TileSprite;
	private var spriteName : String;
	
	public function new(type:String,rotation : String,spriteName : String, gridX:Int, gridY:Int) 
	{
		super(type, rotation, gridX, gridY);
		
		this.spriteName = spriteName;
	}
	
	override public function LoadContent(tileLayer:TileLayer) 
	{
		super.LoadContent(tileLayer);
		
		sprite = new TileSprite(tileLayer, spriteName);
		sprite.x = x;
		sprite.y = y;
		tileLayer.addChild(sprite);
	}
}