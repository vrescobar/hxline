package hxLine.terminal;
using Reflect;

class TerminalLogic {
    static inline public function newStatus(?prompt:String="") return {prompt: prompt, buffer: "", cursorPos:0, yanked:""};
    static inline public function addChar(char:String, status:LineStatus):LineStatus {
        var s2 = status.copy();
        s2.buffer = status.buffer.substring(0, status.cursorPos) + char + status.buffer.substring(status.cursorPos, status.buffer.length);
        s2.cursorPos = status.cursorPos + 1;
        return s2;
    }

    static inline public function cursorLeft(status:LineStatus):LineStatus
        return if (status.cursorPos > 0) {
                var s2 = status.copy();
                s2.cursorPos = status.cursorPos - 1;
                s2;
        } else status;

    static inline public function cursorRight(status:LineStatus):LineStatus
        return if (status.cursorPos < status.buffer.length) {
                    var s2 = status.copy();
                    s2.cursorPos = status.cursorPos + 1;
                    s2;
                } else status;

    static inline public function cursorBeginning(status:LineStatus):LineStatus {
        var s2 = status.copy();
        s2.cursorPos = 0;
        return s2;
    }
    static inline public function cursorEnd(status:LineStatus):LineStatus {
        var s2 = status.copy();
        s2.cursorPos = status.buffer.length;
        return s2;
    }
    static inline public function killLeft(status:LineStatus):LineStatus {
        var s2 = status.copy();
        s2.cursorPos = 0;
        s2.buffer = status.buffer.substr(status.cursorPos);
        return s2;
    }
    static inline public function killRight(status:LineStatus):LineStatus {
        var s2 = status.copy();
        s2.buffer = status.buffer.substr(0,status.cursorPos);
        return s2;
    }
    static inline public function backspace(status:LineStatus):LineStatus {
        var s2 = status.copy();
        s2.buffer = status.buffer.substr(0, status.cursorPos - 1) + status.buffer.substr(status.cursorPos);
        s2.cursorPos = status.cursorPos - 1;
        return s2;
    }
}
