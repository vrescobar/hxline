package hxLine.terminal;
using Reflect;

class TerminalLogic {
    static inline public function newStatus(?prompt:String="") {
        return {prompt: prompt,
                buffer: "",
                cursorPos:0,
                yanked: ""};
            }
    static inline public function addChar(char:String, status:HxLineState):HxLineState {
        var s2 = status.copy();
        s2.buffer = status.buffer.substring(0, status.cursorPos) + char + status.buffer.substring(status.cursorPos);
        s2.cursorPos = status.cursorPos + 1;
        return s2;
    }

    static inline public function cursorLeft(status:HxLineState):HxLineState
        return if (status.cursorPos > 0) {
                var s2 = status.copy();
                s2.cursorPos = status.cursorPos - 1;
                s2;
        } else status;

    static inline public function cursorRight(status:HxLineState):HxLineState
        return if (status.cursorPos < status.buffer.length) {
                    var s2 = status.copy();
                    s2.cursorPos = status.cursorPos + 1;
                    s2;
                } else status;

    static inline public function cursorBeginning(status:HxLineState):HxLineState {
        var s2 = status.copy();
        s2.cursorPos = 0;
        return s2;
    }
    static inline public function cursorWordLeft(status:HxLineState):HxLineState {
        var s2 = status.copy();
        var after_blank = ~/[" "]+[^" "]/g;
        var last_valid = 0;
        // I am not sure about respecting the inmutability so I work on a copy
        after_blank.map(new String.String(status.buffer), function(r) {
            var found_position:Int = r.matchedPos().pos + r.matchedPos().len - 1;
            if (found_position < status.cursorPos) last_valid = found_position;
            return r.matched(0);
        });
        s2.cursorPos = last_valid;
        return s2;
    }

    static inline public function cursorWordRight(status:HxLineState):HxLineState {
        var s2 = status.copy();
        var blank_after = ~/[^" "]+[" "]/g;
        var min_valid = status.buffer.length;
        // It way MUCH easier to work only after the cursor :)
        blank_after.map(status.buffer.substr(status.cursorPos), function(r) {
            var found_position:Int = r.matchedPos().pos + r.matchedPos().len + status.cursorPos - 1;
            if (found_position < min_valid) min_valid = found_position;
            return r.matched(0);
        });
        s2.cursorPos = min_valid;
        return s2;
    }

    static inline public function yank(status:HxLineState):HxLineState {
        var s2 = status.copy();
        s2.buffer = status.buffer.substring(0, status.cursorPos) + status.yanked + status.buffer.substring(status.cursorPos);
        s2.cursorPos = status.cursorPos + status.yanked.length;
        return s2;
    }

    static inline public function cursorEnd(status:HxLineState):HxLineState {
        var s2 = status.copy();
        s2.cursorPos = status.buffer.length;
        return s2;
    }

    static inline public function killLeft(status:HxLineState):HxLineState {
        var s2 = status.copy();
        s2.cursorPos = 0;
        s2.buffer = status.buffer.substr(status.cursorPos);
        s2.yanked = status.buffer.substr(0, status.cursorPos);
        return s2;
    }

    static inline public function killRight(status:HxLineState):HxLineState {
        var s2 = status.copy();
        s2.buffer = status.buffer.substr(0,status.cursorPos);
        s2.yanked = status.buffer.substr(status.cursorPos);
        return s2;
    }

    static inline public function backspace(status:HxLineState):HxLineState {
        var s2 = status.copy();
        s2.buffer = status.buffer.substr(0, status.cursorPos - 1) + status.buffer.substr(status.cursorPos);
        s2.cursorPos = status.cursorPos - 1;
        return s2;
    }
    static inline public function cancel(status:HxLineState):HxLineState {
        var s2 = status.copy();
        s2.buffer = "";
        s2.cursorPos = 0;
        return s2;
    }
}
