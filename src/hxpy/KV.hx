package hxpy;

@:valueType
class KV {
  public var key:String;
  public var value:Int;

  public inline function new(key:String = "", value:Int = 0) {
    this.key = key;
    this.value = value;
  }
}
