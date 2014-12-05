import 'dart:html';
import 'package:captcha/captcha.dart';

void main() {
  var e = querySelector('#captcha');
  captcha(e, () => e.insertAdjacentHtml('afterEnd', '<h1>Validated!</h1>'));
}
