package hxLine.history;
using StringTools;

class TextHistory extends BasicHistory {
    public var history_file:String;
    public function new(histfile:String) {
        history_file = histfile;
        // read history from the given file, if failing, then empty
        super(try {
                    var f = sys.io.File.read(history_file);
                    var text = f.readAll().toString();
                    f.close();
                    // ignore empty lines
                    [for (t in text.split("\n")) if (t.trim().length > 0) t];
                } catch(e:Dynamic) {
                    [];
                });
    }
    public function save() {
        /* Write everything in a file and close it */
        var f = sys.io.File.write(history_file);
        f.writeString(this.toArray().join("\n"));
        f.close();
    }
}
