import Sys;
import haxe.Utf8;
using StringTools;
import hxLine.HxLine;
import hxLine.terminal.XTERM_VT100;

class Main {
    static function main() {
        //Sys.println(Utf8.decode("Reading your keymap, please follow the next instructions:"));
        //var km:Map<String,hxLine.terminal.UnixKeyMap.KeyStroke> = hxLine.terminal.UnixKeyMap.read_keyMap(Sys.println);
        /*var s = new haxe.Serializer();
        s.serialize(km);
        Sys.println(s.toString());
        Sys.println("And now directly:");*/
        //Sys.println(haxe.Json.stringify(km));
        //Sys.println("Bell " + "\x0F");
        //trace(haxe.Json.stringify(hxLine.terminal.UnixKeyMap.read_keyMap(Sys.println)));
        main2();

    }
    static function main2() {
        var output = Sys.stdout();
        var terminal = new XTERM_VT100(output);

        var rl = new HxLine(output);
        var help = 'Type "quit" to exit';
        terminal.println(help);
        while(true) {
            var line:String = rl.readline("$> ");
            //terminal.println(line);
            switch (line) {
                case "quit"|"exit": break;
                case ""|"\n": continue;
                case "clean": terminal.clean();
                default: {
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

}
