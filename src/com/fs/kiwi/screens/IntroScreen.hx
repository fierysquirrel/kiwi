package com.fs.kiwi.screens;
import flash.display.Bitmap;
import flash.display.BitmapData;
import fs.screenmanager.GameScreen;
import flash.ui.Keyboard;
import fs.screenmanager.ScreenManager;
import openfl.Assets;
import extension.share.Share;

/**
 * ...
 * @author Henry D. Fernández B.
 */
class IntroScreen extends GameScreen
{
	static public var NAME : String = "intro";
	
	private var back : Bitmap;
	
	public function new() 
	{
		super(NAME, 0, 0, "", true);
	}
	
	override public function LoadContent():Void 
	{
		super.LoadContent();
		
		back = new Bitmap(Assets.getBitmapData(Globals.SPRITES_PATH + "intro.png"));
		back.x = 0;
		back.y = 0;
		addChild(back);
	}
	
	public function OnPlayHandler() : Void
	{
		ScreenManager.LoadScreen(new GamePlayScreen());
	}
	
	override public function HandleKeyUpEvent(key:UInt):Void 
	{
		super.HandleKeyUpEvent(key);
		
		OnPlayHandler();
	}
}