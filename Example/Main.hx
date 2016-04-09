import Sys;
import haxe.Utf8;
using StringTools;

import hxLine.HxLine;
import hxLine.terminal.VT220;

class Main {
    static private var help = 'Type "quit" to exit';
    static function main() {
        var output = Sys.stdout();
        var terminal = new VT220(function(){ return Sys.getChar(false); },
                                 output.writeString);

        terminal.println(help);

        var rl = new HxLine(terminal, function (query:String) {
                        /* input is query output is list of candidates */
                        var list_autocomplete = ["quit", "exit", "clean", "readchar", "passwd",
                                                 "recordTC", "help", "hxLine",
                                                 "echo"];
                        var suggestions = [for(str in list_autocomplete) if (str.startsWith(query)) str];
                        if (suggestions.length > 1) {
                            terminal.println("");
                            terminal.println("Too many options");
                        }
                        return suggestions;
                    });




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
                case "passwd": askpwd(terminal, rl);
                case "recordTC": recordTC(terminal, rl);
                case "hxLine": terminal.println("In the Beginning... Was the Command Line");
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

    static public function recordTC(terminal:VT220, rl:HxLine) {
        terminal.println("This demo shows how all internal state, key by key, is tracked and recorded.");

        var options = Reflect.copy(rl.options);
        var logging_system = new Array<Dynamic>();

        options.prompt = "(recording)";
        options.logStatus = logging_system.push;

        rl.hxReadline(options);
        terminal.println("Done:\n" + logging_system.join('\n'));
    }
    static public function askpwd(terminal:VT220, rl:HxLine) {
        var pass = rl.readpasswd("Introduce an example of password (it will be printed)\npasswd: ");
        terminal.println("here comes your password: " + pass);
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

class History {
    private var arr:Array<String>;
    function new(){
        arr = new Array<String>();
    }
    function push(s:String) return arr.push(s);
    function prev(ref):String return arr[ref-1];
    function next(ref):String return arr[ref+1];
    function hasNext(ref):Bool return false;
    function hasPrev(ref):Bool return false;
}
