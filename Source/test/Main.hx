//import hxLine.terminal.VT220;
import hxLine.Helpers;
import haxe.unit.TestCase;

class MyTestCase extends haxe.unit.TestCase {
  public function test_last_equal() {
     assertEquals(Helpers.last_equal_char("", ""), 0);
     assertEquals(Helpers.last_equal_char("abc", ""), 0);
     assertEquals(Helpers.last_equal_char("", " "), 0);
     assertEquals(Helpers.last_equal_char("abc", "a12"), 0);
     assertEquals(Helpers.last_equal_char("ab", "abc"), 1);
     assertEquals(Helpers.last_equal_char("abc", "a12"), 0);

     assertEquals(Helpers.last_equal_char("1234", "123"), 2);
     assertEquals(Helpers.last_equal_char("123", "1234"), 2);
     assertEquals(Helpers.last_equal_char("1234567890", "1234567890"), 9);
     assertEquals(Helpers.last_equal_char(" 1234567890", "1234567890"), 0);

     assertEquals(Helpers.last_equal_char("hello", "hello"), 4);
     assertEquals(Helpers.last_equal_char("hello", "helloWorld"), 4);
  }
}

class Main {
  static function main() {
    var r = new haxe.unit.TestRunner();
    // add TestCases here
    r.add(new MyTestCase());


    // finally, run the tests
    r.run();
  }
}
