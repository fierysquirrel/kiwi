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
import com.fs.kiwi.mapobjects.Empty;

/**
 * ...
 * @author Fiery Squirrel
 */
class GamePlayScreen extends GameScreen
{
	private var isDebugging : Bool = false;
	//private var level : Array<Array<String>>;
	private var level : Array<Array<GameObject>>;
	private var tilelayer : TileLayer;
	
	private var player : Player;
	
	public function new() 
	{
		super();
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
		
		HandlePhysics();
		
		if (isDebugging)
		{
			graphics.clear();
			DrawGrid();
			DrawPlayerFrame(player.GetGridX(),player.GetGridY());
		}
	}
	
	private function HandlePhysics() : Void
	{
		player.HandlePhysics(level);
		/*if (player.GetState() == State.Fall && player.GetVelY() > 0)
		{
			if (player.GetGridX() >= 0 && player.GetGridX() < Globals.NUMBER_GRID_SQUARES_X && player.GetGridY() >= 0 && player.GetGridY() < Globals.NUMBER_GRID_SQUARES_Y)
			{
				//if (Helper.GetLevelType(level,player.GetGridX(),player.GetGridY()) == Platform.TYPE)
					//player.StopFalling();
			}
		}*/
	}
	
	override public function Draw(graphics:Graphics):Void 
	{
		super.Draw(graphics);
		
		for (l in layers)
			l.render();
	}
	
	private function DrawGrid() : Void
	{
		//vertical lines
		for (i in 0...Globals.NUMBER_GRID_SQUARES_X)
		{
			graphics.lineStyle(Globals.GRID_LINE_THICK,Globals.GRID_LINE_COLOR,Globals.GRID_LINE_ALPHA);
			graphics.moveTo(i * Globals.GRID_SEP_X,0);
			graphics.lineTo(i * Globals.GRID_SEP_X,Globals.SCREEN_HEIGHT);
		}
		
		//horizontal lines
		for (i in 0...Globals.NUMBER_GRID_SQUARES_Y)
		{
			graphics.lineStyle(Globals.GRID_LINE_THICK,Globals.GRID_LINE_COLOR,Globals.GRID_LINE_ALPHA);
			graphics.moveTo(0,i * Globals.GRID_SEP_Y);
			graphics.lineTo(Globals.SCREEN_WIDTH,i * Globals.GRID_SEP_Y);
		}
	}
	
	private function DrawPlayerFrame(i : Int, j : Int) : Void
	{
		var iniX, iniY : Float;
		
		iniX = i * Globals.GRID_SEP_X;
		iniY = j * Globals.GRID_SEP_Y;
		
		
		graphics.lineStyle(Globals.FRAME_LINE_THICK, Globals.FRAME_LINE_COLOR, Globals.FRAME_LINE_ALPHA);
		//Up
		graphics.moveTo(iniX,iniY);
		graphics.lineTo(iniX + Globals.GRID_SEP_X, iniY);
		//Right
		graphics.moveTo(iniX + Globals.GRID_SEP_X, iniY);
		graphics.lineTo(iniX + Globals.GRID_SEP_X, iniY+ Globals.GRID_SEP_Y);
		//Down
		graphics.moveTo(iniX + Globals.GRID_SEP_X, iniY + Globals.GRID_SEP_Y);
		graphics.lineTo(iniX, iniY + Globals.GRID_SEP_Y);
		//Left
		graphics.moveTo(iniX, iniY + Globals.GRID_SEP_Y);
		graphics.lineTo(iniX,iniY);
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
		var level : Array<Array<String>>;
		
		level = [["30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "20", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "10", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "30", "30", "30", "30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "30", "40", "30", "30", "30", "30", "30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "30", "30", "30", "30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30"]];
		
		
		this.level = new Array<Array<GameObject>>();
		for (i in 0...Globals.NUMBER_GRID_SQUARES_X)
		{
			this.level[i] = new Array<GameObject>();
			
			//level = new Array<Array<String>>();
			for (j in 0...Globals.NUMBER_GRID_SQUARES_Y)
			{
				type = Helper.GetLevelType(level,i,j);
				rotation = Helper.GetLevelRotation(level,i,j);
				
				gameObject = null;
				switch(type)
				{
					case Player.TYPE:
						player = new Player(i, j);
					case Empty.TYPE:
						gameObject = new Empty(rotation, i, j);
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
					
				if(gameObject != null)	
					this.level[i][j] = gameObject;
			}
		}
		
		player.LoadContent(tilelayer);
	}
	
	override public function HandleKeyDownEvent(key:UInt):Void 
	{
		super.HandleKeyDownEvent(key);
		
		switch(key)
		{
			case Keyboard.RIGHT:
				player.MoveRight(level);
			case Keyboard.LEFT:
				player.MoveLeft(level);
				
			case Keyboard.UP:
				player.Jump(level);
			case Keyboard.DOWN:
				player.MoveDown(level);
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
			case Keyboard.R:
				player.Reset();
		}
	}
}