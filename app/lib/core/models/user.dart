class User {
  final String id;
  final String email;
  final String displayName;
  final String? picture;
  final String plan; // free | pro | premium
  final int storageUsedMb;

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    this.picture,
    this.plan = 'free',
    this.storageUsedMb = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        email: json['email'] as String,
        displayName: json['displayName'] as String? ?? '',
        picture: json['picture'] as String?,
        plan: json['plan'] as String? ?? 'free',
        storageUsedMb: (json['storageUsedMb'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'picture': picture,
        'plan': plan,
        'storageUsedMb': storageUsedMb,
      };

  String get initial => displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  String get firstName => displayName.split(' ').first;
}
