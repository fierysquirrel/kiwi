package com.fs.kiwi.characters;

import aze.display.behaviours.TileGroupTransform;
import aze.display.TileLayer;
import com.fs.kiwi.GameObject;
import aze.display.TileSprite;
import com.fs.kiwi.animation.Animation2D;
import aze.display.TileGroup;
import com.fs.kiwi.mapobjects.Platform;
import com.fs.kiwi.mapobjects.Empty;
import com.fs.kiwi.sound.Sound;
import flash.geom.Point;
import com.fs.kiwi.items.Kiwi;

enum State
{
	Fall;
	Jump;
	Walk;
	Idle;
}

enum MoveDir
{
	Right;
	Left;
}

enum GravityDir
{
	Up;
	Down;
	Right;
	Left;
}
	
/**
 * ...
 * @author Fiery Squirrel
 */
class Player extends GameObject
{
	public static var TYPE = "1";
	
	public static var ANIM_IDLE = "kiwi-idle";
	public static var ANIM_BREATHE = "kiwi-breathe";
	public static var ANIM_BLINK = "kiwi-blink";
	public static var ANIM_WALK = "kiwi-walk";
	public static var ANIM_START_JUMP = "kiwi-start-jump";
	public static var ANIM_JUMP_UP = "kiwi-jump-up";
	public static var ANIM_JUMP_DOWN = "kiwi-jump-down";
	
	private var state : State;
	private var velX : Float;
	private var velY : Float;
	private var accX : Float;
	private var accY : Float;
	private var animation : TileGroup;
	private var animations : Map<String,Animation2D>;
	private var currentAnimation : String;
	private var animationTransformation : TileGroupTransform;
	private var jumpImpulse : Float;
	private var direction : MoveDir;
	private var gravityDir : GravityDir;
	private var prevGridX : Int;
	private var prevGridY : Int;
	
	private var rightAhead : GravityDir;
	private var leftAhead : GravityDir;
	private var level : Array<Array<GameObject>>;
	private var lives : Int = 3;
	private var isHit : Bool;
	private var hitTimer : Float;
	private var hitTime : Float = 3;
	private var alpha : Float;
	
	private var soundJump : Sound;
	private var soundHit : Sound;
	private var soundGameover : Sound;
	
	public function new(gridX:Int, gridY:Int, level : Array<Array<GameObject>>) 
	{
		super(TYPE, Globals.ROTATION_0, gridX, gridY);
		
		velX = 0;
		velY = 0;
		accX = 0;
		accY = Globals.GRAVITY;
		
		animations = new Map<String,Animation2D>();
		currentAnimation = "";
		state = State.Fall;
		direction = MoveDir.Right;
		gravityDir = GravityDir.Down;
		rightAhead = GravityDir.Down;
		leftAhead = GravityDir.Down;
		prevGridX = gridX;
		prevGridY = gridY;
		this.level = level;
		isHit = false;
		hitTimer = 0;
		alpha = 1;
	}
	
	override public function Reset():Void 
	{
		super.Reset();
		
		velX = 0;
		velY = 0;
		accX = 0;
		accY = Globals.GRAVITY;
		
		gridX = cast((x - Globals.GRID_SEP_X / 2) / Globals.GRID_SEP_X, Int);
		gridY = cast((y - Globals.GRID_SEP_Y / 2) / Globals.GRID_SEP_Y, Int);
		
		state = State.Fall;
		direction = MoveDir.Right;
		ChangeGravityDir(GravityDir.Down);
		prevGridX = gridX;
		prevGridY = gridY;
	}
	
	public function GetLives() : Int
	{
		return lives;
	}
	
