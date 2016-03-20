package hxLine.terminal;
import hxLine.terminal.Actions;

class VT220 implements ITerminal {
    private var _readChar:Dynamic;
    private var _print:Dynamic;
    private var conversionTable:Map<String, Actions>;

    public function new(inputChar:Void ->Int, outputString:String -> Void) {
        this._readChar = inputChar;
        this._print = outputString;
        this.conversionTable = [
             "[27,91,66]" => CursorDown,
             "[27,91,65]" => CursorUp,
             "[27,91,67]" => CursorRight,
             "[27,91,68]" => CursorLeft,
             "[27,98]" => CursorWordLeft,
             "[27,102]" => CursorWordRight,
             "[1]" => CursorBegining,
             "[4]" => Eof,
             "[3]" => Cancel, // c-C
             "[9]" => Ignore, // Tab
             "[5]" => CursorEnd,
             "[21]" => KillLeft,
             "[11]" => KillRight,
             "[12]" => Clean,
             "[25]" => Yank,
             "[127]" => Backspace,
             "[27]" => Escape,
             "[13]" => Enter,
         ];
    }
    public function readChar():Int return this._readChar();
    public function print(msg:String):Void this._print(msg);
    public function printNL():Void this.print("\n");
    public function println(msg:String):Void { this.print(msg); this.printNL(); }
    public function getAction():Actions return this.translate(this.readKeyStroke());

    private inline function translate(k:KeyStroke):Actions {
         return if (!conversionTable.exists(k.toString())) NewChar(String.fromCharCode(k[0]));
         else conversionTable.get(k.toString());
    }

    private inline function readKeyStroke(?AllowEscapeChars:Bool=true):KeyStroke {
        var captured:Array<Int> = [];
        while (true) {
            captured.push(this.readChar());
            if (AllowEscapeChars||captured[0] != 27) {
                switch(captured.toString()) {
                    case "[27,102]"|"[27,98]": break;
                }
                if (captured[0] == 27 && captured.length < 3) continue;
            }
            break;
        }
        return captured;
    }
    private inline function keyStroke_toString(m:Array<Int>):String return m.map(String.fromCharCode).join("");
    public function clean():Void this.print("\x1b[H\x1b[2J");
    public function bell():Void this.print("\x07");
    public function up():Void this.print(this.keyStroke_toString(([27,91,65])));
    public function down():Void this.print(this.keyStroke_toString(([27,91,66])));
    public function right():Void this.print(this.keyStroke_toString(([27,91,67])));
    public function left():Void this.print(this.keyStroke_toString(([27,91,68])));
    public function render_status(previous_status:LineStatus, current_status:LineStatus): Void {
        // TODO: this optimization broke the repaint after a clean was triggered :(
        //if (previous_status.prompt != current_status.prompt||previous_status.buffer != current_status.buffer) {
            // Repaint the whole terminal line (no further optimization yet)
            for (i in 0...previous_status.prompt.length + previous_status.cursorPos) this.left();
            for (i in 0...previous_status.prompt.length + previous_status.buffer.length) this.print(" ");
            for (i in 0...previous_status.prompt.length + previous_status.buffer.length) this.left();
            this.print(current_status.prompt + current_status.buffer);
            // move the cursor back to its new position
            for (i in 0...(current_status.buffer.length - current_status.cursorPos)) this.left();
        /*} else if (current_status.cursorPos != previous_status.cursorPos) {
            // If the only changed thing was the cursor position
            if (current_status.cursorPos > previous_status.cursorPos) {
                for (i in 0...current_status.cursorPos - previous_status.cursorPos) this.right();
            } else {
                for (i in 0... previous_status.cursorPos - current_status.cursorPos) this.left();
            }
        }*/
    }
}
