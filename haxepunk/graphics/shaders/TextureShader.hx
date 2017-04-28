package haxepunk.graphics.shaders;

#if hardware_render

class TextureShader extends Shader
{
	static var VERTEX_SHADER =
"// HaxePunk texture vertex shader
#ifdef GL_ES
precision mediump float;
#endif

attribute vec4 aPosition;
attribute vec4 aColor;
attribute vec2 aTexCoord;
varying vec2 vTexCoord;
varying vec4 vColor;
uniform mat4 uMatrix;

void main(void) {
	vColor = aColor;
	vTexCoord = aTexCoord;
	gl_Position = uMatrix * aPosition;
}";

	static var FRAGMENT_SHADER =
"// HaxePunk texture fragment shader
#ifdef GL_ES
precision mediump float;
#endif

varying vec4 vColor;
varying vec2 vTexCoord;
uniform sampler2D uImage0;

void main(void) {
	vec4 color = texture2D(uImage0, vTexCoord);
	if (color.a == 0.0) {
		gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
	} else {
		gl_FragColor = color * vec4(vColor.rgb * vColor.a, vColor.a);
	}
}";

	public function new(?fragment:String)
	{
		super(VERTEX_SHADER, fragment == null ? FRAGMENT_SHADER : fragment);
		position.name = "aPosition";
		texCoord.name = "aTexCoord";
		color.name = "aColor";
	}

	public static var defaultShader(get, null):TextureShader;
	static inline function get_defaultShader():TextureShader
	{
		if (defaultShader == null) defaultShader = new TextureShader();
		return defaultShader;
	}

}
#end