	override public function LoadContent(tileLayer:TileLayer) 
	{
		super.LoadContent(tileLayer);
		
		var anim : Animation2D;
		
		//Idle
		animation = new TileGroup(tileLayer);
		anim = Helper.CreateAnimation(tileLayer, ANIM_IDLE, ANIM_IDLE, [], 1, AnimationType.OneWay, Direction.Forward);
		animations.set(ANIM_IDLE, anim);
		
		//Breathe
		animation = new TileGroup(tileLayer);
		anim = Helper.CreateAnimation(tileLayer, ANIM_BREATHE, ANIM_BREATHE, [0,1,2], 5, AnimationType.Loop, Direction.Forward);
		animations.set(ANIM_BREATHE, anim);
		
		//Blink
		animation = new TileGroup(tileLayer);
		anim = Helper.CreateAnimation(tileLayer, ANIM_BLINK, ANIM_BLINK, [0,1,2,3], 5, AnimationType.Loop, Direction.Forward);
		animations.set(ANIM_BLINK, anim);
		
		//Walk
		animation = new TileGroup(tileLayer);
		anim = Helper.CreateAnimation(tileLayer, ANIM_WALK, ANIM_WALK, [0,1,2,3,4,5], 20, AnimationType.Loop, Direction.Forward);
		animations.set(ANIM_WALK, anim);
		
		//Start Jump
		animation = new TileGroup(tileLayer);
		anim = Helper.CreateAnimation(tileLayer, ANIM_START_JUMP, ANIM_START_JUMP, [0,1,2], 10, AnimationType.OneWay, Direction.Forward);
		animations.set(ANIM_START_JUMP, anim);
		
		//Jump Up
		animation = new TileGroup(tileLayer);
		anim = Helper.CreateAnimation(tileLayer, ANIM_JUMP_UP, ANIM_JUMP_UP, [0,1], 5, AnimationType.Loop, Direction.Forward);
		animations.set(ANIM_JUMP_UP, anim);
		
		//Jump Down
		animation = new TileGroup(tileLayer);
		anim = Helper.CreateAnimation(tileLayer, ANIM_JUMP_DOWN, ANIM_JUMP_DOWN, [0,1], 5, AnimationType.Loop, Direction.Forward);
		animations.set(ANIM_JUMP_DOWN, anim);
		
		//Add frames
		for (a in animations)
		{
			for (f in a.GetFrames())
				animation.addChild(f);
		}
		
		animation.x = x;
		animation.y = y;
		tileLayer.addChild(animation);
		
		animationTransformation = new TileGroupTransform(animation);
		
		ChangeAnimation(ANIM_IDLE);
		
		soundHit = new Sound(Globals.SOUND_HIT,false);
		soundJump = new Sound(Globals.SOUND_JUMP,false);
		soundGameover = new Sound(Globals.SOUND_GAMEOVER,false);
	}
	
