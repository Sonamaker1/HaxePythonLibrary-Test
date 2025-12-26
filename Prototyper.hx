import Sys;
import hxpy.Api;
class Prototyper {
  static function main() {

    Sys.println("Running Prototyper.main() to test hxpy.Api...");
    var result = Api.add(3, 5);
    Sys.println("Api.add(3, 5) = " + result);

    var hexInput = 0xFF5733;
    var hexResult = Api.hexToRGB(hexInput);

    Sys.println("Api.hexToRGB(0x"+hexToString(hexInput)+") = " + hexResult);

    var rgbInput = hexResult;
    var hexOutput = Api.rgbToHex(rgbInput[0], rgbInput[1], rgbInput[2]);
    Sys.println("Api.rgbToHex(" + rgbInput + ") = " + hexToString(hexOutput));
  }

  static function hexToString(hexIn:Int):String {
    var s = "";
    var hexChars = "0123456789ABCDEF";
    do {
        s = hexChars.charAt(hexIn & 15) + s;
        hexIn >>>= 4;
    } while (hexIn > 0);

    return s;
  }
}
