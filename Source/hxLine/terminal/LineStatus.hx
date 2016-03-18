package hxLine.terminal;

enum LSActions {
    NewChar;
    CursorPos;
    Clean;
    HistoryPrev;
    HistoryNext;
}
typedef LineStatus =  {
          var prompt:String;
          var buffer:String;
          var cursorPos:Int;
          var echoes:Bool;
          @:optional var action:LSActions;
      }
