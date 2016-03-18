package hxLine.terminal;

class XTERM_VT100 implements ITerminal {
    //public static var Stroke2Action:Map<String, String> = [];
    private var output:haxe.io.Output;
    public var status: LineStatus;
    public var Stroke2Action:Map<String, Void -> Dynamic>;

    public function new(out:haxe.io.Output, ?previousState:Null<LineStatus>=null){
        output = out;
        status = if (previousState == null)
                    {prompt: "", buffer: "", cursorPos:0, echoes:true}
                else previousState;

        Stroke2Action = [
             /*"[27,91,66]" => "down",
             "[27,91,65]" => "up",*/
             "[5]" => this.cursorEnd,
             "[12]" => this.clean,
             "[27,91,67]" => this.right,
             "[1]" => this.cursorBegin,
             /*"[27,91,68]" => "left",
             "[11]" => "ctr-k",
             "[25]" => "ctr-y",
             "[127]" => "backspace",
             "[27]" => "esc",
             "[21]" => "ctr-u"*/
         ];
    }
    inline public function print(msg:String):LineStatus {
        this.output.writeString(msg);
        return this.status;
    }
    
    public function println(msg:String):LineStatus {
        this.print(msg + "\n");
        return this.status;
    }

    public function clean():LineStatus {
        this.print("\x1b[H\x1b[2J");
        return this.status;
    }
    public function cancel():LineStatus {
        return {
            prompt: this.status.prompt,
            buffer: "",
            cursorPos: 0,
            echoes: this.status.echoes,
        };
    }
    public function readChar():Int{
        return Sys.getChar(false);
    }

    public function bell():LineStatus {
        this.print("\x07");
        return this.status;
    }

    public function left():LineStatus {
        return if (this.status.cursorPos > 0) {
             {
                prompt: this.status.prompt,
                buffer: this.status.buffer,
                cursorPos: this.status.cursorPos - 1,
                echoes: this.status.echoes,
             }
        } else this.status;
    }

    public function right():LineStatus {
        return if (this.status.cursorPos < this.status.buffer.length) {
             {
                buffer: this.status.buffer,
                cursorPos: this.status.cursorPos + 1,
                echoes: this.status.echoes,
                prompt: this.status.prompt,
             }
        } else this.status;
    }
    public function cursorBegin():LineStatus {
        return {
                prompt: this.status.prompt,
                buffer: this.status.buffer,
                cursorPos: 0,
                echoes: this.status.echoes,
             };
    }
    public function cursorEnd():LineStatus {
        return {
                prompt: this.status.prompt,
                buffer: this.status.buffer,
                cursorPos: this.status.buffer.length,
                echoes: this.status.echoes,
             };
    }
}
