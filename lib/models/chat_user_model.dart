class ChatUser {
  late String image;
  late String name;
  late String username;
  late String createdAt;
  late bool isOnline;
  late String id;
  late String lastActive;
  late String email;

  ChatUser({
    required this.image,
    required this.name,
    required this.username,
    required this.createdAt,
    required this.isOnline,
    required this.id,
    required this.lastActive,
    required this.email,
  });

  ChatUser.fromJson(Map<String, dynamic> json) {
    image = json['image'] ?? '';
    name = json['name'] ?? '';
    username = json['username'] ?? '';
    createdAt = json['createdAt'] ?? '';
    isOnline = json['isOnline'] ?? false;
    id = json['id'] ?? '';
    lastActive = json['lastActive'] ?? '';
    email = json['email'] ?? '';
  }

  String get displayName {
    final trimmedName = name.trim();
    if (trimmedName.isNotEmpty) return trimmedName;

    final trimmedUsername = username.trim();
    if (trimmedUsername.isNotEmpty) return trimmedUsername;

    final trimmedEmail = email.trim();
    if (trimmedEmail.isNotEmpty) return trimmedEmail;

    return 'Unknown user';
  }

  String get displayHandle {
    final trimmedUsername = username.trim();
    if (trimmedUsername.isNotEmpty) return '@$trimmedUsername';

    final trimmedEmail = email.trim();
    if (trimmedEmail.isNotEmpty) return trimmedEmail;

    return 'No username';
  }

  String get avatarLabel => displayName[0].toUpperCase();

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['name'] = name;
    data['username'] = username;
    data['createdAt'] = createdAt;
    data['isOnline'] = isOnline;
    data['id'] = id;
    data['lastActive'] = lastActive;
    data['email'] = email;
    return data;
  }
}
