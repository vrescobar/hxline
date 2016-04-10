package hxLine;

using StringTools;
import hxLine.terminal.*;
/***
Various helpers which are better tested and distributed when separated.
***/
class Helpers {
    public inline static function last_equal(it:String, it2:String):Int {
        var p:Int = 0;
        for( pos in 0...Std.int(Math.min(it.length, it2.length))) {
            if (it.charAt(pos) != it2.charAt(pos)) break;
            p = pos;
        }
        return p;
    }
    public static inline function detectTerminal(): ITerminal {
        /**
        Discovers the terminal which you are using in the current system and returns you the instance
        of that equivalent ITerminal class
         **/
        var output = Sys.stdout();
        var inp = function() { return Sys.getChar(false); };
        var outp = output.writeString;
        return new VT220(inp, outp);
    }
    static public function recordTC(terminal:ITerminal, rl:HxLine) {
        terminal.println("This demo shows how all internal state, key by key, is tracked and recorded.");

        var options = Reflect.copy(rl.options);
        var logging_system = new Array<Dynamic>();

        options.prompt = "(recording)";
        options.logStatus = logging_system.push;

        rl.hxReadline(options);
        terminal.println("Done:\n" + logging_system.join('\n'));
    }

    public static function mkAutocompleter(terminal:ITerminal, list_to_autocomplete:Array<String>):String->Array<String> {
        /**
        Returns a function which behaves as a minimally competent autocompleter.
        **/
        return function (query:String) {
                /* input is query output is list of candidates */
                var suggestions = [for(str in list_to_autocomplete) if (str.startsWith(query)) str];

                // if we got one or no match, return already :)
                if (suggestions.length <= 1) return suggestions;
                // if our string is contained don't make any suggestion
                if (query.trim().length > 0) for(sug in suggestions) if (sug == query.trim()) return [];

                // Show some suggestions in the screen:
                terminal.printNL();
                for(curr in 0...suggestions.length) {
                    terminal.print(suggestions[curr] + "  ");
                    // Too many suggestions? prompts user whether it wants more:
                    /* // At the moment that is not working fine
                    if (curr % 3 == 0 && curr < suggestions.length) {
                        terminal.printNL();
                        terminal.print('${suggestions.length - curr} results omitted... show more? [Y/N]');
                        switch (String.fromCharCode(terminal.readChar())) {
                        case "Y"|"y":
                            terminal.printNL();
                            continue;
                        default:
                            break;
                        }
                    }*/
                }
                terminal.printNL();
                return suggestions;
            };
        }
}
