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
import hxLine.terminal.*;

class HxLine {
    private var output:Dynamic;
    public function new(output:Dynamic) { this.output = output; }
    function readChar() return Sys.getChar(false);
    function print(msg) this.output.writeString(msg);
    function println(msg) this.print(msg+"\n");

    public function readline(prompt:String, ?echo:Bool=true):String {
        var current_status = TerminalLogic.newStatus(prompt);
        this.print(prompt);
        while (true) {
            var previous_status = current_status;
            // Read single keyStroke and translate it to an action with the terminal Code Table
            var action:Actions = VT220.translate(this.readKeyStroke());
            // Apply ending actions or actions wich have side effects
            switch(action) {
                case Enter: break; // it gonna return what was already in the buffer
                case Cancel: return "";
                case Eof if (current_status.buffer.length == 0): return String.fromCharCode(0x0);
                case Eof: { VT220.bell(output); continue;} // Not allowed
                case Clean: { VT220.clean(output); }; // Back to (0,0)
                case Bell: { VT220.bell(output); continue; } // a bell, just that
                case Backspace | CursorLeft if (current_status.cursorPos == 0): { VT220.bell(output); continue;}
                case CursorRight if (current_status.cursorPos == current_status.buffer.length): { VT220.bell(output); continue;}
                default: true; //pass
            }
            current_status = switch(action) {
                case NewChar(char): TerminalLogic.addChar(char, previous_status);
                case Backspace: TerminalLogic.backspace(previous_status);
                case CursorLeft: TerminalLogic.cursorLeft(previous_status);
                case CursorRight: TerminalLogic.cursorRight(previous_status);
                case CursorEnd: TerminalLogic.cursorEnd(previous_status);
                case CursorBegining: TerminalLogic.cursorBeginning(previous_status);
                case KillLeft: TerminalLogic.killLeft(previous_status);
                case KillRight: TerminalLogic.killRight(previous_status);
                case CursorWordLeft: TerminalLogic.cursorWordLeft(previous_status);
                case CursorWordRight: TerminalLogic.cursorWordRight(previous_status);
                case Yank: TerminalLogic.yank(previous_status);
                // To be implemented
                case CursorUp | CursorDown : previous_status;
                // Type system r00lz
                default: previous_status;
                //case Escape|Ignore|Enter|Cancel|Clean|Bell: previous_status;
            };

            if (previous_status.prompt != current_status.prompt||previous_status.buffer != current_status.buffer) {
                // Repaint the whole terminal line (no further optimization yet)
                for (i in 0...previous_status.prompt.length + previous_status.cursorPos) VT220.left(output);
                for (i in 0...previous_status.prompt.length + previous_status.buffer.length) this.print(" ");
                for (i in 0...previous_status.prompt.length + previous_status.buffer.length) VT220.left(output);
                this.print(current_status.prompt + current_status.buffer);
                // move the cursor back to its new position
                for (i in 0...(current_status.buffer.length - current_status.cursorPos)) VT220.left(output);
            } else if (current_status.cursorPos != previous_status.cursorPos) {
                // If the only changed thing was the cursor position
                if (current_status.cursorPos > previous_status.cursorPos) {
                    for (i in 0...current_status.cursorPos - previous_status.cursorPos) VT220.right(output);
                } else {
                    for (i in 0... previous_status.cursorPos - current_status.cursorPos) VT220.left(output);
                }
            }

        }
        this.print('\n');
        return current_status.buffer;
    }

    public function readKeyStroke(?AllowEscapeChars:Bool=true):KeyStroke {
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
