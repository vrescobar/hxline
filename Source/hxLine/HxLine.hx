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
using Reflect;

import hxLine.history.IHistory;
import hxLine.history.BasicHistory;

import hxLine.terminal.Actions;
import hxLine.terminal.ITerminal;
import hxLine.terminal.HxLineState;
import hxLine.terminal.TerminalLogic;


typedef HxLineOptions = {
                            var activeBell:Bool;
                            var echoes:Bool; // when deactivated, clean can't work
                            var allowClean:Bool;
                            var terminal:ITerminal;
                            @:optional var autocompleter:String -> Array<String>;
                            @:optional var logStatus:Dynamic; // Function where the state comes as firts paramenter
                            @:optional var prompt:String;
                            @:optional var notAllowed:Void -> Void;
                            @:optional var history:IHistory;
                        }

class HxLine {
    public var options:HxLineOptions; // easy serialization
    public function new(terminal:ITerminal, ?history:IHistory, ?autocompleter:String -> Array<String>) {
        this.options = { terminal: terminal,
                         activeBell: true,
                         echoes: true,
                         allowClean: true,
                         history: history,
                         autocompleter: autocompleter,
                        };


    }

    public function readline(prompt:String):String {
        /* default readline, ready to use out of the box */
        var newOpts = Reflect.copy(this.options);
        newOpts.prompt = prompt;
        return hxReadline(newOpts);
    }

    public function readpasswd(prompt:String):String {
        /* default readline, ready to use out of the box */
        var newOpts = Reflect.copy(this.options);
        newOpts.prompt = prompt;
        newOpts.echoes = false;
        // newOpts.allowClean = false; // It will be anyway deactivated
        return hxReadline(newOpts);
    }

    public function hxReadline(options:HxLineOptions):String {
        /* hxReadline with several options as input parameter */

        // Optional options with their defaults:
        if (!Reflect.hasField(options, "prompt")) options.prompt = "HxLine>";
        if (!Reflect.hasField(options, "notAllowed")) options.notAllowed = function() if (options.activeBell) options.terminal.bell();
        if (!Reflect.hasField(options, "autocompleter")||options.autocompleter == null) options.autocompleter = function(s:String){return [s];};
        if (!Reflect.hasField(options, "history")||options.history == null) options.history = new BasicHistory();

        var logStatus = if (Reflect.hasField(options, "logStatus")) options.logStatus else function(l:HxLineState){};
        // Initialize and start looping
        var current_status:HxLineState = TerminalLogic.newStatus(options.prompt);
        options.terminal.print(options.prompt);
        while (true) {
            var previous_status = current_status;
            // Read single keyStroke and translate it to an action with the terminal Code Table
            var action:Actions = options.terminal.getAction();
            // Side effects actions (including quitting ones)
            switch(action) {
                case Enter: break; // it gonna return what was already in the buffer
                case Cancel: options.terminal.printNL(); // The rest will restart the buffer
                case Eof if (current_status.buffer.length == 0): return String.fromCharCode(0x0);
                case Eof: { options.notAllowed(); continue; }
                case Clean if (options.allowClean && options.echoes): options.terminal.clean(); // needs to re-render
                case Bell: { options.terminal.bell(); continue; } // explicitly requested
                case Backspace | CursorLeft if (current_status.cursorPos == 0): { options.notAllowed(); continue;}
                case CursorRight if (current_status.cursorPos == current_status.buffer.length): { options.notAllowed(); continue;}
                default: true; //pass
            }
            // We keep in the history the current edition
            //options.history.addEntry(current_status.buffer);

            // Here comes the logic update of the terminal
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
                case Autocomplete: autocompletion(previous_status, options);
                case CursorUp: TerminalLogic.history_prev(previous_status, options.history);
                case CursorDown: TerminalLogic.history_next(previous_status, options.history);
                // Type system: those are in the previous switch and I am forgot none
                case Eof|Escape|Ignore|Enter|Clean|Bell: previous_status;
                };

            if (options.echoes) options.terminal.render_status(previous_status, current_status);
            logStatus(current_status);
        }
        options.terminal.printNL();
        return current_status.buffer;
    }
    private inline static function autocompletion(prev_state:HxLineState, options:HxLineOptions):HxLineState {
        var alternatives = options.autocompleter(prev_state.buffer);
        var state = prev_state.copy();
        switch(alternatives.length) {
            case 0: options.terminal.bell();
            case 1: {
                    state.buffer = alternatives[0];
                    state.cursorPos = state.buffer.length;
                }
        }

        return state;
    }
}
