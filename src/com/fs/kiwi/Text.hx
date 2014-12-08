package com.fs.kiwi;

import flash.geom.Point;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

/**
 * ...
 * @author Henry D. Fernández B.
 */
class Text extends TextField
{
	var timer : Float;
	var isDead : Bool;
	var rawText : String;
	
	public function new(fontName : String, text : String, size : Int, color : Int,letterSpacing : Int, pos : Point = null, xAlign : String = "center",yAlign : String = "center",bold : Bool) 
	{
		super();
		var format : TextFormat;
		var textField : TextField;
		
		isDead = false;
		timer = 0;
		format = new TextFormat (fontName, size, color);
		format.letterSpacing = letterSpacing;
		format.bold = bold;
		defaultTextFormat = format;
		antiAliasType = AntiAliasType.ADVANCED;
		autoSize = TextFieldAutoSize.LEFT;
		selectable = false;
		embedFonts = true;
		mouseEnabled = false;
		rawText = text;
		this.text = text;
		
		if (pos != null)
		{
			switch(xAlign)
			{
				case "left":
					x = pos.x;
				case "center":
					x = pos.x - width/2;
				case "right":
					x = pos.x - width;
				default:
					x = pos.x;
			}
			switch(yAlign)
			{
				case "left":
					y = pos.y;
				case "center":
					y = pos.y - height/2;
				case "right":
					y = pos.y - height;
				default:
					y = pos.y;
			}
		}
		
	}
	
	public function GetRawText() : String
	{
		return rawText;
	}
	
	public function Update(gameTime:Float):Void 
	{
	}
	
	public function IsDead() : Bool
	{
		return isDead;
	}
}