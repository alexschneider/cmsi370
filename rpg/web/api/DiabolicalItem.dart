part of diabolical;

class DiabolicalItem {
  final num absorption, blockchance, critchance, defense, maxdamage, mindamage;
  final int atkspeed, level;
  final String name, slot;
  DiabolicalItem._fromMap(Map<String, dynamic> itemMap)
    : absorption  = itemMap['absorption'],
      atkspeed    = itemMap['atkspeed'],
      blockchance = itemMap['blockchance'],
      critchance  = itemMap['critchance'],
      defense     = itemMap['defense'],
      level       = itemMap['level'],
      maxdamage   = itemMap['maxdamage'],
      mindamage   = itemMap['mindamage'],
      name        = itemMap['name'],
      slot        = itemMap['slot'];

  Map<String, dynamic> toMap() => {
    'absorption': absorption,
    'atkspeed': atkspeed,
    'blockchance': blockchance,
    'critchance': critchance,
    'defense': defense,
    'level': level,
    'maxdamage': maxdamage,
    'mindamage': mindamage,
    'name': name,
    'slot': slot
  };
}
