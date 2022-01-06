import 'dart:io' show Directory, Platform;
import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import "package:path/path.dart" show join;
import 'dart:convert';

typedef String_String_int32_funcType = Pointer<Utf8> Function(
    Pointer<Utf8> str, Int32 length);
typedef String_String_int_funcType = Pointer<Utf8> Function(
    Pointer<Utf8> str, int length);

class libReadUtils {
  static late DynamicLibrary? preferences = null;
  static late Map FuncMap;

  static bool getInstance() {
    if (preferences == null) {
      preferences = DynamicLibrary.open("libReadUtils.so");
      FuncMap = {
        "Split": preferences!.lookupFunction<String_String_int32_funcType,
            String_String_int_funcType>("Split"),
        "LoadFile": preferences!.lookupFunction<String_String_int32_funcType,
            String_String_int_funcType>("LoadFile"),
      };
      return true;
    }
    return true;
  }

  static void test() {
    /*final helloWorld =
        preferences.lookupFunction<Int32 Function(), int Function()>("test");
    try {
      final funHandle =
          preferences.lookup<NativeFunction<String_String_funcType>>("Hello2");
      final thisFun = funHandle
          .asFunction<Pointer<Utf8> Function(Pointer<Utf8> str, int length)>();

      var str = StringUtf8Pointer("更多精校小说尽在新奇书网下载：http://www.xsqishu.com")
          .toNativeUtf8();

      var r = Utf8Pointer(thisFun(str, str.length)).toDartString();

      //free(funHandle);
      return r;
    } catch (e) {
      return "null:${e}";
    }*/
    //var aa = test1();
    //return helloWorld();
  }

  static int Split(Uint8List data, String Pattern) {
    try {
      final funHandle = FuncMap["Split"] as String_String_int_funcType;
      /*var str = StringUtf8Pointer("更多精校小说尽在新奇书网下载：http://www.xsqishu.com")
          .toNativeUtf8();*/
      var str = toNativeUtf8(data);
      //var str = StringUtf8Pointer("更多精校小说尽在新奇书网下载：http://ww0000000000000000000w.xsqishu.com")
      //    .toNativeUtf8();

      //var str1 = StringUtf8Pointer(Pattern).toNativeUtf8();

      var r = Utf8Pointer(funHandle(str, str.length)).toDartString();

      //free(funHandle);
      return r.length;
    } catch (e) {
      return 1;
    }
  }

  static String LoadFile(String data) {
    try {
      final funHandle = FuncMap["LoadFile"] as String_String_int_funcType;
      /*var str = StringUtf8Pointer("更多精校小说尽在新奇书网下载：http://www.xsqishu.com")
          .toNativeUtf8();*/
      var path = StringUtf8Pointer(data).toNativeUtf8();
      //var str = toNativeUtf8(data);
      //var str = StringUtf8Pointer("更多精校小说尽在新奇书网下载：http://ww0000000000000000000w.xsqishu.com")
      //    .toNativeUtf8();

      //var str1 = StringUtf8Pointer(Pattern).toNativeUtf8();

      var r = Utf8Pointer(funHandle(path, path.length)).toDartString();

      //free(funHandle);
      return r;
    } catch (e) {
      return "";
    }
  }

  static Pointer<Utf8> toNativeUtf8(Uint8List units,
      {Allocator allocator = malloc}) {
    final Pointer<Uint8> result = allocator<Uint8>(units.length + 1);
    final Uint8List nativeString = result.asTypedList(units.length + 1);
    nativeString.setAll(0, units);
    nativeString[units.length] = 0;
    return result.cast();
  }
}

String _platformPath(String name, {String path = ''}) {
  if (Platform.isMacOS) return path + "lib" + name + ".dylib";
  if (Platform.isLinux || Platform.isAndroid)
    return path + "lib" + name + ".so";
  if (Platform.isWindows) return path + name + ".dll";
  throw Exception("Platform not implemented");
}
