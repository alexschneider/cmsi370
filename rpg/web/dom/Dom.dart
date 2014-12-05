library dom;

import 'dart:html';
import 'dart:async';
import 'dart:js';
import '../api/Diabolical.dart';
import 'package:captcha/captcha.dart';

part 'ButtonListeners.dart';
part 'HtmlGeneration.dart';
part 'Modals.dart';

Set<int> savedCharacterIds() {
  var saved = window.localStorage['saved'];
  return saved != null && saved != ''?
         saved.split(r',').map(int.parse).toSet() :
         new Set<int>();
}
void toggleSavedCharacter(DiabolicalCharacter c) {
  var savedCharacters = savedCharacterIds();
  if (savedCharacters.contains(c.id)) {
    savedCharacters.remove(c.id);
  } else {
    savedCharacters.add(c.id);
  }
  window.localStorage['saved'] = savedCharacters.join(',');
}