	override public function Update(gameTime:Float):Void 
	{
		super.Update(gameTime);
		
		var plat : Platform;
		var rightDownObj, rightUpObj, leftDownObj, leftUpObj : GameObject;
		
		velX += accX;
		velY += accY;
		x += velX;
		y += velY;
		
		animation.x = x;
		animation.y = y;
		
		rightDownObj = level[Globals.NUMBER_GRID_SQUARES_X - 1][Globals.NUMBER_GRID_SQUARES_Y - 1];
		rightUpObj = level[Globals.NUMBER_GRID_SQUARES_X - 1][0];
		leftDownObj = level[0][Globals.NUMBER_GRID_SQUARES_Y - 1];
		leftUpObj = level[0][0];
		
		
		gridX = cast((x - Globals.GRID_SEP_X / 2) / Globals.GRID_SEP_X, Int);
		gridY = cast((y - Globals.GRID_SEP_Y / 2) / Globals.GRID_SEP_Y, Int);
		
		plat = null;
		if ((prevGridX != gridX || prevGridY != gridY) && state == State.Walk)
		{
			if (level[gridX][gridY].GetType() == Kiwi.TYPE)
				cast(level[gridX][gridY], Kiwi).Pick();
				
			switch(direction)
			{
				case MoveDir.Right:
						
					switch(gravityDir)
					{
						case GravityDir.Down:
							if (x + width / 2 >= rightDownObj.GetX() - rightDownObj.GetW() / 2)
							{
								plat = cast(rightDownObj, Platform);
								rightAhead = GravityDir.Right;
							}
							else
								rightAhead = GravityDir.Down;
						case GravityDir.Left:
							if (y + height / 2 >= leftDownObj.GetY() - leftDownObj.GetH() / 2)
							{
								plat = cast(leftDownObj, Platform);
								rightAhead = GravityDir.Down;
							}
							else
								rightAhead = GravityDir.Left;
						case GravityDir.Right:
							if (y - height / 2 <= rightUpObj.GetY() + rightUpObj.GetH() / 2)
							{
								plat = cast(rightUpObj, Platform);
								rightAhead = GravityDir.Up;
							}
							else
								rightAhead = GravityDir.Right;
						case GravityDir.Up:
							if (x - width / 2 <= leftUpObj.GetX() + leftUpObj.GetW() / 2)
							{
								plat = cast(leftUpObj, Platform);
								rightAhead = GravityDir.Left;
							}
							else
								rightAhead = GravityDir.Up;
					}
					
					if (gravityDir != rightAhead)
					{
						if(gravityDir == GravityDir.Down || gravityDir == GravityDir.Up)
							velX = 0;
						if(gravityDir == GravityDir.Right || gravityDir == GravityDir.Left)
							velY = 0;
							
						ChangeGravityDir(rightAhead);
						
						MoveRight(level);
						if (plat != null)
						{
							switch(gravityDir)
							{
								case GravityDir.Down:
									y = plat.GetY() - height / 2 - plat.GetH() / 2;
									x = plat.GetX();
								case GravityDir.Up:
									y = plat.GetY() + height / 2 + plat.GetH() / 2;
									x = plat.GetX();
								case GravityDir.Left:
									x = plat.GetX() + width / 2 + plat.GetW() / 2;
									y = plat.GetY();
								case GravityDir.Right:
									x = plat.GetX() - width / 2 - plat.GetW() / 2;
									y = plat.GetY();
							}
						}
					}
				case MoveDir.Left:
					
					switch(gravityDir)
					{
						case GravityDir.Down:
							if (x - width / 2 <= leftDownObj.GetX() + leftDownObj.GetW() / 2)
							{
								leftAhead = GravityDir.Left;
								plat = cast(leftDownObj, Platform);
							}
							else
								leftAhead = GravityDir.Down;
						case GravityDir.Left:
							if (y - width / 2 <= leftUpObj.GetY() + leftUpObj.GetH() / 2)
							{
								leftAhead = GravityDir.Up;
								plat = cast(leftUpObj, Platform);
							}
							else
								leftAhead = GravityDir.Left;
						case GravityDir.Right:
							if (y + width / 2 >= rightDownObj.GetY() - rightDownObj.GetH() / 2)
							{
								leftAhead = GravityDir.Down;
								plat = cast(rightDownObj, Platform);
							}
							else
								leftAhead = GravityDir.Right;
						case GravityDir.Up:
							if (x + width / 2 >= rightUpObj.GetX() - rightUpObj.GetW() / 2)
							{
								plat = cast(rightUpObj, Platform);
								leftAhead = GravityDir.Right;
							}
							else
								leftAhead = GravityDir.Up;
					}
					
					if (gravityDir != leftAhead)
					{
						if(gravityDir == GravityDir.Down || gravityDir == GravityDir.Up)
							velX = 0;
						if(gravityDir == GravityDir.Right || gravityDir == GravityDir.Left)
							velY = 0;
							
						ChangeGravityDir(leftAhead);
						
						MoveLeft(level);
						if (plat != null)
						{
							switch(gravityDir)
							{
								case GravityDir.Down:
									y = plat.GetY() - height / 2 - plat.GetH() / 2;
									x = plat.GetX();
								case GravityDir.Up:
									y = plat.GetY() + height / 2 + plat.GetH() / 2;
									x = plat.GetX();
								case GravityDir.Left:
									x = plat.GetX() + width / 2 + plat.GetW() / 2;
									y = plat.GetY();
								case GravityDir.Right:
									x = plat.GetX() - width / 2 - plat.GetW() / 2;
									y = plat.GetY();
							}
						}
					}
			}
				
			prevGridX = gridX;
			prevGridY = gridY;
		}
		
		//Constraints
		if (x - width / 2 < level[0][Globals.NUMBER_GRID_SQUARES_Y - 1].GetX() + level[0][Globals.NUMBER_GRID_SQUARES_Y - 1].GetW() / 2)
			x = level[0][Globals.NUMBER_GRID_SQUARES_Y - 1].GetX() + level[0][Globals.NUMBER_GRID_SQUARES_Y - 1].GetW() / 2 + width / 2;
		
		if (x + width / 2 > level[Globals.NUMBER_GRID_SQUARES_X - 1][Globals.NUMBER_GRID_SQUARES_Y - 1].GetX() - level[Globals.NUMBER_GRID_SQUARES_X - 1][Globals.NUMBER_GRID_SQUARES_Y - 1].GetW() / 2)
			x = level[Globals.NUMBER_GRID_SQUARES_X - 1][Globals.NUMBER_GRID_SQUARES_Y - 1].GetX() - level[Globals.NUMBER_GRID_SQUARES_X - 1][Globals.NUMBER_GRID_SQUARES_Y - 1].GetW() / 2 - width / 2;
		
		if (y + height / 2 > level[Globals.NUMBER_GRID_SQUARES_X - 1][Globals.NUMBER_GRID_SQUARES_Y - 1].GetY() - level[Globals.NUMBER_GRID_SQUARES_X - 1][Globals.NUMBER_GRID_SQUARES_Y - 1].GetH() / 2)
			y = level[Globals.NUMBER_GRID_SQUARES_X - 1][Globals.NUMBER_GRID_SQUARES_Y - 1].GetY() - level[Globals.NUMBER_GRID_SQUARES_X - 1][Globals.NUMBER_GRID_SQUARES_Y - 1].GetH() / 2 - height / 2;
		
		if (y - height / 2 < level[Globals.NUMBER_GRID_SQUARES_X - 1][0].GetY() + level[Globals.NUMBER_GRID_SQUARES_X - 1][0].GetH() / 2)
			y = level[Globals.NUMBER_GRID_SQUARES_X - 1][0].GetY() + level[Globals.NUMBER_GRID_SQUARES_X - 1][0].GetH() / 2 + height / 2;
			
		//Rotation
		switch(rotation)
		{
			case Globals.ROTATION_0:
				animations.get(currentAnimation).Rotate(0);
			case Globals.ROTATION_90:
				animations.get(currentAnimation).Rotate(Math.PI/2);
			case Globals.ROTATION_180:
				animations.get(currentAnimation).Rotate(Math.PI);
			case Globals.ROTATION_270:
				animations.get(currentAnimation).Rotate(Math.PI + Math.PI/2);
		}
		
		//FLip
		switch(direction)
		{
			case MoveDir.Left:
				animations.get(currentAnimation).ScaleX(-1);
			case MoveDir.Right:
				animations.get(currentAnimation).ScaleX(1);
		}
		
		for (a in animations)
			a.Update(gameTime);
			
		if (isHit)
		{
			if (hitTimer > Helper.ConvertSecToMillisec(hitTime))
			{
				isHit = false;
				alpha = 1;
				hitTimer = 0;
			}
			else
				hitTimer += gameTime;
		}
		
		animations.get(currentAnimation).ChangeAlpha(alpha);
	}
	
