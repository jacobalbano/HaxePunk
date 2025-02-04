package haxepunk.utils;

import haxe.Timer;

class OncePer {
	public static function seconds(seconds:Float):()->Bool {
		var time = Timer.stamp();
		var accumulator = seconds;
		return () -> {
			var now = Timer.stamp();
			accumulator += (now - time);
			time = now;
			if (accumulator > seconds) {
				accumulator = 0;
				return true;
			}

			return false;
		};
	}
}