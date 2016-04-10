
package hxLine.history;

interface IHistory {
    public function addEntry(s:String):String;
    public function pop():String;
    //public function query(String);
    public function prev():String;
    public function next():String;
    public function dump():Array<String>;
    //public function iter():Iterable<String>;
}
