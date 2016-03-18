
package hxLine.terminal;

interface ITerminal {
    public var Stroke2Action:Map<String, Void -> Dynamic>;
    public var status:LineStatus;
    public function readChar():Int;
    public function print(msg:String):LineStatus;
    public function println(msg:String):LineStatus;
    public function clean():LineStatus;
    public function cancel():LineStatus;
    public function bell():LineStatus;
    public function left():LineStatus;
    public function right():LineStatus;
    public function cursorBegin():LineStatus;
    public function cursorEnd():LineStatus;
    //public var history:IHistory;
    //public function name():String;
    //public function name():String;
    //public function name():String;
}
