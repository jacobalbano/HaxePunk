package haxepunk.graphics.hardware.opengl;

import openfl.display.BitmapData;
import lime.graphics.opengl.GL;
import lime.graphics.WebGLRenderContext;

class GLInternal
{
	public static var renderer:openfl.display.OpenGLRenderer;
	public static var gl:WebGLRenderContext;

	@:access(openfl.display.OpenGLRenderer.__context3D)
	@:access(openfl.display.Stage)
	@:access(openfl.display3D.textures.TextureBase.__getTexture)
	@:allow(haxepunk.graphics.hardware.opengl.GLUtils)
	static function bindTexture(texture:Texture)
	{
		var bmd:BitmapData = cast texture;
		GL.bindTexture(GL.TEXTURE_2D, bmd.getTexture(
			renderer.__context3D
		).__getTexture());
	}

	public static inline function invalid(object:Dynamic)
	{
		// FIXME: Lime WebGL objects are native, don't extend GLObject
		return object == null;
	}
}
