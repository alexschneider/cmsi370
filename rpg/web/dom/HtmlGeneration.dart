part of dom;

void updateFieldsFromCharacter(DiabolicalCharacter char) {
  var el = getCharacterElements();

  el['name'].value = char.name;
  if (char.gender != null) {
    var gender = char.gender.toLowerCase();
    el['gender-$gender'].checked = true;
  }
  el['class'].value = char.classType;
  el['level'].value = char.level.toString();
  el['money'].value = char.money.toString();
}

Map<String, InputElement> getCharacterElements() => {
    'name': querySelector('#character-name'),
    'gender-male': querySelector('#character-gender-male'),
    'gender-female': querySelector('#character-gender-female'),
    'class': querySelector('#character-class'),
    'level': querySelector('#character-level'),
    'money': querySelector('#character-money')
};

void generateModalFromCharacters(Iterable<DiabolicalCharacter> characters) {
  var characterListImport = (querySelector('#list-characters-page') as
                                LinkElement).import;
  var listTemplate = characterListImport.querySelector('#character-table');
  var characterTable = document.importNode(listTemplate.content, true);

  var rows = characters.map((e) => generateRowFromCharacter(e, characterListImport));

  characterTable.querySelector('tbody').children.addAll(rows);
  characterTable.querySelectorAll('.sort').forEach((Element e) =>
      e.onClick.listen(handleSort));
  querySelector('#list-characters').children
                                    ..clear()
                                    ..addAll(characterTable.children);

}

TableRowElement generateRowFromCharacter(DiabolicalCharacter character,
                                         Document import) {
  var idBase = '.list-character';
  var rowTemplate = import.querySelector('$idBase-row');
  TableRowElement row = document.importNode(rowTemplate.content.querySelector
                                        ('tr'), true);
  row.querySelector('$idBase-name').text = character.name;
  row.querySelector('.gender-symbol-${character.gender.toLowerCase()}')
      ..classes.remove('hide');
  row.querySelector('$idBase-classtype').text = character.classType;
  row.querySelector('$idBase-level').text = character.level.toString();
  row.querySelector('$idBase-money').text = character.money.toString();
  row.querySelector('.use').onClick.listen((_) => handleUseCharacter(character));
  row.querySelector('.modify').onClick.listen((_) => handleModifyCharacter(character));
  var delete = row.querySelector('.delete');
  delete.onClick.listen((_) => handleDeleteCharacter(character, delete, row));

  return row;
}

void generateCharacterModal([DiabolicalCharacter fromCharacter]) {
  var characterImport = (querySelector('#create-edit-character-page')
      as LinkElement).import;
  var characterTemplate = characterImport.querySelector('#create-edit-character');
  DocumentFragment characterForm = document.importNode(characterTemplate.content, true);
  var headerText, buttonText, callback;
  var verifiedHuman = false;
  if (fromCharacter == null) { // We are creating a new character
    headerText = "Create a new character";
    buttonText = "Create";
    callback = handleCreate;
  } else { // we are modifying an existing character
    headerText = "Modify an existing character";
    buttonText = "Modify";
    callback = (Event e) => handleModify(e, fromCharacter);
  }

  captcha(characterForm.querySelector('#character-captcha'),
          () => verifiedHuman = true);

  characterForm
      ..querySelector('#create-modify-header').text = headerText
      ..querySelector('#create-modify-button').text = buttonText
      // Hack to make sure that the validation occurs before we check for it.
      ..querySelector('#create-modify-button').onClick.listen((e) =>
          new Future(() {
            if (verifiedHuman) {
              callback(e);
            }
          }))
      ..querySelector('form').onSubmit.listen((e) => e.preventDefault())
      ..querySelector('#random-character').onClick.listen(handleRandomCharacter);

  querySelector('#create-modify-character')
      .children..clear()..addAll(characterForm.children);
  if (fromCharacter != null) {
    updateFieldsFromCharacter(fromCharacter);
  }

}

void generateUseCharacterModal(DiabolicalCharacter character) {
  var useCharacterImport = (querySelector('#use-character-page')
      as LinkElement).import;
  var useCharacterTemplate = useCharacterImport.querySelector('#use-character');
  DocumentFragment useCharacterForm = document.importNode(useCharacterTemplate.content, true);

  var prefix = '#use-character';
  useCharacterForm
      ..querySelector('$prefix-name').text = '${character.name}'
      ..querySelector('$prefix-gender-${character.gender.toLowerCase()}')
          .classes.remove('hide')
      ..querySelector('$prefix-avatar-${character.gender.toLowerCase()}')
          .classes.remove('hide')
      ..querySelector('$prefix-class').text = '${character.classType}'
      ..querySelector('$prefix-level').text = '${character.level}'
      ..querySelector('$prefix-money').text = '${character.money}';


  var futures = ['head', 'body', 'arms', 'legs'].map((e) {
    return DiabolicalApi.createRandomItem(character.level, e).then((item) {
      var useCharacterItemTemplate =
          useCharacterImport.querySelector('#use-character-item');
      DocumentFragment useCharacterItem =
          document.importNode(useCharacterItemTemplate.content, true);
      item.toMap().forEach((key, val) {
        var element = useCharacterItem.querySelector('.item-$key');
        if (element != null) {
          if (element is SpanElement) {
            element.style.width = '$val%';
          } else {
            element.text = '$val';
          }
        }
      });
      querySelector('#item-$e')
        .children..clear()..addAll(useCharacterItem.children);
    });
  });
  Future.wait(futures).then((_) => '' );
  querySelector('#use-character-modal')
      .children..clear()..addAll(useCharacterForm.children);
}

void generateItemAccordion(DiabolicalItem item) {

}

/// [reinitializeFoundation] must be called after inserting this element.
DocumentFragment generateAlert(String cssClass, String text) {
  var alertTemplate = querySelector('#alert');
  DocumentFragment alert = document.importNode(alertTemplate.content, true);

  alert.querySelector('div')..classes.add(cssClass)..text = text;

  return alert;
}

void clearAllTemp() => querySelectorAll('.temp').forEach((Element e) => e.remove());