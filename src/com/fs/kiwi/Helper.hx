package com.fs.kiwi;
import aze.display.behaviours.TileGroupTransform;
import com.fs.kiwi.animation.Animation2D;
import com.fs.kiwi.sound.Sound;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import openfl.Assets;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.AntiAliasType;
import flash.text.TextFieldAutoSize;
import flash.net.SharedObject;
import flash.net.SharedObjectFlushStatus;
import flash.text.TextFormatAlign;
import aze.display.SparrowTilesheet;
import aze.display.TileLayer;
import aze.display.TileSprite;
import flash.net.URLRequest;
import flash.net.URLLoader;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;
import flash.events.Event;
import flash.system.Capabilities;
import flash.events.IOErrorEvent;
import haxe.Utf8;
#if !flash
import openfl.feedback.Haptic;
#end

/**
 * ...
 * @author Henry D. Fernández B.
 */
class Helper
{
	private static var UID_CHARS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
	
	private static var MAX_HEX = 255;
	
	private static var SPRITESHEET_DATA : Map < String, Map < String, flash.geom.Rectangle >> ;
	
	private static var BITMAP_SEP_X : Int = 1;
	private static var BITMAP_SEP_Y : Int = 1;
	private static var PLATFORM_BITMAPS_DATA : Array<BitmapData>;
	private static var STATS : String;
	
	public static function CreateID(?size : Int) : String 
	{
		if (size == null) 
			size = 32;
			
		var nchars = UID_CHARS.length; 
		var uid = new StringBuf(); 
		
		for (i in 0 ... size)
			uid.add(UID_CHARS.charAt( Std.int(Math.random() * nchars) )); 
		
		return uid.toString(); 
	}
	
   /*
	* Return object with rgb triplet from hex float
	* <pre class="code haxe">
	* var rgb = Color.toRGB(Color.RED);
	* // outputs 0
	* trace(rgb.r-255);
	* </pre>
	* @param input color
	* @return Dynamic object with r,g,b fields
	*/
	public static inline function HexToRGB(color:Int) : Array<Float> 
	{
		
		var r : Int = (color >> 16) & 0xFF ;
		var g : Int = (color >> 8) & 0xFF ;
		var b : Int = color & 0xFF ;
		
		return [r/MAX_HEX,g/MAX_HEX, b/MAX_HEX];
	}
	
	public static function F2T(delta : Float, value : Float) : Float
	{
		return (value * delta) * Globals.TIME_STEP;
	}
	
	public static function P2T(delta : Float, value : Point) : Point
	{
		return new Point((value.x * delta) * Globals.TIME_STEP,(value.y * delta) * Globals.TIME_STEP);
	}
	
	public static inline function CalculateReflect(vector : Point, normal : Point) : Point
	{
		var relNv : Float;
		var reflect : Point;
		
		relNv = vector.x * normal.x + vector.y * normal.y;
		reflect = new Point();
		reflect.x = (vector.x - (2 * relNv * normal.x));
		reflect.y = (vector.y - (2 * relNv * normal.y));
					
		
		return reflect;
	}
	
	public static function Normalize(vector : Point) : Point
	{
		var mod : Float;
		var normalized : Point;
		
		mod = Math.sqrt(Math.pow(vector.x, 2) + Math.pow(vector.y, 2));
		
		if(mod > 0)
			normalized = new Point(vector.x / mod, vector.y / mod);
		else
			normalized = vector;
		
		
		return normalized;
	}
	
	/// <summary>
	/// Get the direction to aim the initial point to final point.
	/// </summary>
	/// <param name="initialPoint">Initial point.</param>
	/// <param name="finalPoint">Final point.</param>
	/// <returns>An unitary vector pointing to the final point.</returns>
	public static function Aim(initialPoint : Point,finalPoint : Point) : Point
	{
		var direction, aim : Point;
		var dirLength : Float;
		
		direction = new Point();
		direction.x = finalPoint.x - initialPoint.x;
		direction.y = finalPoint.y - initialPoint.y;

		dirLength = Math.sqrt(Math.pow(direction.x, 2) + Math.pow(direction.y, 2));
		
		if (dirLength == 0)
			aim = Normalize(finalPoint);
		else
			aim = Normalize(direction);

		return aim;
	}
	
