package hxLine.terminal;

enum Actions {  CursorLeft; CursorUp; CursorDown; CursorRight; CursorBegining; CursorEnd;
                KillLeft; KillRight;
                Backspace; Cancel; Clean; Enter; Escape; Bell;
                Ignore; NewChar(c:String);
            }
