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
    private var terminal:ITerminal;
    public function new(terminal:ITerminal) { this.terminal=terminal; }
    function readChar() return Sys.getChar(false);

    public function readline(prompt:String):String {
        var current_status = TerminalLogic.newStatus(prompt);
        terminal.print(prompt);
        while (true) {
            var previous_status = current_status;
            // Read single keyStroke and translate it to an action with the terminal Code Table
            var action:Actions = terminal.getAction();
            // Apply ending actions or actions wich have side effects
            switch(action) {
                case Enter: break; // it gonna return what was already in the buffer
                case Cancel: terminal.printNL(); // The rest will restart the buffer
                case Eof if (current_status.buffer.length == 0): return String.fromCharCode(0x0);
                case Eof: { terminal.bell(); continue; } // Not allowed
                case Clean: { terminal.clean(); }; // Back to (0,0)
                case Bell: { terminal.bell(); continue; } // a bell, just that
                case Backspace | CursorLeft if (current_status.cursorPos == 0): { terminal.bell(); continue;}
                case CursorRight if (current_status.cursorPos == current_status.buffer.length): { terminal.bell(); continue;}
                default: true; //pass
            }
            current_status = switch(action) {
                case NewChar(char): TerminalLogic.addChar(char, previous_status);
                case Cancel: TerminalLogic.cancel(previous_status);
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
                // Type system: those are in the previous switch and I am forgot none
                case Eof|Escape|Ignore|Enter|Clean|Bell: previous_status;
            };
            terminal.render_status(previous_status, current_status);
            }
        terminal.printNL();
        return current_status.buffer;
    }
}
