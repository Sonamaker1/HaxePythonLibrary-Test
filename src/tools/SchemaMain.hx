package tools;

class SchemaMain {
  static function main() {
    // This is compile-time executed macro that writes the json file.
    tools.PySchema.emit("gen/py_schema.json");
  }
}
