
package hxLine.history;

interface IHistory {
    public var max_length:Null<Int>;
    public function addEntry(current:String):String;
    public function backwardQuery(query:String, skip_current:Bool):Null<String>;
    public function forwardQuery(query:String, skip_current:Bool):Null<String>;
    public function prev(current:String):String;
    public function next(current:String):String;
    public function toArray():Array<String>;
}