	public function IsHit() : Bool
	{
		return isHit;
	}
	
	public function GetVelX() : Float
	{
		return velX;
	}
	
	public function GetVelY() : Float
	{
		return velY;
	}
	
	public function GetState() : State
	{
		return state;
	}
	
	private function ChangeGravityDir(dir : GravityDir) : Void
	{
		gravityDir = dir;
		
		switch(dir)
		{
			case GravityDir.Down:
				rotation = Globals.ROTATION_0;
			case GravityDir.Up:
				rotation = Globals.ROTATION_180;
			case GravityDir.Right:
				rotation = Globals.ROTATION_270;
			case GravityDir.Left:
				rotation = Globals.ROTATION_90;
		}
	}
	
	override public function HandlePhysics(level:Array<Array<GameObject>>):Void 
	{
		super.HandlePhysics(level);
		
		var plat : Platform;
		if (state == State.Fall)
		{
			switch(gravityDir)
			{
				case GravityDir.Down:
					
						//Down Collision
						if (velY >= 0)
						{
							if (gridY + 1 < Globals.NUMBER_GRID_SQUARES_Y)
							{	
								if (level[gridX][gridY + 1].GetType() == Platform.TYPE)
								{
									plat = cast(level[gridX][gridY + 1], Platform);
									if (x + width / 2 >= plat.GetX() - plat.GetW() / 2 && x - width / 2 <= plat.GetX() + plat.GetW() / 2)
									{
										if (y + velY + height/2 >= plat.GetY() - plat.GetH()/2)
										{
											state = State.Walk;
											if(velX == 0)
												ChangeAnimation(ANIM_IDLE);
											y = plat.GetY() - height/2 - plat.GetH()/2;
											accY = 0;
											velY = 0;
										}
									}
								}
							}
						}
						
						//Up Collision
						if (velY <= 0)
						{
							if (gridY - 1 >= 0)
							{	
								if (level[gridX][gridY - 1].GetType() == Platform.TYPE)
								{
									plat = cast(level[gridX][gridY - 1], Platform);
									if (x + width / 2 >= plat.GetX() - plat.GetW() / 2 && x - width / 2 <= plat.GetX() + plat.GetW() / 2)
									{
										if (y + velY - height/2 <= plat.GetY() + plat.GetH()/2)
										{
											y = plat.GetY() + height/2 + plat.GetH()/2;
											velY = 0;
										}
									}
								}
							}
						}
				case GravityDir.Left:
					//Down Collision
					if (velX <= 0)
					{
						if (gridX - 1 >= 0)
						{	
							if (level[gridX - 1][gridY].GetType() == Platform.TYPE)
							{
								plat = cast(level[gridX - 1][gridY], Platform);
								if (y + height / 2 >= plat.GetY() - plat.GetH() / 2 && y - height / 2 <= plat.GetY() + plat.GetH() / 2)
								{
									if (x + velX - width/2 <= plat.GetX() + plat.GetW()/2)
									{
										state = State.Walk;
										if(velY == 0)
											ChangeAnimation(ANIM_IDLE);
										x = plat.GetX() + width/2 + plat.GetW()/2;
										accX = 0;
										velX = 0;
									}
								}
							}
						}
					}
					
					//Up Collision
					if (velX >= 0)
					{
						if (gridX + 1 <= 0)
						{	
							if (level[gridX + 1][gridY].GetType() == Platform.TYPE)
							{
								plat = cast(level[gridX + 1][gridY], Platform);
								if (y + height / 2 >= plat.GetY() - plat.GetH() / 2 && y - height / 2 <= plat.GetY() + plat.GetH() / 2)
								{
									if (x + velX + width/2 >= plat.GetX() - plat.GetW()/2)
									{
										x = plat.GetX() - width/2 - plat.GetW()/2;
										velX = 0;
									}
								}
							}
						}
					}
				case GravityDir.Right:
					//Down Collision
					if (velX >= 0)
					{
						if (gridX + 1 < Globals.NUMBER_GRID_SQUARES_X)
						{	
							if (level[gridX + 1][gridY].GetType() == Platform.TYPE)
							{
								plat = cast(level[gridX + 1][gridY], Platform);
								if (y + height / 2 >= plat.GetY() - plat.GetH() / 2 && y - height / 2 <= plat.GetY() + plat.GetH() / 2)
								{
									if (x + velX + width/2 >= plat.GetX() - plat.GetW()/2)
									{
										state = State.Walk;
										if(velY == 0)
											ChangeAnimation(ANIM_IDLE);
										x = plat.GetX() - width/2 - plat.GetW()/2;
										accX = 0;
										velX = 0;
									}
								}
							}
						}
					}
					
					//Up Collision
					if (velX <= 0)
					{
						if (gridX - 1 >= 0)
						{	
							if (level[gridX - 1][gridY].GetType() == Platform.TYPE)
							{
								plat = cast(level[gridX - 1][gridY], Platform);
								if (y + height / 2 >= plat.GetY() - plat.GetH() / 2 && y - height / 2 <= plat.GetY() + plat.GetH() / 2)
								{
									if (x + velX - width/2 <= plat.GetX() + plat.GetW()/2)
									{
										x = plat.GetX() + width/2 + plat.GetW()/2;
										velX = 0;
									}
								}
							}
						}
					}
				case GravityDir.Up:
					//Down Collision
					if (velY <= 0)
					{
						if (gridY - 1 >= 0)
						{	
							if (level[gridX][gridY - 1].GetType() == Platform.TYPE)
							{
								plat = cast(level[gridX][gridY - 1], Platform);
								if (x + width / 2 >= plat.GetX() - plat.GetW() / 2 && x - width / 2 <= plat.GetX() + plat.GetW() / 2)
								{
									if (y + velY - height/2 <= plat.GetY() + plat.GetH()/2)
									{
										state = State.Walk;
										if(velX == 0)
											ChangeAnimation(ANIM_IDLE);
										y = plat.GetY() + height/2 + plat.GetH()/2;
										accY = 0;
										velY = 0;
									}
								}
							}
						}
					}
					
					//Up Collision
					if (velY >= 0)
					{
						if (gridY + 1 <= 0)
						{	
							if (level[gridX][gridY + 1].GetType() == Platform.TYPE)
							{
								plat = cast(level[gridX][gridY + 1], Platform);
								if (x + width / 2 >= plat.GetX() - plat.GetW() / 2 && x - width / 2 <= plat.GetX() + plat.GetW() / 2)
								{
									if (y + velY + height/2 >= plat.GetY() - plat.GetH()/2)
									{
										y = plat.GetY() - height/2 - plat.GetH()/2;
										velY = 0;
									}
								}
							}
						}
					}
			}
		}
	}
	
