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
                            var history:IHistory;
                            @:optional var autocompleter:String -> Array<String>;
                            @:optional var logStatus:Dynamic; // Function where the state comes as firts paramenter
                            @:optional var prompt:String;
                            @:optional var notAllowed:Void -> Void;
                        }

class HxLine {
    public var options:HxLineOptions; // easy serialization
    public function new(terminal:ITerminal, ?autocompleter:String -> Array<String>, ?history:IHistory) {
        this.options = { terminal: terminal,
                         activeBell: true,
                         echoes: true,
                         allowClean: true,
                         history: if (history != null) history else new BasicHistory(),
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
        return hxReadline(newOpts);
    }

    public function hxReadline(options:HxLineOptions):String {
        /* hxReadline with several options as input parameter */

        // Optional options with their defaults:
        if (!Reflect.hasField(options, "prompt")) options.prompt = "HxLine>";
        if (!Reflect.hasField(options, "notAllowed")) options.notAllowed = function() if (options.activeBell) options.terminal.bell();
        if (!Reflect.hasField(options, "autocompleter")||options.autocompleter == null) options.autocompleter = function(s:String){return [s];};

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
                case BackwardSearch: history_loop(previous_status, options, false);
                case ForwardSearch: history_loop(previous_status, options, true);
                // Type system: those are already in the previous switch. I forgot none.
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
        return if (alternatives.length == 0) {
                    options.terminal.bell();
                    prev_state;
                } else {
                    var state = prev_state.copy();
                    state.buffer = Helpers.maximum_common_substring(state.buffer, alternatives);
                    state.cursorPos = state.buffer.length;
                    state;
                };
    }
    static public function history_loop(original_status:HxLineState, options:HxLineOptions, forward:Bool) {
        /*
        Side effect history-query and query-interface and re-renderer. The goal is to end the terminal
        drawn as we found it and return the queary of the user.
        */
        var isForward = forward;
        var current_status:HxLineState =  {
                      prompt: if (isForward) '(i-search)`\': ' else '(reverse-i-search)`\': ',
                      buffer: "",
                      cursorPos:0,
                      yanked:"",
                    };
        // I need this rerender the prompto to show the query interface
        options.terminal.render_status(original_status, current_status);
        var last_drawn = current_status;

        while (true) {
            /*
            invariant:
                previous_status: Internal status of the current history readline
                current_status: Idem, but this one is updated based on user input.
                query: query by user against history (possible match)
                last_drawn: latest drawn status on screen
                isForward: direction of query
                query_further: decides whether the user explicitly wanted to perform again a query
                action: requested by the user requested to do based on its input.
            */
            var previous_status = current_status;
            var query = "";
            var query_further = false;
            var action:Actions = options.terminal.getAction(false);

            switch (action) {
                case Enter: {
                    current_status = original_status.copy();
                    current_status.buffer = query; // rescued value
                    break;
                };
                case Cancel|Eof|Escape: {
                    options.terminal.printNL(); // print the evidence
                    current_status = original_status;
                    break;
                };
                case Clean if (options.allowClean && options.echoes): options.terminal.clean();
                case Bell: { options.terminal.bell(); continue; } // explicitly requested
                case BackwardSearch: {
                    isForward = false;
                    query_further = true;
                }
                case ForwardSearch:  {
                    isForward = true;
                    query_further = true;
                }
                default: true;
            }
            current_status = switch(action) {
                case NewChar(char): TerminalLogic.addChar(char, previous_status);
                case Backspace: TerminalLogic.backspace(previous_status);
                default: previous_status;
            }
            // repeat the query with the new status
            var new_query = if(isForward) options.history.forwardQuery(current_status.buffer, query_further)
                            else options.history.backwardQuery(current_status.buffer, query_further);
            query = if (new_query == null) {
                options.terminal.bell();
                // don't allow to write new chars when nothing will match
                current_status = previous_status;
                query;
            } else new_query;

            // what we paint in the screen is NOT the status but the history-query interface
            var next_drawn = {
                          prompt: if (isForward) '(i-search)`${current_status.buffer}'
                                  else '(reverse-i-search)`${current_status.buffer}',
                          buffer: '\': ' + query,
                          cursorPos:0,
                          yanked:"",
                      };
            options.terminal.render_status(last_drawn, next_drawn);
            last_drawn = next_drawn;
        }
        current_status.prompt = original_status.prompt;
        current_status.cursorPos = current_status.buffer.length;
        // Let it painted as it was before we got in
        options.terminal.render_status(last_drawn, original_status);
        return current_status;
    }
}