	/// <summary>
	/// Get the direction to aim the initial point to final point.
	/// </summary>
	/// <param name="initialPoint">Initial point.</param>
	/// <param name="finalPoint">Final point.</param>
	/// <returns>An unitary vector pointing to the final point.</returns>
	public static function RotateVector(angle : Float,vector : Point) : Point
	{
		var x , y : Float;
		
		x = vector.x * Math.cos(angle) - vector.y * Math.sin(angle);
		y = vector.y * Math.cos(angle) - vector.x * Math.sin(angle);

		return new Point(x,y);
	}
	
	public static function ClampValue(value : Int, min : Int,max : Int) : Int
	{
		var clampVal : Int;
		
		clampVal = value;
		
		if (value > max)
			clampVal = max;
		else if (value < min)
			clampVal = min;
		
		return clampVal;
	}
	
	public static function Clamp(vector : Point, max : Point) : Point
	{
		var clampVec : Point;
		
		clampVec = new Point(vector.x,vector.y);
		
		if (vector.x > Math.abs(max.x))
			clampVec.x = Math.abs(max.x);
		else if (vector.x < -Math.abs(max.x))
			clampVec.x = -Math.abs(max.x);
			
		if (vector.y > Math.abs(max.y))
			clampVec.y = Math.abs(max.y);
		else if (vector.y < -Math.abs(max.y))
			clampVec.y = -Math.abs(max.y);

		return clampVec;
	}
	
	public static function CrossProduct(vector1 : Point,vector2 : Point) : Float
    {
		var cross : Float;

		cross = vector1.x * vector2.y - vector1.y * vector2.x;

		return cross;
    }
	
	public static function DotProduct(vector1 : Point,vector2 : Point) : Float
    {
		var dot : Float;

		dot = vector1.x * vector2.x + vector1.y * vector2.y;

		return dot;
    }
	
	public static function Module(vector : Point) : Float
    {
		var module : Float;

		module = Math.sqrt(Math.pow(vector.x, 2) + Math.pow(vector.y, 2));

		return module;
    }
	
	public static function CalculateAngle(vector1 : Point, vector2 : Point) : Float
    {
		var angle : Float;
		var mod : Float;

		mod = Module(vector1) * Module(vector2);
		if(mod > 0)
			angle = Math.acos(DotProduct(vector1, vector2) / mod);
		else
			angle = 0;
		
		return angle;
    }
	
	public static function ConvertSecToMillisec(val : Float) : Float
    {
		return Globals.MILLISECONDS * val;
    }
	
	public static function ConvertMillisecToSec(val : Float) : Float
    {
		return val / Globals.MILLISECONDS;
    }
	
	public static function ConvertRadToDeg(val : Float) : Float
    {
		return (val * 180) / Math.PI;
    }
	
	public static function ConvertDegToRad(val : Float) : Float
    {
		return (val * Math.PI) / 180;
    }
	
	public static function TransformPoint(point : Point, pivot : Point, theta : Float) : Point
	{
		var newPoint : Point;
		newPoint = new Point();
		
		newPoint.x = pivot.x + (point.x - pivot.x) * Math.cos(theta) - (point.y - pivot.y) * Math.sin(theta);
		newPoint.y = pivot.y + (point.x - pivot.x) * Math.sin(theta) + (point.y - pivot.y) * Math.cos(theta);
		
		return newPoint;
	}
	
	public static function LoadBitmapData(path : String) : BitmapData
	{
		var bitmapData : BitmapData;
		
		if (Assets.cache.bitmapData.exists(path))
			bitmapData = Assets.cache.bitmapData.get(path);
		else
		{
			bitmapData = Assets.getBitmapData(path);
			Assets.cache.bitmapData.set(path,bitmapData);
		}
			
		
		return bitmapData;
	}
	
	public static function LoadSpriteSheetData(path : String) : Map<String,flash.geom.Rectangle>
	{
		var data : Map<String,flash.geom.Rectangle>;
		
		if (SPRITESHEET_DATA == null)
			SPRITESHEET_DATA = new Map<String,Map<String,flash.geom.Rectangle>>();
		
		if (SPRITESHEET_DATA.exists(path))
			data = SPRITESHEET_DATA.get(path);
		else
		{
			data = ParseObjectsData(path);
			SPRITESHEET_DATA.set(path, data);
		}
		
		return data;
	}
	
