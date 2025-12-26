package hxpy;

class Api {
  @:pyExport("add")
  public static function add(a:Int, b:Int):Int {
    return a + b;
  }

  @:pyExport("hexToRGB")
  public static function hexToRGB(hexIn:Int):Array<String>{
    var s1:String = "";
		var s2:String = "";
		var s3:String = "";
		var hexChars = "0123456789ABCDEF";
		do {
      if(s3.length < 2)
        s3 = hexChars.charAt(hexIn & 15) + s3;
      else if(s2.length < 2)
        s2 = hexChars.charAt(hexIn & 15) + s2;
      else if(s1.length < 2)
			  s1 = hexChars.charAt(hexIn & 15) + s1;
			hexIn >>>= 4;
		} while (hexIn > 0);

    return [s1, s2, s3];
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
