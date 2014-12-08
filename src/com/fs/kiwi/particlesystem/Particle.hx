package com.fs.kiwi.particlesystem;

import aze.display.TileLayer;
import aze.display.TileSprite;
import com.fs.kiwi.Color;
import flash.geom.Point;

/**
 * ...
 * @author Henry D. Fernández B.
 */
class Particle extends TileSprite
{
	var velocity : Point;
	var acceleration : Point;
	var timer : Float;
	var maxTime : Float;
	var isDead : Bool;
	var partScale : Float;
	var partAlpha : Float;
	var partRotation : Float;
	var initialScale : Float;
	var initialAlpha : Float;
	var disappear : Bool;
	
	public function new(tileLayer : TileLayer,name : String,pos : Point, vel : Point, acc : Point, scale : Float, rot : Float, alpha : Float, time : Float,  color : Color, disappear : Bool = true) 
	{
		super(tileLayer,name);
		
		this.maxTime = time;
		this.velocity = Helper.FixPoint2Screen(vel);
		this.acceleration = Helper.FixPoint2Screen(acc);
		this.disappear = disappear;
		x = pos.x;
		y = pos.y;
		initialScale = scale * Helper.GetFixScale();
		initialAlpha = alpha;
		partScale = scale * Helper.GetFixScale();
		partAlpha = alpha;
		partRotation = rot;
		r = color.r;
		g = color.g;
		b = color.b;
		this.alpha = partAlpha;
		this.scale = partScale;
		this.rotation = partRotation;
		timer = 0;
		
	}
	
	public function Update(gameTime:Float):Void 
	{
		UpdateVelocity();
		UpdatePosition();

		if (timer >= Helper.ConvertSecToMillisec(maxTime))
		{
			isDead = true;
		}
		else
		{
			UpdateAlpha();
			UpdateScale();
			UpdateRotation();
			
			timer += gameTime;
		}
		
		if(disappear)
			alpha = partAlpha;
		else
			alpha = 1;
			
		scale = partScale;
		rotation = partRotation;
	}
	
	private function UpdateVelocity() : Void
	{
		velocity.x += acceleration.x;
		velocity.y += acceleration.y;
	}
	
	private function UpdatePosition() : Void
	{
		x += velocity.x;
		y += velocity.y;
	}
	
	private function UpdateRotation() : Void
	{}
	
	private function UpdateAlpha() : Void
	{
		partAlpha = initialAlpha * (1 - (timer/Helper.ConvertSecToMillisec(maxTime)));
	}
	
	private function UpdateScale() : Void
	{
		partScale = initialScale * (1 - (timer/Helper.ConvertSecToMillisec(maxTime)));
	}
	
	public function IsDead() : Bool
	{
		return isDead;
	}
}