	public static function LoadBitmap(path : String) : Bitmap
	{
		var bitmap : Bitmap;
		var bitmapData : BitmapData;
	
		bitmapData = LoadBitmapData(path);
		bitmap = new Bitmap(bitmapData);
	
		return bitmap;
	}
	
	public static function ParseObjectsData(path : String) : Map<String,flash.geom.Rectangle>
	{
		var str,name : String;
		var xml : Xml;
		var x, y, w, h : Int;
		
		var data : Map<String,flash.geom.Rectangle> = new Map<String,flash.geom.Rectangle>();
			
		try
		{
			str = Assets.getText(path);
			xml = Xml.parse(str).firstElement();
			for (i in xml.iterator())
			{
				if (i.nodeType == Xml.Element)
				{
					name = i.get("name");
					x = Std.parseInt(i.get("x"));
					y = Std.parseInt(i.get("y"));
					w = Std.parseInt(i.get("width"));
					h = Std.parseInt(i.get("height"));
					
					data.set(name, new flash.geom.Rectangle(x, y, w, h));
				}
			}
		}
		catch (e : String)
		{
			trace(e);
		}
		
		return data;
	}
	
	public static function TurnSoundsOn() : Void
	{
	}
	
	public static function TurnSoundsOff() : Void
	{
	}
	
	public static function TurnMusicOn() : Void
	{
	}
	
	public static function TurnMusicOff() : Void
	{
	}
	
	public static function TurnVibrationOn() : Void
	{
	}
	
	public static function TurnVibrationOff() : Void
	{
	}
	
	public static function AddSound(key : String,sound : Sound) : Void
	{
		/*if (Globals.SOUNDS != null)
		{
			if(!Globals.SOUNDS.exists(key) && sound != null)
				Globals.SOUNDS.set(key, sound);
		}*/
	}
	
	public static function IsPlayingSoundtrack(key : String) : Bool
	{
		var playing : Bool;
		
		playing = false;
		
		/*if (Globals.MUSIC_ON)
		{
			if (Globals.SOUNDS.exists(key))
			{
				if(Globals.SOUNDS.get(key) != null)
					playing = Globals.SOUNDS.get(key).GetState() == Play;
			}
		}*/
		
		return playing;
	}
	
	public static function SetVolumeSoundtrack(key : String,vol : Float) : Void
	{
		/*if (Globals.MUSIC_ON)
		{
			if(Globals.SOUNDS.exists(key))
				Globals.SOUNDS.get(key).SetVolume(vol);
		}*/
	}
	
	public static function PlaySoundtrack(key : String) : Void
	{
		/*if (Globals.MUSIC_ON)
		{
			if (Globals.SOUNDS.exists(key))
			{
				if(Globals.SOUNDS.get(key) != null)
					Globals.SOUNDS.get(key).Play();
			}
		}*/
	}
	
	public static function ResumeSoundtrack(key : String) : Void
	{
		/*if (Globals.MUSIC_ON)
		{
			if (Globals.SOUNDS.exists(key))
			{
				if(Globals.SOUNDS.get(key) != null)
					Globals.SOUNDS.get(key).Resume();
			}
		}*/
	}
	
	public static function PlaySound(key : String) : Void
	{
		/*if (Globals.SOUNDS_ON)
		{
			if (Globals.SOUNDS.exists(key))
			{
				if(Globals.SOUNDS.get(key) != null)
					Globals.SOUNDS.get(key).Play();
			}
		}*/
	}
	
	public static function PauseSound(key : String) : Void
	{
		//if (Globals.SOUNDS_ON)
		//{
			/*if (Globals.SOUNDS.exists(key))
			{
				if(Globals.SOUNDS.get(key) != null)
					Globals.SOUNDS.get(key).Pause();
			}*/
		//}
	}
	
	public static function StopSound(key : String) : Void
	{
		//if (Globals.SOUNDS_ON)
		//{
			/*if (Globals.SOUNDS.exists(key))
			{
				if(Globals.SOUNDS.get(key) != null)
					Globals.SOUNDS.get(key).Stop();
			}*/
		//}
	}
	
