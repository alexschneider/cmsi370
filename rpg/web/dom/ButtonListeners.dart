part of dom;

// TODO: We probably want a better way to handle multiple things needing the
// same data. For now, we'll just assume that consumers of the future return
// the characters, so we can chain then calls.
Future<Iterable<DiabolicalCharacter>> characterListFuture;

void initializeListeners() {
  // JD: 7
  /*querySelector('#random-character').onClick.listen(handleRandomCharacter);*/
  querySelector('#list-all-characters').onClick.listen(handleListAll);
  querySelector('#create-character').onClick.listen(handleCreateCharacter);
  characterListFuture = DiabolicalApi.getAllCharacters();
}

void handleModifyCharacter(DiabolicalCharacter c) {
  generateCharacterModal(c);
}

void handleListAll(_) {
  querySelector('#list-characters').text = "Loading...";
  characterListFuture.then((Iterable<DiabolicalCharacter> characters) {
    generateModalFromCharacters(characters);
    return characters;
  });
}

void handleRandomCharacter(Event e) {
  e.preventDefault();
  DiabolicalApi.generateRandomCharacter()
      .then(updateFieldsFromCharacter);
}

void handleCreateCharacter(_) {
  generateCharacterModal();
}

void handleModify(Event e, DiabolicalCharacter c) {
  var el = getCharacterElements();
  if (querySelector('[data-invalid]') == null) {
    c.classType = el['class'].value;
    c.gender = el['gender-male'].checked ? new Gender.male() : new Gender.female();
    c.level = int.parse(el['level'].value);
    c.money = int.parse(el['money'].value);
    c.name = el['name'].value;
    querySelector('#create-modify-character')
        .children.addAll(generateAlert('info',  'Modifying...').children);
    DiabolicalApi.updateCharacter(c).then((_) {
      characterListFuture = DiabolicalApi.getAllCharacters();
      handleUseCharacter(c);
    });
  }
}

void handleCreate(Event e) {
  var el = getCharacterElements();
  if (querySelector('[data-invalid]') == null) {
    DiabolicalCharacter dbc = new DiabolicalCharacter(
      el['class'].value,
      el['gender-male'].checked ? new Gender.male() : new Gender.female(),
      int.parse(el['level'].value),
      int.parse(el['money'].value),
      el['name'].value
    );
    querySelector('#create-modify-character')
        .children.addAll(generateAlert('info',  'Creating...').children);
    DiabolicalApi.createCharacter(dbc).then((int characterId) {
      characterListFuture = DiabolicalApi.getAllCharacters();
      handleUseCharacter(dbc);
    });

  }
}

void handleSort(MouseEvent event) {
  var element = event.path.first;
  var reversed = element.parent.classes.contains('sort-up');
  characterListFuture.then((Iterable<DiabolicalCharacter> c) {
    var sortedList =  c.toList()..sort((DiabolicalCharacter a,
                                        DiabolicalCharacter b) {
      var property = element.classes.firstWhere((var val) => val != 'sort');
      var compare = a.toMap()[property].compareTo(b.toMap()[property]);
      if (reversed) {
        compare = -compare;
      }
      return compare;
    });
    var sortClass = reversed ? 'sort-down' : 'sort-up';
    generateModalFromCharacters(sortedList);
    querySelector('#${element.parent.id}').classes.add(sortClass);
    return sortedList;
  });

}

void handleDeleteCharacter(DiabolicalCharacter c, ButtonElement b,
                           TableRowElement r) {
  b.text = "Deleting";
  b.classes.add('disabled');
  DiabolicalApi.deleteCharacter(c)
      .then((_) {
        characterListFuture = DiabolicalApi.getAllCharacters();
        r.remove();
  });
}

void handleUseCharacter(DiabolicalCharacter c) {
  querySelector('#use-character').click();
  generateUseCharacterModal(c);
}
