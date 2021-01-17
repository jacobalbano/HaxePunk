package haxepunk.debug;

import haxepunk.graphics.text.BitmapText;
import haxepunk.input.MouseManager;
import haxepunk.utils.Draw;

@:access(haxepunk.World)
private class LayerToggle extends Entity
{
	public var layerNumber:Null<Int>;

	var label:BitmapText;

	public function new(mouseManager:MouseManager)
	{
		super();
		label = new BitmapText("Layer", {size: 12});
		label.alpha = 0.75;
		addGraphic(label);
		width = 220;
		height = 18;
		type = mouseManager.type;
		mouseManager.add(this, null, onClick, onEnter, onExit, true);
	}

	override public function update()
	{
		visible = collidable = layerNumber != null;
		if (layerNumber != null)
		{
			var entityCount = HXP.world._layers.exists(layerNumber) ? Lambda.count(HXP.world._layers[layerNumber]) : 0;
			var txt = "Layer " + layerNumber + " [" + entityCount + "]";
			if (label.text != txt) label.text = txt;
			label.color = HXP.world.layerVisible(layerNumber) ? 0x00ff00 : 0xff0000;
		}
	}

	function onClick()
	{
		if (layerNumber != null)
		{
			var display = !HXP.world.layerVisible(layerNumber);
			HXP.world.showLayer(layerNumber, display);
			HXP.world.updateLists();
		}
	}

	function onEnter() label.alpha = 1;
	function onExit() label.alpha = 0.75;
}

@:access(haxepunk.World)
class LayerList extends EntityList<LayerToggle>
{
	var alpha:Float = 0.5;
	var mouseManager:MouseManager;
	var worldLabel:BitmapText;
	var childY:Int = 8;

	public function new(mouseManager:MouseManager)
	{
		super();
		this.mouseManager = mouseManager;
		width = 240;
		height = 320;

		worldLabel = new BitmapText("World", {size: 12});
		worldLabel.x = 10;
		worldLabel.y = childY;
		childY += worldLabel.textHeight;
		graphic = worldLabel;

		type = mouseManager.type;
		mouseManager.add(this, null, null, onEnter, onExit);
	}

	override public function update()
	{
		super.update();

		var layerCount = HXP.world._layerList.length;
		while (entities.length < layerCount)
		{
			var toggle = new LayerToggle(mouseManager);
			add(toggle);
			toggle.localY = childY;
			childY += toggle.height + 4;
		}

		for (i in 0 ... entities.length)
		{
			entities[i].layerNumber = i >= HXP.world._layerList.length ? null : HXP.world._layerList[i];
			entities[i].update();
		}

		var txt = Type.getClassName(Type.getClass(HXP.world));
		if (worldLabel.text != txt) worldLabel.text = txt;
	}

	override public function render(camera:Camera)
	{
		var fsx:Float = camera.screenScaleX,
			fsy:Float = camera.screenScaleY;
		Draw.setColor(0, alpha);
		Draw.lineThickness = 4;
		Draw.rectFilled((x - 2) * fsx, y * fsy, (width + 4) * fsx, height * fsy);

		super.render(camera);
	}

	function onEnter() alpha = 0.75;
	function onExit() alpha = 0.5;
}
