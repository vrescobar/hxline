
package hxLine;

/***
Various helpers which better tested when separated.
***/
class Helpers {
    public inline static function last_equal(it:String, it2:String):Int {
        var p:Int = 0;
        for( pos in 0...Std.int(Math.min(it.length, it2.length))) {
            if (it.charAt(pos) != it2.charAt(pos)) break;
            p = pos;
        }
        return p;
    }
}
