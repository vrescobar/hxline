using StringTools;

class EasyExample {
    static var allowed_commands = ["hello", "helloWorld", "quit"];
    static function main() {
        var terminal = hxLine.Helpers.detectTerminal();
        var autocompleter = hxLine.Helpers.mkAutocompleter(terminal, allowed_commands);
        var rl = new hxLine.HxLine(terminal, autocompleter);

        terminal.println("Press Control + D or type \"quit\" to exit");
        while(true) {
            // Read a line with the given prompt
            var line:String = rl.readline("greet-CLI $ ");
            if (line == "quit" || line.charCodeAt(0) == 0x0) break;
            if (line.length == 0) continue;
            if (line == "helloWorld") {
                terminal.println("你好!");
            } else if (line.startsWith("hello")) {
                terminal.println('Hi ${line.substring("hello".length).trim()}!');
            } else {
                terminal.println('Please use one of these commands: ${allowed_commands.join(" ")}');
                continue;
            }
            rl.options.history.addEntry(line);
        }
        terminal.println("ĝis poste!");
    }
}