	public function Hit() : Void
	{
		alpha = 0.5;
		lives--;
		isHit = true;
		if(lives > 0)
			soundHit.Play();
		else
			soundGameover.Play();
	}
	
	public function MoveRight(level : Array<Array<GameObject>>) : Void
	{	
		if (state == State.Walk)
		{
			direction = MoveDir.Right;
			ChangeAnimation(ANIM_WALK);
			
			switch(gravityDir)
			{
				case GravityDir.Down:
					velX = Globals.PLAYER_SPEED;
				case GravityDir.Left:
					velY = Globals.PLAYER_SPEED;
				case GravityDir.Right:
					velY = -Globals.PLAYER_SPEED;
				case GravityDir.Up:
					velX = -Globals.PLAYER_SPEED;
			}
		}
	}
	
	public function MoveLeft(level : Array<Array<GameObject>>) : Void
	{	
		if (state == State.Walk)
		{
			direction = MoveDir.Left;
			ChangeAnimation(ANIM_WALK);
			
			switch(gravityDir)
			{
				case GravityDir.Down:
					velX = -Globals.PLAYER_SPEED;
				case GravityDir.Left:
					velY = -Globals.PLAYER_SPEED;
				case GravityDir.Right:
					velY = Globals.PLAYER_SPEED;
				case GravityDir.Up:
					velX = Globals.PLAYER_SPEED;
			}
		}
	}
	
