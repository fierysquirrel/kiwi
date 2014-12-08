package com.fs.kiwi.screens;

import aze.display.TileSprite;
import com.fs.kiwi.Color;
import com.fs.kiwi.GameObject;
import com.fs.kiwi.particlesystem.ParticleSystem;
import com.fs.kiwi.screens.GameOverScreen;
import com.fs.kiwi.sound.Sound;
import com.fs.kiwi.Text;
import flash.display.Graphics;
import flash.geom.Point;
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
import com.fs.kiwi.items.Item;
import fs.screenmanager.ScreenManager;

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
	private var bulletlayer : TileLayer;
	private var items : Array<Item>;
	private var cannons : Array<Cannon>;
	
	private var player : Player;
	
	private var rPressed : Bool;
	private var lPressed : Bool;
	
	private var kiwiTimer : Float;
	private var kiwiTime : Float;
	private var numberOfKiwis : Int;
	
	private var cannonTimer : Float;
	private var cannonTime : Float;
	
	private var kiwisText : Text;
	private var hudLifes : Array<TileSprite>;
	private var hudKiwi : TileSprite;
	private var tutMove : TileSprite;
	private var tutJump : TileSprite;
	private var prevLives : Int;
	
	private var soundtrack : Sound;
	
	private var particleSystem : ParticleSystem;
	
	public function new() 
	{
		super();
		rPressed = false;
		lPressed = false;
		
		kiwiTimer = 0;
		numberOfKiwis = 0;
		cannonTimer = 0;
		cannonTime = 30;
		
		particleSystem = new ParticleSystem();
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
		
		items = new Array<Item>();
		cannons = new Array<Cannon>();
		tilesheet = new SparrowTilesheet(bitmapData, xml);
		tilelayer = new TileLayer(tilesheet);
		bulletlayer = new TileLayer(tilesheet);
		
		layers.set("0", bulletlayer);
		layers.set("1", tilelayer);
		
		addChild(bulletlayer.view);
		addChild(tilelayer.view);
		
		//Level
		InitLevel();
		
		kiwiTime = 1 + Math.random() * 10;

		kiwisText = Helper.CreateText(Globals.FONT.fontName, "x " + numberOfKiwis, 15, 0xffffff, 1);
		kiwisText.x = 115;
		kiwisText.y = 73;
		kiwisText.alpha = 0.7;
		addChild(kiwisText);
		
		soundtrack = new Sound(Globals.SOUNDTRACK, true);
		soundtrack.Play();
		
		particleSystem.LoadContent(layers);
	}
	
	override public function Update(gameTime:Float):Void 
	{
		super.Update(gameTime);
		
		player.Update(gameTime);
		
		for (c in cannons)
			c.Update(gameTime);
			
		HandlePhysics();
		
		if (isDebugging)
		{
			graphics.clear();
			DrawGrid();
			DrawPlayerFrame(player.GetGridX(),player.GetGridY());
		}
		
		if (kiwiTimer > Helper.ConvertSecToMillisec(kiwiTime))
		{
			//trace("kiwi time!");
			
			
			switch(cast(1 + Math.random() * 4,Int))
			{
				case 1:
					AddKiwi(1, cast(1 + Math.random() * Globals.NUMBER_GRID_SQUARES_Y - 2,Int));
				case 2:
					AddKiwi(cast(1 + Math.random() * Globals.NUMBER_GRID_SQUARES_X - 2,Int), 1);
				case 3:
					AddKiwi(cast(1 + Math.random() * Globals.NUMBER_GRID_SQUARES_X - 2,Int),Globals.NUMBER_GRID_SQUARES_Y - 2);
				case 4:
					AddKiwi(Globals.NUMBER_GRID_SQUARES_X - 2, cast(1 + Math.random() * Globals.NUMBER_GRID_SQUARES_Y - 2,Int));
			}
			kiwiTimer = 0;
		}
		else
			kiwiTimer += gameTime;
			
		if (cannonTimer > Helper.ConvertSecToMillisec(cannonTime))
		{
			AddCannon(cast(5 + Math.random() * (Globals.NUMBER_GRID_SQUARES_X - 5),Int), cast(5 + Math.random() * (Globals.NUMBER_GRID_SQUARES_Y - 8),Int),cast(1 + Math.random() * 4,Int));
			cannonTimer = 0;
		}
		else
			cannonTimer += gameTime;
			
		for (i in items)
		{
			if (i.IsPicked())
			{
				RemoveItem(i);
				numberOfKiwis++;
				kiwisText.text = "x " + numberOfKiwis;
			}
		}
		
		if (player.GetLives() <= 0)
		{
			soundtrack.Stop();
			ScreenManager.LoadScreen(new GameOverScreen(numberOfKiwis));
		}
		else
		{
			if (prevLives != player.GetLives())
			{
				hudLifes[player.GetLives()].visible = false;
				prevLives = player.GetLives();
			}
		}
		
		soundtrack.Update(gameTime);
		particleSystem.Update(gameTime);
	}
	
	private function RemoveItem(i : Item) : Void
	{
		tilelayer.removeChild(i.GetSprite());
		level[i.GetGridX()][i.GetGridY()] = new Empty(Globals.ROTATION_0, i.GetGridX(),i.GetGridY());
		items.remove(i);
		
		particleSystem.GenerateParticles("1", ["particle-4"], 50, new Point(i.GetX(), i.GetY()), 1, "random", new Point(1 - 2 * Math.random(), 1 - 2 * Math.random()), new Point(), [new Color(255, 255, 255)], 1);
		particleSystem.GenerateParticles("1", ["particle-3"], 50, new Point(i.GetX(), i.GetY()), 1, "random", new Point(1 - 2*Math.random(),1 - 2*Math.random()), new Point(), [new Color(255,255,255)],1);
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
		var life : TileSprite;
		
		level = [["30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30", "30"],
				 ["30", "53", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "50", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "50", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "51", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "53", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "50", "00", "52", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "51", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "53", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "50", "00", "52", "00", "00", "00", "00", "00", "51", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "53", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "50", "00", "52", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "53", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "51", "00", "00", "50", "00", "52", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "53", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "51", "00", "00", "00", "00", "00", "00", "00", "00", "50", "00", "52", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "53", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "51", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "50", "00", "52", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "00", "00", "53", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "00", "51", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "52", "00", "30"],
				 ["30", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "30"],
				 ["30", "52", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "10", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "51", "30"],
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
						player = new Player(i, j, this.level);
						gameObject = new Empty(rotation, i, j);
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
						cast(gameObject, Cannon).SetBulletsLayer(bulletlayer);
						cast(gameObject, Cannon).SetLevel(this.level);
						cast(gameObject, Cannon).SetParticleSystem(particleSystem);
						
						cannons.push(cast(gameObject, Cannon));
					default:
				}
				
				if (gameObject != null)
				{
					if (gameObject.GetType() == Platform.TYPE)
						gameObject.LoadContent(bulletlayer);
					else
						gameObject.LoadContent(tilelayer);
				}
					
				if(gameObject != null)	
					this.level[i][j] = gameObject;
			}
		}
		
		player.LoadContent(tilelayer);
		
		for (c in cannons)
			c.SetPlayer(player);
		
		tutMove = new TileSprite(bulletlayer, "tut-move");
		tutMove.x = 300;
		tutMove.y = 600;
		tutMove.alpha = 0.7;
		bulletlayer.addChild(tutMove);
		
		tutJump = new TileSprite(bulletlayer, "tut-jump");
		tutJump.x = 370;
		tutJump.y = 600;
		tutJump.alpha = 0.7;
		bulletlayer.addChild(tutJump);
		
		hudKiwi = new TileSprite(bulletlayer, "hud-kiwi");
		hudKiwi.x = 100;
		hudKiwi.y = 80;
		hudKiwi.alpha = 0.7;
		bulletlayer.addChild(hudKiwi);
		hudLifes = new Array<TileSprite>();
		for (i in 0...player.GetLives())
		{
			life = new TileSprite(bulletlayer, "hud-life");
			life.x = 500 + 30 * i;
			life.y = 80;
			life.alpha = 0.7;
			bulletlayer.addChild(life);
			hudLifes.push(life);
		}
		
		prevLives = player.GetLives();
		
		AddKiwi(player.GetGridX() + 3,player.GetGridY());
	}
	
	private function AddKiwi(i : Int, j : Int) : Void
	{
		var kiwi : Kiwi;
		var rot : String;
		
		if (level[i][j].GetType() == Empty.TYPE)
		{
			rot = Globals.ROTATION_0;
			
			if (i == 1)
				rot = Globals.ROTATION_90;
			if (j == 1)
				rot = Globals.ROTATION_180;
			if (i == Globals.NUMBER_GRID_SQUARES_X - 2)
				rot = Globals.ROTATION_270;
			if (j == Globals.NUMBER_GRID_SQUARES_X - 2)
				rot = Globals.ROTATION_0;
			
			
			kiwi = new Kiwi(rot, i, j);
			kiwi.LoadContent(tilelayer);
				
			this.level[i][j] = kiwi;
			items.push(kiwi);
			kiwiTime = 1 + Math.random() * 10;
		}
	}
	
	private function AddCannon(i : Int, j : Int, r : Int) : Void
	{
		var cannon : Cannon;
		var rot : String;
		
		if (level[i][j].GetType() == Empty.TYPE)
		{
			rot = Globals.ROTATION_0;
			
			switch(r)
			{
				case 1:
					rot = Globals.ROTATION_0;
				case 2:
					rot = Globals.ROTATION_90;
				case 3:
					rot = Globals.ROTATION_180;
				case 4:
					rot = Globals.ROTATION_270;
			}
			
			cannon = new Cannon(rot, i, j);
			cannon.LoadContent(bulletlayer);
			cannon.SetBulletsLayer(bulletlayer);
			cannon.SetLevel(this.level);
			cannon.SetPlayer(player);
			cannon.SetParticleSystem(particleSystem);
			cannons.push(cast(cannon, Cannon));
						
			this.level[i][j] = cannon;
			
			//kiwiTime = 1 + Math.random() * 10;
		}
	}
	
	override public function HandleKeyDownEvent(key:UInt):Void 
	{
		super.HandleKeyDownEvent(key);
		
		switch(key)
		{
			case Keyboard.RIGHT:
				player.MoveRight(level);
				rPressed = true;
			case Keyboard.LEFT:
				player.MoveLeft(level);
				lPressed = true;
			case Keyboard.UP:
				player.Jump(level);
		}
	}
	
	override public function HandleKeyUpEvent(key:UInt):Void 
	{
		super.HandleKeyUpEvent(key);
		
		switch(key)
		{
			case Keyboard.RIGHT:
				if (rPressed)
				{
					player.Stop();
					rPressed = false;
				}
			case Keyboard.LEFT:
				if (lPressed)
				{
					player.Stop();
					lPressed = false;
				}
			//case Keyboard.R:
				//player.Reset();
		}
	}
}