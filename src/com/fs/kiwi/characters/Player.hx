package com.fs.kiwi.characters;

import aze.display.behaviours.TileGroupTransform;
import aze.display.TileLayer;
import com.fs.kiwi.GameObject;
import aze.display.TileSprite;
import com.fs.kiwi.animation.Animation2D;
import aze.display.TileGroup;
import com.fs.kiwi.mapobjects.Platform;

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
	
	public function new(gridX:Int, gridY:Int) 
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
		prevGridX = gridX;
		prevGridY = gridY;
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
	}
	
	override public function Update(gameTime:Float):Void 
	{
		super.Update(gameTime);
		
		velX += accX;
		velY += accY;
		x += velX;
		y += velY;
		
		animation.x = x;
		animation.y = y;
		
		gridX = cast((x - Globals.GRID_SEP_X / 2) / Globals.GRID_SEP_X, Int);
		gridY = cast((y - Globals.GRID_SEP_Y / 2) / Globals.GRID_SEP_Y, Int);
		
		switch(state)
		{
			case State.Walk:
			case State.Fall:
			case State.Idle:
			case State.Jump:
				if (animations.get(currentAnimation).HasEnded())
				{
					animations.get(currentAnimation).Restart();
					velY = jumpImpulse;
					accY = Globals.GRAVITY;
					ChangeAnimation(ANIM_JUMP_UP);
					state = State.Fall;
				}
		}
		
		//Rotation
		switch(rotation)
		{
			case Globals.ROTATION_0:
				animations.get(currentAnimation).Rotate(0);
			case Globals.ROTATION_90:
				animations.get(currentAnimation).Rotate(-(Math.PI + Math.PI/4));
			case Globals.ROTATION_180:
				animations.get(currentAnimation).Rotate(Math.PI);
			case Globals.ROTATION_270:
				animations.get(currentAnimation).Rotate(Math.PI + Math.PI/4);
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
		trace(dir);
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
	
	/*public function Move(speed : Float) : Void
	{	
		velX = speed;
		if (speed > 0)
			direction = MoveDir.Right;
		else
			direction = MoveDir.Left;
			
		if(state == State.Walk)
			ChangeAnimation(ANIM_WALK);
	}*/
	
	override public function HandlePhysics(level:Array<Array<GameObject>>):Void 
	{
		super.HandlePhysics(level);
		
		var plat : Platform;
		switch(gravityDir)
		{
			case GravityDir.Down:
				if (state == State.Fall)
				{
					//Down Collision
					if (velY >= 0)
					{
						if (gridY + 1 < Globals.NUMBER_GRID_SQUARES_Y)
						{	
							if (level[gridX][gridY + 1].GetType() == Platform.TYPE)
							{
								plat = cast(level[gridX][gridY + 1], Platform);
								if (y + velY + height/2 >= plat.GetY())
								{
									state = State.Walk;
									if(velX == 0)
										ChangeAnimation(ANIM_IDLE);
									y = plat.GetY() - height/2;
									accY = 0;
									velY = 0;
								}
							}
						}
					}
					
					if (velY <= 0)
					{
						//Up Collision
						if (gridY - 1 >= 0)
						{	
							if (level[gridX][gridY - 1].GetType() == Platform.TYPE)
							{
								plat = cast(level[gridX][gridY - 1], Platform);
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
			case GravityDir.Right:
			case GravityDir.Up:
		}
	}
	
	public function MoveRight(level : Array<Array<GameObject>>) : Void
	{	
		var newGridX, newGridY : Int;
		
		//x += 1;
		
		velX = Globals.PLAYER_SPEED;
		direction = MoveDir.Right;
		ChangeAnimation(ANIM_WALK);
		
		/*switch(gravityDir)
		{
			case GravityDir.Down:
				if (prevGridX == gridX)
				{
					//This is a platform, the next one is empty => out-corner (one platform)
					if (Helper.GetLevelType(level,gridX,gridY) == Platform.TYPE && Helper.GetLevelType(level,gridX + 1,gridY) == "0")
					{
						ChangeGravityDir(GravityDir.Left);
						velX = 0;
						velY = Globals.PLAYER_SPEED;
					}
					else
						velX = Globals.PLAYER_SPEED;
				}
				else
				{	
					//This is a platform, you are about to collide against a platform => in-corner
					if (Helper.GetLevelType(level,gridX ,gridY) == Platform.TYPE && Helper.GetLevelType(level,gridX,gridY - 1) == Platform.TYPE)
					{
						ChangeGravityDir(GravityDir.Right);
						velX = 0;
						velY = -Globals.PLAYER_SPEED;
					}
					//This is a platform, the next one is empty => out-corner
					else if (Helper.GetLevelType(level,gridX,gridY) == Platform.TYPE && Helper.GetLevelType(level,gridX + 1,gridY) == "0")
					{
						ChangeGravityDir(GravityDir.Left);
						velX = 0;
						velY = Globals.PLAYER_SPEED;
					}
					else
						velX = Globals.PLAYER_SPEED;
				}
			case GravityDir.Up:
				if (prevGridX == gridX)
				{
					//This is a platform, the next one is empty => out-corner (one platform)
					if (Helper.GetLevelType(level,gridX,gridY) == Platform.TYPE && Helper.GetLevelType(level,gridX - 1,gridY) == "0")
					{
						ChangeGravityDir(GravityDir.Right);
						velX = 0;
						velY = -Globals.PLAYER_SPEED;
					}
					else
						velX = -Globals.PLAYER_SPEED;
				}
				else
				{	
					//This is a platform, you are about to collide against a platform => in-corner
					if (Helper.GetLevelType(level,gridX ,gridY) == Platform.TYPE && Helper.GetLevelType(level,gridX,gridY + 1) == Platform.TYPE)
					{
						ChangeGravityDir(GravityDir.Left);
						velX = 0;
						velY = Globals.PLAYER_SPEED;
					}
					//This is a platform, the next one is empty => out-corner
					else if (Helper.GetLevelType(level,gridX,gridY) == Platform.TYPE && Helper.GetLevelType(level,gridX - 1,gridY) == "0")
					{
						ChangeGravityDir(GravityDir.Right);
						velX = 0;
						velY = -Globals.PLAYER_SPEED;
					}
					else
						velX = -Globals.PLAYER_SPEED;
				}
				
			case GravityDir.Right:
				if (prevGridY == gridY)
				{
					//This is a platform, the next one is empty => out-corner (one platform)
					if (Helper.GetLevelType(level,gridX,gridY) == Platform.TYPE && Helper.GetLevelType(level,gridX,gridY - 1) == "0")
					{
						ChangeGravityDir(GravityDir.Down);
						velY = 0;
						velX = Globals.PLAYER_SPEED;
					}
					else
						velY = -Globals.PLAYER_SPEED;
				}
				else
				{	
					//This is a platform, you are about to collide against a platform => in-corner
					if (Helper.GetLevelType(level,gridX,gridY) == Platform.TYPE && Helper.GetLevelType(level,gridX - 1,gridY) == Platform.TYPE)
					{
						ChangeGravityDir(GravityDir.Up);
						velX = -Globals.PLAYER_SPEED;
						velY = 0;
						
					}
					//This is a platform, the next one is empty => out-corner
					else if (Helper.GetLevelType(level,gridX,gridY) == Platform.TYPE && Helper.GetLevelType(level,gridX,gridY - 1) == "0")
					{
						ChangeGravityDir(GravityDir.Down);
						velY = 0;
						velX = Globals.PLAYER_SPEED;
					}
					else
						velY = -Globals.PLAYER_SPEED;
				}
			case GravityDir.Left:
				if (prevGridY == gridY)
				{
					//This is a platform, the next one is empty => out-corner (one platform)
					if (Helper.GetLevelType(level,gridX,gridY) == Platform.TYPE && Helper.GetLevelType(level,gridX,gridY + 1) == "0")
					{
						ChangeGravityDir(GravityDir.Up);
						velY = 0;
						velX = -Globals.PLAYER_SPEED;
					}
					else
						velY = Globals.PLAYER_SPEED;
				}
				else
				{	
					//This is a platform, you are about to collide against a platform => in-corner
					if (Helper.GetLevelType(level,gridX,gridY) == Platform.TYPE && Helper.GetLevelType(level,gridX + 1,gridY) == Platform.TYPE)
					{
						ChangeGravityDir(GravityDir.Down);
						velX = Globals.PLAYER_SPEED;
						velY = 0;
						
					}
					//This is a platform, the next one is empty => out-corner
					else if (Helper.GetLevelType(level,gridX,gridY) == Platform.TYPE && Helper.GetLevelType(level,gridX,gridY + 1) == "0")
					{
						ChangeGravityDir(GravityDir.Up);
						velY = 0;
						velX = -Globals.PLAYER_SPEED;
					}
					else
						velY = Globals.PLAYER_SPEED;
				}
		}*/
		
		prevGridX = gridX;
		prevGridY = gridY;
	}
	
	public function MoveLeft(level : Array<Array<GameObject>>) : Void
	{	
		velX = -Globals.PLAYER_SPEED;
		direction = MoveDir.Left;
		ChangeAnimation(ANIM_WALK);
		
		//x -= 1;
		/*switch(gravityDir)
		{
			case GravityDir.Down:
				velX = -Globals.PLAYER_SPEED;
			case GravityDir.Up:
				velX = Globals.PLAYER_SPEED;
			case GravityDir.Right:
				velY = Globals.PLAYER_SPEED;
			case GravityDir.Left:
				velY = -Globals.PLAYER_SPEED;
		}*/
	}
	
	public function MoveUp(level : Array<Array<GameObject>>) : Void
	{	
		y -= 1;
	}
	
	public function MoveDown(level : Array<Array<GameObject>>) : Void
	{	
		y += 1;
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
	
	public function StopFalling() : Void
	{
		velY = 0;
		accY = 0;
		//x = Globals.GRID_SEP_X/2 + Globals.GRID_SEP_X * gridX;
		//y = Globals.GRID_SEP_Y / 2 + Globals.GRID_SEP_Y * gridY - Globals.GRID_SEP_Y/2;
		state = State.Walk;
	}
	
	public function Jump(level : Array<Array<GameObject>>) : Void
	{
		if (state == State.Walk)
		{
			velY = -Globals.PLAYER_JUMP_IMP;
			accY = Globals.GRAVITY;
			state = State.Fall;
		}
		
		/*jumpImpulse = impulse;
		ChangeAnimation(ANIM_START_JUMP);
		state = State.Jump;*/
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