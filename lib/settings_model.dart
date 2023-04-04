final String tableSettings = 'settings';

class SettingsFields {
  static final List<String> values = [
    id, name, age, maxHR, ftp
  ];

  static final String id = '_id';
  static final String name = 'name';
  static final String age = 'age';
  static final String maxHR = 'maxHR';
  static final String ftp = 'ftp';
}

class ProfileSettings {
  final int? id;
  final String name;
  final int? age;
  final int? maxHR;
  final int? ftp;

  const ProfileSettings({
    this.id,
    required this.name,
    this.age,
    this.maxHR,
    this.ftp,
  });

  ProfileSettings copy({
    int? id,
    String? name,
    int? age,
    int? maxHR,
    int? ftp,
  }) => ProfileSettings(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      maxHR: maxHR ?? this.maxHR,
      ftp: ftp ?? this.ftp,
  );

  static ProfileSettings fromJson(Map<String, Object?> json) => ProfileSettings(
    id: json[SettingsFields.id] as int?,
    name: json[SettingsFields.name] as String,
    age: json[SettingsFields.age] as int?,
    maxHR: json[SettingsFields.maxHR] as int?,
    ftp: json[SettingsFields.ftp] as int?
  );

  Map<String, Object?> toJson() => {
    SettingsFields.id: id,
    SettingsFields.name: name,
    SettingsFields.age: age,
    SettingsFields.maxHR: maxHR,
    SettingsFields.ftp: ftp
  };

}