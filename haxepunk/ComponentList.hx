package haxepunk;

private enum Operation {
    Add(component:Component);
    Remove(component:Component);
}

class ComponentList {
    public function new(owner:Entity) {
        _entity = owner;
    }

    public function add<TComponent:Component>(component:TComponent):TComponent {
        operationBuffer.push(Add(component));
        return component;
    }

    public function remove<TComponent:Component>(component:TComponent):TComponent {
        operationBuffer.push(Remove(component));
        return component;
    }

    public function addedToWorld() {
        for (c in components) {
            c.addedToWorld();
        }
    }
    
    public function removedFromWorld() {
        for (c in components) {
            c.removedFromWorld();
        }
    }

    public function update() {
        for (c in components) {
            c.update();
        }
    }

    public function updateLists() {
        if (operationBuffer.length == 0) return;
        for (op in operationBuffer) {
            switch (op) {
                case Add(c):
                    if (!components.contains(c)) {
                        components.push(c);
                        c._entity = _entity;
                        c.addedToEntity();
                        if (_entity.world != null)
                            c.addedToWorld();
                    }
                case Remove(c):
                    if (components.remove(c)) {
                        c.removedFromEntity();
                        if (_entity.world != null)
                            c.removedFromWorld();
                        c._entity = null;
                    }
            }
        }
        
        operationBuffer = [];
    }

    private var _entity:Entity;
    private var components:Array<Component> = [];
    private var operationBuffer:Array<Operation> = [];
}