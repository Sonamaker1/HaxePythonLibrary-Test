package tools;

import haxe.macro.Context;
import haxe.macro.Expr;

#if macro
import haxe.Json;
import haxe.macro.Type;
import sys.FileSystem;
import sys.io.File;
#end

class PySchema {
  /**
   * Run at compile-time via:
   *   --macro tools.PySchema.emit("gen/py_schema.json", "hxpy")
   */
  public static macro function emit(outPath:String = "gen/py_schema.json", rootPkg:String = "hxpy"):Expr {
    #if macro
    final moduleNames = collectModuleNames(rootPkg);

    // IMPORTANT: initialize exports too so it always exists
    final schema:Dynamic = { classes: [], exports: [] };

    for (m in moduleNames) {
      final types = Context.getModule(m); // Array<Type>
      for (t in types) {
        switch (t) {
          case TInst(c, _):
            final cls = c.get();
            if (cls.isExtern) continue;

            final fullName = (cls.pack.length == 0) ? cls.name : (cls.pack.join(".") + "." + cls.name);
            final cppOwner = fullName.split(".").join("::");

            // ---- 1) Capture @:pyExport on static methods for ALL classes ----
            for (sf in cls.statics.get()) {
              if (!sf.isPublic) continue;

              // NOTE: your metadata is @:pyExport("name"), so we fetch the string
              final pyExportName = getMetaString(sf.meta.get(), ":pyExport", null);
              if (pyExportName == null) continue;

              switch (Context.follow(sf.type)) {
                case TFun(args, ret):
                  final argSchema:Array<Dynamic> = [];
                  for (a in args) {
                    argSchema.push({
                      name: a.name,
                      type: typeToSchema(Context.follow(a.t))
                    });
                  }

                  (schema.exports : Array<Dynamic>).push({
                    pyName: pyExportName,
                    hxName: sf.name,
                    owner: fullName,     // "hxpy.Api"
                    cppOwner: cppOwner,  // "hxpy::Api"
                    args: argSchema,
                    ret: typeToSchema(Context.follow(ret))
                  });

                default:
                  // not a function, ignore
              }
            }

            // ---- 2) Capture @:pyDict instance fields ONLY for @:pyDict classes ----
            if (hasMeta(cls.meta.get(), ":pyDict")) {
              final fields:Array<Dynamic> = [];
              for (f in cls.fields.get()) {
                if (!f.isPublic) continue;
                if (!f.kind.match(FVar(_, _))) continue;
                if (hasMeta(f.meta.get(), ":pyIgnore")) continue;

                final pyName = getMetaString(f.meta.get(), ":pyName", f.name);
                fields.push({
                  name: f.name,
                  pyName: pyName,
                  type: typeToSchema(Context.follow(f.type))
                });
              }

              (schema.classes : Array<Dynamic>).push({
                name: fullName,
                cppName: cppOwner,
                fields: fields
              });
            }

          default:
        }
      }
    }

    // ensure output dir exists
    final parts = outPath.split("/");
    parts.pop();
    final dir = parts.join("/");
    if (dir != "" && !FileSystem.exists(dir)) FileSystem.createDirectory(dir);

    File.saveContent(outPath, Json.stringify(schema, "  "));
    Context.info("Wrote " + outPath, Context.currentPos());
    #end

    return macro null;
  }

  #if macro
  static function collectModuleNames(rootPkg:String):Array<String> {
    final rel = rootPkg.split(".").join("/");

    final modules:Array<String> = [];

    for (cp in Context.getClassPath()) {
      var base = StringTools.replace(cp, "\\", "/");
      if (base != "" && StringTools.endsWith(base, "/")) base = base.substr(0, base.length - 1);

      final root = base + "/" + rel;
      if (!FileSystem.exists(root) || !FileSystem.isDirectory(root)) continue;

      collectRec(root, rootPkg, modules);
    }

    // de-dupe
    final seen = new Map<String, Bool>();
    final out:Array<String> = [];
    for (m in modules) if (!seen.exists(m)) { seen.set(m, true); out.push(m); }
    return out;
  }

  static function collectRec(dir:String, pkg:String, out:Array<String>):Void {
    for (name in FileSystem.readDirectory(dir)) {
      final p = dir + "/" + name;
      if (FileSystem.isDirectory(p)) {
        collectRec(p, pkg + "." + name, out);
      } else if (StringTools.endsWith(name, ".hx")) {
        final base = name.substr(0, name.length - 3);
        if (StringTools.startsWith(base, "_")) continue;
        out.push(pkg + "." + base);
      }
    }
  }

  static function hasMeta(meta:Array<haxe.macro.Expr.MetadataEntry>, name:String):Bool {
    for (m in meta) if (m.name == name) return true;
    return false;
  }

  static function getMetaString(meta:Array<haxe.macro.Expr.MetadataEntry>, name:String, fallback:Null<String>):Null<String> {
    for (m in meta) {
      if (m.name == name && m.params != null && m.params.length == 1) {
        switch (m.params[0].expr) {
          case EConst(CString(s)): return s;
          default:
        }
      }
    }
    return fallback;
  }

  static function typeToSchema(t:Type):Dynamic {
    return switch (t) {
      case TAbstract(a, _):
        final n = a.get().name;
        if (n == "Int") { kind: "int" }
        else if (n == "Float") { kind: "float" }
        else if (n == "Bool") { kind: "bool" }
        else if (n == "String") { kind: "string" }
        else { kind: "unknown", name: n };

      case TInst(c, params):
        final cls = c.get();
        final name = cls.name;
        final full = (cls.pack.length == 0) ? name : (cls.pack.join(".") + "." + name);

        // Normalize String regardless of how it shows up
        if (full == "String" || name == "String") {
          return { kind: "string" };
        }

        if (name == "Array" && params.length == 1) {
          return { kind: "array", elem: typeToSchema(Context.follow(params[0])) };
        } else {
          return { kind: "object", name: full, cppName: full.split(".").join("::") };
        }

      default:
        { kind: "unknown" };
    }
  }
  #end
}
