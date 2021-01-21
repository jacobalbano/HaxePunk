package haxepunk.tweens.motion;

import haxepunk.Tween;

typedef MotionTarget = {
	var x(get, set):Float;
	var y(get, set):Float;
}
/**
 * Base class for motion Tweens.
 */
class Motion extends Tween
{
	public var object:MotionTarget;
	
	/**
	 * Current x position of the Tween.
	 */
	public var x:Float = 0;

	/**
	 * Current y position of the Tween.
	 */
	public var y:Float = 0;

	/**
	 * Constructor.
	 * @param	complete	Optional completion callback.
	 * @param	type		Tween type.
	 */
	public function new(?type:TweenType)
	{
		super(0, type);
	}
}
