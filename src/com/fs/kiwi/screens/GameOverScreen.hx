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
class GameOverScreen extends GameScreen
{
	static public var NAME : String = "gameoveer";
	
	private var kiwisText : Text;
	private var back : Bitmap;
	private var numberOfKiwis : Int;
	
	public function new(kiwis : Int) 
	{
		super(NAME, 0, 0, "", true);
		
		numberOfKiwis = kiwis;
	}
	
	override public function LoadContent():Void 
	{
		super.LoadContent();
		
		back = new Bitmap(Assets.getBitmapData(Globals.SPRITES_PATH + "gameover.png"));
		back.x = 0;
		back.y = 0;
		addChild(back);
		
		kiwisText = Helper.CreateText(Globals.FONT.fontName, " x " + numberOfKiwis, 70, 0xffffff, 1);
		kiwisText.x = 500;
		kiwisText.y = 465;
		addChild(kiwisText);
	}
	
	public function OnPlayHandler() : Void
	{
		ScreenManager.LoadScreen(new GamePlayScreen());
		//eventDispatcher.dispatchEvent(new GameScreenEvent(GameEvents.EVENT_SCREEN_LOADED,new GamePlayScreen()));
	}
	
	public function OnShare() : Void
	{
		Share.share("I ate " + numberOfKiwis + " #kiwis, how many can you eat? try! http://www.newgrounds.com/portal/view/649793 #gamedev #LDJAM #newgrounds");
	}
	
	override public function HandleKeyUpEvent(key:UInt):Void 
	{
		super.HandleKeyUpEvent(key);
		
		switch(key)
		{
			case Keyboard.R:
				OnPlayHandler();
			case Keyboard.S:
				OnShare();
		}
	}
}