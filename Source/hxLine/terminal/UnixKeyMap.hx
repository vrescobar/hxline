package hxLine.terminal;
import haxe.Utf8;

typedef KeyStroke = Array<Int>;
class UnixKeyMap{
    // the mac key-map
    public static var keyMap:Map<String, String> = [
         "[27,91,66]" => "down",
         "[27,91,65]" => "up",
         "[5]" => "ctr-e",
         "[12]" => "ctr-l",
         "[27,91,67]" => "right",
         "[1]" => "ctr-a",
         "[27,91,68]" => "left",
         "[11]" => "ctr-k",
         "[25]" => "ctr-y",
         "[127]" => "backspace",
         "[27]" => "esc",
         "[21]" => "ctr-u"
     ];
    public static inline function keyToString(keyStroke:Array<Int>):String{
        return keyStroke.map(String.fromCharCode).join("");
    }
    public static function read_keyMap(printer:Dynamic -> Void):Map<String,KeyStroke> {
            //var ioh = new IOHandler();
            var localKeyMap:Map<String,KeyStroke> = new Map();

            printer("Press [enter] just once:");
            var enter = Sys.getChar(false);
            localKeyMap.set("enter", [enter]);

            for( stroke in ["up", "down", "left", "right", "backspace", "esc", "ctr-a", "ctr-e", "ctr-u", "ctr-k", "ctr-y", "ctr-l"] ) {
                printer("Now press [" + stroke + "] followed by [enter]:");
                var buff = new Array<Int>();
                while( true ) {
                    var ch = Sys.getChar(false);
                    if (ch == enter) break;
                    buff.push(ch);
                }
                localKeyMap.set(stroke, buff);
            }
            return localKeyMap;
        }
}