	public function Stop() : Void
	{
		switch(gravityDir)
		{
			case GravityDir.Down:
				velX = 0;
			case GravityDir.Up:
				velX = 0;
			case GravityDir.Right:
				velY = 0;
			case GravityDir.Left:
				velY = 0;
		}
		
		ChangeAnimation(ANIM_IDLE);
	}
	
	public function Jump(level : Array<Array<GameObject>>) : Void
	{
		if (state == State.Walk)
		{
			switch(gravityDir)
			{
				case GravityDir.Down:
					velY = -Globals.PLAYER_JUMP_IMP;
					accY = Globals.GRAVITY;
				case GravityDir.Up:
					velY = Globals.PLAYER_JUMP_IMP;
					accY = -Globals.GRAVITY;
				case GravityDir.Left:
					velX = Globals.PLAYER_JUMP_IMP;
					accX = -Globals.GRAVITY;
				case GravityDir.Right:
					velX = -Globals.PLAYER_JUMP_IMP;
					accX = Globals.GRAVITY;
			}
			
			state = State.Fall;
			soundJump.Play();
		}
	}
	
	
	public function ChangeAnimation(anim : String) : Void
	{
		if (currentAnimation != "")
			animations.get(currentAnimation).Off();
		
		currentAnimation = anim;
		animations.get(currentAnimation).On();
		//FLip
		switch(direction)
		{
			case MoveDir.Left:
				animations.get(currentAnimation).ScaleX(-1);
			case MoveDir.Right:
				animations.get(currentAnimation).ScaleX(1);
		}
	}
}