package com.fs.kiwi.characters;

import aze.display.behaviours.TileGroupTransform;
import aze.display.TileLayer;
import com.fs.kiwi.GameObject;
import aze.display.TileSprite;
import com.fs.kiwi.animation.Animation2D;
import aze.display.TileGroup;

enum State
{
	StartedJump;
	Fall;
	Jump;
	Walk;
	Idle;
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
	private var animation : TileGroup;
	private var animations : Map<String,Animation2D>;
	private var currentAnimation : String;
	private var animationTransformation : TileGroupTransform;
	private var scaleX : Float;
	private var startedJump : Bool;
	private var jumpImpulse : Float;
	
	public function new(gridX:Int, gridY:Int) 
	{
		super(TYPE, Globals.ROTATION_0, gridX, gridY);
		
		velX = 0;
		velY = 0;
		
		animations = new Map<String,Animation2D>();
		currentAnimation = "";
		scaleX =  1;
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
		anim = Helper.CreateAnimation(tileLayer, ANIM_START_JUMP, ANIM_START_JUMP, [0,1,2], 1, AnimationType.OneWay, Direction.Forward);
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
		
		x += velX;
		y += velY;
		
		animation.x = x;
		animation.y = y;
		
		if (startedJump)
		{
			if (animations.get(currentAnimation).HasEnded())
			{
				animations.get(currentAnimation).Restart();
				velY = jumpImpulse;
				ChangeAnimation(ANIM_JUMP_UP);
				startedJump = false;
			}
		}
		//FLip
		if (velX > 0)
			animations.get(currentAnimation).ScaleX(1);
		else if (velX < 0)
			animations.get(currentAnimation).ScaleX( -1);
		
		for (a in animations)
			a.Update(gameTime);
	}
	
	public function Move(speed : Float) : Void
	{	
		velX = speed;
		ChangeAnimation(ANIM_WALK);
	}
	
	public function Stop() : Void
	{
		ChangeAnimation(ANIM_IDLE);
		if (velX > 0)
			animations.get(currentAnimation).ScaleX(1);
		else if (velX < 0)
			animations.get(currentAnimation).ScaleX( -1);
		velX = 0;
	}
	
	public function Jump(impulse : Float) : Void
	{
		jumpImpulse = impulse;
		ChangeAnimation(ANIM_START_JUMP);
		startedJump = true;
	}
	
	
	public function ChangeAnimation(anim : String) : Void
	{
		if (currentAnimation != "")
			animations.get(currentAnimation).Off();
		
		currentAnimation = anim;
		animations.get(currentAnimation).On();
	}
}