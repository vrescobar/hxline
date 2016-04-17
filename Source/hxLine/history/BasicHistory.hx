
package hxLine.history;
import hxLine.history.IHistory;
using hxLine.Helpers;

class BasicHistory implements IHistory {
    public var max_length:Null<Int>=null;
    private var arr:Array<String>;
    private var possibleBuffer:String;
    private var pos:Int;

    public function new(?existing_history:Array<String>) {
        arr = if (existing_history != null) existing_history else new Array<String>();
        possibleBuffer = "";
        pos = arr.length;
    }
    private function cut_length():Void {
        if (max_length != null && arr.length > max_length){
            var elems_to_remove = if (arr.length - max_length < 0) 0 else arr.length - max_length;
            arr.splice(0, elems_to_remove);
        }
    }
    public function addEntry(current:String):String {
        if (arr.length == 0) {
            arr.push(current);
            pos = 1;
            return current;
        }
        arr.push(current);
        cut_length();
        pos = arr.length;
        possibleBuffer = "";
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
    public function backwardQuery(query:String, skip_current:Bool):Null<String> {
        /* Performs a backwards query discover the first matching history entry containing query.
        If skip_current is set false, the query will search also in the current position.
        */
        var querable_array = arr.copy();
        querable_array.push(possibleBuffer);
        var res:Null<String> = null;
        var it = pos;
        if (!skip_current && querable_array[pos].contains(query)) return querable_array[pos];
        while (--it >= 0) { //why range operator can't iterate backwards?
            var possible = querable_array[it];
            if (possible.contains(query)){
                pos = it;
                return possible;
                }
        }
        return res;
    }

    public function forwardQuery(query:String, skip_current:Bool):Null<String> {
        /* Performs a forwards query discover the first matching history entry containing query.
        If skip_current is set false, the query will search also in the current position.
        */
        var querable_array = arr.copy();
        querable_array.push(possibleBuffer);
        var res:Null<String> = null;
        for (it in pos...querable_array.length) {
            var possible = querable_array[it];
            if (!skip_current && querable_array[pos].contains(query)) return querable_array[pos];
            if (possible.contains(query)){
                pos = it;
                res = possible;
                }
        }
        return res;
    }
    public function toArray():Array<String> {
        return arr.copy();
    }
}
