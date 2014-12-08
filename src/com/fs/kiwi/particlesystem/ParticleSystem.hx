package com.fs.kiwi.particlesystem;

import aze.display.TileLayer;
import aze.display.TileSprite;
import flash.geom.Point;
import com.fs.kiwi.Color;
import com.fs.kiwi.events.ParticlesEvent;

/**
 * ...
 * @author Henry D. Fernández B.
 */
class ParticleSystem
{
	static public var NUMBER_OF_PARTICLES : Int = 100;
	
	private var layers : Map<String,TileLayer>;
	private var particles : Array<Particle>;
	
	public function new() 
	{
		particles = new Array<Particle>();
	}
	
	public function LoadContent(layers : Map<String,TileLayer>) : Void
	{
		this.layers = layers;
	}
	
	public function Update(gameTime:Float):Void 
	{
		for (p in particles)
		{
			p.Update(gameTime);
			if (p.IsDead())
			{
				particles.remove(p);
				p.parent.removeChild(p);
			}
		}
	}
	
	public function GenerateParticles(layer : String, names : Array<String>,number : Int,pos : Point,size : Float,direction : String,speed : Point,acceleration : Point, colors : Array<Color>,time : Float = 0, rotation : Float = 0, disappear : Bool = true) : Void
    {
		var part : Particle;
		var c : Color;
		var vel : Point;
		var idx : Int;
		var rot : Float;
		var name :String;
			
		if (rotation != 0)
			rot = rotation;
		else
			rot = 0;
			
		for (i in 0...number)
		{	
			idx = Math.round(Math.random() * (colors.length -1));
			c = colors[idx];
			
			idx = Math.round(Math.random() * (names.length -1));
			name = names[idx];
			
			switch(direction)
			{
				case "up":
					vel = new Point(Math.sin(2 * Math.random() - 1) * 2, Math.sin( -Math.random()));
					pos = new Point(pos.x + Math.sin(2 * Math.random() - 1), pos.y + Math.cos(2 * Math.random() - 1));
				case "side":
					vel = new Point(Math.random(), 2 * Math.random() - 1);
				case "random":
					vel = new Point(2 * Math.random() - 1, 2 * Math.random() - 1);
				case "radial":
					vel = new Point(1, 1);
				case "sin":
					vel = new Point(Math.random(),Math.random());
				default:
					vel = new Point();
					
			}
			
			vel.x *= speed.x;
			vel.y *= speed.y;
			
			part = new Particle(layers.get(layer),name,pos,vel,acceleration, size,rotation,0.1 + Math.random(),0.1 + (time * Math.random()),c,disappear);
			particles.push(part);
			layers.get(layer).addChild(part);
		}
    }
	
	public function HandleParticlesEvent(e : ParticlesEvent) : Void
	{
		var names : Array<String>;
		var layer,direction : String;
		var number : Int;
		var pos, vel,acc : Point;
		var colors : Array<Color>;
		var size, time, radius, gravity : Float;
		var disappear : Bool;
		
		layer = e.GetLayer();
		names = e.GetNames();
		direction = e.GetDirection();
		number = e.GetNumber();
		pos = e.GetPos();
		vel = e.GetVel();
		acc = e.GetAcc();
		colors = e.GetColors();
		size = e.GetSize();
		time = e.GetTime();
		disappear = e.GetDisappear();
		
		GenerateParticles(layer, names, number, pos, size, direction, vel,acc, colors,time,0,disappear);
	}
	
	public function Clean() : Void
	{
		for (p in particles)
		{
			if(p.parent != null)
				p.parent.removeChild(p);
			particles.remove(p);
		}
	}
	
	public function IsEmpty() : Bool
	{
		return particles.length <= 0;
	}
}