	public static function ResumeSound(key : String) : Void
	{
		/*if (Globals.SOUNDS_ON)
		{
			if (Globals.SOUNDS.exists(key))
			{
				if(Globals.SOUNDS.get(key) != null)
					Globals.SOUNDS.get(key).Resume();
			}
		}*/
	}
	
	public static function SetVolumeSound(key : String,volume : Float) : Void
	{
		/*if (Globals.SOUNDS_ON)
		{
			if (Globals.SOUNDS.exists(key))
			{
				if(Globals.SOUNDS.get(key) != null)
					Globals.SOUNDS.get(key).SetVolume(volume);
			}
		}*/
	}
	
	/*
	 * Fixed point to Screen: Generate relative values, using fixed screen width and height.
	 * */
	public static function FixPoint2Screen(value : Point) : Point
	{
		var scale : Point;
		
		scale = new Point(Globals.SCREEN_WIDTH/Globals.FIXED_SCREEN_WIDTH, Globals.SCREEN_HEIGHT/Globals.FIXED_SCREEN_HEIGHT );
		
		return new Point(value.x * scale.x,value.y * scale.y);
	}
	
	/*
	 * Fixed float to Screen: Generate relative values, using fixed screen width and height.
	 * */
	public static function FixFloat2ScreenX(value : Float) : Float
	{
		var scale : Float;
		
		scale = Globals.SCREEN_WIDTH/Globals.FIXED_SCREEN_WIDTH;
		
		return value * scale;
	}
	
	/*
	 * Fixed float to Screen: Generate relative values, using fixed screen width and height.
	 * */
	public static function FixFloat2ScreenY(value : Float) : Float
	{
		var scale : Float;
		
		scale = Globals.SCREEN_HEIGHT/Globals.FIXED_SCREEN_HEIGHT;
		
		return value * scale;
	}
	
	/*
	 * Fixed float to Screen: Generate relative values, using fixed screen width and height.
	 * */
	public static function FixInt2ScreenX(value : Int) : Int
	{
		var scale : Float;
		
		scale = Globals.SCREEN_WIDTH/Globals.FIXED_SCREEN_WIDTH;
		
		return Math.round(value * scale);
	}
	
	/*
	 * Fixed float to Screen: Generate relative values, using fixed screen width and height.
	 * */
	public static function FixInt2ScreenY(value : Int) : Int
	{
		var scale : Float;
		
		scale = Globals.SCREEN_HEIGHT/Globals.FIXED_SCREEN_HEIGHT;
		
		return Math.round(value * scale);
	}
	
	/*
	 * Fixed float to Screen: Generate relative values, using fixed screen width and height.
	 * */
	public static function FixIntScale2Screen(value : Int) : Int
	{
		var scaleX,scaleY, scale : Float;
		
		scaleX = Globals.SCREEN_WIDTH/Globals.FIXED_SCREEN_WIDTH;
		scaleY = Globals.SCREEN_HEIGHT/Globals.FIXED_SCREEN_HEIGHT;
		//scale = Math.max(scaleX, scaleY);
		scale = Math.min(scaleX, scaleY);
		
		
		return Math.round(value * scale);
	}
	
	/*
	 * Fixed float to Screen: Generate relative values, using fixed screen width and height.
	 * */
	public static function FixFloatScale2Screen(value : Float) : Float
	{
		var scaleX,scaleY, scale : Float;
		
		scaleX = Globals.SCREEN_WIDTH/Globals.FIXED_SCREEN_WIDTH;
		scaleY = Globals.SCREEN_HEIGHT/Globals.FIXED_SCREEN_HEIGHT;
		//scale = Math.max(scaleX, scaleY);
		scale = Math.min(scaleX, scaleY);
		
		
		return value * scale;
	}
	
	/*
	 * Fixed float to Screen: Generate relative values, using fixed screen width and height.
	 * */
	public static function GetFixScale() : Float
	{
		var scaleX,scaleY, scale : Float;
		
		scaleX = Globals.SCREEN_WIDTH/Globals.FIXED_SCREEN_WIDTH;
		scaleY = Globals.SCREEN_HEIGHT/Globals.FIXED_SCREEN_HEIGHT;
		//scale = Math.max(scaleX, scaleY);
		scale = Math.min(scaleX, scaleY);
		
		
		return scale;
	}
	
