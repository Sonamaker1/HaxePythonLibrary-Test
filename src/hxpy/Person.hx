package hxpy;

@:valueType
class Person {
  public var name:String;
  public var age:Int;

  public inline function new(name:String = "", age:Int = 0) {
    this.name = name;
    this.age = age;
  }
}