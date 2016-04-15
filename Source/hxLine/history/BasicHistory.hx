
package hxLine.history;
import hxLine.history.IHistory;


class BasicHistory implements IHistory {
    private var arr:Array<String>;
    private var possibleBuffer:String;
    private var pos:Int;

    public function new(?existing_history:Array<String>) {
        arr = if (existing_history != null) existing_history else new Array<String>();
        possibleBuffer = "";
        pos = arr.length;
    }
    public function addEntry(current:String):String {
        if (arr.length == 0) {
            arr.push(current);
            pos = 1;
            return current;
        }
        arr.push(current);
        pos = arr.length;
        return current;
    }
    public function prev(current:String):String {
        if (pos == arr.length) possibleBuffer = current;
        if (arr.length == 0||pos == 0) {
            return current;
        }
        if (pos < arr.length) arr[pos] = current;
        pos = pos - 1;
        return arr[pos];
    }
    public function next(current:String):String {
        if (pos == arr.length) {
            return current;
        }
        pos = pos + 1;
        var c = if (pos == arr.length) this.possibleBuffer else arr[pos];
        return c;

    }
    public function toArray():Array<String> {
        return arr.copy();
    }


}