	/*
	 * Fixed float to Screen: Generate relative values, using fixed screen width and height.
	 * */
	public static function GetMaxScale() : Float
	{
		var scaleX,scaleY, scale : Float;
		
		scaleX = Globals.SCREEN_WIDTH/Globals.FIXED_SCREEN_WIDTH;
		scaleY = Globals.SCREEN_HEIGHT/Globals.FIXED_SCREEN_HEIGHT;
		scale = Math.max(scaleX, scaleY);
		//scale = Math.min(scaleX, scaleY);
		
		
		return scale;
	}
	
	
	public static function PointInsideRectangle(point : Point,rectPos : Point,rectWidth : Float,rectHeight : Float) : Bool
	{
		var xCond, yCond : Bool;
		
		xCond = point.x <= rectPos.x + rectWidth/2 && point.x >= rectPos.x - rectWidth/2;
		yCond = point.y <= rectPos.y + rectHeight/2 && point.y >= rectPos.y - rectHeight/2;
		
		return xCond && yCond;
	}
	
	public static function PointOutsideRectangle(point : Point,rectPos : Point,rectWidth : Float,rectHeight : Float) : Bool
	{
		var xCond, yCond : Bool;
		
		xCond = point.x > rectPos.x + rectWidth/2 || point.x < rectPos.x - rectWidth/2;
		yCond = point.y > rectPos.y + rectHeight/2 || point.y < rectPos.y - rectHeight/2;
		
		return xCond || yCond;
	}
	
	public static function PointInsideCircle(point : Point, circlePoint : Point, radius : Float) : Bool
	{
		return ((point.x - circlePoint.x) * (point.x - circlePoint.x)) + ((point.y - circlePoint.y) * (point.y - circlePoint.y)) < radius * radius;
	}
	
	public static function CleanBitmaps() : Void
	{
		var bitmapData : BitmapData;
		
		if (Assets.cache.bitmapData != null)
		{
			//trace("1disposing platforms " + Assets.cache.bitmapData.keys().length);
			
			for (k in Assets.cache.bitmapData.keys())
			{
				bitmapData = Assets.cache.bitmapData.get(k);
				if (bitmapData != null)
				{
					bitmapData.dispose();
					bitmapData = null;
				}
				Assets.cache.bitmapData.remove(k);
			}
			
			//trace("2disposing platforms " + Assets.cache.bitmapData.keys().length);
		}
	}
	
	public static function CleanPlatformBitmaps() : Void
	{
		var bitmapData : BitmapData;
		if (PLATFORM_BITMAPS_DATA != null)
		{
			while (PLATFORM_BITMAPS_DATA.length > 0)
			{
				bitmapData = PLATFORM_BITMAPS_DATA.pop();
				if (bitmapData != null)
				{
					bitmapData.dispose();
					bitmapData = null;
				}
			}
		}
	}
	
	public static function CreateAnimation(tileLayer : TileLayer,name : String, key : String,indices : Array<Int>, fps : Int,type : AnimationType,direction : Direction,offset : Point = null,rotation : Float = 0, onComplete : Dynamic->Void = null) : Animation2D
	{
		var frame,glowFrame : TileSprite;
		var anim : Animation2D;
        var frames : Array<TileSprite>;
		
		frames = new Array<TileSprite>();
		
		if (indices.length > 0)
		{
			for (i in indices)
			{
				frame = new TileSprite(tileLayer, name + "-" + i);
					
				if (offset != null)
					frame.offset = offset;
				
				frames.push(frame);
			}
		}
		else
		{
			frame = new TileSprite(tileLayer, name);
			
			if (offset != null)
				frame.offset = offset;
			frames.push(frame);
		}
		
		anim = new Animation2D(tileLayer, frames, direction, type, fps, rotation);
		
		
		if (onComplete != null)
			anim.GetEndedEvent().addEventListener(Animation2D.EVENT_ANIMATION_ENDED,onComplete);
		
		return anim;
	}
}