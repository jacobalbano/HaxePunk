package haxepunk;

import openfl.Assets;
import haxepunk.Signal;
import haxepunk.debug.Console;
import haxepunk.graphics.hardware.HardwareRenderer;
import haxepunk.input.Input;
import haxepunk.math.Random;
import haxepunk.math.Rectangle;
import haxepunk.utils.Draw;
import haxepunk.App;

/**
 * Main game Sprite class, added to the Stage.
 * Manages the game loop.
 *
 * Your main class **needs** to extends this.
 */
class Engine
{
	public var console:Console;

	/**
	 * If the game should stop updating/rendering.
	 */
	public var paused:Bool = false;

	/**
	 * Cap on the elapsed time (default at 30 FPS). Raise this to allow for lower framerates (eg. 1 / 10).
	 */
	public var maxElapsed:Float = 0.0333;

	/**
	 * The max amount of frames that can be skipped in fixed framerate mode.
	 */
	public var maxFrameSkip:Int = 5;

	/**
	 * Invoked before the update cycle begins each frame.
	 */
	public var preUpdate:Signal0 = new Signal0();
	/**
	 * Invoked after update cycle.
	 */
	public var postUpdate:Signal0 = new Signal0();
	/**
	 * Invoked before rendering begins each frame.
	 */
	public var preRender:Signal0 = new Signal0();
	/**
	 * Invoked after rendering completes.
	 */
	public var postRender:Signal0 = new Signal0();
	/**
	 * Invoked after the screen is resized.
	 */
	public var onResize:Signal0 = new Signal0();
	/**
	 * Invoked when input is received.
	 */
	public var onInputPressed:Signals = new Signals();
	/**
	 * Invoked when input is received.
	 */
	public var onInputReleased:Signals = new Signals();
	/**
	 * Invoked after the world is switched.
	 */
	public var onWorldSwitch:Signal0 = new Signal0();
	/**
	 * Invoked when the application is closed.
	 */
	public var onClose:Signal0 = new Signal0();

	/**
	 * Constructor. Defines startup information about your game.
	 * @param	width			The width of your game.
	 * @param	height			The height of your game.
	 * @param	frameRate		The game framerate, in frames per second.
	 * @param	fixed			If a fixed-framerate should be used.
	 */
	public function new(width:Int = 0, height:Int = 0, frameRate:Float = 60, fixed:Bool = false)
	{
		// global game properties
		HXP.bounds = new Rectangle(0, 0, width, height);
		HXP.assignedFrameRate = frameRate;
		HXP.fixed = fixed;

		// global game objects
		HXP.engine = this;
		HXP.width = width;
		HXP.height = height;

		HXP.screen = new Screen();
		HXP.app = app = createApp();

		// miscellaneous startup stuff
		if (Random.randomSeed == 0) Random.randomizeSeed();

		HXP.entity = new Entity();
		HXP.time = app.getTimeMillis();

		_frameList = new Array();

		_iterator = new VisibleWorldIterator();

		app.init();
	}

	/**
	 * @private This should be the only place an App instance is created
	 */
	function createApp():App
	{
		return new App(this);
	}

	/**
	 * Override this, called after Engine has been added to the stage.
	 */
	public function init() {}

	/**
	 * Override this, called when game gains focus
	 */
	public function focusGained() {}

	/**
	 * Override this, called when game loses focus
	 */
	public function focusLost() {}

	/**
	 * Updates the game, updating the World and Entities.
	 */
	public function update()
	{
		if (HXP.needsResize)
		{
			HXP.resize(HXP.windowWidth, HXP.windowHeight);
		}

		_world.updateLists();
		checkWorld();

		preUpdate.invoke();
		_world.preUpdate.invoke();

		if (HXP.tweener.active && HXP.tweener.hasTween) HXP.tweener.updateTweens(HXP.elapsed);
		if (_world.active)
		{
			if (_world.hasTween) _world.updateTweens(HXP.elapsed);
			_world.update();
		}
		_world.updateLists(false);

		_world.postUpdate.invoke();
		postUpdate.invoke();
	}

	/**
	 * Called from backend renderer. Any visible world will have its draw commands rendered to OpenGL.
	 */
	public function onRender()
	{
		// timing stuff
		var t:Float = app.getTimeMillis();
		if (paused)
		{
			_frameLast = t; // continue updating frame timer
			if (!Console.enabled) return; // skip rendering if paused and console is not enabled
		}
		if (_frameLast == 0) _frameLast = Std.int(t);

		preRender.invoke();

		_renderer.startFrame();
		for (world in _iterator.reset(this))
		{
			_renderer.startWorld(world);
			HXP.renderingWorld = world;
			world.render();
			for (commands in world.batch)
			{
				_renderer.render(commands);
			}
			_renderer.flushWorld(world);
		}
		HXP.renderingWorld = null;
		_renderer.endFrame();

		postRender.invoke();

		// more timing stuff
		t = app.getTimeMillis();
		_frameListSum += (_frameList[_frameList.length] = Std.int(t - _frameLast));
		if (_frameList.length > 10) _frameListSum -= _frameList.shift();
		HXP.frameRate = 1000 / (_frameListSum / _frameList.length);
		_frameLast = t;
	}

