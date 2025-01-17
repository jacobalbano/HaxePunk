package haxepunk.ds;

import haxe.Exception;

// TODO: migrate `Grid` to use this class

class DataGrid<T> {
    public var columns(default, null):Int;
    public var rows(default, null):Int;

    public function new(columns:Int, rows:Int, defaultValue:(c:Int, r:Int) -> T) {
        this.columns = columns;
        this.rows = rows;

        for (r in 0...rows) {
            var row = [];
            data.push(row);
            for (c in 0...columns) {
                row.push(defaultValue(c, r));
            }
        }
    }

    public function setTile(column:Int, row:Int, value:T) {
        if (!checkTile(column, row)) return;
        data[row][column] = value;
    }

    public function setRect(column:Int = 0, row:Int = 0, width:Int = 1, height:Int = 1, valueFactory:(c:Int, r:Int) -> T) {
        for (r in row...(row + height))
            for (c in column...(column + width))
                setTile(c, r, valueFactory(c, r));
    }

    public function getTile(column:Int, row:Int) {
        if (!checkTile(column, row)) throw new Exception("Tile index was outside the grid");
        return data[row][column];
    }

    public function clone():DataGrid<T> {
        return new DataGrid(columns, rows, (c, r) -> getTile(c, r));
    }
    
	public inline function checkTile(column:Int, row:Int):Bool {
        return !(column < 0 || column > columns - 1 || row < 0 || row > rows - 1);
    }

    private var data:Array<Array<T>> = [];
}