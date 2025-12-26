package hxpy;

@:pyDict
@:valueType
class Person {
  @:pyName("name") public var name:String;
  @:pyName("age") public var age:Int;

  public inline function new(name:String = "", age:Int = 0) {
    this.name = name;
    this.age = age;
  }
}
