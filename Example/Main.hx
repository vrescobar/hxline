import Sys;
import haxe.Utf8;
using StringTools;

import hxLine.HxLine;
//import hxLine.terminal.VT220;

class Main {
    static function main2() {
        var s:hxLine.terminal.LineStatus = {prompt: "", buffer: "", cursorPos:0, yanked:""};
        var f = function(s:hxLine.terminal.LineStatus) {
            var s2 = Reflect.copy(s);
            s2.cursorPos = 9;
            return s2;
        }
        trace("s0:" + s);
        trace("s2:" + f(s));
        trace("s1:" + s);

    }
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
    static function main() {
        var output = Sys.stdout();
        var println = function(msg) : Void { output.writeString(msg+"\n"); };

        var rl = new HxLine(output);
        var help = 'Type "quit" to exit';
        println(help);
        while(true) {
            var line:String = rl.readline("$> ");
            switch (line) {
                case "q"|"\n"|"quit"|"exit": break;
                case "": continue;
                case "clean": hxLine.terminal.VT220.clean(output);
                case "readchar": readchars(output.writeString);
                default: {
                    var command:Array<Dynamic> = [line.split(" ")[0], line.split(" ").slice(1)] ;
                    switch command {
                        case ["help", _]: println(help);
                        case ["echo", to_echo]: println(to_echo.join(' '));
                        default: println('${line}: command not found');
                    }
                }
            }
        }
    }
    static inline function readchars(print:String -> Void): Void {
        print("Ends when pressing [ENTER]: ");
        var char = Sys.getChar(false);
        print("" + char);
        while (true) {
            char = Sys.getChar(false);
            if (char == 13) break;
            print(", " + char);
        };
        print("\n");
    }
}
