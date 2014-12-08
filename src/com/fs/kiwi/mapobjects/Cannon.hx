package com.fs.kiwi.mapobjects;
import aze.display.TileLayer;
import com.fs.kiwi.characters.Player;
import com.fs.kiwi.particlesystem.ParticleSystem;

import com.fs.kiwi.sound.Sound;
import flash.geom.Point;

/**
 * ...
 * @author Fiery Squirrel
 */
class Cannon extends MapObject
{
	public static var TYPE = "5";
	public static var SPRITE_NAME = "cannon-front";
	
	public  var speed : Float;
	
	private var bullets : Array<Bullet>;
	private var shootTimer : Float;
	private var shootTime : Float;
	private var bulletsLayer : TileLayer;
	private var level : Array<Array<GameObject>>;
	private var player : Player;
	
	private var scaleX : Float;
	private var scaleY : Float;
	private var scaleTimes : Int;
	private var scaleUp : Bool;
	
	private var soundShoot : Sound;
	private var soundBullet : Sound;
	private var particleSystem : ParticleSystem;
	
	public function new(rotation:String, gridX:Int, gridY:Int) 
	{
		super(TYPE, rotation,SPRITE_NAME, gridX, gridY);
		
		shootTimer = 0;
		bullets = new Array<Bullet>();
		
		speed = 2 + Math.random() * 3;
		shootTime = 1 + Math.random() * 5;
		scaleX = 1;
		scaleY = 1;
		scaleTimes = 0;
		scaleUp = false;
	}
	
	override public function LoadContent(tileLayer:TileLayer) 
	{
		super.LoadContent(tileLayer);
		
		//Rotation
		switch(rotation)
		{
			case Globals.ROTATION_0:
				sprite.rotation = 0;
			case Globals.ROTATION_90:
				sprite.rotation = Math.PI/2;
			case Globals.ROTATION_180:
				sprite.rotation = Math.PI;
			case Globals.ROTATION_270:
				sprite.rotation = Math.PI + Math.PI/2;
		}
		
		soundShoot = new Sound(Globals.SOUND_SHOOT, false);
		soundBullet = new Sound(Globals.SOUND_BULLET_COLLIDE, false);
	}
	
	public function SetBulletsLayer(bulletsLayer : TileLayer) : Void
	{
		this.bulletsLayer = bulletsLayer;
	}
	
	public function SetLevel(level : Array<Array<GameObject>>) : Void
	{
		this.level = level;
	}
	
	public function SetParticleSystem(part : ParticleSystem) : Void
	{
		this.particleSystem = part;
	}
	
	public function SetPlayer(player : Player) : Void
	{
		this.player = player;
	}
	
	override public function Update(gameTime:Float):Void 
	{
		super.Update(gameTime);
		
		if (shootTimer > Helper.ConvertSecToMillisec(shootTime))
		{
			if (scaleTimes >= 1)
			{
				scaleX = 1;
				scaleY = 1;
				shootTimer = 0;
				Shoot();
				scaleTimes = 0;
			}
			else
			{
				if (scaleUp)
				{
					if (scaleX >= 1.2)
					{
						scaleUp = false;
					}
					else
					{
						scaleX += 0.01;
						scaleY -= 0.01;
					}
				}
				else
				{
					if (scaleX < 1)
					{
						scaleUp = true;
						scaleTimes++;
					}
					else
					{
						scaleX -= 0.01;
						scaleY += 0.01;
					}
				}
			}
		}
		else
			shootTimer += gameTime;
			
		for (b in bullets)
		{
			b.Update(gameTime);
			b.CheckLevelCollision(player,level);
			
			if (b.Collided())
			{
				b.GetSprite().layer.removeChild(b.GetSprite());
				bullets.remove(b);
				soundBullet.Play();
				particleSystem.GenerateParticles("1", ["particle-2"], 50, new Point(b.GetX(), b.GetY()), 1, "random", new Point(1 - 2 * Math.random(), 1 - 2 * Math.random()), new Point(), [new Color(255, 255, 255)], 1);
			}
		}
		
		sprite.scaleX = scaleX;
		sprite.scaleY = scaleY;
	}
	
	public function Shoot() : Void
	{
		var bullet : Bullet;
		var velX, velY : Float;
		
		velX = 0.0;
		velY = 0.0;
		//Rotation
		switch(rotation)
		{
			case Globals.ROTATION_0:
				velY = speed;
			case Globals.ROTATION_90:
				velX = -speed;
			case Globals.ROTATION_180:
				velY = -speed;
			case Globals.ROTATION_270:
				velX = speed;
		}
		
		bullet = new Bullet(this,gridX, gridY,velX,velY);
		bullet.LoadContent(bulletsLayer);
		bullets.push(bullet);
		
		speed = 2 + Math.random() * 3;
		shootTime = 1 + Math.random() * 5;
		
		soundShoot.Play();
	}
}