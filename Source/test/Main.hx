//import hxLine.terminal.VT220;
import hxLine.Helpers;
import haxe.unit.TestCase;

class MyTestCase extends haxe.unit.TestCase {
  public function test_last_equal() {
     assertEquals(Helpers.last_equal("", ""), 0);
     assertEquals(Helpers.last_equal("abc", ""), 0);
     assertEquals(Helpers.last_equal("", " "), 0);
     assertEquals(Helpers.last_equal("abc", "a12"), 0);
     assertEquals(Helpers.last_equal("ab", "abc"), 1);
     assertEquals(Helpers.last_equal("abc", "a12"), 0);

     assertEquals(Helpers.last_equal("1234", "123"), 2);
     assertEquals(Helpers.last_equal("123", "1234"), 2);
     assertEquals(Helpers.last_equal("1234567890", "1234567890"), 9);
     assertEquals(Helpers.last_equal(" 1234567890", "1234567890"), 0);
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
