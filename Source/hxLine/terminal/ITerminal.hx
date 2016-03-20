
package hxLine.terminal;

interface ITerminal {
    public function readChar():Int; // blocking read a char / KeyStroke
    public function print(msg:String):Void;
    public function printNL():Void; // The creation of a new line
    public function println(msg:String):Void; // Prints msg and newline
    public function getAction():Actions;
    public function clean():Void; // clean && moe cursor to 0,0
    public function bell():Void;
    public function up():Void;
    public function down():Void;
    public function right():Void;
    public function left():Void;
    public function render_status(previous_status:LineStatus, current_status:LineStatus): Void;
}
