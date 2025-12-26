package hxpy;

class PyExports {
  // Types that should be convertible to Python dicts automatically
  public static final TYPES:Array<String> = [
    "hxpy.KV",
    "hxpy.Person",
    "hxpy.ComplexData",
  ];

  // Static functions to expose from hxpy.Api (name -> exported python name)
  public static final API_FUNCS:Array<{ hx:String, py:String }> = [
    { hx: "add", py: "add" },
    { hx: "buildComplex", py: "build_complex" },
  ];
}
