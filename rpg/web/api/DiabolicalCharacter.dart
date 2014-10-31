part of diabolical;

class DiabolicalCharacter {
  int _id;
  int _level, _money;
  String classType, _gender, name;

  DiabolicalCharacter(this.classType, Gender gender, this._level, this._money,
                      this.name)
    : this._gender     = gender._gender;

  DiabolicalCharacter.empty();

  DiabolicalCharacter._fromMap(Map characterMap)
    : _id         = characterMap['id'],
      classType  = characterMap['classType'],
      _gender     = characterMap['gender'],
      _level      = characterMap['level'],
      _money      = characterMap['money'],
      name       = characterMap['name'];

  Map<String, dynamic> toMap() {
    var characterMap = {
        'classType':  this.classType,
        'gender':     this._gender,
        'level':      this.level,
        'money':      this.money,
        'name':       this.name
    };

    if (_id != null) {
      var idMap = {'id': _id};
      idMap.addAll(characterMap);
      characterMap = idMap;
    }

    return characterMap;
  }

  get id => _id;
  get gender => _gender;
  set gender (Gender g) => _gender = g._gender;
  get money => _money != null ? _money : 0;
  set money (int m) => _money = m;
  get level => _level != null ? _level : 0;
  set level (int l) => _level = l;
}

class Gender implements Comparable {
  String _gender;
  Gender.male(): _gender = 'MALE';
  Gender.female(): _gender = 'FEMALE';

  int compareTo(Gender other) {
    return _gender.compareTo(other._gender);
  }

}
