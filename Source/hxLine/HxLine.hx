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
import hxLine.terminal.TerminalLogic;
using StringTools;
import Lambda;

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
            var previous_status = Reflect.copy(current_status);
            // Read single keyStroke and translate it to an action with the terminal Code Table
            var action:Actions = VT220.translate(this.readKeyStroke());
            // Apply ending actions or actions with side effects
            switch(action) {
                case Enter: break; // return with what it was in the buffer
                case Cancel: return "";
                case Clean: { VT220.clean(output);
                              this.print(prompt + current_status.buffer); };
                case Bell: VT220.bell(output);
                case Backspace if (current_status.cursorPos == 0): VT220.bell(output);
                case CursorLeft if (current_status.cursorPos == 0): VT220.bell(output);
                case CursorRight if (current_status.cursorPos == current_status.buffer.length): VT220.bell(output);
                default: true; //pass
            }
            current_status = switch(action) {
                case NewChar(char): TerminalLogic.addChar(char, previous_status);
                case CursorLeft: TerminalLogic.cursorLeft(previous_status);
                case CursorRight: TerminalLogic.cursorRight(previous_status);
                case CursorEnd: TerminalLogic.cursorEnd(previous_status);
                case CursorBegining: TerminalLogic.cursorBeginning(previous_status);
                case KillLeft: TerminalLogic.killLeft(previous_status);
                case KillRight: TerminalLogic.killRight(previous_status);
                // To be implemented
                case CursorUp | CursorDown | Backspace: previous_status;
                // Type system r00lz
                default: Reflect.copy(previous_status);
                //case Escape | Ignore | Enter | Cancel | Clean | Bell: previous_status;
            }
            // Repaint the terminal and move the cursor to its new position. NOTE: it does not worth to optimize yet
            for (i in 0...previous_status.cursorPos+previous_status.prompt.length) VT220.left(output);
            for (i in 0...previous_status.cursorPos+previous_status.prompt.length) this.print(" ");
            for (i in 0...previous_status.cursorPos+previous_status.prompt.length) VT220.left(output);
            this.print(current_status.prompt + current_status.buffer);
            for (i in 0...(current_status.buffer.length - current_status.cursorPos)) VT220.left(output);
        }
        this.print('\n');
        return current_status.buffer;
    }

    public function readKeyStroke():KeyStroke {
        return [this.readChar()];
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
