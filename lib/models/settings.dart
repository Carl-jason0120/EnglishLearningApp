class UserSettings {
  final int id;
  final int userId;
  final int dailyGoal;
  final bool notificationEnabled;
  final bool darkMode;

  UserSettings({
    this.id = 0,
    required this.userId,
    required this.dailyGoal,
    required this.notificationEnabled,
    required this.darkMode,
  });

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      id: map['id'],
      userId: map['userId'],
      dailyGoal: map['dailyGoal'],
      notificationEnabled: map['notificationEnabled'] == 1,
      darkMode: map['darkMode'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'dailyGoal': dailyGoal,
      'notificationEnabled': notificationEnabled ? 1 : 0,
      'darkMode': darkMode ? 1 : 0,
    };
  }

  UserSettings copyWith({
    int? dailyGoal,
    bool? notificationEnabled,
    bool? darkMode,
  }) {
    return UserSettings(
      id: id,
      userId: userId,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      darkMode: darkMode ?? this.darkMode,
    );
  }
}