package hxpy;

@:valueType
class ComplexData {
  // "map<string,int>" represented as Array<KV>
  public var counts:Array<KV>;

  // arrays
  public var values:Array<Int>;
  public var people:Array<Person>;

  public inline function new() {
    counts = [];
    values = [];
    people = [];
  }
}
