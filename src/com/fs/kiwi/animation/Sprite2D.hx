package com.fs.kiwi.animation;

import com.fs.fluffeaters.TileSheetBatch2;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.Tilesheet;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;

/**
 * Represents an animation in 2 dimensions. 
 * Made from a Sprite Sheet.
 * 
 * @author Henry D. Fernández B.
 */

/*/*
 * Flip: Horizontal, Vertical, None.
 * */
/*enum FlipState
{
	Horizontal;
	Vertical;
	None;
}*/

class Sprite2D
{
	/*
	 * Center circle color.
	 * */
	static private var CENTER_COLOR :Int = 0xFF0000;
	
	/*
	 * Center circle size.
	 * */
	static private var CENTER_SIZE : Int = 5;
	
	/*
	 * Frame color.
	 * */
	static private var FRAME_COLOR : Int = 0xFF0000;
	
	/*
	 * Debugging information.
	 */
	private var debuggingText : TextField;
	
	/*
	 * Is debugging?.
	 */
	private var isDebugging : Bool;
	    
	/*
	 * Animation pivot. Used to scale, rotate and translate.
	 */
	private var pivot : Point;
	
	/*
	 * Duration of the animation
	 */
	private var rotation : Float;
	
	/*
	 * Sprite sheet used to draw the animation on the screen.
	 * */
	private var spriteSheet : BitmapData;

	/*
	 * Tilesheet used to construct the drawing frames to perform the animation.
	 * */
	//private var tilesheet : Tilesheet;

	/*
	 * Animation position X (in pixels).
	 * */
	private var x : Float;
	
	/*
	 * Animation position Y (in pixels).
	 * */
	private var y : Float;
	
	/*
	 * Animation scale X.
	 */
	private var scaleX : Float;
	
	/*
	 * Animation scale Y.
	 */
	private var scaleY : Float;
	
	/*
	 * An array for all positions, ID, frames
	 * This array is used to draw the animation.
	 * */
	private var data:Array<Float>;
	
	/*
	 * Red color.
	 * */
	private var colorR : Float;
	
	/*
	 * Red color.
	 * */
	private var colorG : Float;
	
	/*
	 * Red color.
	 * */
	private var colorB : Float;
	
	/*
	 * Alpha.
	 * */
	private var colorA : Float;
	
	/*
	 * Current flip.
	 * */
	private var flip : Animation2D.FlipState;
	
	private var frame : Rectangle;
	
	private var tilesheet : Tilesheet;
	
	

	/*
	 * Initializes a 2D sprite animation.
	 * 
	 * @param id An identifier to distinguish the animation in a collection.
	 * @param spriteSheet a bitmap loaded spritesheet.
	 * @param frames an array of rectangles thar represent each frame of the animation.
	 * @param direction should the animation run Forward or Backward?.
	 * @param isLoop is it a loop animation?.
	 * @param fps frames per second, determine the speed of the animation.
	 * */
	public function new(frame : Rectangle, pivot : Point = null) 
	{	
		//this.spriteSheet = spriteSheet;
		this.frame = frame;
		
		//Pivot
		pivot = new Point(-frame.width / 2, -frame.height / 2);
		
		//Initialize Frames
		tilesheet = new Tilesheet(spriteSheet);
		tilesheet.addTileRect(frame, pivot);
			
		data = [0.0, 0.0, 0,0,0,0];
		
		colorR = 1;
		colorG = 1;
		colorB = 1;
		colorA = 1;
		flip = Animation2D.FlipState.None;
	}
	
	/*
	 * Duration of the animation.
	 */
	public function GetCenter() : Point
	{
		var c : Point;
		
		c = new Point();
		
		return c;
	}

	/*
	 * Get the pivot.
	 */
	public function GetPivot() : Point
	{
		return this.pivot;
	}
	
	/*
	 * Set the pivot.
	 */
	public function SetPivot(pivot : Point)
	{
		this.pivot = pivot;
	}
	
	/*
	 * Draws the animation on the screen.
	 *
	 * */
	public function Draw(sprite : Sprite,tilesheet2 : TileSheetBatch2,m : Matrix, position : Point = null, rotation : Float = 0, scale : Float = 1, flip : Animation2D.FlipState = null)
	{
		//var m : Matrix;
		//m = new Matrix(1, 0, 0, 1, 0, 0);
		
		if (flip != null)
		{
		switch(flip)
		{
			case FlipState.None:
			case FlipState.Horizontal:
				m.scale(-1,1);
			case FlipState.Vertical:
				m.scale(1, -1);
		}
		}
		
		
			
		if (position == null)
			position = new Point();
		/*
		//Scale
		m.scale(scale.x,scale.y);
		//Rotate
		m.rotate(rotation * Globals.DEGREE_RAD_CONVERSION);
		//Translate
		m.translate(position.x, position.y);
		//Apply transformations
		sprite.transform.matrix = m;
		sprite.transform.colorTransform = new ColorTransform(colorR,colorG,colorB,colorA, 0, 0, 0, 0);*/
		
		#if !js
		data[0] = position.x;// pivot.x + frames[currentFrame].GetOffset().x;
		data[1] = position.y;// pivot.y + frames[currentFrame].GetOffset().y;
		data[2] = 0;
		data[3] = 1;
		data[4] = 0;// Helper.ConvertDegToRad(rotation);
		data[5] = 0.5;
		//data[6] = 0;
		//data[7] = 0;
		//data[8] = 0;
	
		/*sprite.graphics.beginBitmapFill(spriteSheet,m,false,true);
		sprite.graphics.drawRect(0, 0, 400, 400);
		m.translate(400, 400);
		m.rotate(90);
		sprite.graphics.beginBitmapFill(spriteSheet,m,false,true);
		sprite.graphics.drawRect(400, 400, 400, 400);
		sprite.graphics.endFill();
		sprite.x = 0;
		sprite.y = 0;*/
		
		//tilesheet.draw(frame, pivot,position,rotation,1,true,TileSheetBatch2.TILE_SCALE | TileSheetBatch2.TILE_ROTATION | TileSheetBatch2.TILE_ALPHA | TileSheetBatch2.TILE_RGB);
		tilesheet.drawTiles(sprite.graphics,data, true, Tilesheet.TILE_SCALE | Tilesheet.TILE_ROTATION | Tilesheet.TILE_ALPHA);
		
		//tilesheet.drawTiles(sprite.graphics, data, true);
		#end
		
		//#if !js
		//tilesheet.drawTiles(sprite.graphics, data, true);
		//#end
	}
	
	/*
	 * Shows / hides debuggin info depending on if it's debugging or not.
	 * 
	 * @param value true to turn on debugging, false to turn it off.
	 * */
	public function SetDebugging(value : Bool)
	{
		/*if (isDebugging)
		{
			if (!value)
			{
				removeChild(frame);
				removeChild(center);
			}
		}
		else
		{
			if (value)
			{
				addChild(frame);
				addChild(center);
			}
		}
		
		isDebugging = value;*/
	}
	
	/*
	 * Changes the animation color.
	 * 
	 * @param r quantity of red color 0..1.
	 * @param g quantity of green color 0..1.
	 * @param b quantity of blue color 0..1.
	 * @param a quantity of alpha 0..1.
	 * */
	public function ChangeColor(r : Float,g : Float, b: Float,a : Float = 1)
	{
		if (r < 0 || r > 1 || g < 0 || g > 1 || b < 0 || b > 1 || a < 0 || a > 1)
			throw "Error: values must be between 0..1";
			
		colorR = r;
		colorG = g;
		colorB = b;
		colorA = a;
	}
}