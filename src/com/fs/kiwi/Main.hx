package com.fs.kiwi;

import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import flash.events.EventDispatcher;
import fs.screenmanager.ScreenManager;
import fs.screenmanager.GameScreen;
import com.fs.kiwi.screens.GamePlayScreen;
import flash.events.KeyboardEvent;
import openfl.Assets;
import extension.share.Share;
import com.fs.kiwi.screens.IntroScreen;

/**
 * ...
 * @author Fiery Squirrel
 */

class Main extends Sprite 
{
	var inited:Bool;
	var lastTime : Float;
	var container : Sprite;
	var eventDispatcher : EventDispatcher;
	var initialScreen : GameScreen;
	var gameContainer : Sprite;
	var fixedContainer : Sprite;
	var screenManager : ScreenManager;

	/* ENTRY POINT */
	
	function resize(e) 
	{
		if (!inited) init();
		// else (resize or orientation change)
	}
	
	function init() 
	{
		if (inited) return;
		inited = true;

		// (your code here)
		//Containers
		gameContainer = new Sprite();
		fixedContainer = new Sprite();
		container = new Sprite();
		
		//Event dispatcher
		eventDispatcher = new EventDispatcher();
		
		addChild(gameContainer);
		addChild(fixedContainer);
		addChild(container);
		
		//Screen manager
		screenManager = ScreenManager.InitInstance(eventDispatcher, gameContainer, fixedContainer, Globals.SCREEN_WIDTH, Globals.SCREEN_HEIGHT, 0x000000);
		
		//Main loop
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, MainLoop);
		
		//Keyboard
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, ScreenManager.HandleKeyboardEvent);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, ScreenManager.HandleKeyboardEvent);
		
		//Initial screen
		//initialScreen = new GamePlayScreen();
		initialScreen = new IntroScreen();
		
		if(initialScreen != null)
			ScreenManager.LoadScreen(initialScreen);
		
		Globals.FONT = Assets.getFont("assets/fonts/TektonProBold.ttf");
		Globals.SOUND_JUMP = Assets.getSound("assets/sounds/jump.wav");
		Globals.SOUND_SHOOT = Assets.getSound("assets/sounds/shoot.wav");
		Globals.SOUND_HIT = Assets.getSound("assets/sounds/hit.wav");
		Globals.SOUND_GAMEOVER = Assets.getSound("assets/sounds/gameover.wav");
		Globals.SOUND_KIWI = Assets.getSound("assets/sounds/kiwi.wav");
		Globals.SOUND_NEW_KIWI = Assets.getSound("assets/sounds/new-kiwi.wav");
		Globals.SOUND_BULLET_COLLIDE = Assets.getSound("assets/sounds/bullet-collide.wav");
		Globals.SOUNDTRACK = Assets.getSound("assets/sounds/soundtrack.mp3");
		
		Share.init(Share.TWITTER); // for non supported targets, we share on Twitter (you can also use Share.FACEBOOK)
		
		// Stage:
		// stage.stageWidth x stage.stageHeight @ stage.dpiScale
		
		// Assets:
		// nme.Assets.getBitmapData("img/assetname.jpg");
	}

	/* SETUP */

	public function new() 
	{
		super();	
		addEventListener(Event.ADDED_TO_STAGE, added);
	}
	
	function MainLoop(event : Event)
	{
		var time : Float = Lib.getTimer();
		var deltaTime : Float = time - lastTime;
		lastTime = time;
		
		ScreenManager.Update(deltaTime);
		ScreenManager.Draw(graphics);
	}
	
	public function Exit()
	{
		ScreenManager.Destroy();
		#if flash
		
		#else
		Lib.exit();
		#end
	}

	function added(e) 
	{
		removeEventListener(Event.ADDED_TO_STAGE, added);
		stage.addEventListener(Event.RESIZE, resize);
		#if ios
		haxe.Timer.delay(init, 100); // iOS 6
		#else
		init();
		#end
	}
	
	public static function main() 
	{
		// static entry point
		Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		Lib.current.addChild(new Main());
	}
}
