
package hxLine.history;
import hxLine.history.IHistory;


class BasicHistory implements IHistory {
    private var arr:Array<String>;
    private var pos:Int;

    public function new() {
        arr = new Array<String>();
    }
    public function addEntry(s:String):String {
        if (arr.length == 0) {
            arr.push(s);
            pos = 0;
            return s;
        }
        arr.push(s);
        pos = arr.length - 1;
        return s;
    }
    public function pop():String {
        if (arr.length == 0) return "";
        var s = arr.pop();
        if (pos >= arr.length - 1) pos = arr.length - 1;
        return s;
    }
    public function prev():String {
        if (arr.length == 0) return "";
        var s = arr[pos];
        if (pos > 0) pos = pos - 1;
        return s;
    }
    public function next():String {
        if (arr.length == 0) return "";
        var s = arr[pos];
        if (pos < arr.length - 1) pos = pos + 1;
        return s;
    }
    public function dump():Array<String> {
        return arr;
    }


}
