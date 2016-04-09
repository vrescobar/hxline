import Sys;
import haxe.Utf8;
using StringTools;

import hxLine.HxLine;
import hxLine.terminal.ITerminal;
import hxLine.Helpers;

// Let's try to create a beautyful command line!
class Main {

    static private var help = 'Type "quit" to exit';
    static function main() {
        // create a System Terminal, fully autodetected and self configured
        var terminal = Helpers.detectTerminal();
        // Create an autocompleter function for our commands (using a helper for the default)
        var autocompleter = Helpers.mkAutocompleter(terminal, ["quit", "exit", "clean", "readchar", "passwd",
                                                               "recordTC", "help", "hxLine", "echo"]);
        // Before we start the session, print the help for the user
        terminal.println(help);

        // Initialize the readline reader, passing it a terminal and the autocompleter
        var rl = new HxLine(terminal, autocompleter);

        while(true) {
            // Read a line with the given prompot
            var line:String = rl.readline("$> ");
            // Special cases, such as a given Eof:
            if (line.charCodeAt(0) == 0x0) { terminal.println("exit"); break; }
            if (line.trim().length == 0) continue;
            // Embedded commands that I offer in my command line:
            switch (line) {
                case "quit"|"exit": break;
                case "clean": terminal.clean();
                case "readchar": readchars(terminal.print, Sys.getChar);
                case "passwd": askpwd(terminal, rl);
                case "recordTC": Helpers.recordTC(terminal, rl);
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
        terminal.println("bye!");
    }

    static public function askpwd(terminal:ITerminal, rl:HxLine) {
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
