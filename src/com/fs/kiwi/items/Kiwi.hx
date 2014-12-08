package com.fs.kiwi.items;
import aze.display.TileLayer;
import com.fs.kiwi.sound.Sound;

/**
 * ...
 * @author Fiery Squirrel
 */
class Kiwi extends Item
{
	public static var TYPE = "2";
	public static var SPRITE_NAME = "kiwi-item";
	private var soundPick : Sound;
	private var soundNew : Sound;
	
	public function new(rotation : String,gridX:Int, gridY:Int) 
	{
		super(TYPE, rotation, SPRITE_NAME, gridX, gridY);
		
		switch(rotation)
		{
			case Globals.ROTATION_0:
				y += height / 2;
			case Globals.ROTATION_90:
				x -= width / 2;
			case Globals.ROTATION_180:
				y -= height / 2;
			case Globals.ROTATION_270:
				x += width / 2;
		}
		
		soundPick = new Sound(Globals.SOUND_KIWI, false);
		soundNew = new Sound(Globals.SOUND_NEW_KIWI, false);
		soundNew.Play();
	}
	
	override public function LoadContent(tileLayer:TileLayer) 
	{
		super.LoadContent(tileLayer);
		
		//Rotation
		switch(rotation)
		{
			case Globals.ROTATION_0:
				sprite.rotation = 0;
			case Globals.ROTATION_90:
				sprite.rotation = Math.PI/2;
			case Globals.ROTATION_180:
				sprite.rotation = Math.PI;
			case Globals.ROTATION_270:
				sprite.rotation = Math.PI + Math.PI/2;
		}
	}
	
	override public function Pick():Void 
	{
		super.Pick();
		
		soundPick.Play();
	}
}