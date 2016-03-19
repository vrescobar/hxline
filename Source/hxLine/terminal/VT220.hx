package hxLine.terminal;
import hxLine.terminal.Actions;

class VT220 {
    public static function translate(k:KeyStroke):Actions {
        var conversionTable:Map<String, Actions> = [
             "[27,91,66]" => CursorDown,
             "[27,91,65]" => CursorUp,
             "[27,91,67]" => CursorRight,
             "[27,91,68]" => CursorLeft,
             "[1]" => CursorBegining,
             "[5]" => CursorEnd,
             "[21]" => KillLeft,
             "[11]" => KillRight,
             "[12]" => Clean,
             "[25]" => Yank, // yank previous removed text, "ctr-y",
             "[127]" => Backspace,
             "[27]" => Escape,
             "[13]" => Enter,
         ];
         return if (!conversionTable.exists(k.toString())) NewChar(String.fromCharCode(k[0]));
         else conversionTable.get(k.toString());
    }
    public static inline function clean(output) output.writeString("\x1b[H\x1b[2J"); // clean && go 0,0
    public static inline function bell(output) output.writeString("\x07");
    public static inline function up(output) output.writeString(to_str([27,91,65]));
    public static inline function down(output) output.writeString(to_str([27,91,66]));
    public static inline function right(output) output.writeString(to_str([27,91,67]));
    public static inline function left(output) output.writeString(to_str([27,91,68]));
    public static inline function to_str(m:Array<Int>):String return m.map(String.fromCharCode).join("");
}
