package hxpy;

class Api {
  @:pyExport("add")
  public static function add(a:Int, b:Int):Int {
    return a + b;
  }

  @:pyExport("hexToRGB")
  public static function hexToRGB(hexIn:Int):Array<Float>{
		var red = (hexIn >> 16) & 0xFF;   
    var green = (hexIn >> 8) & 0xFF;
    var blue = hexIn & 0xFF;

    return [red/255.0, green/255.0, blue/255.0];
  }

  @:pyExport("rgbToHex")
  public static function rgbToHex(red:Float, green:Float, blue:Float):Int {
    var int_red = Math.round(red * 255.0);
    var int_green = Math.round(green * 255.0);
    var int_blue = Math.round(blue * 255.0);

    return (int_red << 16) | (int_green << 8) | int_blue;
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