	/** @private Framerate independent game loop. */
	public function onUpdate()
	{
		_time = _gameTime = app.getTimeMillis();
		HXP._systemTime = _time - _systemTime;
		_updateTime = _time;

		// update timer
		var elapsed = (_time - _last) / 1000;
		if (HXP.fixed)
		{
			_elapsed += elapsed;
			HXP.elapsed = 1 / HXP.assignedFrameRate;
			if (_elapsed > HXP.elapsed * maxFrameSkip) _elapsed = HXP.elapsed * maxFrameSkip;
			while (_elapsed > HXP.elapsed)
			{
				_elapsed -= HXP.elapsed;
				step();
			}
		}
		else
		{
			HXP.elapsed = elapsed;
			if (HXP.elapsed > maxElapsed) HXP.elapsed = maxElapsed;
			HXP.elapsed *= HXP.rate;
			step();
		}
		_last = _time;

		// update timer
		_time = app.getTimeMillis();
		HXP._updateTime = _time - _updateTime;

		// update timer
		_time = _systemTime = app.getTimeMillis();
		HXP._gameTime = _time - _gameTime;
	}

	function step()
	{
		// update input
		Input.update();

		// update loop
		if (!paused) update();

		// update console
		if (console != null) console.update();

		Input.postUpdate();
	}

	/** @private Switch worlds if they've changed. */
	inline function checkWorld()
	{
		if (_world != null && _worlds.length > 0 && _worlds[_worlds.length - 1] != _world)
		{
			Log.debug("ending world: " + Type.getClassName(Type.getClass(_world)));
			_world.end();
			_world.updateLists(false);
			if (_world.autoClear && _world.hasTween) _world.clearTweens();

			_world = _worlds[_worlds.length - 1];

			onWorldSwitch.invoke();

			Log.debug("starting world: " + Type.getClassName(Type.getClass(_world)));
			_world.assetCache.enable();
			_world.updateLists();
			if (_world.started) _world.resume();
			else _world.begin();
			_world.started = true;
			_world.updateLists(true);
		}
	}

	/**
	 * Push a world onto the stack. It will not become active until the next update.
	 * @param value  The world to push
	 * @since	2.5.3
	 */
	public function pushWorld(value:World):Void
	{
		Log.debug("pushed world: " + Type.getClassName(Type.getClass(_world)));
		_worlds.push(value);
	}

	/**
	 * Pop a world from the stack. The current world will remain active until the next update.
	 * @since	2.5.3
	 */
	public function popWorld():World
	{
		Log.debug("popped world: " + Type.getClassName(Type.getClass(_world)));
		var world = _worlds.pop();
		if (world.assetCache.enabled)
		{
			world.assetCache.dispose();
		}
		return world;
	}

	/**
	 * The currently active World object. When you set this, the World is flagged
	 * to switch, but won't actually do so until the end of the current frame.
	 */
	public var world(get, set):World;
	inline function get_world():World return _world;
	function set_world(value:World):World
	{
		if (_world == value) return value;
		if (_worlds.length > 0)
		{
			popWorld();
		}
		_worlds.push(value);
		return _world;
	}

	public function iterator() return _iterator.reset(this);

	var app:App;

	// World information.
	var _world:World = new World();
	var _worlds:Array<World> = new Array<World>();

	// Timing information.
	var _delta:Float = 0;
	var _time:Float = 0;
	var _last:Float = 0;
	var _rate:Float = 0;
	var _skip:Float = 0;
	var _prev:Float = 0;
	var _elapsed:Float = 0;

	// Debug timing information.
	var _updateTime:Float = 0;
	var _gameTime:Float = 0;
	var _systemTime:Float = 0;

	// FrameRate tracking.
	var _frameLast:Float = 0;
	var _frameListSum:Int = 0;
	var _frameList:Array<Int>;

	var _renderer:HardwareRenderer = new HardwareRenderer();

	var _iterator:VisibleWorldIterator;
}

private class VisibleWorldIterator
{
	public function new() {}

	public inline function hasNext():Bool
	{
		return worlds.length > 0;
	}

	public inline function next():World
	{
		return worlds.pop();
	}

	@:access(haxepunk.Engine)
	public function reset(engine:Engine):VisibleWorldIterator
	{
		HXP.clear(worlds);

		if (engine.console != null)
		{
			worlds.push(engine.console);
		}

		var world:World;
		var i = engine._worlds.length - 1;
		while (i >= 0)
		{
			world = engine._worlds[i];
			if (world.visible && world.started)
			{
				worlds.push(world);
			}
			// if this world has a solid background, stop adding worlds
			if (world.bgAlpha == 1) break;
			--i;
		}
		return this;
	}

	var worlds:Array<World> = [];
}
