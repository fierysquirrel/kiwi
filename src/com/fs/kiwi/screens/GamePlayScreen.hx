package com.fs.kiwi.screens;

import aze.display.TileSprite;
import com.fs.kiwi.GameObject;
import flash.display.Graphics;
import fs.screenmanager.GameScreen;
import aze.display.SparrowTilesheet;
import flash.display.BitmapData;
import aze.display.TileLayer;
import openfl.Assets;
import com.fs.kiwi.characters.Player;
import com.fs.kiwi.items.Kiwi;
import com.fs.kiwi.mapobjects.Platform;
import com.fs.kiwi.mapobjects.Spike;
import com.fs.kiwi.mapobjects.Cannon;
import flash.ui.Keyboard;

/**
 * ...
 * @author Fiery Squirrel
 */
class GamePlayScreen extends GameScreen
{
	private var isDrawingGrid : Bool = true;
	private var level : Array<Array<String>>;
	private var tilelayer : TileLayer;
	
	private var player : Player;
	
	public function new() 
	{
		super();
		
		//Grid
		if (isDrawingGrid)
			DrawGrid();
	}
	
	override public function LoadContent():Void 
	{
		super.LoadContent();
		
		var tilesheet : SparrowTilesheet;
		var bitmapData : BitmapData;
		var xml : String;
		
		layers = new Map<String,TileLayer>();
		xml = Assets.getText(Globals.SPRITES_PATH + "spritesheet.xml");
		bitmapData = Assets.getBitmapData(Globals.SPRITES_PATH + "spritesheet.png");
		
		tilesheet = new SparrowTilesheet(bitmapData, xml);
		tilelayer = new TileLayer(tilesheet);
		
		layers.set("1", tilelayer);
		
		addChild(tilelayer.view);
		
		//Level
		InitLevel();
	}
	
	override public function Update(gameTime:Float):Void 
	{
		super.Update(gameTime);
		
		player.Update(gameTime);
	}
	
	override public function Draw(graphics:Graphics):Void 
	{
		super.Draw(graphics);
		
		for (l in layers)
			l.render();
	}
	
	private function DrawGrid() : Void
	{
		var gridSepX, gridSepY : Float;
		
		gridSepX = Globals.SCREEN_WIDTH / Globals.NUMBER_GRID_SQUARES_X;
		gridSepY = Globals.SCREEN_HEIGHT / Globals.NUMBER_GRID_SQUARES_Y;
		
		//vertical lines
		for (i in 0...Globals.NUMBER_GRID_SQUARES_X)
		{
			graphics.lineStyle(Globals.GRID_LINE_THICK,Globals.GRID_LINE_COLOR,Globals.GRID_LINE_ALPHA);
			graphics.moveTo(i * gridSepX,0);
			graphics.lineTo(i * gridSepX,Globals.SCREEN_HEIGHT);
		}
		
		//horizontal lines
		for (i in 0...Globals.NUMBER_GRID_SQUARES_Y)
		{
			graphics.lineStyle(Globals.GRID_LINE_THICK,Globals.GRID_LINE_COLOR,Globals.GRID_LINE_ALPHA);
			graphics.moveTo(0,i * gridSepY);
			graphics.lineTo(Globals.SCREEN_WIDTH,i * gridSepY);
		}
	}
	
	
	/*
	 * (Element Type, Rotation)
	 * 
	 * Type
	 * 0: none
	 * 1: player
	 * Rotation
	 * 0: none
	 * 1: 90
	 * 2: 180
	 * 3: 270
	 * */
	private function InitLevel() : Void
	{
		var type, rotation : String;
		var kiwi : Kiwi;
		var gameObject : GameObject;
		
		level = [["00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00"],
				 ["00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00"],
				 ["00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00"],
				 ["00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00"],
				 ["00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00"],
				 ["00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00"],
				 ["00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00"],
				 ["00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00"],
				 ["00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00"],
				 ["00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00"],
				 ["00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00"],
				 ["00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00"],
				 ["00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00"],
				 ["00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "20", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00"],
				 ["00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00"],
				 ["00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00"],
				 ["00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00"],
				 ["00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00"],
				 ["00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00"],
				 ["00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00"],
				 ["00", "10", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00"],
				 ["30", "30", "30", "40", "40", "30", "50", "30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00"],
				 ["00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00"],
				 ["00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00"],
				 ["00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00"],
				 ["00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00"],
				 ["00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00"],
				 ["00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00"]];
		
		
		for (i in 0...Globals.NUMBER_GRID_SQUARES_X)
		{
			for (j in 0...Globals.NUMBER_GRID_SQUARES_Y)
			{
				type = level[j][i].charAt(0);
				rotation = level[j][i].charAt(1);
				
				gameObject = null;
				switch(type)
				{
					case Player.TYPE:
						player = new Player(i, j);
						player.LoadContent(tilelayer);
					case Kiwi.TYPE:
						gameObject = new Kiwi(rotation, i, j);
					case Platform.TYPE:
						gameObject = new Platform(rotation, i, j);
					case Spike.TYPE:
						gameObject = new Spike(rotation, i, j);
					case Cannon.TYPE:
						gameObject = new Cannon(rotation, i, j);
					default:
				}
				
				if(gameObject != null)
					gameObject.LoadContent(tilelayer);
			}
		}
	}
	
	override public function HandleKeyDownEvent(key:UInt):Void 
	{
		super.HandleKeyDownEvent(key);
		
		switch(key)
		{
			case Keyboard.RIGHT:
				player.Move(Globals.PLAYER_SPEED);
			case Keyboard.LEFT:
				player.Move( -Globals.PLAYER_SPEED);
			case Keyboard.UP:
				player.Jump(Globals.PLAYER_JUMP_IMP);
		}
	}
	
	override public function HandleKeyUpEvent(key:UInt):Void 
	{
		super.HandleKeyUpEvent(key);
		
		switch(key)
		{
			case Keyboard.RIGHT:
				player.Stop();
			case Keyboard.LEFT:
				player.Stop();
		}
	}
}