package hxLine.terminal;

enum Actions {  CursorLeft; CursorUp; CursorDown; CursorRight; CursorBegining; CursorEnd; CursorWordLeft; CursorWordRight;
                KillLeft; KillRight; Yank;
                Backspace; Cancel; Clean; Enter; Escape; Bell; Eof;
                Autocomplete;
                Ignore; NewChar(c:String);
            }
