import Sys;
import haxe.Utf8;
using StringTools;

import hxLine.HxLine;
import hxLine.terminal.VT220;

class Main {
    static function readcharmap() {
        //Sys.println(Utf8.decode("Reading your keymap, please follow the next instructions:"));
        //var km:Map<String,hxLine.terminal.UnixKeyMap.KeyStroke> = hxLine.terminal.UnixKeyMap.read_keyMap(Sys.println);
        /*var s = new haxe.Serializer();
        s.serialize(km);
        Sys.println(s.toString());
        Sys.println("And now directly:");*/
        //Sys.println(haxe.Json.stringify(km));
        //Sys.println("Bell " + "\x0F");
        //trace(haxe.Json.stringify(hxLine.terminal.UnixKeyMap.read_keyMap(Sys.println)));
    }
    static private var help = 'Type "quit" to exit';
    static function main() {
        var output = Sys.stdout();
        var terminal = new VT220(function(){ return Sys.getChar(false); },
                                 output.writeString);
        var rl = new HxLine(terminal);

        terminal.println(help);
        while(true) {
            var line:String = rl.readline("$> ");
            // Special cases:
            if (line.charCodeAt(0) == 0x0) { terminal.println("exit"); break; }
            if (line.trim().length == 0) continue;
            // Commands:
            switch (line) {
                case "q"|"quit"|"exit": break;
                case "clean": terminal.clean();
                case "readchar": readchars(output.writeString, Sys.getChar);
                default: {
                    // complex commands:
                    var command:Array<Dynamic> = [line.split(" ")[0], line.split(" ").slice(1)] ;
                    switch command {
                        case ["help", _]: terminal.println(help);
                        case ["echo", to_echo]: terminal.println(to_echo.join(' '));
                        default: terminal.println('${line}: command not found');
                    }
                }
            }
        }
    }
    static inline function readchars(print:String -> Void, getChar:Bool -> Int): Void {
        print("Ends when pressing [ENTER]: ");
        var char = getChar(false);
        print("" + char);
        while (true) {
            char = getChar(false);
            if (char == 13) break;
            print(", " + char);
        };
        print("\n");
    }
}
