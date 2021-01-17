package haxepunk.pixel;

import haxepunk.Entity;
import haxepunk.HXP;
import haxepunk.Graphic;
import haxepunk.graphics.shader.WorldShader;

class PixelArtScaler extends Entity
{
	public static var baseWidth:Null<Int> = null;
	public static var baseHeight:Null<Int> = null;

	static var s1:WorldShader;
	static var s2:WorldShader;

	public static function globalActivate()
	{
		Graphic.smoothDefault = false;
		Graphic.pixelSnappingDefault = true;
		HXP.engine.onWorldSwitch.bind(activate);
	}

	public static function activate()
	{
		var e = new PixelArtScaler();
		HXP.world.add(e);
		HXP.world.camera.pixelSnapping = true;
		return e;
	}

	function new()
	{
		super();
		visible = collidable = false;
	}

	override public function update()
	{
		if (HXP.screen.width <= s1.width || HXP.screen.height <= s1.height)
		{
			s1.active = s2.active = false;
		}
		else if (HXP.screen.width == s1.width && HXP.screen.height == s1.height)
		{
			s1.active = s2.active = false;
		}
		else if (HXP.screen.width % s1.width == 0 && HXP.screen.height % s1.height == 0)
		{
			s1.active = true;
			s2.active = false;
		}
		else s1.active = s2.active = true;

		if (s2.active)
		{
			var sx = Std.int(Math.max(HXP.screen.width / s1.width, 1)),
				sy = Std.int(Math.max(HXP.screen.height / s1.height, 1));
			s2.width = Std.int(sx * s1.width);
			s2.height = Std.int(sy * s1.height);
		}
	}

	override public function added()
	{
		if (world.shaders == null) world.shaders = new Array();
		if (s1 == null) s1 = new WorldShader();
		s1.width = baseWidth == null ? HXP.width : baseWidth;
		s1.height = baseHeight == null ? HXP.height : baseHeight;
		s1.smooth = false;
		if (s2 == null) s2 = new WorldShader();
		resized();

		if (world.shaders.indexOf(s1) == -1) world.shaders.push(s1);
		if (world.shaders.indexOf(s2) == -1) world.shaders.push(s2);
		Log.info("pixel art shaders activated");
	}

	override public function removed()
	{
		if (world.shaders != null)
		{
			world.shaders.remove(s2);
			world.shaders.remove(s1);
		}
	}
}
