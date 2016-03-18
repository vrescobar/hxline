/**
 *   Copyright (c) Victor R. Escobar. All rights reserved.
 *   The use and distribution terms for this software are covered by the
 *   Eclipse Public License 1.0 (http://opensource.org/licenses/eclipse-1.0.php)
 *   which can be found in the file epl-v10.html at the root of this distribution.
 *   By using this software in any fashion, you are agreeing to be bound by
 * 	 the terms of this license.
 *   You must not remove this notice, or any other, from this software.
 **/
package hxLine;

import hxLine.terminal.ITerminal;
import hxLine.terminal.UnixKeyMap;
using StringTools;
import Lambda;


typedef KeyStroke = Array<Int>;

class HxLine {
    private var output:Dynamic;
    private var terminal:ITerminal;

    public function new(output:Dynamic) {
        this.output = output;
        terminal = new hxLine.terminal.XTERM_VT100(output);
    }

    public function readline(prompt:String, ?echo:Bool=true):String {
        var charints:KeyStroke = [];
        var previous_status = { buffer: "",
                                prompt: prompt,
                                cursorPos: 0,
                                echoes: echo}
        terminal.print(prompt);
        while (true) {
            terminal = new hxLine.terminal.XTERM_VT100(this.output, previous_status);
            var r = this.readKeyStroke();

            // move back the cursor temporary
            var left = [27,91,68].map(String.fromCharCode).join("");
            for (i in 0...(previous_status.prompt.length + previous_status.buffer.length)) terminal.print(left);

            if (r.length == 0) continue;
            if (r.length == 1 && r[0] == 13) break;
            charints = charints.concat(r);
            var potential_action = charints.toString();

            previous_status = if (terminal.Stroke2Action.exists(potential_action))
                                    terminal.Stroke2Action.get(potential_action)();
                              else {
                                  var new_state = terminal.status;
                                  new_state.buffer = new_state.buffer + to_str(r);
                                  new_state;
                              };
            terminal.print(previous_status.prompt + previous_status.buffer);
            ////var left = [27,91,68].map(String.fromCharCode).join("");
            ////for (i in 0...(previous_status.prompt.length + previous_status.buffer.length)) terminal.print(left);
            //terminal.print(previous_status.prompt + previous_status.buffer);
            //terminal.cursorBegin();
        }
        terminal.println(prompt + previous_status.buffer);
        return previous_status.buffer;
    }
    public static inline function to_str(m:Array<Int>):String {
        return m.map(String.fromCharCode).join("");
    }

    public function readKeyStroke():KeyStroke {
        var charints:KeyStroke = new Array<Int>();
        while(true) {
            charints.push(terminal.readChar());
            if (UnixKeyMap.keyMap.exists(charints.toString())) break;
            else if (charints[0] == 27) continue;
            else {
                if (Lambda.exists(UnixKeyMap.keyMap,
                        function (strokeChain):Bool { return strokeChain.toString().startsWith(charints.toString().substr(-1));})) {
                    continue;
                }
                break;
            }
        }
        return charints;
    }
}

/*typedef void(linenoiseCompletionCallback)(const char *, linenoiseCompletions *);
void linenoiseSetCompletionCallback(linenoiseCompletionCallback *);
void linenoiseAddCompletion(linenoiseCompletions *, const char *);

char *linenoise(const char *prompt);
int linenoiseHistoryAdd(const char *line);
int linenoiseHistorySetMaxLen(int len);
int linenoiseHistorySave(const char *filename);
int linenoiseHistoryLoad(const char *filename);
void linenoiseClearScreen(void);
void linenoiseSetMultiLine(int ml);
void linenoisePrintKeyCodes(void);*/
