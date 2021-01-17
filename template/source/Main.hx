import haxepunk.Engine;
import haxepunk.HXP;
import haxepunk.World;

class Main extends Engine
{
	public function new()
	{
		super(800, 600, 60, true);
	}

	override public function init()
	{
		super.init();
		HXP.world = new World();
	}

	public static function main() { new Main(); }
}