package haxepunk;

@:allow(haxepunk.ComponentList)
abstract class Component {
    public var entity(get, never):Null<Entity>;
    inline function get_entity():Entity return _entity;

    public var world(get, never):Null<World>;
    inline function get_world():World return _entity?.world;

    public function addedToEntity() {
        
    }

    public function addedToWorld() {
        
    }
    
    public function update() {

    }

    public function removedFromEntity() {

    }

    public function removedFromWorld() {

    }

    private var _entity:Entity;
}