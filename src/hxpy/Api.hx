package hxpy;

class Api {
  @:pyExport("add")
  public static function add(a:Int, b:Int):Int {
    return a + b;
  }

  @:pyExport("build_complex")
  public static function buildComplex():ComplexData {
    var d = new ComplexData();

    d.counts.push(new KV("apples", 3));
    d.counts.push(new KV("oranges", 5));
    d.counts.push(new KV("bananas", 2));

    d.values = [1, 2, 3, 4, 5];

    d.people.push(new Person("Alice", 30));
    d.people.push(new Person("Bob", 41));

    return d;
  }
}
